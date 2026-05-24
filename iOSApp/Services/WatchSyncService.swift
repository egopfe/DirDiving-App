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
    @Published var lastMessage = String(localized: "Non sincronizzato")
    @Published private(set) var importedSessionCount = 0
    @Published private(set) var failedImportCount = 0
    @Published private(set) var conflicts: [SyncConflict] = []
    private weak var logStore: DiveLogStore?
    private var importedSessionIDs: Set<UUID> = []
    private var pushedToWatchSessionIDs: Set<UUID> = []
    private var pendingOutboundSessions: [DiveSession] = []
    private let pushedToWatchIDsKey = "dirdiving_ios_pushed_to_watch_session_ids"

    // F9: conflicts persisted to a Documents/ file with `.completeFileProtection`
    // instead of UserDefaults. UserDefaults is not covered by Data Protection on a
    // locked device, and conflicts carry full DiveSession content (GPS included).
    // The legacy UserDefaults key is migrated once on init.
    private let legacyConflictsKey = "dirdiving_ios_watch_sync_conflicts"
    private let conflictsFileName = "dirdiving_ios_watch_sync_conflicts.json"

    private static let logger = Logger(subsystem: "com.egopfe.dirdiving.ios", category: "WatchSyncService")

    var userVisibleState: String {
        if !isSupported { return String(localized: "Non supportato") }
        if failedImportCount > 0 { return String(localized: "Errore import: retry disponibile") }
        if activationState == .activated, !WatchSyncAuth.hasPeerSecret() { return String(localized: "Associazione Watch non verificata") }
        if activationState == .activated { return String(localized: "Attivo") }
        return String(localized: "In attesa attivazione")
    }

    func activate(logStore: DiveLogStore) {
        self.logStore = logStore
        importedSessionIDs = WatchDiveSyncCodec.loadImportedSessionIDs()
        importedSessionCount = importedSessionIDs.count
        pushedToWatchSessionIDs = loadPushedToWatchSessionIDs()
        conflicts = loadConflicts()
        guard WCSession.isSupported() else {
            lastMessage = String(localized: "WatchConnectivity non supportato")
            return
        }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func retryActivation(logStore: DiveLogStore) {
        failedImportCount = 0
        lastMessage = String(localized: "Retry Watch Sync richiesto")
        activate(logStore: logStore)
    }

    func resetPairingTrust(logStore: DiveLogStore) {
        WatchSyncAuth.resetPeerTrust()
        failedImportCount = 0
        lastMessage = String(localized: "Trust Watch resettato: attendi una nuova associazione verificata.")
        activate(logStore: logStore)
    }

    /// Push a logbook session to the paired Watch (skips demo dives and sessions received from Watch).
    func transferToWatch(_ session: DiveSession) {
        guard WCSession.isSupported() else { return }
        guard !session.isDemoDive else { return }
        guard !importedSessionIDs.contains(session.id) else { return }
        guard !pushedToWatchSessionIDs.contains(session.id) else { return }
        enqueueOutboundSession(session)
        if WatchSyncAuth.hasPeerSecret() {
            flushOutboundTransfers()
        } else {
            WatchSyncAuth.publishSharedSecretIfNeeded()
            lastMessage = String(format: String(localized: "In coda verso Watch (%lld) — attendi associazione"), pendingOutboundSessions.count)
        }
    }

    /// Incremental sync: push sessions not yet sent and not imported from Watch.
    func syncUnpushedSessionsToWatch() {
        guard let sessions = logStore?.sessions else { return }
        for session in sessions where !session.isDemoDive {
            transferToWatch(session)
        }
    }

    func publishDeletedSessionIDs(_ ids: Set<UUID>) {
        guard WCSession.isSupported(), WCSession.default.activationState == .activated, !ids.isEmpty else { return }
        var existing = Set((WCSession.default.applicationContext[WatchSyncKeys.deletedSessionBroadcastKey] as? [String]) ?? [])
        existing.formUnion(ids.map(\.uuidString))
        WatchSyncAuth.mergeApplicationContext([WatchSyncKeys.deletedSessionBroadcastKey: Array(existing)])
        lastMessage = String(format: String(localized: "Tombstone inviata al Watch (%lld)"), ids.count)
    }

    func pushUnitsPreference(_ value: String) {
        let preference = IOSUnitPreference.fromStorage(value)
        guard WCSession.isSupported() else { return }
        WatchSyncAuth.mergeApplicationContext([WatchSyncKeys.unitsPreferenceKey: preference.syncCode])
    }

    func sendPhotoToWatch(_ imageData: Data, fileName: String) {
        guard WCSession.isSupported(), !imageData.isEmpty else { return }
        let sanitized = fileName.replacingOccurrences(of: "/", with: "_")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("DIRDivingPhoto_\(UUID().uuidString)_\(sanitized)")
        do {
            try imageData.write(to: url, options: [.atomic])
            WCSession.default.transferFile(url, metadata: [WatchSyncKeys.companionPhotoFileNameKey: sanitized])
            lastMessage = String(localized: "Foto inviata al Watch")
        } catch {
            lastMessage = String(format: String(localized: "Errore invio foto Watch: %@"), error.localizedDescription)
        }
    }

    private func ingestCompanionContext(_ context: [String: Any]) {
        WatchSyncAuth.ingestSharedSecretFromContext(context)
        if let units = context[WatchSyncKeys.unitsPreferenceKey] as? String {
            let preference = IOSUnitPreference.fromSyncCode(units)
            UserDefaults.standard.set(preference.rawValue, forKey: IOSUnitPreference.storageKey)
        }
        if let strings = context[WatchSyncKeys.deletedSessionBroadcastKey] as? [String] {
            let ids = Set(strings.compactMap(UUID.init(uuidString:)))
            if !ids.isEmpty {
                logStore?.applyRemoteDeletedSessionIDs(ids)
                lastMessage = String(format: String(localized: "Tombstone Watch applicata (%lld)"), ids.count)
            }
        }
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
                lastMessage = String(localized: "Conflitto sync salvato per revisione")
                return AckContext(sessionID: session.id, issuedAt: parsed.issuedAt)
            }
            guard !importedSessionIDs.contains(session.id) else {
                lastMessage = String(localized: "Immersione duplicata ignorata")
                return AckContext(sessionID: session.id, issuedAt: parsed.issuedAt)
            }
            logStore?.add(session, suppressWatchPush: true)
            importedSessionIDs.insert(session.id)
            WatchDiveSyncCodec.saveImportedSessionIDs(importedSessionIDs)
            importedSessionCount = importedSessionIDs.count
            lastMessage = String(localized: "Immersione ricevuta dal Watch")
            return AckContext(sessionID: session.id, issuedAt: parsed.issuedAt)
        } catch {
            failedImportCount += 1
            lastMessage = String(format: String(localized: "Errore sync Watch: %@"), error.localizedDescription)
            Self.logger.error("Watch sync import failed: \(error.localizedDescription, privacy: .private)")
            return nil
        }
    }

    func resolveConflictUsingIncoming(_ conflict: SyncConflict) {
        logStore?.add(conflict.incoming, suppressWatchPush: true)
        importedSessionIDs.insert(conflict.id)
        WatchDiveSyncCodec.saveImportedSessionIDs(importedSessionIDs)
        importedSessionCount = importedSessionIDs.count
        removeConflict(conflict)
        lastMessage = String(localized: "Conflitto risolto: usata versione Watch")
    }

    func resolveConflictKeepingLocal(_ conflict: SyncConflict) {
        importedSessionIDs.insert(conflict.id)
        WatchDiveSyncCodec.saveImportedSessionIDs(importedSessionIDs)
        importedSessionCount = importedSessionIDs.count
        removeConflict(conflict)
        if let local = logStore?.session(id: conflict.id), !local.isDemoDive {
            pushedToWatchSessionIDs.remove(conflict.id)
            savePushedToWatchSessionIDs()
            transferToWatch(local)
            lastMessage = String(localized: "more.sync.keep_local_repushed")
        } else {
            lastMessage = String(localized: "more.sync.keep_local_only")
        }
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

    private func enqueueOutboundSession(_ session: DiveSession) {
        pendingOutboundSessions.removeAll { $0.id == session.id }
        pendingOutboundSessions.append(session)
        pendingOutboundSessions.sort { $0.startDate > $1.startDate }
    }

    private func removeOutboundSession(id: UUID) {
        pendingOutboundSessions.removeAll { $0.id == id }
    }

    private func flushOutboundTransfers() {
        guard WatchSyncAuth.hasPeerSecret(), !pendingOutboundSessions.isEmpty else { return }
        let queue = pendingOutboundSessions
        for session in queue.reversed() {
            sendOutbound(session)
        }
    }

    private func sendOutbound(_ session: DiveSession) {
        do {
            let envelope = try WatchDiveSyncCodec.makePayload(session: session)
            if WCSession.default.isReachable {
                WCSession.default.sendMessage(envelope.message) { [weak self] _ in
                    Task { @MainActor in
                        self?.markPushedToWatch(session.id)
                        self?.removeOutboundSession(id: session.id)
                        self?.lastMessage = String(localized: "Immersione inviata al Watch")
                    }
                } errorHandler: { [weak self] _ in
                    Task { @MainActor in
                        WCSession.default.transferUserInfo(envelope.message)
                        self?.lastMessage = String(localized: "Invio Watch in coda (transferUserInfo)")
                    }
                }
            } else {
                WCSession.default.transferUserInfo(envelope.message)
                markPushedToWatch(session.id)
                removeOutboundSession(id: session.id)
                lastMessage = String(localized: "Invio Watch in coda (Watch non raggiungibile)")
            }
            Self.logger.info("Outbound session push queued id=\(session.id.uuidString, privacy: .public)")
        } catch {
            failedImportCount += 1
            lastMessage = String(format: String(localized: "Errore invio Watch: %@"), error.localizedDescription)
            Self.logger.error("Outbound Watch push failed: \(error.localizedDescription, privacy: .private)")
        }
    }

    private func markPushedToWatch(_ id: UUID) {
        pushedToWatchSessionIDs.insert(id)
        savePushedToWatchSessionIDs()
    }

    private func loadPushedToWatchSessionIDs() -> Set<UUID> {
        guard let strings = UserDefaults.standard.stringArray(forKey: pushedToWatchIDsKey) else { return [] }
        return Set(strings.compactMap(UUID.init(uuidString:)))
    }

    private func savePushedToWatchSessionIDs() {
        let trimmed = Array(pushedToWatchSessionIDs.suffix(256))
        UserDefaults.standard.set(trimmed.map(\.uuidString), forKey: pushedToWatchIDsKey)
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
        let context = session.receivedApplicationContext
        Task { @MainActor in
            self.activationState = activationState
            self.lastMessage = error?.localizedDescription ?? String(localized: "Sessione Watch attiva")
            if activationState == .activated {
                self.ingestCompanionContext(context)
                WatchSyncAuth.publishSharedSecretIfNeeded()
                self.flushOutboundTransfers()
            }
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor in
            self.ingestCompanionContext(applicationContext)
            WatchSyncAuth.publishSharedSecretIfNeeded()
            self.flushOutboundTransfers()
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
