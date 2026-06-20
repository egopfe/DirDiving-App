import Combine
import Foundation

@MainActor
final class IOSSnorkelingLogbookStore: ObservableObject {
    static var testHook_storageDirectoryURL: URL?

    @Published private(set) var sessions: [SnorkelingSession] = []
    @Published private(set) var loadErrorMessage: String?

    private let fileName = "dirdiving_ios_snorkeling_sessions.json"
    private let deletedLocalKey = WatchSyncKeys.snorkelingDeletedSessionIDsLocalKey
    private var deletedSessionIDs: Set<UUID> = []
    private weak var tombstonePublisher: (any SnorkelingSessionTombstonePublishing)?

    init() {
        deletedSessionIDs = loadDeletedSessionIDs()
        load()
    }

    func attachWatchSync(_ service: any SnorkelingSessionTombstonePublishing) {
        tombstonePublisher = service
    }

    func applyRemoteDeletedSessionIDs(_ ids: Set<UUID>) {
        guard !ids.isEmpty else { return }
        deletedSessionIDs.formUnion(ids)
        sessions.removeAll { deletedSessionIDs.contains($0.id) }
        saveDeletedSessionIDs(deletedSessionIDs)
        persistAtomically()
    }

    var lastSession: SnorkelingSession? { sessions.first }

    func statistics() -> SnorkelingLogbookStatistics {
        SnorkelingLogbookStatistics.aggregate(from: sessions)
    }

    func aggregate(range: SnorkelingStatisticsRange = .allTime) -> SnorkelingAggregateStatistics {
        SnorkelingLogbookAnalytics.aggregate(from: sessions, range: range)
    }

    func personalRecords(options: SnorkelingRecordEligibilityOptions = .default) -> SnorkelingPersonalRecordsSummary {
        SnorkelingPersonalRecordsEngine.compute(from: sessions, options: options)
    }

    func charts(for session: SnorkelingSession) -> SnorkelingSessionChartsModel {
        SnorkelingSessionChartBuilder.build(from: session)
    }

    func dipMetrics(for session: SnorkelingSession) -> [SnorkelingDipMetrics] {
        SnorkelingDipAnalytics.metricsForSession(session)
    }

    func delete(id: UUID) {
        deletedSessionIDs.insert(id)
        sessions.removeAll { $0.id == id }
        saveDeletedSessionIDs(deletedSessionIDs)
        persistAtomically()
        tombstonePublisher?.publishDeletedSnorkelingSessionIDs([id])
    }

    func session(id: UUID) -> SnorkelingSession? {
        sessions.first { $0.id == id }
    }

    func reload() {
        deletedSessionIDs = loadDeletedSessionIDs()
        load()
    }

    @discardableResult
    func mergeImportedSession(_ incoming: SnorkelingSession) -> SnorkelingSessionSyncImportResult {
        let normalizedIncoming = SnorkelingLogbookPolicy.normalizedSession(incoming)
        guard !deletedSessionIDs.contains(normalizedIncoming.id) else {
            return .duplicateIgnored
        }
        let outcome = SnorkelingSessionSyncImportPolicy.importSession(
            incoming,
            existingSessions: sessions,
            importedIDs: importedSessionIDs
        )
        importedSessionIDs = outcome.updatedImportedIDs
        SnorkelingSessionSyncCodec.saveImportedSessionIDs(importedSessionIDs)

        guard let merged = outcome.session else {
            if case .failed(let reason) = outcome.result {
                loadErrorMessage = reason
            }
            return outcome.result
        }

        sessions.removeAll { $0.id == merged.id }
        sessions.insert(merged, at: 0)
        sessions = SnorkelingLogbookPolicy.normalizedAndCapped(sessions, deletedIDs: deletedSessionIDs)
        persistAtomically()
        return outcome.result
    }

    private var importedSessionIDs: Set<UUID> = SnorkelingSessionSyncCodec.loadImportedSessionIDs()

    private func persistAtomically() {
        do {
            let envelope = try SnorkelingLogbookPersistence.makeEnvelope(sessions: sessions)
            try SnorkelingLogbookPersistence.writeEnvelope(envelope, to: fileURL())
            loadErrorMessage = nil
        } catch {
            loadErrorMessage = error.localizedDescription
        }
    }

    private func load() {
        let url = fileURL()
        guard FileManager.default.fileExists(atPath: url.path) else {
            sessions = []
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try SnorkelingLogbookPersistence.decodeSessionsResiliently(from: data)
            let filtered = SnorkelingLogbookPolicy.filterValidLoadedSessions(decoded)
            sessions = SnorkelingLogbookPolicy.normalizedAndCapped(filtered.sessions, deletedIDs: deletedSessionIDs)
        } catch {
            let base = Self.testHook_storageDirectoryURL
                ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            try? SnorkelingLogbookPersistence.quarantineCorruptFile(at: url, baseDirectory: base)
            loadErrorMessage = error.localizedDescription
            sessions = []
        }
    }

    private func fileURL() -> URL {
        let base = Self.testHook_storageDirectoryURL
            ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent(fileName)
    }

    private func deletedIDsFileURL() -> URL {
        fileURL().deletingLastPathComponent().appendingPathComponent("dirdiving_ios_snorkeling_deleted_session_ids.json")
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

    #if DEBUG
    func replaceSessionsForTesting(_ sessions: [SnorkelingSession]) throws {
        let envelope = try SnorkelingLogbookPersistence.makeEnvelope(sessions: sessions)
        try SnorkelingLogbookPersistence.writeEnvelope(envelope, to: fileURL())
        load()
    }

    func resetForTesting() {
        sessions = []
        deletedSessionIDs = []
        try? FileManager.default.removeItem(at: fileURL())
        try? FileManager.default.removeItem(at: deletedIDsFileURL())
        UserDefaults.standard.removeObject(forKey: deletedLocalKey)
    }

    func resetImportedIDsForTesting() {
        importedSessionIDs = []
        SnorkelingSessionSyncCodec.saveImportedSessionIDs([])
    }
    #endif
}
