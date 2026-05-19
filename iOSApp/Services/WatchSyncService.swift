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
    @Published private(set) var pendingOutboundCount = 0
    private weak var logStore: DiveLogStore?
    private var importedSessionIDs: Set<UUID> = []
    private var pendingOutboundSessions: [DiveSession] = []
    private let conflictsKey = "dirdiving_ios_watch_sync_conflicts"
    private let pendingOutboundKey = "dirdiving_ios_pending_watch_outbound_sessions"

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
        pendingOutboundSessions = loadPendingOutbound()
        pendingOutboundCount = pendingOutboundSessions.count
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

    func pushSession(_ session: DiveSession) {
        // UX-H2: gate every outbound push on the verified companion key; never
        // ship raw payloads from iOS without HMAC. If the peer secret is not
        // yet exchanged, queue the session and re-flush when the secret is
        // received from the Watch.
        guard WCSession.isSupported() else { return }
        guard !importedSessionIDs.contains(session.id) else { return }
        enqueueOutbound(session)
        if WatchSyncAuth.hasPeerSecret() {
            flushPendingOutbound()
        } else {
            WatchSyncAuth.publishSharedSecretIfNeeded()
            lastMessage = "Push Watch in coda: in attesa associazione verificata (\(pendingOutboundCount) pending)"
        }
    }

    func pushUnitsPreference(_ rawValue: String) {
        // UX-M7: today Watch only supports metric. We still broadcast the
        // canonical key so the contract is established; the Watch side
        // explicitly ignores any non-metric value.
        guard WCSession.isSupported(), WCSession.default.activationState == .activated else { return }
        let canonical = rawValue == IOSUnitPreference.imperial.rawValue ? "imperial" : "metric"
        do {
            try WCSession.default.updateApplicationContext([WatchSyncKeys.unitsPreferenceKey: canonical])
        } catch {
            lastMessage = "Settings sync: contesto unità non aggiornato (\(error.localizedDescription))"
        }
    }

    private func flushPendingOutbound() {
        guard WatchSyncAuth.hasPeerSecret(), !pendingOutboundSessions.isEmpty else { return }
        let queue = pendingOutboundSessions
        for session in queue.reversed() {
            sendQueuedOutbound(session)
        }
    }

    private func sendQueuedOutbound(_ session: DiveSession) {
        do {
            let payload = try WatchDiveSyncCodec.makePayload(session: session)
            if WCSession.default.isReachable {
                WCSession.default.sendMessage(payload) { [weak self] reply in
                    Task { @MainActor in
                        if reply["status"] as? String == "acknowledged" {
                            self?.removePendingOutbound(id: session.id)
                            self?.lastMessage = "Push iPhone -> Watch: confermato"
                        } else {
                            self?.lastMessage = "Push iPhone -> Watch: ack non ricevuto, coda preservata"
                        }
                    }
                } errorHandler: { [weak self] error in
                    Task { @MainActor in
                        self?.lastMessage = "Push diretto fallito, fallback coda: \(error.localizedDescription)"
                        WCSession.default.transferUserInfo(payload)
                    }
                }
            } else {
                WCSession.default.transferUserInfo(payload)
                lastMessage = "Push iPhone -> Watch: in coda WatchConnectivity"
            }
        } catch WatchDiveSyncError.unverifiedPeer {
            WatchSyncAuth.publishSharedSecretIfNeeded()
            lastMessage = "Push iPhone -> Watch: peer non ancora verificato (coda preservata)"
        } catch {
            lastMessage = "Push iPhone -> Watch fallito: \(error.localizedDescription)"
        }
    }

    private func enqueueOutbound(_ session: DiveSession) {
        pendingOutboundSessions.removeAll { $0.id == session.id }
        pendingOutboundSessions.append(session)
        pendingOutboundSessions = pendingOutboundSessions.sorted { $0.startDate > $1.startDate }
        pendingOutboundCount = pendingOutboundSessions.count
        savePendingOutbound()
    }

    private func removePendingOutbound(id: UUID) {
        pendingOutboundSessions.removeAll { $0.id == id }
        pendingOutboundCount = pendingOutboundSessions.count
        savePendingOutbound()
    }

    private func loadPendingOutbound() -> [DiveSession] {
        guard let data = UserDefaults.standard.data(forKey: pendingOutboundKey) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([DiveSession].self, from: data)) ?? []
    }

    private func savePendingOutbound() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(pendingOutboundSessions) {
            UserDefaults.standard.set(data, forKey: pendingOutboundKey)
        }
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
                self.flushPendingOutbound()
            }
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor in
            WatchSyncAuth.ingestSharedSecretFromContext(applicationContext)
            WatchSyncAuth.publishSharedSecretIfNeeded()
            self.flushPendingOutbound()
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
