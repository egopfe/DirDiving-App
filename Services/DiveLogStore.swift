import Foundation
import SwiftUI

@MainActor
final class DiveLogStore: ObservableObject {
    @Published private(set) var sessions: [DiveSession] = []
    private let fileName = "dirdiving_sessions.json"
    private let cloudKey = "dirdiving_watch_dive_sessions"
    private let maxSessions = 40
    private let cloudSync = CloudSyncStore()

    init() { load() }

    func add(_ session: DiveSession) {
        sessions.insert(session, at: 0)
        sessions = Array(sessions.sorted { $0.startDate > $1.startDate }.prefix(maxSessions))
        save()
        WatchSyncService.shared.transfer(session)
    }

    func delete(at offsets: IndexSet) {
        sessions.remove(atOffsets: offsets)
        save()
    }

    private func load() {
        let localSessions = loadLocalSessions()
        let cloudSessions = cloudSync.load([DiveSession].self, forKey: cloudKey)
        sessions = mergeSessions(local: localSessions, cloud: cloudSessions)
            .sorted { $0.startDate > $1.startDate }
        if !sessions.isEmpty {
            save()
        }
    }

    private func loadLocalSessions() -> [DiveSession] {
        let url = fileURL()
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([DiveSession].self, from: Data(contentsOf: url))
        } catch {
            return []
        }
    }

    private func mergeSessions(local: [DiveSession], cloud: [DiveSession]?) -> [DiveSession] {
        var byID: [UUID: DiveSession] = [:]
        for session in local {
            byID[session.id] = session
        }
        guard let cloud else { return Array(byID.values) }
        for session in cloud {
            if let existing = byID[session.id] {
                byID[session.id] = existing.endDate >= session.endDate ? existing : session
            } else {
                byID[session.id] = session
            }
        }
        return Array(byID.values)
    }

    private func save() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            try encoder.encode(sessions).write(to: fileURL(), options: .atomic)
            cloudSync.save(sessions, forKey: cloudKey)
        } catch { print("Save error: \(error.localizedDescription)") }
    }

    private func fileURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
    }
}
