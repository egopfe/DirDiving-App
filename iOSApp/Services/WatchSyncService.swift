import Foundation
import Combine
import WatchConnectivity
import os

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

    // F9: conflicts persisted to a Documents/ file with `.completeFileProtection`
    // instead of UserDefaults. UserDefaults is not covered by Data Protection on a
    // locked device, and conflicts carry full DiveSession content (GPS included).
    // The legacy UserDefaults key is migrated once on init.
    private let legacyConflictsKey = "dirdiving_ios_watch_sync_conflicts"
    private let conflictsFileName = "dirdiving_ios_watch_sync_conflicts.json"

    private static let logger = Logger(subsystem: "com.egopfe.dirdiving.ios", category: "WatchSyncService")

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

    private struct AckContext {
        let sessionID: UUID
        let issuedAt: Date
    }

    @discardableResult
    private func importSessionPayload(_ payload: [String: Any]) -> AckContext? {
        do {
            let parsed = try WatchDiveSyncCodec.parsePayload(from: payload)
            let session = parsed.session
            if let existing = logStore?.session(id: session.id), existing != session {
                storeConflict(local: existing, incoming: session)
                lastMessage = "Conflitto sync salvato per revisione"
                return AckContext(sessionID: session.id, issuedAt: parsed.issuedAt)
            }
            guard !importedSessionIDs.contains(session.id) else {
                lastMessage = "Immersione duplicata ignorata"
                return AckContext(sessionID: session.id, issuedAt: parsed.issuedAt)
            }
            logStore?.add(session)
            importedSessionIDs.insert(session.id)
            WatchDiveSyncCodec.saveImportedSessionIDs(importedSessionIDs)
            importedSessionCount = importedSessionIDs.count
            lastMessage = "Immersione ricevuta dal Watch"
            return AckContext(sessionID: session.id, issuedAt: parsed.issuedAt)
        } catch {
            failedImportCount += 1
            lastMessage = "Errore sync Watch: \(error.localizedDescription)"
            Self.logger.error("Watch sync import failed: \(error.localizedDescription, privacy: .private)")
            return nil
        }
    }

    func resolveConflictUsingIncoming(_ conflict: SyncConflict) {
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

    private func conflictsFileURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(conflictsFileName)
    }

    private func loadConflicts() -> [SyncConflict] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        // Primary source: Documents/ file (with Data Protection).
        let url = conflictsFileURL()
        if FileManager.default.fileExists(atPath: url.path),
           let data = try? Data(contentsOf: url),
           let decoded = try? decoder.decode([SyncConflict].self, from: data) {
            return decoded
        }

        // F9 migration: import once from UserDefaults, then write to the new file
        // and clear the legacy key to keep PII out of UserDefaults going forward.
        guard let legacyData = UserDefaults.standard.data(forKey: legacyConflictsKey) else { return [] }
        let migrated = (try? decoder.decode([SyncConflict].self, from: legacyData)) ?? []
        if !migrated.isEmpty {
            persistConflicts(migrated)
        }
        UserDefaults.standard.removeObject(forKey: legacyConflictsKey)
        return migrated
    }

    private func saveConflicts() {
        persistConflicts(conflicts)
    }

    private func persistConflicts(_ value: [SyncConflict]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(value) else { return }
        do {
            try data.write(to: conflictsFileURL(), options: [.atomic, .completeFileProtection])
        } catch {
            Self.logger.error("Persist watch-sync conflicts failed: \(error.localizedDescription, privacy: .private)")
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
            _ = self.importSessionPayload(message)
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        Task { @MainActor in
            let beforeFailures = self.failedImportCount
            let ackContext = self.importSessionPayload(message)
            let acknowledged = self.failedImportCount == beforeFailures
            var reply: [String: Any] = ["status": acknowledged ? "acknowledged" : "failed"]
            if acknowledged, let ackContext {
                // F11: signed ack lets the Watch confirm that this reply was produced
                // by the same trusted iOS peer (constant-time HMAC over sessionID +
                // issuedAt of the original payload). Watch-side fallback still
                // accepts the legacy `acknowledged` string for older builds.
                reply["ackSignature"] = WatchDiveSyncCodec.ackSignature(
                    sessionID: ackContext.sessionID,
                    issuedAt: ackContext.issuedAt
                )
            }
            replyHandler(reply)
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        Task { @MainActor in
            _ = self.importSessionPayload(userInfo)
        }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}
    nonisolated func sessionDidDeactivate(_ session: WCSession) { WCSession.default.activate() }
}
