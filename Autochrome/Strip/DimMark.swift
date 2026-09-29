import Foundation

/// A miss. The pane stays unlit. The mark does not change which panes are lit.
struct DimMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var paneID: UUID
    var daykey: Int
}
