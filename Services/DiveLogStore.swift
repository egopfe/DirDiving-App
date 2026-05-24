import Foundation
import SwiftUI
import os

@MainActor
final class DiveLogStore: ObservableObject {
    private static let logger = Logger(subsystem: "com.egopfe.dirdiving", category: "DiveLogStore")

    @Published private(set) var sessions: [DiveSession] = []
    @Published private(set) var loadErrorMessage: String?
    private let fileName = "dirdiving_sessions.json"
    private let cloudKey = "dirdiving_watch_dive_sessions"
    private let deletedCloudKey = WatchSyncKeys.deletedSessionIDsKey
    private let legacyDeletedCloudKeys = [
        "dirdiving_watch_deleted_session_ids",
        "dirdiving_ios_deleted_session_ids",
        "dirdiving_ios_deleted_dive_session_ids"
    ]
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

    func isDeleted(id: UUID) -> Bool {
        deletedSessionIDs.contains(id)
    }

    func reloadFromPersistence() {
        deletedSessionIDs = loadDeletedSessionIDs()
        let localSessions = loadLocalSessions()
        let cloudSessions = cloudSync.load([DiveSession].self, forKey: cloudKey)
        sessions = mergeSessions(local: localSessions, cloud: cloudSessions)
            .filter { !deletedSessionIDs.contains($0.id) }
            .sorted { $0.startDate > $1.startDate }
    }

    /// Session created on-device (or finalized locally) — may sync to iPhone.
    func add(_ session: DiveSession) {
        guard !deletedSessionIDs.contains(session.id) else { return }
        sessions.removeAll { $0.id == session.id }
        sessions.insert(session, at: 0)
        sessions = Array(sessions.sorted { $0.startDate > $1.startDate }.prefix(maxSessions))
        save()
        WatchSyncService.shared.transfer(session)
    }

    /// Session received from iPhone — do not echo back via transfer.
    func addFromCompanion(_ session: DiveSession) {
        guard !deletedSessionIDs.contains(session.id) else { return }
        sessions.removeAll { $0.id == session.id }
        sessions.insert(session, at: 0)
        sessions = Array(sessions.sorted { $0.startDate > $1.startDate }.prefix(maxSessions))
        save()
    }

    func applyRemoteDeletedSessionIDs(_ ids: Set<UUID>) {
        guard !ids.isEmpty else { return }
        deletedSessionIDs.formUnion(ids)
        sessions.removeAll { deletedSessionIDs.contains($0.id) }
        saveDeletedSessionIDs(deletedSessionIDs)
        save()
    }

    func delete(id: UUID) {
        guard let index = sessions.firstIndex(where: { $0.id == id }) else { return }
        deletedSessionIDs.insert(id)
        sessions.remove(at: index)
        save()
        WatchSyncService.shared.publishDeletedSessionIDs([id])
    }

    func delete(at offsets: IndexSet) {
        var removed: Set<UUID> = []
        for index in offsets.sorted(by: >) where sessions.indices.contains(index) {
            removed.insert(sessions[index].id)
            deletedSessionIDs.insert(sessions[index].id)
            sessions.remove(at: index)
        }
        save()
        if !removed.isEmpty {
            WatchSyncService.shared.publishDeletedSessionIDs(removed)
        }
    }

    private func load() {
        deletedSessionIDs = loadDeletedSessionIDs()
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
            loadErrorMessage = String(format: String(localized: "Log locale non leggibile: %@"), error.localizedDescription)
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

    private func loadDeletedSessionIDs() -> Set<UUID> {
        let ids = legacyDeletedCloudKeys.flatMap { key in
            cloudSync.load([UUID].self, forKey: key) ?? loadDeletedSessionIDsFromDefaults(key: key)
        }
        var merged = Set(ids)
        if let shared = cloudSync.load([UUID].self, forKey: deletedCloudKey) {
            merged.formUnion(shared)
        }
        if !merged.isEmpty {
            saveDeletedSessionIDs(merged)
        }
        return merged
    }

    private func loadDeletedSessionIDsFromDefaults(key: String) -> [UUID] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([UUID].self, from: data)) ?? []
    }

    private func saveDeletedSessionIDs(_ ids: Set<UUID>) {
        let values = Array(ids)
        if let data = try? JSONEncoder().encode(values) {
            UserDefaults.standard.set(data, forKey: deletedCloudKey)
        }
        cloudSync.save(values, forKey: deletedCloudKey)
    }

    private func save() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(sessions)
            try data.write(to: fileURL(), options: [.atomic, .completeFileProtection])
            cloudSync.save(sessions, forKey: cloudKey)
            saveDeletedSessionIDs(deletedSessionIDs)
        } catch {
            Self.logger.error("DiveLogStore save failed: \(error.localizedDescription, privacy: .private)")
        }
    }

    private func fileURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
    }
}
