import Foundation
import os

/// Seam between the fold and storage. Screens read and write only through this type.
/// Memory is the source of truth. UserDefaults and the document file are projections.
@MainActor
final class StripStore {
    private let defaults: UserDefaults
    private let vault: MediaVault
    private let pendingSave = OSAllocatedUnfairLock<Task<Void, Never>?>(initialState: nil)
    private let debounceNanoseconds: UInt64
    private var saveGeneration: UInt64 = 0

    private(set) var fold: StripFold
    private(set) var recovery: StripRecovery
    private(set) var projectionFailed = false

    init(
        defaults: UserDefaults,
        vault: MediaVault,
        debounceNanoseconds: UInt64 = 400_000_000
    ) {
        self.defaults = defaults
        self.vault = vault
        self.debounceNanoseconds = debounceNanoseconds
        self.fold = .blank
        self.recovery = .none
    }

    deinit {
        pendingSave.withLock { task in
            task?.cancel()
            task = nil
        }
    }

    func load() async {
        let defaultsData = defaults.data(forKey: StripRecord.defaultsKey)
        let fileData = await vault.readDocumentOffMain()
        let backupData = await vault.readBackupOffMain()
        if let record = decode(defaultsData) {
            fold = record.fold
            recovery = .none
            return
        }
        if let record = decode(fileData) {
            fold = record.fold
            recovery = defaultsData == nil ? .none : .restoredFromBackup
            return
        }
        if let record = decode(backupData) {
            fold = record.fold
            recovery = .restoredFromBackup
            return
        }
        let hadBytes = defaultsData != nil || fileData != nil || backupData != nil
        fold = .blank
        recovery = hadBytes ? .startedBlank : .none
    }

    func seat(emotionID: String, photo: Data?, voice: Data?, on date: Date) async throws {
        let daykey = DayKey.make(from: date)
        let frameID = UUID()
        let photoPath = try await stage(photo, frameID: frameID, kind: "photo")
        let voicePath = try await stage(voice, frameID: frameID, kind: "voice")
        do {
            _ = try fold.seat(
                emotionID: emotionID,
                daykey: daykey,
                createdAt: date,
                photoRelativePath: photoPath,
                voiceRelativePath: voicePath,
                frameID: frameID
            )
        } catch {
            await discard(photoPath)
            await discard(voicePath)
            throw error
        }
        scheduleSave()
    }

    func develop(on date: Date) async throws {
        let daykey = DayKey.make(from: date)
        let paneID = UUID()
        guard let frame = fold.frameForToday(daykey), case .seated(let seated) = frame.body else {
            _ = try fold.develop(daykey: daykey, paneID: paneID)
            return
        }
        let photoPath = try await freeze(seated.photoRelativePath, paneID: paneID, kind: "photo")
        let voicePath = try await freeze(seated.voiceRelativePath, paneID: paneID, kind: "voice")
        if let index = fold.frames.firstIndex(where: { $0.id == frame.id }),
           case .seated(var body) = fold.frames[index].body {
            body.photoRelativePath = photoPath
            body.voiceRelativePath = voicePath
            fold.frames[index].body = .seated(body)
        }
        _ = try fold.develop(daykey: daykey, paneID: paneID)
        await discardIfDifferent(seated.photoRelativePath, frozen: photoPath)
        await discardIfDifferent(seated.voiceRelativePath, frozen: voicePath)
        scheduleSave()
    }

    func flare(paneID: UUID, on date: Date) throws -> FlareOutcome {
        let outcome = try fold.flareLitPane(paneID, on: DayKey.make(from: date))
        scheduleSave()
        return outcome
    }

    func renameEmotion(id: String, title: String) {
        fold = fold.renameLabel(id: id, title: title)
        scheduleSave()
    }

    func noteScenePhaseLeftActive() async {
        await flush()
    }

    func flush() async {
        saveGeneration += 1
        let record = StripRecord(fold: fold)
        do {
            let data = try record.encoded()
            defaults.set(data, forKey: StripRecord.defaultsKey)
            try await vault.projectDocumentOffMain(data)
            projectionFailed = false
        } catch {
            projectionFailed = true
        }
    }

    func resetAllData() async {
        saveGeneration += 1
        cancelPendingSave()
        fold = .blank
        recovery = .none
        defaults.removeObject(forKey: StripRecord.defaultsKey)
        defaults.removeObject(forKey: StripRecord.demoSeedKey)
        await vault.removeAllFilesOffMain()
    }

    /// Simulator only. Four developed days: today's hue matches one pane, the other three do not.
    func applySimulatorSeedIfNeeded(on date: Date = Date()) async {
        #if targetEnvironment(simulator)
        if defaults.bool(forKey: StripRecord.demoSeedKey) {
            return
        }
        await load()
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let plan: [(Int, String)] = [
            (-3, "harbor"),
            (-2, "linen"),
            (-1, "grove"),
            (0, "amber")
        ]
        do {
            for (offset, emotion) in plan {
                guard let when = calendar.date(byAdding: .day, value: offset, to: start) else {
                    continue
                }
                try await seat(emotionID: emotion, photo: nil, voice: nil, on: when)
                try await develop(on: when)
            }
        } catch {
            fold = .blank
            return
        }
        fold.onboardingComplete = true
        defaults.set(true, forKey: StripRecord.demoSeedKey)
        await flush()
        #else
        _ = date
        #endif
    }

    private func scheduleSave() {
        saveGeneration += 1
        let generation = saveGeneration
        let nanos = debounceNanoseconds
        let task = Task { @MainActor [weak self] in
            do {
                try await Task.sleep(nanoseconds: nanos)
            } catch {
                return
            }
            guard let self, generation == self.saveGeneration else { return }
            await self.flush()
        }
        pendingSave.withLock { slot in
            slot?.cancel()
            slot = task
        }
    }

    private func cancelPendingSave() {
        pendingSave.withLock { slot in
            slot?.cancel()
            slot = nil
        }
    }

    private func stage(_ bytes: Data?, frameID: UUID, kind: String) async throws -> String? {
        guard let bytes else { return nil }
        let relative = "staging/\(frameID.uuidString)/\(kind)"
        return try await vault.writeAtomicOffMain(bytes, relativePath: relative)
    }

    private func freeze(_ relativePath: String?, paneID: UUID, kind: String) async throws -> String? {
        guard let relativePath else { return nil }
        guard let bytes = await vault.readRelativeOffMain(relativePath) else {
            throw StripStoreError.mediaWriteFailed
        }
        let frozen = "media/\(paneID.uuidString)-\(kind)"
        return try await vault.writeAtomicOffMain(bytes, relativePath: frozen)
    }

    private func discard(_ relativePath: String?) async {
        guard let relativePath else { return }
        await vault.removeOffMain(relativePath)
    }

    private func discardIfDifferent(_ staged: String?, frozen: String?) async {
        guard let staged, staged != frozen else { return }
        await vault.removeOffMain(staged)
    }

    private func decode(_ data: Data?) -> StripRecord? {
        guard let data else { return nil }
        return try? StripRecord.decode(data)
    }

    func setOnboardingComplete(_ complete: Bool) async {
        fold.onboardingComplete = complete
        await flush()
    }
}
