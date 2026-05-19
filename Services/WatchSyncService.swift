import Foundation
import Combine
import WatchConnectivity
import os

@MainActor
final class WatchSyncService: NSObject, ObservableObject {
    static let shared = WatchSyncService()

    @Published private(set) var isSupported = WCSession.isSupported()
    @Published private(set) var activationState: WCSessionActivationState = .notActivated
    @Published private(set) var lastSyncStatus = "Companion non sincronizzato"
    @Published private(set) var pendingTransferCount = 0
    @Published private(set) var sentTransferCount = 0
    @Published private(set) var acknowledgedTransferCount = 0
    @Published private(set) var failedTransferCount = 0
    @Published private(set) var lastRetryDate: Date?

    private var pendingSessions: [DiveSession] = []

    // F9: persist the pending queue to a Documents/ file with `.completeFileProtection`
    // rather than UserDefaults, because each entry is a full DiveSession including
    // GPS coordinates. The legacy UserDefaults key is migrated once on init.
    private let legacyPendingSessionsKey = "dirdiving_watch_pending_sync_sessions"
    private let pendingFileName = "dirdiving_watch_pending_sync_sessions.json"

    private var peerSecretObserver: NSObjectProtocol?

    private static let logger = Logger(subsystem: "com.egopfe.dirdiving", category: "WatchSyncService")

    private override init() {
        super.init()
        pendingSessions = loadPendingSessions()
        pendingTransferCount = pendingSessions.count
        peerSecretObserver = NotificationCenter.default.addObserver(
            forName: .watchSyncPeerSecretDidUpdate,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.flushPendingTransfers() }
        }
        activate()
    }

    deinit {
        if let peerSecretObserver {
            NotificationCenter.default.removeObserver(peerSecretObserver)
        }
    }

    func activate() {
        guard WCSession.isSupported() else {
            lastSyncStatus = "WatchConnectivity non supportato"
            return
        }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func transfer(_ session: DiveSession) {
        guard WCSession.isSupported() else { return }
        enqueuePendingSession(session)

        if WatchSyncAuth.hasPeerSecret() {
            flushPendingTransfers()
        } else {
            WatchSyncAuth.publishSharedSecretIfNeeded()
            lastSyncStatus = "Pending: in attesa chiave sync (\(pendingTransferCount) in coda)"
        }
    }

    func retryPendingTransfers() {
        lastRetryDate = Date()
        guard WCSession.isSupported() else {
            failedTransferCount += 1
            lastSyncStatus = "Retry non disponibile: WatchConnectivity non supportato"
            return
        }
        activate()
        WatchSyncAuth.publishSharedSecretIfNeeded()
        if WatchSyncAuth.hasPeerSecret() {
            flushPendingTransfers()
        } else {
            lastSyncStatus = "Retry richiesto: in attesa chiave companion (\(pendingTransferCount) in coda)"
        }
    }

    func clearFailedQueue() {
        pendingSessions.removeAll()
        pendingTransferCount = 0
        sentTransferCount = 0
        acknowledgedTransferCount = 0
        failedTransferCount = 0
        savePendingSessions()
        lastSyncStatus = "Coda sync cancellata su richiesta"
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
                        // F11: prefer the cryptographic ack. Fall back to the legacy
                        // `status == acknowledged` only when the signature is absent,
                        // so this rollout stays compatible with older iOS builds.
                        // TODO(F11-followup): require the signed ack and treat the
                        // legacy path as `failed` once the iOS floor build is bumped.
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
                            self.lastSyncStatus = "Delivered/acknowledged: ack firmato dal companion"
                        } else if legacyOK {
                            self.removePendingSession(id: session.id)
                            self.acknowledgedTransferCount += 1
                            self.lastSyncStatus = "Delivered/acknowledged: ack legacy (companion da aggiornare)"
                        } else {
                            self.failedTransferCount += 1
                            self.lastSyncStatus = "Failed: iPhone non ha confermato import; pending conservato"
                        }
                    }
                } errorHandler: { [weak self] error in
                    Task { @MainActor in
                        guard let self else { return }
                        self.failedTransferCount += 1
                        self.lastSyncStatus = "Failed: diretto non riuscito; sent via coda, ack pending: \(error.localizedDescription)"
                        self.sentTransferCount += 1
                        WCSession.default.transferUserInfo(envelope.message)
                    }
                }
                sentTransferCount += 1
                lastSyncStatus = "Sent: messaggio diretto inviato, attendo ack"
            } else {
                WCSession.default.transferUserInfo(envelope.message)
                sentTransferCount += 1
                lastSyncStatus = "Sent: coda WatchConnectivity, ack pending"
            }
        } catch WatchDiveSyncError.missingPeerSecret {
            enqueuePendingSession(session)
            WatchSyncAuth.publishSharedSecretIfNeeded()
            lastSyncStatus = "Pending: in attesa chiave sync companion"
        } catch {
            failedTransferCount += 1
            lastSyncStatus = "Failed: errore codifica sync: \(error.localizedDescription)"
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

        // F9 migration: read once from UserDefaults, persist to the protected
        // file, then drop the legacy key so PII no longer lives in UserDefaults.
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
        Task { @MainActor in
            self.activationState = activationState
            self.lastSyncStatus = error?.localizedDescription ?? "Companion sync attivo"
            if activationState == .activated {
                WatchSyncAuth.ingestSharedSecretFromContext(session.receivedApplicationContext)
                WatchSyncAuth.publishSharedSecretIfNeeded()
                self.flushPendingTransfers()
            }
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor in
            WatchSyncAuth.ingestSharedSecretFromContext(applicationContext)
            self.flushPendingTransfers()
        }
    }

    nonisolated func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        Task { @MainActor in
            if let error {
                self.failedTransferCount += 1
                self.lastSyncStatus = "Failed: transferUserInfo non completato: \(error.localizedDescription)"
            } else {
                self.lastSyncStatus = "Sent: transferUserInfo completato, ack companion non confermato"
            }
        }
    }
}
