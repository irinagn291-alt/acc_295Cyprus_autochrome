import Foundation

/// Atomic files in Application Support. The strip record stores relative paths only.
struct MediaVault: Sendable {
    let root: URL

    var documentURL: URL { root.appendingPathComponent("strip.json") }
    var backupURL: URL { root.appendingPathComponent("strip.json.backup") }

    func prepareRoot() throws {
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    }

    func writeAtomic(_ data: Data, relativePath: String) throws -> String {
        try prepareRoot()
        let url = root.appendingPathComponent(relativePath)
        let folder = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try data.write(to: url, options: .atomic)
        return relativePath
    }

    func read(relativePath: String) throws -> Data {
        let url = root.appendingPathComponent(relativePath)
        return try Data(contentsOf: url)
    }

    func remove(relativePath: String) throws {
        let url = root.appendingPathComponent(relativePath)
        do {
            try FileManager.default.removeItem(at: url)
        } catch let error as CocoaError where error.code == .fileNoSuchFile {
            return
        }
    }

    /// Copies a good document aside before the next projection, then writes atomically.
    func projectDocument(_ data: Data) throws {
        try prepareRoot()
        if FileManager.default.fileExists(atPath: documentURL.path),
           let existing = try? Data(contentsOf: documentURL),
           (try? StripRecord.decode(existing)) != nil {
            try existing.write(to: backupURL, options: .atomic)
        }
        try data.write(to: documentURL, options: .atomic)
    }

    func readDocument() -> Data? {
        try? Data(contentsOf: documentURL)
    }

    func readBackup() -> Data? {
        try? Data(contentsOf: backupURL)
    }

    func removeAllFiles() throws {
        do {
            try FileManager.default.removeItem(at: root)
        } catch let error as CocoaError where error.code == .fileNoSuchFile {
            return
        }
    }

    /// Disk work is detached because a nonisolated async method with no
    /// suspension point would stay on the main actor and block it.
    func writeAtomicOffMain(_ data: Data, relativePath: String) async throws -> String {
        let vault = self
        return try await Task.detached {
            try vault.writeAtomic(data, relativePath: relativePath)
        }.value
    }

    func projectDocumentOffMain(_ data: Data) async throws {
        let vault = self
        try await Task.detached {
            try vault.projectDocument(data)
        }.value
    }

    func readDocumentOffMain() async -> Data? {
        let vault = self
        return await Task.detached {
            vault.readDocument()
        }.value
    }

    func readBackupOffMain() async -> Data? {
        let vault = self
        return await Task.detached {
            vault.readBackup()
        }.value
    }

    func readRelativeOffMain(_ relativePath: String) async -> Data? {
        let vault = self
        return await Task.detached {
            try? vault.read(relativePath: relativePath)
        }.value
    }

    func removeOffMain(_ relativePath: String) async {
        let vault = self
        await Task.detached {
            do {
                try vault.remove(relativePath: relativePath)
            } catch {
                return
            }
        }.value
    }

    func removeAllFilesOffMain() async {
        let vault = self
        await Task.detached {
            do {
                try vault.removeAllFiles()
            } catch {
                return
            }
        }.value
    }
}

extension StripRecord {
    static func decode(_ data: Data) throws -> StripRecord {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(StripRecord.self, from: data)
    }

    func encoded() throws -> Data {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .useDefaultKeys
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(self)
    }
}
