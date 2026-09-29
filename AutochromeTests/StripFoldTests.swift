import XCTest
@testable import Autochrome

final class StripFoldTests: XCTestCase {
    private let today = Date(timeIntervalSince1970: 1_758_000_000)

    func testHueEqualityKeepsMediaAndSurvivesRename() throws {
        var fold = StripFold.blank
        let day = DayKey.make(from: today)
        let photo = "staging/photo"
        let voice = "staging/voice"
        _ = try fold.seat(
            emotionID: "amber",
            daykey: day,
            createdAt: today,
            photoRelativePath: photo,
            voiceRelativePath: voice
        )
        let pane = try fold.develop(daykey: day)
        XCTAssertEqual(pane.emotionID, "amber")
        XCTAssertEqual(pane.photoRelativePath, photo)
        XCTAssertEqual(pane.voiceRelativePath, voice)
        XCTAssertTrue(fold.isLit(pane, on: day))

        fold = fold.renameLabel(id: "amber", title: "Honey")
        XCTAssertEqual(fold.emotionLabels.first { $0.id == "amber" }?.title, "Honey")
        XCTAssertTrue(fold.isLit(pane, on: day))

        let other = Pane(
            id: UUID(),
            frameID: UUID(),
            emotionID: "harbor",
            daykey: day - 1,
            photoRelativePath: nil,
            voiceRelativePath: nil
        )
        fold.panes.append(other)
        XCTAssertFalse(fold.isLit(other, on: day))
    }

    func testFlareOnBlankBareAndUnknownPane() {
        var fold = StripFold.blank
        let day = DayKey.make(from: today)
        XCTAssertEqual(fold.phase(on: day), .blank)
        XCTAssertThrowsError(try fold.flareLitPane(UUID(), on: day)) { error in
            XCTAssertEqual(error as? StripRefusal, .flareOnBlank)
        }

        let past = day - 1
        XCTAssertNoThrow(try fold.seat(emotionID: "linen", daykey: past, createdAt: today, photoRelativePath: nil, voiceRelativePath: nil))
        XCTAssertNoThrow(try fold.develop(daykey: past))
        XCTAssertEqual(fold.phase(on: day), .bare)
        XCTAssertThrowsError(try fold.flareLitPane(fold.panes[0].id, on: day)) { error in
            XCTAssertEqual(error as? StripRefusal, .flareOnBare)
        }
        XCTAssertThrowsError(try fold.seat(emotionID: "nope", daykey: day, createdAt: today, photoRelativePath: nil, voiceRelativePath: nil)) { error in
            XCTAssertEqual(error as? StripRefusal, .unknownEmotion)
        }
    }

    func testLitTapStagesAndMissWritesDimWithoutChangingLight() throws {
        var fold = try seatedPair()
        let day = DayKey.make(from: today)
        let lit = try XCTUnwrap(fold.litPanes(on: day).first)
        let dark = try XCTUnwrap(fold.panes.first { $0.emotionID == "harbor" })
        let before = fold.litPanes(on: day).map(\.id)

        let staged = try fold.flareLitPane(lit.id, on: day)
        guard case .staged(let mark) = staged else {
            XCTFail("Expected a flare mark")
            return
        }
        XCTAssertEqual(mark.paneID, lit.id)
        XCTAssertEqual(mark.frameID, lit.frameID)
        XCTAssertEqual(fold.flareMarks.count, 1)

        let missed = try fold.flareLitPane(dark.id, on: day)
        guard case .dimmed(let dim) = missed else {
            XCTFail("Expected a dim mark")
            return
        }
        XCTAssertEqual(dim.paneID, dark.id)
        XCTAssertEqual(fold.dimMarks.count, 1)
        XCTAssertEqual(fold.litPanes(on: day).map(\.id), before)
    }

    func testFoldRefusesSecondSeatAndDevelopOnBare() throws {
        var fold = StripFold.blank
        let day = DayKey.make(from: today)
        XCTAssertThrowsError(try fold.develop(daykey: day)) { error in
            XCTAssertEqual(error as? StripRefusal, .developOnBlank)
        }
        _ = try fold.seat(emotionID: "amber", daykey: day, createdAt: today, photoRelativePath: nil, voiceRelativePath: nil)
        XCTAssertEqual(fold.phase(on: day), .seated)
        XCTAssertThrowsError(try fold.seat(emotionID: "grove", daykey: day, createdAt: today, photoRelativePath: nil, voiceRelativePath: nil)) { error in
            XCTAssertEqual(error as? StripRefusal, .seatWhileSeated)
        }
        _ = try fold.develop(daykey: day)
        XCTAssertEqual(fold.phase(on: day), .cut)
        XCTAssertThrowsError(try fold.develop(daykey: day)) { error in
            XCTAssertEqual(error as? StripRefusal, .developWhileCut)
        }
        XCTAssertThrowsError(try fold.seat(emotionID: "grove", daykey: day, createdAt: today, photoRelativePath: nil, voiceRelativePath: nil)) { error in
            XCTAssertEqual(error as? StripRefusal, .seatWhileCut)
        }

        var bare = StripFold.blank
        let yesterday = day - 1
        _ = try bare.seat(emotionID: "grove", daykey: yesterday, createdAt: today, photoRelativePath: nil, voiceRelativePath: nil)
        _ = try bare.develop(daykey: yesterday)
        XCTAssertEqual(bare.phase(on: day), .bare)
        XCTAssertThrowsError(try bare.develop(daykey: day)) { error in
            XCTAssertEqual(error as? StripRefusal, .developOnBare)
        }
    }

    func testDayKeyUsesStartOfDay() {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        let afternoon = Date(timeIntervalSince1970: 1_720_000_000)
        let key = DayKey.make(from: afternoon, calendar: gregorian)
        let start = gregorian.startOfDay(for: afternoon)
        let parts = gregorian.dateComponents([.year, .month, .day], from: start)
        let expected = (parts.year ?? 0) * 10_000 + (parts.month ?? 0) * 100 + (parts.day ?? 0)
        XCTAssertEqual(key, expected)
        XCTAssertGreaterThan(key, 20_000_000)
    }

    private func seatedPair() throws -> StripFold {
        var fold = StripFold.blank
        let day = DayKey.make(from: today)
        let yesterday = day - 1
        _ = try fold.seat(emotionID: "harbor", daykey: yesterday, createdAt: today.addingTimeInterval(-86_400), photoRelativePath: nil, voiceRelativePath: nil)
        _ = try fold.develop(daykey: yesterday)
        _ = try fold.seat(emotionID: "amber", daykey: day, createdAt: today, photoRelativePath: "photo", voiceRelativePath: nil)
        _ = try fold.develop(daykey: day)
        return fold
    }
}
