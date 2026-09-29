import Foundation

/// A lit tap. Stages the past frame that owns the pane. The day is YYYYMMDD.
struct FlareMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var paneID: UUID
    var frameID: UUID
    var daykey: Int
}
