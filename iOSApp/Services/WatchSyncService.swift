import Foundation
import Combine
import WatchConnectivity

@MainActor
final class WatchSyncService: NSObject, ObservableObject {
    @Published var isSupported = WCSession.isSupported()
    @Published var activationState: WCSessionActivationState = .notActivated
    @Published var lastMessage = "Non sincronizzato"
    @Published var experimentalImportCount = 0
    @Published var experimentalImportStatus = "Nessun payload experimental ricevuto"
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
        if importExperimentalPayload(payload) {
            return
        }
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

    private func importExperimentalPayload(_ payload: [String: Any]) -> Bool {
        guard let envelope = payload["dirdivingExperimentalSync"] as? [String: Any],
              let kind = envelope["kind"] as? String else {
            return false
        }
        experimentalImportCount += 1
        experimentalImportStatus = "Ricevuto \(kind). Import completo/merge LAB."
        lastMessage = "Contratto experimental ricevuto: \(kind)"
        return true
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

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        Task { @MainActor in
            self.importSessionPayload(message)
            replyHandler([
                "ack": true,
                "experimentalImportCount": self.experimentalImportCount,
                "status": self.experimentalImportStatus
            ])
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
