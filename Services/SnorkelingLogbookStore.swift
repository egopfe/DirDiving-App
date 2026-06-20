import Foundation
import os

@MainActor
final class SnorkelingLogbookStore: ObservableObject {
    private static let logger = Logger(subsystem: "com.egopfe.dirdiving", category: "SnorkelingLogbookStore")
    static var testHook_storageDirectoryURL: URL?

    @Published private(set) var sessions: [SnorkelingSession] = []
    @Published private(set) var loadErrorMessage: String?
    @Published private(set) var lastPersistenceError: String?
    @Published private(set) var lastSavedSessionID: UUID?

    private let fileName = "dirdiving_snorkeling_sessions.json"
    private let deletedLocalKey = WatchSyncKeys.snorkelingDeletedSessionIDsLocalKey
    private var deletedSessionIDs: Set<UUID> = []
    private var sessionRevisions: [UUID: Int] = [:]

    init() {
        load()
    }

    func isDeleted(id: UUID) -> Bool {
        deletedSessionIDs.contains(id)
    }

    func revision(for sessionID: UUID) -> Int {
        sessionRevisions[sessionID] ?? 1
    }

    func reloadFromPersistence() {
        deletedSessionIDs = loadDeletedSessionIDs()
        sessions = SnorkelingLogbookPolicy.normalizedAndCapped(
            loadLocalSessions(),
            deletedIDs: deletedSessionIDs
        )
    }

    func applyRemoteDeletedSessionIDs(_ ids: Set<UUID>) {
        guard !ids.isEmpty else { return }
        deletedSessionIDs.formUnion(ids)
        sessions.removeAll { deletedSessionIDs.contains($0.id) }
        saveDeletedSessionIDs(deletedSessionIDs)
        _ = save()
    }

    func add(_ session: SnorkelingSession) {
        let normalized = SnorkelingLogbookPolicy.normalizedSession(session)
        guard !deletedSessionIDs.contains(normalized.id) else { return }
        switch SnorkelingLogbookPolicy.classify(normalized) {
        case .invalid(let reason):
            loadErrorMessage = reason
            return
        case .exportable:
            sessions.removeAll { $0.id == normalized.id }
            sessions.insert(normalized, at: 0)
            sessions = SnorkelingLogbookPolicy.normalizedAndCapped(sessions, deletedIDs: deletedSessionIDs)
            sessionRevisions[normalized.id] = (sessionRevisions[normalized.id] ?? 0) + 1
            guard save() else { return }
            lastSavedSessionID = normalized.id
#if os(watchOS)
            if normalized.state == .completed || normalized.state == .aborted {
                WatchSyncService.shared.transferSnorkelingSession(normalized)
            }
#endif
        }
    }

    func update(_ session: SnorkelingSession) {
        add(session)
    }

    func delete(id: UUID) {
        guard sessions.contains(where: { $0.id == id }) else { return }
        deletedSessionIDs.insert(id)
        sessionRevisions[id] = (sessionRevisions[id] ?? 0) + 1
        sessions.removeAll { $0.id == id }
        saveDeletedSessionIDs(deletedSessionIDs)
        _ = save()
#if os(watchOS)
        WatchSyncService.shared.publishDeletedSnorkelingSessionIDs([id])
#endif
    }

    func statistics() -> SnorkelingLogbookStatistics {
        SnorkelingLogbookStatistics.aggregate(from: sessions)
    }

    func exportData() throws -> Data {
        try SnorkelingLogbookPersistence.exportData(for: sessions)
    }

    private func load() {
        deletedSessionIDs = loadDeletedSessionIDs()
        sessions = SnorkelingLogbookPolicy.normalizedAndCapped(loadLocalSessions(), deletedIDs: deletedSessionIDs)
    }

    private func loadLocalSessions() -> [SnorkelingSession] {
        let url = fileURL()
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try SnorkelingLogbookPersistence.decodeSessionsResiliently(from: data)
            let filtered = SnorkelingLogbookPolicy.filterValidLoadedSessions(decoded)
            if filtered.quarantinedCount > 0 {
                loadErrorMessage = "quarantined:\(filtered.quarantinedCount)"
            }
            return filtered.sessions
        } catch {
            let base = Self.testHook_storageDirectoryURL
                ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                ?? FileManager.default.temporaryDirectory
            try? SnorkelingLogbookPersistence.quarantineCorruptFile(at: url, baseDirectory: base)
            loadErrorMessage = error.localizedDescription
            return []
        }
    }

    @discardableResult
    private func save() -> Bool {
        let url = fileURL()
        do {
            let envelope = try SnorkelingLogbookPersistence.makeEnvelope(sessions: sessions)
            try SnorkelingLogbookPersistence.writeEnvelope(envelope, to: url)
            lastPersistenceError = nil
            return true
        } catch {
            lastPersistenceError = error.localizedDescription
            Self.logger.error("Snorkeling logbook save failed: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    private func fileURL() -> URL {
        let base = Self.testHook_storageDirectoryURL
            ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return base.appendingPathComponent(fileName)
    }

    private func deletedIDsFileURL() -> URL {
        fileURL().deletingLastPathComponent().appendingPathComponent("dirdiving_snorkeling_deleted_session_ids.json")
    }

    private func loadDeletedSessionIDs() -> Set<UUID> {
        let url = deletedIDsFileURL()
        guard let data = try? Data(contentsOf: url),
              let ids = try? JSONDecoder().decode([UUID].self, from: data) else {
            if let legacy = UserDefaults.standard.stringArray(forKey: deletedLocalKey) {
                return Set(legacy.compactMap(UUID.init(uuidString:)))
            }
            return []
        }
        return Set(ids)
    }

    private func saveDeletedSessionIDs(_ ids: Set<UUID>) {
        let sorted = ids.map(\.uuidString).sorted()
        if let data = try? JSONEncoder().encode(sorted.compactMap(UUID.init(uuidString:))) {
            try? data.write(to: deletedIDsFileURL(), options: [.atomic, .completeFileProtection])
        }
        UserDefaults.standard.set(sorted, forKey: deletedLocalKey)
    }
}
