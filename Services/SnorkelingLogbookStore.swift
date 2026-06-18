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

    init() {
        load()
    }

    func reloadFromPersistence() {
        sessions = SnorkelingLogbookPolicy.normalizedAndCapped(loadLocalSessions())
    }

    func add(_ session: SnorkelingSession) {
        let normalized = SnorkelingLogbookPolicy.normalizedSession(session)
        switch SnorkelingLogbookPolicy.classify(normalized) {
        case .invalid(let reason):
            loadErrorMessage = reason
            return
        case .exportable:
            sessions.removeAll { $0.id == normalized.id }
            sessions.insert(normalized, at: 0)
            sessions = SnorkelingLogbookPolicy.normalizedAndCapped(sessions)
            guard save() else { return }
            lastSavedSessionID = normalized.id
        }
    }

    func exportData() throws -> Data {
        try SnorkelingLogbookPersistence.exportData(for: sessions)
    }

    private func load() {
        sessions = SnorkelingLogbookPolicy.normalizedAndCapped(loadLocalSessions())
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
}
