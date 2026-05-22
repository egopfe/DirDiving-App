import Foundation
import Combine
import WatchConnectivity
import os

@MainActor
final class WatchSyncService: NSObject, ObservableObject {
    static let shared = WatchSyncService()

    @Published private(set) var isSupported = WCSession.isSupported()
    @Published private(set) var activationState: WCSessionActivationState = .notActivated
    @Published private(set) var lastSyncStatus = String(localized: "Companion non sincronizzato")
    @Published private(set) var pendingTransferCount = 0
    @Published private(set) var sentTransferCount = 0
    @Published private(set) var acknowledgedTransferCount = 0
    @Published private(set) var failedTransferCount = 0
    @Published private(set) var lastRetryDate: Date?
    @Published private(set) var importedFromCompanionCount = 0

    private var pendingSessions: [DiveSession] = []
    private let legacyPendingSessionsKey = "dirdiving_watch_pending_sync_sessions"
    private let pendingFileName = "dirdiving_watch_pending_sync_sessions.json"
    private weak var logStore: DiveLogStore?
    private var importedFromCompanionIDs: Set<UUID> = []
    private var peerSecretObserver: NSObjectProtocol?

    private static let logger = Logger(subsystem: "com.egopfe.dirdiving", category: "WatchSyncService")

    private override init() {
        super.init()
        pendingSessions = loadPendingSessions()
        pendingTransferCount = pendingSessions.count
        importedFromCompanionIDs = WatchDiveSyncCodec.loadImportedFromCompanionIDs()
        importedFromCompanionCount = importedFromCompanionIDs.count
        peerSecretObserver = NotificationCenter.default.addObserver(
            forName: .watchSyncPeerSecretDidUpdate,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.flushPendingTransfers() }
        }
        activate()
    }

    func attachLogStore(_ store: DiveLogStore) {
        logStore = store
    }

    deinit {
        if let peerSecretObserver {
            NotificationCenter.default.removeObserver(peerSecretObserver)
        }
    }

    func activate() {
        guard WCSession.isSupported() else {
            lastSyncStatus = String(localized: "WatchConnectivity non supportato")
            return
        }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func transfer(_ session: DiveSession) {
        guard WCSession.isSupported() else { return }
        if importedFromCompanionIDs.contains(session.id) { return }
        enqueuePendingSession(session)

        if WatchSyncAuth.hasPeerSecret() {
            flushPendingTransfers()
        } else {
            WatchSyncAuth.publishSharedSecretIfNeeded()
            lastSyncStatus = String(format: String(localized: "Pending: in attesa chiave sync (%lld in coda)"), pendingTransferCount)
        }
    }

    /// Broadcast tombstone UUIDs to iPhone via applicationContext (merge-safe).
    func publishDeletedSessionIDs(_ ids: Set<UUID>) {
        guard WCSession.isSupported(), !ids.isEmpty else { return }
        var existing = Set((WCSession.default.applicationContext[WatchSyncKeys.deletedSessionBroadcastKey] as? [String]) ?? [])
        existing.formUnion(ids.map(\.uuidString))
        WatchSyncAuth.mergeApplicationContext([WatchSyncKeys.deletedSessionBroadcastKey: Array(existing)])
        lastSyncStatus = String(format: String(localized: "Tombstone inviata a iPhone (%lld)"), ids.count)
    }

    func retryPendingTransfers() {
        lastRetryDate = Date()
        guard WCSession.isSupported() else {
            failedTransferCount += 1
            lastSyncStatus = String(localized: "Retry non disponibile: WatchConnectivity non supportato")
            return
        }
        activate()
        WatchSyncAuth.publishSharedSecretIfNeeded()
        if WatchSyncAuth.hasPeerSecret() {
            flushPendingTransfers()
        } else {
            lastSyncStatus = String(format: String(localized: "Retry richiesto: in attesa chiave companion (%lld in coda)"), pendingTransferCount)
        }
    }

    func clearFailedQueue() {
        pendingSessions.removeAll()
        pendingTransferCount = 0
        sentTransferCount = 0
        acknowledgedTransferCount = 0
        failedTransferCount = 0
        savePendingSessions()
        lastSyncStatus = String(localized: "Coda sync cancellata su richiesta")
    }

    private func ingestIncomingPayload(_ payload: [String: Any]) {
        do {
            let session = try WatchDiveSyncCodec.parseSession(from: payload)
            if logStore?.isDeleted(id: session.id) == true {
                rememberCompanionSession(id: session.id)
                lastSyncStatus = String(localized: "Import iPhone ignorato: tombstone presente")
                return
            }
            if importedFromCompanionIDs.contains(session.id) {
                lastSyncStatus = String(localized: "Immersione iPhone duplicata ignorata")
                return
            }
            rememberCompanionSession(id: session.id)
            logStore?.addFromCompanion(session)
            lastSyncStatus = String(localized: "Immersione ricevuta da iPhone")
        } catch {
            failedTransferCount += 1
            lastSyncStatus = String(format: String(localized: "Errore import iPhone: %@"), error.localizedDescription)
            Self.logger.error("Watch import from companion failed: \(error.localizedDescription, privacy: .private)")
        }
    }

    private func rememberCompanionSession(id: UUID) {
        importedFromCompanionIDs.insert(id)
        importedFromCompanionCount = importedFromCompanionIDs.count
        WatchDiveSyncCodec.saveImportedFromCompanionIDs(importedFromCompanionIDs)
    }

    private func ingestCompanionContext(_ context: [String: Any]) {
        WatchSyncAuth.ingestSharedSecretFromContext(context)
        if let units = context[WatchSyncKeys.unitsPreferenceKey] as? String, units == "metric" {
            UserDefaults.standard.set("metric", forKey: "dirdiving_watch_units")
        }
        if let strings = context[WatchSyncKeys.deletedSessionBroadcastKey] as? [String] {
            let ids = Set(strings.compactMap(UUID.init(uuidString:)))
            if !ids.isEmpty {
                logStore?.applyRemoteDeletedSessionIDs(ids)
                lastSyncStatus = String(format: String(localized: "Tombstone iPhone applicata (%lld)"), ids.count)
            }
        }
    }

    private func flushPendingTransfers() {
        guard WatchSyncAuth.hasPeerSecret(), !pendingSessions.isEmpty else { return }
        let queue = pendingSessions
        for session in queue.reversed() {
            sendQueued(session)
        }
    }

    private func sendQueued(_ session: DiveSession) {
        do {
            let envelope = try WatchDiveSyncCodec.makePayload(session: session)

            if WCSession.default.isReachable {
                WCSession.default.sendMessage(envelope.message) { [weak self] reply in
                    Task { @MainActor in
                        guard let self else { return }
                        let providedSignature = reply["ackSignature"] as? String
                        let signedOK = WatchDiveSyncCodec.verifyAckSignature(
                            providedSignature,
                            sessionID: envelope.sessionID,
                            issuedAt: envelope.issuedAt
                        )
                        let legacyOK = (reply["status"] as? String == "acknowledged")
                        if signedOK {
                            self.removePendingSession(id: session.id)
                            self.acknowledgedTransferCount += 1
                            self.lastSyncStatus = String(localized: "Delivered/acknowledged: ack firmato dal companion")
                        } else if legacyOK {
                            self.removePendingSession(id: session.id)
                            self.acknowledgedTransferCount += 1
                            self.lastSyncStatus = String(localized: "Delivered/acknowledged: ack legacy (companion da aggiornare)")
                        } else {
                            self.failedTransferCount += 1
                            self.lastSyncStatus = String(localized: "Failed: iPhone non ha confermato import; pending conservato")
                        }
                    }
                } errorHandler: { [weak self] error in
                    Task { @MainActor in
                        guard let self else { return }
                        self.failedTransferCount += 1
                        self.lastSyncStatus = String(format: String(localized: "Failed: diretto non riuscito; sent via coda, ack pending: %@"), error.localizedDescription)
                        self.sentTransferCount += 1
                        WCSession.default.transferUserInfo(envelope.message)
                    }
                }
                sentTransferCount += 1
                lastSyncStatus = String(localized: "Sent: messaggio diretto inviato, attendo ack")
            } else {
                WCSession.default.transferUserInfo(envelope.message)
                sentTransferCount += 1
                lastSyncStatus = String(localized: "Sent: coda WatchConnectivity, ack pending")
            }
        } catch WatchDiveSyncError.missingPeerSecret {
            enqueuePendingSession(session)
            WatchSyncAuth.publishSharedSecretIfNeeded()
            lastSyncStatus = String(localized: "Pending: in attesa chiave sync companion")
        } catch {
            failedTransferCount += 1
            lastSyncStatus = String(format: String(localized: "Failed: errore codifica sync: %@"), error.localizedDescription)
            Self.logger.error("Watch sync encode failed: \(error.localizedDescription, privacy: .private)")
        }
    }

    private func enqueuePendingSession(_ session: DiveSession) {
        pendingSessions.removeAll { $0.id == session.id }
        pendingSessions.append(session)
        pendingSessions = pendingSessions.sorted { $0.startDate > $1.startDate }
        pendingTransferCount = pendingSessions.count
        savePendingSessions()
    }

    private func removePendingSession(id: UUID) {
        pendingSessions.removeAll { $0.id == id }
        pendingTransferCount = pendingSessions.count
        savePendingSessions()
    }

    private func pendingFileURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(pendingFileName)
    }

    private func loadPendingSessions() -> [DiveSession] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let url = pendingFileURL()
        if FileManager.default.fileExists(atPath: url.path),
           let data = try? Data(contentsOf: url),
           let decoded = try? decoder.decode([DiveSession].self, from: data) {
            return decoded
        }

        guard let legacyData = UserDefaults.standard.data(forKey: legacyPendingSessionsKey) else { return [] }
        let migrated = (try? decoder.decode([DiveSession].self, from: legacyData)) ?? []
        if !migrated.isEmpty {
            persistPendingSessions(migrated)
        }
        UserDefaults.standard.removeObject(forKey: legacyPendingSessionsKey)
        return migrated
    }

    private func savePendingSessions() {
        persistPendingSessions(pendingSessions)
    }

    private func persistPendingSessions(_ value: [DiveSession]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(value) else { return }
        do {
            try data.write(to: pendingFileURL(), options: [.atomic, .completeFileProtection])
        } catch {
            Self.logger.error("Persist watch-sync pending sessions failed: \(error.localizedDescription, privacy: .private)")
        }
    }
}

extension WatchSyncService: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        let context = session.receivedApplicationContext
        Task { @MainActor in
            self.activationState = activationState
            self.lastSyncStatus = error?.localizedDescription ?? String(localized: "Companion sync attivo")
            if activationState == .activated {
                self.ingestCompanionContext(context)
                WatchSyncAuth.publishSharedSecretIfNeeded()
                self.flushPendingTransfers()
            }
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor in
            self.ingestCompanionContext(applicationContext)
            self.flushPendingTransfers()
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        Task { @MainActor in
            self.ingestIncomingPayload(message)
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        Task { @MainActor in
            self.ingestIncomingPayload(message)
            replyHandler(["status": "acknowledged"])
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        Task { @MainActor in
            self.ingestIncomingPayload(userInfo)
        }
    }

    nonisolated func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        Task { @MainActor in
            if let error {
                self.failedTransferCount += 1
                self.lastSyncStatus = String(format: String(localized: "Failed: transferUserInfo non completato: %@"), error.localizedDescription)
            } else {
                self.lastSyncStatus = String(localized: "Sent: transferUserInfo completato, ack companion non confermato")
            }
        }
    }
}
