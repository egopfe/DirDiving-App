import Foundation
import Combine
import WatchConnectivity

@MainActor
final class WatchSyncService: NSObject, ObservableObject {
    @Published var isSupported = WCSession.isSupported()
    @Published var activationState: WCSessionActivationState = .notActivated
    @Published var lastMessage = "Non sincronizzato"
    private weak var logStore: DiveLogStore?
    private let sessionPayloadKey = "dirdiving_dive_session"
    private var importedSessionIDs: Set<UUID> = []

    func activate(logStore: DiveLogStore) {
        self.logStore = logStore
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    private func importSessionPayload(_ payload: [String: Any]) {
        guard let data = payload[sessionPayloadKey] as? Data else { return }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let imported = try decoder.decode(WatchDiveSessionImport.self, from: data)
            guard !importedSessionIDs.contains(imported.id) else { return }
            logStore?.add(imported.diveSession)
            importedSessionIDs.insert(imported.id)
            pruneImportedSessionIDsIfNeeded()
            lastMessage = "Immersione ricevuta dal Watch"
        } catch {
            lastMessage = "Errore sync Watch: \(error.localizedDescription)"
        }
    }

    private func pruneImportedSessionIDsIfNeeded() {
        guard importedSessionIDs.count > 64 else { return }
        importedSessionIDs = Set(importedSessionIDs.suffix(32))
    }
}

extension WatchSyncService: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            self.activationState = activationState
            self.lastMessage = error?.localizedDescription ?? "Sessione Watch attiva"
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

private struct WatchDiveSessionImport: Decodable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let durationSeconds: TimeInterval
    let maxDepthMeters: Double
    let avgDepthMeters: Double
    let avgWaterTemperatureCelsius: Double?
    let minWaterTemperatureCelsius: Double?
    let maxWaterTemperatureCelsius: Double?
    let ttv: Double
    let entryGPS: GPSPoint?
    let exitGPS: GPSPoint?
    let samples: [DiveSample]

    var diveSession: DiveSession {
        DiveSession(
            id: id,
            startDate: startDate,
            endDate: endDate,
            durationSeconds: durationSeconds,
            maxDepthMeters: maxDepthMeters,
            avgDepthMeters: avgDepthMeters,
            avgWaterTemperatureCelsius: avgWaterTemperatureCelsius,
            ttv: ttv,
            entryGPS: entryGPS,
            exitGPS: exitGPS,
            samples: samples,
            siteName: "Watch Import",
            buddy: nil,
            notes: "Imported from Apple Watch",
            gasLabel: .oc,
            sacLitersMinute: nil
        )
    }
}
