import Foundation
import Combine
import WatchConnectivity

@MainActor
final class WatchSyncService: NSObject, ObservableObject {
    @Published var isSupported = WCSession.isSupported()
    @Published var activationState: WCSessionActivationState = .notActivated
    @Published var lastMessage = "Non sincronizzato"
    private weak var logStore: DiveLogStore?
    private var importedSessionIDs: Set<UUID> = []

    func activate(logStore: DiveLogStore) {
        self.logStore = logStore
        importedSessionIDs = WatchDiveSyncCodec.loadImportedSessionIDs()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    private func importSessionPayload(_ payload: [String: Any]) {
        do {
            let session = try WatchDiveSyncCodec.parseSession(from: payload)
            guard !importedSessionIDs.contains(session.id) else { return }
            logStore?.add(session)
            importedSessionIDs.insert(session.id)
            WatchDiveSyncCodec.saveImportedSessionIDs(importedSessionIDs)
            lastMessage = "Immersione ricevuta dal Watch"
        } catch {
            lastMessage = "Errore sync Watch: \(error.localizedDescription)"
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
            }
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor in
            WatchSyncAuth.ingestSharedSecretFromContext(applicationContext)
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
