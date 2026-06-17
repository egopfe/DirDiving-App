import Combine
import Foundation

@MainActor
final class IOSApneaLogbookStore: ObservableObject {
    static var testHook_storageDirectoryURL: URL?

    @Published private(set) var sessions: [ApneaSession] = []
    @Published private(set) var loadErrorMessage: String?

    private let fileName = "dirdiving_ios_apnea_sessions.json"

    init() {
        load()
    }

    var lastSession: ApneaSession? { sessions.first }

    func aggregate(range: ApneaStatisticsRange = .allTime) -> ApneaAggregateStatistics {
        ApneaLogbookStatistics.aggregate(from: sessions, range: range)
    }

    func session(id: UUID) -> ApneaSession? {
        sessions.first { $0.id == id }
    }

    func personalRecords(options: ApneaRecordEligibilityOptions = .default) -> ApneaPersonalRecordsSummary {
        ApneaPersonalRecordsEngine.compute(from: sessions, options: options)
    }

    func charts(for session: ApneaSession) -> ApneaSessionChartsModel {
        ApneaSessionChartBuilder.build(from: session)
    }

    func diveMetrics(for session: ApneaSession) -> [ApneaDiveMetrics] {
        var offset = 0.0
        return session.dives.enumerated().map { index, dive in
            let before = dive.recoveryBefore?.completedSeconds ?? dive.recoveryBefore?.plannedSeconds ?? 0
            offset += before
            let diveStart = offset
            let metrics = ApneaDiveAnalytics.metrics(for: dive, diveIndex: index, sessionOffsetSeconds: diveStart)
            offset = diveStart + dive.durationSeconds
            let after = dive.recoveryAfter?.completedSeconds ?? dive.recoveryAfter?.plannedSeconds ?? 0
            offset += after
            return metrics
        }
    }

    func reload() {
        load()
    }

    @discardableResult
    func mergeImportedSession(_ incoming: ApneaSession) -> ApneaSessionSyncImportResult {
        let outcome = ApneaSessionSyncImportPolicy.importSession(
            incoming,
            existingSessions: sessions,
            importedIDs: importedSessionIDs
        )
        importedSessionIDs = outcome.updatedImportedIDs
        ApneaSessionSyncCodec.saveImportedSessionIDs(importedSessionIDs)

        guard let merged = outcome.session else {
            if case .failed(let reason) = outcome.result {
                loadErrorMessage = reason
            }
            return outcome.result
        }

        sessions.removeAll { $0.id == merged.id }
        sessions.insert(merged, at: 0)
        sessions = ApneaLogbookPolicy.normalizedAndCapped(sessions, deletedIDs: [])
        persistAtomically()
        return outcome.result
    }

    private var importedSessionIDs: Set<UUID> = ApneaSessionSyncCodec.loadImportedSessionIDs()

    private func persistAtomically() {
        do {
            let envelope = try ApneaLogbookPersistence.makeEnvelope(sessions: sessions)
            try ApneaLogbookPersistence.writeEnvelope(envelope, to: fileURL())
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
            let decoded = try ApneaLogbookPersistence.decodeSessionsResiliently(from: data)
            let filtered = ApneaLogbookPolicy.filterValidLoadedSessions(decoded)
            sessions = ApneaLogbookPolicy.normalizedAndCapped(filtered.sessions, deletedIDs: [])
        } catch {
            let base = Self.testHook_storageDirectoryURL
                ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            try? ApneaLogbookPersistence.quarantineCorruptFile(at: url, baseDirectory: base)
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
    func replaceSessionsForTesting(_ sessions: [ApneaSession]) throws {
        let envelope = try ApneaLogbookPersistence.makeEnvelope(sessions: sessions)
        try ApneaLogbookPersistence.writeEnvelope(envelope, to: fileURL())
        load()
    }

    func resetImportedIDsForTesting() {
        importedSessionIDs = []
        ApneaSessionSyncCodec.saveImportedSessionIDs([])
    }
    #endif
}
