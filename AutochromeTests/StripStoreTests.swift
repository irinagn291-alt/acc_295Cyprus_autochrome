import XCTest
@testable import Autochrome

@MainActor
final class StripStoreTests: XCTestCase {
    private var directory: URL!
    private var suiteName = ""
    private var defaults: UserDefaults!

    override func setUp() async throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        suiteName = "aut.test.\(UUID().uuidString)"
        defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() async throws {
        defaults.removePersistentDomain(forName: suiteName)
        try? FileManager.default.removeItem(at: directory)
    }

    func testRoundTripReload() async throws {
        let store = makeStore()
        let when = Date(timeIntervalSince1970: 1_758_100_000)
        let photo = Data("pane-bytes".utf8)
        try await store.seat(emotionID: "amber", photo: photo, voice: Data([1, 2, 3]), on: when)
        try await store.develop(on: when)
        let pane = try XCTUnwrap(store.fold.panes.first)
        let outcome = try store.flare(paneID: pane.id, on: when)
        guard case .staged = outcome else {
            XCTFail("Expected flare")
            return
        }
        await store.flush()

        let reloaded = makeStore()
        await reloaded.load()
        XCTAssertEqual(reloaded.recovery, .none)
        XCTAssertEqual(reloaded.fold.panes.count, 1)
        XCTAssertEqual(reloaded.fold.flareMarks.count, 1)
        XCTAssertEqual(reloaded.fold.phase(on: DayKey.make(from: when)), .cut)
        let path = try XCTUnwrap(reloaded.fold.panes.first?.photoRelativePath)
        let vault = MediaVault(root: directory)
        let bytes = try vault.read(relativePath: path)
        XCTAssertEqual(bytes, photo)
        XCTAssertFalse(path.contains("staging"))
    }

    func testCorruptRecordStartsBlank() async throws {
        defaults.set(Data("not-json".utf8), forKey: StripRecord.defaultsKey)
        let vault = MediaVault(root: directory)
        try vault.prepareRoot()
        try Data("also-bad".utf8).write(to: vault.documentURL, options: .atomic)
        let store = StripStore(defaults: defaults, vault: vault)
        await store.load()
        XCTAssertEqual(store.fold, .blank)
        XCTAssertEqual(store.recovery, .startedBlank)
    }

    func testBackupRestoresWhenPrimaryFails() async throws {
        let vault = MediaVault(root: directory)
        var fold = StripFold.blank
        _ = try fold.seat(
            emotionID: "linen",
            daykey: 20260926,
            createdAt: Date(timeIntervalSince1970: 1_758_200_000),
            photoRelativePath: nil,
            voiceRelativePath: nil
        )
        let record = StripRecord(fold: fold)
        try vault.prepareRoot()
        try record.encoded().write(to: vault.backupURL, options: .atomic)
        try Data("{".utf8).write(to: vault.documentURL, options: .atomic)
        defaults.set(Data("[]".utf8), forKey: StripRecord.defaultsKey)
        let store = StripStore(defaults: defaults, vault: vault)
        await store.load()
        XCTAssertEqual(store.recovery, .restoredFromBackup)
        XCTAssertEqual(store.fold.frames.count, 1)
    }

    func testResetDeletesKeyAndMedia() async throws {
        let store = makeStore()
        let when = Date(timeIntervalSince1970: 1_758_300_000)
        try await store.seat(emotionID: "grove", photo: Data([9]), voice: nil, on: when)
        await store.flush()
        XCTAssertNotNil(defaults.data(forKey: StripRecord.defaultsKey))
        await store.resetAllData()
        XCTAssertNil(defaults.data(forKey: StripRecord.defaultsKey))
        XCTAssertEqual(store.fold.frames.count, 0)
        XCTAssertFalse(FileManager.default.fileExists(atPath: directory.appendingPathComponent("strip.json").path))
    }

    func testSchemaRejectsUnknownVersion() throws {
        let payload = #"{"schemaVersion":9,"fold":{}}"#.data(using: .utf8)
        let data = try XCTUnwrap(payload)
        XCTAssertThrowsError(try StripRecord.decode(data))
    }

    func testLeavingActiveFlushesBeforeDebounce() async throws {
        let store = makeStore(debounceNanoseconds: 60_000_000_000)
        let when = Date(timeIntervalSince1970: 1_758_400_000)
        try await store.seat(emotionID: "amber", photo: nil, voice: nil, on: when)
        XCTAssertNil(defaults.data(forKey: StripRecord.defaultsKey))
        await store.noteScenePhaseLeftActive()
        let saved = try XCTUnwrap(defaults.data(forKey: StripRecord.defaultsKey))
        let reloaded = makeStore(debounceNanoseconds: 60_000_000_000)
        await reloaded.load()
        XCTAssertEqual(reloaded.fold.frames.count, 1)
        XCTAssertEqual(try StripRecord.decode(saved).fold.frames.count, 1)
    }

    func testSecondFlareWhileBusyDoesNotWriteAnotherMark() async throws {
        let store = makeStore(debounceNanoseconds: 60_000_000_000)
        let when = Date()
        try await store.seat(emotionID: "amber", photo: nil, voice: nil, on: when)
        try await store.develop(on: when)
        let pane = try XCTUnwrap(store.fold.panes.first)
        let session = StripSession(store: store)
        session.flare(paneID: pane.id)
        XCTAssertTrue(session.busy)
        XCTAssertEqual(session.fold.flareMarks.count, 1)
        session.flare(paneID: pane.id)
        XCTAssertEqual(session.fold.flareMarks.count, 1)
    }

    private func makeStore(debounceNanoseconds: UInt64 = 400_000_000) -> StripStore {
        StripStore(
            defaults: defaults,
            vault: MediaVault(root: directory),
            debounceNanoseconds: debounceNanoseconds
        )
    }
}
