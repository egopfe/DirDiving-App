import Foundation
import Combine
import WatchConnectivity

@MainActor
final class WatchSyncService: NSObject, ObservableObject {
    struct SyncConflict: Identifiable, Codable, Hashable {
        let id: UUID
        let detectedAt: Date
        let localSummary: String
        let incoming: DiveSession
    }

    @Published var isSupported = WCSession.isSupported()
    @Published var activationState: WCSessionActivationState = .notActivated
    @Published var lastMessage = "Non sincronizzato"
    @Published private(set) var importedSessionCount = 0
    @Published private(set) var failedImportCount = 0
    @Published private(set) var conflicts: [SyncConflict] = []
    private weak var logStore: DiveLogStore?
    private var importedSessionIDs: Set<UUID> = []
    private let conflictsKey = "dirdiving_ios_watch_sync_conflicts"

    var userVisibleState: String {
        if !isSupported { return "Non supportato" }
        if failedImportCount > 0 { return "Errore import: retry disponibile" }
        if activationState == .activated, !WatchSyncAuth.hasPeerSecret() { return "Associazione Watch non verificata" }
        if activationState == .activated { return "Attivo" }
        return "In attesa attivazione"
    }

    func activate(logStore: DiveLogStore) {
        self.logStore = logStore
        importedSessionIDs = WatchDiveSyncCodec.loadImportedSessionIDs()
        importedSessionCount = importedSessionIDs.count
        conflicts = loadConflicts()
        guard WCSession.isSupported() else {
            lastMessage = "WatchConnectivity non supportato"
            return
        }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func retryActivation(logStore: DiveLogStore) {
        failedImportCount = 0
        lastMessage = "Retry Watch Sync richiesto"
        activate(logStore: logStore)
    }

    func resetPairingTrust(logStore: DiveLogStore) {
        WatchSyncAuth.resetPeerTrust()
        failedImportCount = 0
        lastMessage = "Trust Watch resettato: attendi una nuova associazione verificata."
        activate(logStore: logStore)
    }

    private func importSessionPayload(_ payload: [String: Any]) {
        do {
            let session = try WatchDiveSyncCodec.parseSession(from: payload)
            guard logStore?.isDeleted(id: session.id) != true else {
                importedSessionIDs.insert(session.id)
                WatchDiveSyncCodec.saveImportedSessionIDs(importedSessionIDs)
                importedSessionCount = importedSessionIDs.count
                lastMessage = "Immersione cancellata ignorata dal tombstone"
                return
            }
            if let existing = logStore?.session(id: session.id), existing != session {
                storeConflict(local: existing, incoming: session)
                lastMessage = "Conflitto sync salvato per revisione"
                return
            }
            guard !importedSessionIDs.contains(session.id) else {
                lastMessage = "Immersione duplicata ignorata"
                return
            }
            logStore?.add(session)
            importedSessionIDs.insert(session.id)
            WatchDiveSyncCodec.saveImportedSessionIDs(importedSessionIDs)
            importedSessionCount = importedSessionIDs.count
            lastMessage = "Immersione ricevuta dal Watch"
        } catch {
            failedImportCount += 1
            lastMessage = "Errore sync Watch: \(error.localizedDescription)"
        }
    }

    func resolveConflictUsingIncoming(_ conflict: SyncConflict) {
        guard logStore?.isDeleted(id: conflict.id) != true else {
            removeConflict(conflict)
            lastMessage = "Conflitto ignorato: immersione gia cancellata"
            return
        }
        logStore?.add(conflict.incoming)
        importedSessionIDs.insert(conflict.id)
        WatchDiveSyncCodec.saveImportedSessionIDs(importedSessionIDs)
        importedSessionCount = importedSessionIDs.count
        removeConflict(conflict)
        lastMessage = "Conflitto risolto: usata versione Watch"
    }

    func resolveConflictKeepingLocal(_ conflict: SyncConflict) {
        importedSessionIDs.insert(conflict.id)
        WatchDiveSyncCodec.saveImportedSessionIDs(importedSessionIDs)
        importedSessionCount = importedSessionIDs.count
        removeConflict(conflict)
        lastMessage = "Conflitto risolto: mantenuta versione locale"
    }

    private func storeConflict(local: DiveSession, incoming: DiveSession) {
        conflicts.removeAll { $0.id == incoming.id }
        conflicts.insert(
            SyncConflict(
                id: incoming.id,
                detectedAt: Date(),
                localSummary: "\(Formatters.one(local.maxDepthMeters)) m / \(Formatters.time(local.durationSeconds))",
                incoming: incoming
            ),
            at: 0
        )
        saveConflicts()
    }

    private func removeConflict(_ conflict: SyncConflict) {
        conflicts.removeAll { $0.id == conflict.id }
        saveConflicts()
    }

    private func loadConflicts() -> [SyncConflict] {
        guard let data = UserDefaults.standard.data(forKey: conflictsKey) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([SyncConflict].self, from: data)) ?? []
    }

    private func saveConflicts() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(conflicts) {
            UserDefaults.standard.set(data, forKey: conflictsKey)
        }
    }
}

extension WatchSyncService: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            self.activationState = activationState
            self.lastMessage = error?.localizedDescription ?? "Sessione Watch attiva"
            if activationState == .activated {
                WatchSyncAuth.ingestSharedSecretFromContext(WatchSyncAuth.cachedApplicationContext())
                WatchSyncAuth.publishSharedSecretIfNeeded()
            }
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor in
            WatchSyncAuth.ingestSharedSecretFromContext(applicationContext)
            WatchSyncAuth.publishSharedSecretIfNeeded()
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        Task { @MainActor in
            self.importSessionPayload(message)
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        Task { @MainActor in
            self.importSessionPayload(userInfo)
        }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}
    nonisolated func sessionDidDeactivate(_ session: WCSession) { WCSession.default.activate() }
}
