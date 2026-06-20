import Foundation
import os

@MainActor
final class ApneaLogbookStore: ObservableObject {
    private static let logger = Logger(subsystem: "com.egopfe.dirdiving", category: "ApneaLogbookStore")
    static var testHook_storageDirectoryURL: URL?

    @Published private(set) var sessions: [ApneaSession] = []
    @Published private(set) var loadErrorMessage: String?
    @Published private(set) var lastPersistenceError: String?
    @Published private(set) var lastSavedSessionID: UUID?

    private let fileName = "dirdiving_apnea_sessions.json"
    private let cloudKey = "dirdiving_watch_apnea_sessions"
    private let deletedCloudKey = "dirdiving_watch_deleted_apnea_session_ids"
    private let cloudSync = CloudSyncStore()
    private var deletedSessionIDs: Set<UUID> = []
    private var isReady = false

    init() {
        load()
        isReady = true
        NotificationCenter.default.addObserver(
            forName: .cloudSyncDidChangeExternally,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.reloadFromPersistence() }
        }
    }

    func reloadFromPersistence() {
        deletedSessionIDs = loadDeletedSessionIDs()
        let localSessions = loadLocalSessions()
        let cloudSessions = loadCloudSessions()
        sessions = ApneaLogbookPolicy.normalizedAndCapped(
            applyLoadIntegrityFilter(to: ApneaLogbookPolicy.mergedAndCapped(
                local: localSessions,
                cloud: cloudSessions,
                deletedIDs: deletedSessionIDs
            )),
            deletedIDs: deletedSessionIDs
        )
        if cloudSessions != nil {
            save()
        }
    }

    func add(_ session: ApneaSession) {
        let normalized = ApneaLogbookPolicy.normalizedSession(session)
        guard !deletedSessionIDs.contains(normalized.id) else { return }
        switch ApneaLogbookPolicy.classify(normalized) {
        case .invalid(let reason):
            loadErrorMessage = reason
            return
        case .exportable:
            sessions.removeAll { $0.id == normalized.id }
            sessions.insert(normalized, at: 0)
            sessions = ApneaLogbookPolicy.normalizedAndCapped(sessions, deletedIDs: deletedSessionIDs)
            guard save() else { return }
            lastSavedSessionID = normalized.id
            if normalized.state == .completed || normalized.state == .aborted {
                WatchSyncService.shared.transferApneaSession(normalized)
            }
        }
    }

    func update(_ session: ApneaSession) {
        add(session)
    }

    func applyRemoteDeletedSessionIDs(_ ids: Set<UUID>) {
        guard !ids.isEmpty else { return }
        deletedSessionIDs.formUnion(ids)
        sessions.removeAll { deletedSessionIDs.contains($0.id) }
        save()
    }

    func delete(id: UUID) {
        guard sessions.contains(where: { $0.id == id }) else { return }
        deletedSessionIDs.insert(id)
        sessions.removeAll { $0.id == id }
        save()
#if os(watchOS)
        WatchSyncService.shared.publishDeletedApneaSessionIDs([id])
#endif
    }

    func exportData() throws -> Data {
        try ApneaLogbookPersistence.exportData(for: sessions)
    }

    func aggregateStatistics(range: ApneaStatisticsRange = .allTime) -> ApneaAggregateStatistics {
        ApneaLogbookStatistics.aggregate(from: sessions, range: range)
    }

    private func load() {
        deletedSessionIDs = loadDeletedSessionIDs()
        let localSessions = loadLocalSessions()
        let cloudSessions = loadCloudSessions()
        sessions = ApneaLogbookPolicy.normalizedAndCapped(
            applyLoadIntegrityFilter(to: ApneaLogbookPolicy.mergedAndCapped(
                local: localSessions,
                cloud: cloudSessions,
                deletedIDs: deletedSessionIDs
            )),
            deletedIDs: deletedSessionIDs
        )
        if !sessions.isEmpty {
            save()
        }
    }

    private func loadLocalSessions() -> [ApneaSession] {
        let url = fileURL()
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try ApneaLogbookPersistence.decodeSessionsResiliently(from: data)
            let filtered = ApneaLogbookPolicy.filterValidLoadedSessions(decoded)
            if filtered.quarantinedCount > 0 {
                loadErrorMessage = "quarantined:\(filtered.quarantinedCount)"
            }
            return filtered.sessions
        } catch {
            let base = Self.testHook_storageDirectoryURL
                ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            try? ApneaLogbookPersistence.quarantineCorruptFile(at: url, baseDirectory: base)
            loadErrorMessage = error.localizedDescription
            return []
        }
    }

    private func loadCloudSessions() -> [ApneaSession]? {
        guard let data = cloudSync.loadRawCloudData(forKey: cloudKey) else { return nil }
        guard let decoded = try? ApneaLogbookPersistence.decodeSessionsResiliently(from: data) else { return nil }
        let filtered = ApneaLogbookPolicy.filterValidLoadedSessions(decoded)
        return filtered.sessions
    }

    private func applyLoadIntegrityFilter(to merged: [ApneaSession]) -> [ApneaSession] {
        let filtered = ApneaLogbookPolicy.filterValidLoadedSessions(merged)
        if filtered.quarantinedCount > 0 {
            loadErrorMessage = "quarantined:\(filtered.quarantinedCount)"
        }
        return filtered.sessions
    }

    private func loadDeletedSessionIDs() -> Set<UUID> {
        Set(cloudSync.load([UUID].self, forKey: deletedCloudKey) ?? [])
    }

    private func saveDeletedSessionIDs(_ ids: Set<UUID>) {
        cloudSync.save(Array(ids), forKey: deletedCloudKey)
    }

    @discardableResult
    private func save() -> Bool {
        do {
            let envelope = try ApneaLogbookPersistence.makeEnvelope(sessions: sessions)
            try ApneaLogbookPersistence.writeEnvelope(envelope, to: fileURL())
            cloudSync.removeValue(forKey: cloudKey)
            saveDeletedSessionIDs(deletedSessionIDs)
            lastPersistenceError = nil
            return true
        } catch {
            lastPersistenceError = error.localizedDescription
            Self.logger.error("ApneaLogbookStore save failed: \(error.localizedDescription, privacy: .private)")
            return false
        }
    }

    private func fileURL() -> URL {
        let base = Self.testHook_storageDirectoryURL
            ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent(fileName)
    }
}
