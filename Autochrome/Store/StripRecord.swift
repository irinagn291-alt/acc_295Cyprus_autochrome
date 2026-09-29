import Foundation

/// Codable root under `aut.strip.v1`. Version 1 holds the fold and its collections.
struct StripRecord: Codable, Equatable, Sendable {
    var schemaVersion: Int
    var fold: StripFold

    static let currentSchema = 1
    static let defaultsKey = "aut.strip.v1"
    static let demoSeedKey = "aut.demo.v1"

    init(fold: StripFold) {
        schemaVersion = Self.currentSchema
        self.fold = fold
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version = try container.decode(Int.self, forKey: .schemaVersion)
        switch version {
        case 1:
            schemaVersion = 1
            fold = try container.decode(StripFold.self, forKey: .fold)
        default:
            throw StripStoreError.unsupportedSchema(version)
        }
    }
}

enum StripStoreError: Error, Equatable {
    case unsupportedSchema(Int)
    case mediaWriteFailed
}

enum StripRecovery: Equatable, Sendable {
    case none
    case restoredFromBackup
    case startedBlank
}
