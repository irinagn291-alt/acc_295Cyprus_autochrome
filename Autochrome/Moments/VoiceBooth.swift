import AVFoundation
import Foundation

/// Short on-device voice clip. Recording starts only after Continue.
@MainActor
final class VoiceBooth: ObservableObject {
    @Published var clip: Data?
    @Published var recording = false
    @Published var needsContinue = false
    @Published var denied = false

    private var recorder: AVAudioRecorder?
    private var fileURL: URL?

    func askToRecord() {
        denied = false
        needsContinue = true
    }

    func continueToSystemPrompt() {
        needsContinue = false
        AVAudioApplication.requestRecordPermission { [weak self] allowed in
            Task { @MainActor in
                guard let self else { return }
                if allowed {
                    self.begin()
                } else {
                    self.denied = true
                }
            }
        }
    }

    func stop() {
        recorder?.stop()
        recording = false
        guard let fileURL else { return }
        clip = try? Data(contentsOf: fileURL)
        try? FileManager.default.removeItem(at: fileURL)
        self.fileURL = nil
        recorder = nil
    }

    func clear() {
        stop()
        clip = nil
    }

    private func begin() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
        } catch {
            denied = true
            return
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("autochrome-voice-\(UUID().uuidString).m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 22_050,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]
        do {
            let recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder.record(forDuration: 8)
            self.recorder = recorder
            fileURL = url
            recording = true
        } catch {
            denied = true
        }
    }
}
