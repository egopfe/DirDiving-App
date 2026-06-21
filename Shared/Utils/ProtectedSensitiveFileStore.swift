import Foundation

/// File-backed sensitive payload storage with complete data protection (SEC-P2-005).
enum ProtectedSensitiveFileStore {
    enum StoreError: Error, Equatable {
        case directoryUnavailable
        case encodeFailed
        case writeFailed
        case decodeFailed
        case corruptPayload
    }

    static func syncQueuesRoot() throws -> URL {
        try applicationSupportSubdirectory("SyncQueues")
    }

    static func conflictsRoot() throws -> URL {
        try applicationSupportSubdirectory("Conflicts")
    }

    static func conflictFileURL(fileName: String) throws -> URL {
        let root = try conflictsRoot()
        return root.appendingPathComponent(fileName)
    }

    static func activityQueueDirectory(_ activity: String) throws -> URL {
        let root = try syncQueuesRoot()
        let url = root.appendingPathComponent(activity, isDirectory: true)
        try ensureDirectory(url)
        return url
    }

    static func fileURL(activity: String, fileName: String) throws -> URL {
        try activityQueueDirectory(activity).appendingPathComponent(fileName)
    }

    static func loadData(from url: URL) -> Data? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return try? Data(contentsOf: url)
    }

    static func saveData(_ data: Data, to url: URL) throws {
        let directory = url.deletingLastPathComponent()
        try ensureDirectory(directory)
        try data.write(to: url, options: [.atomic, .completeFileProtection])
    }

    static func loadDecodable<T: Decodable>(
        _ type: T.Type,
        from url: URL,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> T {
        guard let data = loadData(from: url) else {
            throw StoreError.decodeFailed
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw StoreError.corruptPayload
        }
    }

    static func saveEncodable<T: Encodable>(
        _ value: T,
        to url: URL,
        encoder: JSONEncoder = JSONEncoder()
    ) throws {
        guard let data = try? encoder.encode(value) else {
            throw StoreError.encodeFailed
        }
        do {
            try saveData(data, to: url)
        } catch {
            throw StoreError.writeFailed
        }
    }

    @discardableResult
    static func migrateUserDefaultsData(
        key: String,
        to url: URL,
        removeLegacyAfterVerifiedWrite: Bool = true
    ) -> Data? {
        guard let legacy = UserDefaults.standard.data(forKey: key) else { return nil }
        do {
            try saveData(legacy, to: url)
            if removeLegacyAfterVerifiedWrite,
               let written = loadData(from: url),
               written == legacy {
                UserDefaults.standard.removeObject(forKey: key)
            }
            return legacy
        } catch {
            return nil
        }
    }

    static func migrateUserDefaultsDictionaryPayload(
        key: String,
        field: String,
        to url: URL
    ) -> Data? {
        guard let dict = UserDefaults.standard.dictionary(forKey: key),
              let data = dict[field] as? Data else { return nil }
        do {
            try saveData(data, to: url)
            if loadData(from: url) == data {
                var updated = dict
                updated.removeValue(forKey: field)
                if updated.isEmpty {
                    UserDefaults.standard.removeObject(forKey: key)
                } else {
                    UserDefaults.standard.set(updated, forKey: key)
                }
            }
            return data
        } catch {
            return nil
        }
    }

    private static func applicationSupportSubdirectory(_ name: String) throws -> URL {
        guard let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw StoreError.directoryUnavailable
        }
        let url = base.appendingPathComponent(name, isDirectory: true)
        try ensureDirectory(url)
        return url
    }

    private static func ensureDirectory(_ url: URL) throws {
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
            guard isDirectory.boolValue else { throw StoreError.directoryUnavailable }
            return
        }
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        try? FileManager.default.setAttributes(
            [.protectionKey: FileProtectionType.complete],
            ofItemAtPath: url.path
        )
    }
}
