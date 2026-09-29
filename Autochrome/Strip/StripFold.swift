import Foundation

/// The strip is a fold over frames. An empty strip is blank.
/// Seat folds blank or bare into seated. Develop folds seated into cut.
/// Flare, while seated or cut, lights panes whose emotion id equals today's frame.
enum StripPhase: Equatable, Sendable {
    case blank
    case bare
    case seated
    case cut
}

enum StripRefusal: Error, Equatable, Sendable {
    case seatWhileSeated
    case seatWhileCut
    case developOnBlank
    case developOnBare
    case developWhileCut
    case flareOnBlank
    case flareOnBare
    case unknownEmotion
    case unknownPane
}

enum FlareOutcome: Equatable, Sendable {
    case staged(FlareMark)
    case dimmed(DimMark)
}

struct StripFold: Codable, Equatable, Sendable {
    var frames: [Frame]
    var panes: [Pane]
    var flareMarks: [FlareMark]
    var dimMarks: [DimMark]
    var emotionLabels: [EmotionLabel]
    var onboardingComplete: Bool

    static let blank = StripFold(
        frames: [],
        panes: [],
        flareMarks: [],
        dimMarks: [],
        emotionLabels: EmotionLabel.starter,
        onboardingComplete: false
    )

    func phase(on daykey: Int) -> StripPhase {
        guard let frame = frameForToday(daykey) else {
            if frames.isEmpty && panes.isEmpty {
                return .blank
            }
            return .bare
        }
        switch frame.body {
        case .seated:
            return .seated
        case .cut:
            return .cut
        }
    }

    /// Latest frame whose daykey equals today. Several frames may share a day.
    func frameForToday(_ daykey: Int) -> Frame? {
        frames
            .filter { $0.daykey == daykey }
            .max { $0.createdAt < $1.createdAt }
    }

    func todayEmotionID(on daykey: Int) -> String? {
        frameForToday(daykey)?.emotionID
    }

    /// Hue equality is the emotion id. A renamed label does not change the light.
    func isLit(_ pane: Pane, on daykey: Int) -> Bool {
        guard let emotionID = todayEmotionID(on: daykey) else {
            return false
        }
        return pane.emotionID == emotionID
    }

    func litPanes(on daykey: Int) -> [Pane] {
        panes.filter { isLit($0, on: daykey) }
    }

    mutating func seat(
        emotionID: String,
        daykey: Int,
        createdAt: Date,
        photoRelativePath: String?,
        voiceRelativePath: String?,
        frameID: UUID = UUID()
    ) throws -> Frame {
        guard emotionLabels.contains(where: { $0.id == emotionID }) else {
            throw StripRefusal.unknownEmotion
        }
        switch phase(on: daykey) {
        case .blank, .bare:
            break
        case .seated:
            throw StripRefusal.seatWhileSeated
        case .cut:
            throw StripRefusal.seatWhileCut
        }
        let frame = Frame(
            id: frameID,
            daykey: daykey,
            body: .seated(
                SeatedBody(
                    emotionID: emotionID,
                    createdAt: createdAt,
                    photoRelativePath: photoRelativePath,
                    voiceRelativePath: voiceRelativePath
                )
            )
        )
        frames.append(frame)
        return frame
    }

    mutating func develop(daykey: Int, paneID: UUID = UUID()) throws -> Pane {
        switch phase(on: daykey) {
        case .blank:
            throw StripRefusal.developOnBlank
        case .bare:
            throw StripRefusal.developOnBare
        case .cut:
            throw StripRefusal.developWhileCut
        case .seated:
            break
        }
        guard let index = frames.lastIndex(where: { $0.daykey == daykey && isSeated($0) }) else {
            throw StripRefusal.developOnBare
        }
        guard case .seated(let seated) = frames[index].body else {
            throw StripRefusal.developOnBare
        }
        let frameID = frames[index].id
        let pane = Pane(
            id: paneID,
            frameID: frameID,
            emotionID: seated.emotionID,
            daykey: daykey,
            photoRelativePath: seated.photoRelativePath,
            voiceRelativePath: seated.voiceRelativePath
        )
        frames[index].body = .cut(
            CutBody(
                emotionID: seated.emotionID,
                createdAt: seated.createdAt,
                paneID: pane.id,
                photoRelativePath: seated.photoRelativePath,
                voiceRelativePath: seated.voiceRelativePath
            )
        )
        panes.append(pane)
        return pane
    }

    /// Lit tap writes a FlareMark and stages that pane's frame. A miss writes a DimMark.
    mutating func flareLitPane(_ paneID: UUID, on daykey: Int, markID: UUID = UUID()) throws -> FlareOutcome {
        switch phase(on: daykey) {
        case .blank:
            throw StripRefusal.flareOnBlank
        case .bare:
            throw StripRefusal.flareOnBare
        case .seated, .cut:
            break
        }
        guard let pane = panes.first(where: { $0.id == paneID }) else {
            throw StripRefusal.unknownPane
        }
        if isLit(pane, on: daykey) {
            let mark = FlareMark(id: markID, paneID: pane.id, frameID: pane.frameID, daykey: daykey)
            flareMarks.append(mark)
            return .staged(mark)
        }
        let mark = DimMark(id: markID, paneID: pane.id, daykey: daykey)
        dimMarks.append(mark)
        return .dimmed(mark)
    }

    func renameLabel(id: String, title: String) -> StripFold {
        var copy = self
        guard let index = copy.emotionLabels.firstIndex(where: { $0.id == id }) else {
            return copy
        }
        copy.emotionLabels[index].title = title
        return copy
    }

    private func isSeated(_ frame: Frame) -> Bool {
        if case .seated = frame.body {
            return true
        }
        return false
    }
}
