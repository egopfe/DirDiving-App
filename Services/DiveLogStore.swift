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
    }

    /// Session created on-device (or finalized locally) — may sync to iPhone.
    func add(_ session: DiveSession) {
        let normalizedSession = DiveSessionMerge.preferred(session, session)
        guard !deletedSessionIDs.contains(normalizedSession.id) else { return }

        switch DiveSessionPersistenceClass.classify(normalizedSession) {
        case .invalid(let reason):
            loadErrorMessage = reason
            return
        case .profileExportable, .manualNoDepth:
            break
        }

        sessions.removeAll { $0.id == normalizedSession.id }
        sessions.insert(normalizedSession, at: 0)
        sessions = DiveLogbookPolicy.normalizedAndCapped(sessions, deletedIDs: deletedSessionIDs)
        save()
        if DiveSessionPersistenceClass.classify(normalizedSession).allowsSync {
            WatchSyncService.shared.transfer(normalizedSession)
        }
    }

    func persistenceClass(for session: DiveSession) -> DiveSessionPersistenceClass {
        DiveSessionPersistenceClass.classify(DiveSessionMerge.preferred(session, session))
    }

    /// Session received from iPhone — do not echo back via transfer.
    func addFromCompanion(_ session: DiveSession) {
        let normalizedSession = DiveSessionMerge.preferred(session, session)
        guard !deletedSessionIDs.contains(normalizedSession.id) else { return }
        sessions.removeAll { $0.id == normalizedSession.id }
        sessions.insert(normalizedSession, at: 0)
        sessions = DiveLogbookPolicy.normalizedAndCapped(sessions, deletedIDs: deletedSessionIDs)
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
                .map { DiveSessionMerge.preferred($0, $0) }
        } catch {
            loadErrorMessage = String(format: String(localized: "Log locale non leggibile: %@"), error.localizedDescription)
            return []
        }
    }

    private func mergeSessions(local: [DiveSession], cloud: [DiveSession]?) -> [DiveSession] {
        DiveLogbookPolicy.mergedAndCapped(local: local, cloud: cloud, deletedIDs: deletedSessionIDs)
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
