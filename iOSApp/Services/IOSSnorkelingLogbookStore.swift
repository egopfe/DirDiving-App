import Combine
import Foundation

@MainActor
final class IOSSnorkelingLogbookStore: ObservableObject {
    static var testHook_storageDirectoryURL: URL?

    @Published private(set) var sessions: [SnorkelingSession] = []
    @Published private(set) var loadErrorMessage: String?

    private let fileName = "dirdiving_ios_snorkeling_sessions.json"

    init() {
        load()
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
        sessions.removeAll { $0.id == id }
        persistAtomically()
    }

    func session(id: UUID) -> SnorkelingSession? {
        sessions.first { $0.id == id }
    }

    func reload() {
        load()
    }

    @discardableResult
    func mergeImportedSession(_ incoming: SnorkelingSession) -> SnorkelingSessionSyncImportResult {
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
        sessions = SnorkelingLogbookPolicy.normalizedAndCapped(sessions)
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
            sessions = SnorkelingLogbookPolicy.normalizedAndCapped(filtered.sessions)
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

    #if DEBUG
    func replaceSessionsForTesting(_ sessions: [SnorkelingSession]) throws {
        let envelope = try SnorkelingLogbookPersistence.makeEnvelope(sessions: sessions)
        try SnorkelingLogbookPersistence.writeEnvelope(envelope, to: fileURL())
        load()
    }

    func resetForTesting() {
        sessions = []
        try? FileManager.default.removeItem(at: fileURL())
    }

    func resetImportedIDsForTesting() {
        importedSessionIDs = []
        SnorkelingSessionSyncCodec.saveImportedSessionIDs([])
    }
    #endif
}
