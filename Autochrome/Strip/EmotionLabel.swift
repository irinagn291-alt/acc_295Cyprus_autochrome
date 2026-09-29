import Foundation

/// A keeper-facing name for an emotion id. Matching uses the id, so a rename still flares.
struct EmotionLabel: Codable, Equatable, Sendable, Identifiable {
    var id: String
    var title: String

    static let starter: [EmotionLabel] = [
        EmotionLabel(id: "amber", title: "Amber"),
        EmotionLabel(id: "harbor", title: "Harbor"),
        EmotionLabel(id: "linen", title: "Linen"),
        EmotionLabel(id: "grove", title: "Grove")
    ]
}
