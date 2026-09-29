import Foundation

/// One frame on the filmstrip. Bare is the absence of today's frame, not a stored row.
/// Seat writes a seated body. Develop folds that body to cut and points at a pane.
struct Frame: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var daykey: Int
    var body: FrameBody

    var emotionID: String {
        switch body {
        case .seated(let seated):
            return seated.emotionID
        case .cut(let cut):
            return cut.emotionID
        }
    }

    var createdAt: Date {
        switch body {
        case .seated(let seated):
            return seated.createdAt
        case .cut(let cut):
            return cut.createdAt
        }
    }
}

enum FrameBody: Codable, Equatable, Sendable {
    case seated(SeatedBody)
    case cut(CutBody)
}

/// Emotion plus optional on-device photo or voice, still waiting to be cut.
struct SeatedBody: Codable, Equatable, Sendable {
    var emotionID: String
    var createdAt: Date
    var photoRelativePath: String?
    var voiceRelativePath: String?
}

/// A seated frame after Develop. Media paths name the frozen pane files.
struct CutBody: Codable, Equatable, Sendable {
    var emotionID: String
    var createdAt: Date
    var paneID: UUID
    var photoRelativePath: String?
    var voiceRelativePath: String?
}
