import Foundation
import Combine
import WatchConnectivity

@MainActor
final class WatchSyncService: NSObject, ObservableObject {
    static let shared = WatchSyncService()

    @Published private(set) var isSupported = WCSession.isSupported()
    @Published private(set) var activationState: WCSessionActivationState = .notActivated
    @Published private(set) var lastSyncStatus = "Companion non sincronizzato"
    @Published private(set) var experimentalQueueCount = 0
    @Published private(set) var experimentalLastKind = "--"
    @Published private(set) var experimentalDeliveryState = "Nessun payload experimental"

    private var pendingSessions: [DiveSession] = []
    private var pendingExperimentalEnvelopes: [ExperimentalSyncEnvelope] = []
    private var peerSecretObserver: NSObjectProtocol?

    private override init() {
        super.init()
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
            WatchSyncAuth.publishSharedSecretIfNeeded()
            lastSyncStatus = "In attesa chiave sync (\(pendingSessions.count) in coda)"
        }
    }

    func transferExperimentalPOI(_ marker: GPSInterestMarker) {
        var payload: [String: String] = [
            "id": marker.id.uuidString,
            "category": marker.category.rawValue,
            "timestamp": Self.isoFormatter.string(from: marker.timestamp),
            "depthMeters": String(marker.depthMeters),
            "distanceFromEntryMeters": String(marker.distanceFromEntryMeters),
            "bearingDegrees": String(marker.bearingDegrees),
            "isEnriched": String(marker.isEnriched)
        ]
        if let latitude = marker.latitude { payload["latitude"] = String(latitude) }
        if let longitude = marker.longitude { payload["longitude"] = String(longitude) }
        if let temperature = marker.temperatureCelsius { payload["temperatureCelsius"] = String(temperature) }
        if let waypoint = marker.activeWaypointName { payload["activeWaypointName"] = waypoint }
        if let sessionID = marker.sessionID { payload["sessionID"] = sessionID }
        transferExperimentalEnvelope(ExperimentalSyncEnvelope(kind: .watchPOI, payload: payload))
    }

    func transferExperimentalApneaRecord(_ record: ApneaDiveRecord) {
        let payload = [
            "id": record.id.uuidString,
            "durationSeconds": String(record.durationSeconds),
            "maxDepthMeters": String(record.maxDepthMeters),
            "recoverySeconds": String(record.recoverySeconds)
        ]
        transferExperimentalEnvelope(ExperimentalSyncEnvelope(kind: .watchApneaRecord, payload: payload))
    }

    private func flushPendingTransfers() {
        guard WatchSyncAuth.hasPeerSecret(), !pendingSessions.isEmpty else { return }
        let queue = pendingSessions
        pendingSessions.removeAll()
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
                        self?.lastSyncStatus = "Sync diretto non riuscito: \(error.localizedDescription)"
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
            WatchSyncAuth.publishSharedSecretIfNeeded()
            lastSyncStatus = "In attesa chiave sync companion"
        } catch {
            lastSyncStatus = "Errore codifica sync: \(error.localizedDescription)"
        }
    }

    private func transferExperimentalEnvelope(_ envelope: ExperimentalSyncEnvelope) {
        experimentalLastKind = envelope.kind.rawValue
        guard WCSession.isSupported() else {
            lastSyncStatus = "Sync sperimentale non supportato"
            experimentalDeliveryState = "WatchConnectivity non supportato"
            return
        }
        do {
            let payload = try envelope.userInfo()
            if WCSession.default.isReachable {
                WCSession.default.sendMessage(payload, replyHandler: { [weak self] _ in
                    Task { @MainActor in
                        self?.experimentalDeliveryState = "ACK companion ricevuto"
                    }
                }) { [weak self] error in
                    Task { @MainActor in
                        self?.queueExperimentalEnvelope(envelope, reason: error.localizedDescription)
                        WCSession.default.transferUserInfo(payload)
                    }
                }
                lastSyncStatus = "Sync sperimentale inviato: \(envelope.kind.rawValue)"
                experimentalDeliveryState = "Invio diretto tentato"
            } else {
                queueExperimentalEnvelope(envelope, reason: "Companion non raggiungibile")
                WCSession.default.transferUserInfo(payload)
                lastSyncStatus = "Sync sperimentale in coda: \(envelope.kind.rawValue)"
            }
        } catch {
            lastSyncStatus = "Errore contratto sync sperimentale: \(error.localizedDescription)"
            experimentalDeliveryState = "Errore codifica payload"
        }
    }

    private func queueExperimentalEnvelope(_ envelope: ExperimentalSyncEnvelope, reason: String) {
        pendingExperimentalEnvelopes.insert(envelope, at: 0)
        pendingExperimentalEnvelopes = Array(pendingExperimentalEnvelopes.prefix(20))
        experimentalQueueCount = pendingExperimentalEnvelopes.count
        experimentalLastKind = envelope.kind.rawValue
        experimentalDeliveryState = "In coda: \(reason)"
    }

    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
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
