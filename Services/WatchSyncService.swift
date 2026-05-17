import Foundation
import Combine
import WatchConnectivity

@MainActor
final class WatchSyncService: NSObject, ObservableObject {
    static let shared = WatchSyncService()

    @Published private(set) var isSupported = WCSession.isSupported()
    @Published private(set) var activationState: WCSessionActivationState = .notActivated
    @Published private(set) var lastSyncStatus = "Companion non sincronizzato"
    @Published private(set) var pendingTransferCount = 0

    private var pendingSessions: [DiveSession] = []
    private let pendingSessionsKey = "dirdiving_watch_pending_sync_sessions"
    private var peerSecretObserver: NSObjectProtocol?

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

        if WatchSyncAuth.hasPeerSecret() {
            send(session)
        } else {
            pendingSessions.append(session)
            pendingSessions = pendingSessions.sorted { $0.startDate > $1.startDate }
            pendingTransferCount = pendingSessions.count
            savePendingSessions()
            WatchSyncAuth.publishSharedSecretIfNeeded()
            lastSyncStatus = "In attesa chiave sync (\(pendingSessions.count) in coda)"
        }
    }

    func retryPendingTransfers() {
        guard WCSession.isSupported() else {
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

    private func flushPendingTransfers() {
        guard WatchSyncAuth.hasPeerSecret(), !pendingSessions.isEmpty else { return }
        let queue = pendingSessions
        pendingSessions.removeAll()
        pendingTransferCount = 0
        savePendingSessions()
        for session in queue.reversed() {
            send(session)
        }
    }

    private func send(_ session: DiveSession) {
        do {
            let payload = try WatchDiveSyncCodec.makePayload(session: session)

            if WCSession.default.isReachable {
                WCSession.default.sendMessage(payload, replyHandler: nil) { [weak self] error in
                    Task { @MainActor in
                        self?.lastSyncStatus = "Sync diretto fallito; invio in coda: \(error.localizedDescription)"
                        WCSession.default.transferUserInfo(payload)
                    }
                }
                lastSyncStatus = "Immersione inviata al companion"
            } else {
                WCSession.default.transferUserInfo(payload)
                lastSyncStatus = "Immersione in coda per il companion"
            }
        } catch WatchDiveSyncError.missingPeerSecret {
            pendingSessions.insert(session, at: 0)
            pendingTransferCount = pendingSessions.count
            savePendingSessions()
            WatchSyncAuth.publishSharedSecretIfNeeded()
            lastSyncStatus = "In attesa chiave sync companion"
        } catch {
            lastSyncStatus = "Errore codifica sync: \(error.localizedDescription)"
        }
    }

    private func loadPendingSessions() -> [DiveSession] {
        guard let data = UserDefaults.standard.data(forKey: pendingSessionsKey) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([DiveSession].self, from: data)) ?? []
    }

    private func savePendingSessions() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(pendingSessions) {
            UserDefaults.standard.set(data, forKey: pendingSessionsKey)
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
}
