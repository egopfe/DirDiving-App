import Foundation
import Combine
import WatchConnectivity

@MainActor
final class WatchSyncService: NSObject, ObservableObject {
    static let shared = WatchSyncService()

    @Published private(set) var isSupported = WCSession.isSupported()
    @Published private(set) var activationState: WCSessionActivationState = .notActivated
    @Published private(set) var lastSyncStatus = "Companion non sincronizzato"

    private let sessionPayloadKey = "dirdiving_dive_session"

    private override init() {
        super.init()
        activate()
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

        do {
            let payload = try WatchDiveSyncCodec.makePayload(session: session)

            if WCSession.default.isReachable {
                WCSession.default.sendMessage(payload, replyHandler: nil) { [weak self] error in
                    Task { @MainActor in
                        self?.lastSyncStatus = "Sync diretto non riuscito: \(error.localizedDescription)"
                        WCSession.default.transferUserInfo(payload)
                    }
                }
                lastSyncStatus = "Immersione inviata al companion"
            } else {
                WCSession.default.transferUserInfo(payload)
                lastSyncStatus = "Immersione in coda per il companion"
            }
        } catch {
            lastSyncStatus = "Errore codifica sync: \(error.localizedDescription)"
        }
    }
}

extension WatchSyncService: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            self.activationState = activationState
            self.lastSyncStatus = error?.localizedDescription ?? "Companion sync attivo"
            if activationState == .activated {
                WatchSyncAuth.publishSharedSecretIfNeeded()
            }
        }
    }
}
