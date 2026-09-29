import Foundation
import UIKit

/// Screen seam over StripStore. Views read this snapshot and call these verbs.
@MainActor
final class StripSession: ObservableObject {
    @Published private(set) var fold: StripFold
    @Published private(set) var recovery: StripRecovery
    @Published private(set) var projectionFailed: Bool
    @Published var notice: String?
    @Published var stagedLine: String?
    @Published var busy = false
    @Published var showSuccess = false

    let store: StripStore

    init(store: StripStore) {
        self.store = store
        fold = store.fold
        recovery = store.recovery
        projectionFailed = store.projectionFailed
    }

    /// The one live strip. The app scene owns this object so it can flush on leave.
    static func live() -> StripSession {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let vault = MediaVault(root: support.appendingPathComponent("Autochrome", isDirectory: true))
        return StripSession(store: StripStore(defaults: .standard, vault: vault))
    }

    func boot() async {
        await store.load()
        await store.applySimulatorSeedIfNeeded()
        pull()
    }

    func reload() async {
        await store.load()
        pull()
        notice = nil
    }

    func seat(emotionID: String, photo: Data?, voice: Data?) async {
        guard !busy else { return }
        busy = true
        defer { busy = false }
        do {
            try await store.seat(emotionID: emotionID, photo: photo, voice: voice, on: Date())
            pull()
            notice = nil
            celebrate()
        } catch let refusal as StripRefusal {
            notice = Self.copy(for: refusal)
        } catch {
            notice = "This moment was not saved. Try again."
        }
    }

    func develop() async {
        guard !busy else { return }
        busy = true
        defer { busy = false }
        do {
            try await store.develop(on: Date())
            pull()
            notice = nil
            celebrate()
        } catch let refusal as StripRefusal {
            notice = Self.copy(for: refusal)
        } catch {
            notice = "This day was not kept. Try again."
        }
    }

    func flare(paneID: UUID) {
        guard !busy else { return }
        busy = true
        do {
            let outcome = try store.flare(paneID: paneID, on: Date())
            pull()
            switch outcome {
            case .staged(let mark):
                stagedLine = stagedCopy(mark)
                notice = nil
                celebrate()
            case .dimmed:
                notice = "That day does not match today."
            }
        } catch let refusal as StripRefusal {
            notice = Self.copy(for: refusal)
        } catch {
            notice = "That moment did not open. Try again."
        }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 400_000_000)
            busy = false
        }
    }

    func noteScenePhaseLeftActive() async {
        await store.noteScenePhaseLeftActive()
    }

    func rename(id: String, title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        store.renameEmotion(id: id, title: trimmed)
        pull()
    }

    func finishOnboarding() async {
        await store.setOnboardingComplete(true)
        pull()
    }

    func replayOnboarding() async {
        await store.setOnboardingComplete(false)
        pull()
    }

    func eraseStrip() async {
        await store.resetAllData()
        pull()
        notice = nil
        stagedLine = nil
    }

    func flushNow() async {
        await store.flush()
        pull()
    }

    private func pull() {
        fold = store.fold
        recovery = store.recovery
        projectionFailed = store.projectionFailed
    }

    private func celebrate() {
        StripHaptic.success()
        showSuccess = true
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 900_000_000)
            showSuccess = false
        }
    }

    private func stagedCopy(_ mark: FlareMark) -> String {
        let title = fold.emotionLabels.first { $0.id == fold.panes.first { $0.id == mark.paneID }?.emotionID }?.title
            ?? "That moment"
        return "\(title) is open again."
    }

    static func copy(for refusal: StripRefusal) -> String {
        switch refusal {
        case .seatWhileSeated:
            "Today is already saved. Keep it before saving another."
        case .seatWhileCut:
            "Today is already kept. Open the matching day."
        case .developOnBlank, .developOnBare:
            "Save a moment before you keep it."
        case .developWhileCut:
            "Today is already kept."
        case .flareOnBlank, .flareOnBare:
            "Save today before a past day can open."
        case .unknownEmotion:
            "Pick one of the feelings."
        case .unknownPane:
            "That moment is no longer saved."
        }
    }
}

enum StripHaptic {
    static func success() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
}
