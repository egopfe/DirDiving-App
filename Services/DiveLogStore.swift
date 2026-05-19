import Foundation
import SwiftUI
import os

@MainActor
final class DiveLogStore: ObservableObject {
    // F12: structured logging via os.Logger so error details are redacted from
    // the public device log and never accidentally surface GPS / session content.
    private static let logger = Logger(subsystem: "com.egopfe.dirdiving", category: "DiveLogStore")

    @Published private(set) var sessions: [DiveSession] = []
    @Published private(set) var loadErrorMessage: String?
    private let fileName = "dirdiving_sessions.json"
    private let cloudKey = "dirdiving_watch_dive_sessions"
    private let deletedCloudKey = "dirdiving_watch_deleted_session_ids"
    private let maxSessions = 40
    private let cloudSync = CloudSyncStore()
    private var deletedSessionIDs: Set<UUID> = []

    init() {
        load()
        NotificationCenter.default.addObserver(
            forName: .cloudSyncDidChangeExternally,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.reloadFromPersistence() }
        }
    }

    func reloadFromPersistence() {
        deletedSessionIDs = Set(cloudSync.load([UUID].self, forKey: deletedCloudKey) ?? Array(deletedSessionIDs))
        let localSessions = loadLocalSessions()
        let cloudSessions = cloudSync.load([DiveSession].self, forKey: cloudKey)
        sessions = mergeSessions(local: localSessions, cloud: cloudSessions)
            .filter { !deletedSessionIDs.contains($0.id) }
            .sorted { $0.startDate > $1.startDate }
    }

    func add(_ session: DiveSession) {
        guard !deletedSessionIDs.contains(session.id) else { return }
        sessions.insert(session, at: 0)
        sessions = Array(sessions.sorted { $0.startDate > $1.startDate }.prefix(maxSessions))
        save()
        WatchSyncService.shared.transfer(session)
    }

    func delete(id: UUID) {
        guard let index = sessions.firstIndex(where: { $0.id == id }) else { return }
        deletedSessionIDs.insert(id)
        sessions.remove(at: index)
        save()
    }

    func delete(at offsets: IndexSet) {
        for index in offsets {
            deletedSessionIDs.insert(sessions[index].id)
        }
        sessions.remove(atOffsets: offsets)
        save()
    }

    private func load() {
        deletedSessionIDs = Set(cloudSync.load([UUID].self, forKey: deletedCloudKey) ?? [])
        let localSessions = loadLocalSessions()
        let cloudSessions = cloudSync.load([DiveSession].self, forKey: cloudKey)
        sessions = mergeSessions(local: localSessions, cloud: cloudSessions)
            .filter { !deletedSessionIDs.contains($0.id) }
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
            loadErrorMessage = "Log locale non leggibile: \(error.localizedDescription)"
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
                byID[session.id] = DiveSessionMerge.preferred(existing, session)
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
            let data = try encoder.encode(sessions)
            try data.write(to: fileURL(), options: [.atomic, .completeFileProtection])
            cloudSync.save(sessions, forKey: cloudKey)
            cloudSync.save(Array(deletedSessionIDs), forKey: deletedCloudKey)
        } catch {
            Self.logger.error("DiveLogStore save failed: \(error.localizedDescription, privacy: .private)")
        }
    }

    private func fileURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
    }
}
