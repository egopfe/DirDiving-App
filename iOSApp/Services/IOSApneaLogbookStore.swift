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

    func reload() {
        load()
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
    #endif
}
