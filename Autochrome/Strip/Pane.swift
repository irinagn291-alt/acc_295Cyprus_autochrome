import Foundation

/// A stained-glass cell cut from one frame. Identity is the pane id, never a list index.
struct Pane: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var frameID: UUID
    var emotionID: String
    var daykey: Int
    var photoRelativePath: String?
    var voiceRelativePath: String?
}
