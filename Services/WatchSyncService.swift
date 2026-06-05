import Foundation
import Combine
import WatchConnectivity
import os

@MainActor
final class WatchSyncService: NSObject, ObservableObject {
    static let shared = WatchSyncService()

    struct SyncActivityItem: Identifiable, Hashable {
        let id = UUID()
        let title: String
        let detail: String
        let timestamp: Date
    }

    @Published private(set) var isSupported = WCSession.isSupported()
    @Published private(set) var activationState: WCSessionActivationState = .notActivated
    @Published private(set) var lastSyncStatus = String(localized: "Companion non sincronizzato")
    @Published private(set) var pendingTransferCount = 0
    @Published private(set) var sentTransferCount = 0
    @Published private(set) var acknowledgedTransferCount = 0
    @Published private(set) var failedTransferCount = 0
    @Published private(set) var lastRetryDate: Date?
    @Published private(set) var importedFromCompanionCount = 0
    @Published private(set) var recentActivity: [SyncActivityItem] = []
    @Published private(set) var experimentalQueueCount = 0
    @Published private(set) var experimentalLastKind = "--"
    @Published private(set) var experimentalDeliveryState = "Nessun payload experimental"

    private var pendingSessions: [DiveSession] = []
    private var pendingExperimentalEnvelopes: [ExperimentalSyncEnvelope] = []
    private let legacyPendingSessionsKey = "dirdiving_watch_pending_sync_sessions"
    private let pendingFileName = "dirdiving_watch_pending_sync_sessions.json"
    private weak var logStore: DiveLogStore?
    private var importedFromCompanionIDs: Set<UUID> = []
    private var peerSecretObserver: NSObjectProtocol?

    private static let logger = Logger(subsystem: "com.egopfe.dirdiving", category: "WatchSyncService")
    private static let activityDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM HH:mm"
        return formatter
    }()

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
        recordActivity(title: String(localized: "sync.activity.pending_to_iphone"), detail: sessionSummary(session))

        if WatchSyncAuth.hasPeerSecret() {
            flushPendingTransfers()
        } else {
            WatchSyncAuth.publishSharedSecretIfNeeded()
            lastSyncStatus = String(format: String(localized: "Pending: in attesa chiave sync (%lld in coda)"), pendingTransferCount)
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

    /// Broadcast tombstone UUIDs to iPhone via applicationContext (merge-safe).
    func publishDeletedSessionIDs(_ ids: Set<UUID>) {
        guard WCSession.isSupported(), !ids.isEmpty else { return }
        var existing = Set((WCSession.default.applicationContext[WatchSyncKeys.deletedSessionBroadcastKey] as? [String]) ?? [])
        existing.formUnion(ids.map(\.uuidString))
        WatchSyncAuth.mergeApplicationContext([WatchSyncKeys.deletedSessionBroadcastKey: Array(existing)])
        lastSyncStatus = String(format: String(localized: "Tombstone inviata a iPhone (%lld)"), ids.count)
    }

    func publishUnitsPreference(_ value: String) {
        guard DIRUnitPreference(rawValue: value) != nil else { return }
        guard WCSession.isSupported() else { return }
        WatchSyncAuth.mergeApplicationContext([WatchSyncKeys.unitsPreferenceKey: value])
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
        pendingExperimentalEnvelopes.removeAll()
        experimentalQueueCount = 0
        experimentalLastKind = "--"
        experimentalDeliveryState = "Nessun payload experimental"
        savePendingSessions()
        lastSyncStatus = String(localized: "Coda sync cancellata su richiesta")
    }

    private struct AckContext {
        let sessionID: UUID
        let issuedAt: Date
    }

    func publishUploadedImageInventory(requestID: String? = nil) {
        guard WCSession.isSupported(), activationState == .activated else { return }
        let payload = CompanionPhotoManagementSupport.makeInventoryResponsePayload(
            requestID: requestID,
            items: UserImageStore.buildUploadedInventory()
        )
        deliverCompanionManagementPayload(payload)
    }

    @discardableResult
    private func handleCompanionManagementPayload(
        _ payload: [String: Any],
        replyHandler: (([String: Any]) -> Void)? = nil
    ) -> Bool {
        if CompanionPhotoManagementSupport.isInventoryRequest(payload) {
            let requestID = payload[WatchSyncKeys.companionPhotoInventoryRequestIDKey] as? String
            let response = CompanionPhotoManagementSupport.makeInventoryResponsePayload(
                requestID: requestID,
                items: UserImageStore.buildUploadedInventory()
            )
            if let replyHandler {
                replyHandler(response)
            } else {
                deliverCompanionManagementPayload(response)
            }
            return true
        }
        if CompanionPhotoManagementSupport.isDeleteRequest(payload) {
            handleDeleteRequest(payload)
            replyHandler?(["status": "acknowledged"])
            return true
        }
        return false
    }

    private func handleDeleteRequest(_ payload: [String: Any]) {
        guard let requestID = payload[WatchSyncKeys.companionPhotoDeleteRequestIDKey] as? String,
              !requestID.isEmpty,
              let storedFileName = payload[WatchSyncKeys.companionPhotoDeleteFileNameKey] as? String else {
            return
        }
        do {
            let deletedName = try UserImageStore.deleteUploadedImage(named: storedFileName)
            deliverDeleteAck(
                requestID: requestID,
                storedFileName: deletedName,
                status: CompanionPhotoManagementSupport.deleteStatusDeleted
            )
            publishUploadedImageInventory()
        } catch let error as UserImageStore.DeleteError {
            deliverDeleteAck(
                requestID: requestID,
                storedFileName: storedFileName,
                status: CompanionPhotoManagementSupport.deleteStatus(for: error),
                errorCode: CompanionPhotoManagementSupport.deleteErrorCode(for: error)
            )
        } catch {
            deliverDeleteAck(
                requestID: requestID,
                storedFileName: storedFileName,
                status: CompanionPhotoManagementSupport.deleteStatusFailed,
                errorCode: "unknown"
            )
        }
    }

    private func deliverDeleteAck(
        requestID: String,
        storedFileName: String,
        status: String,
        errorCode: String? = nil
    ) {
        guard WCSession.isSupported(), activationState == .activated else { return }
        let payload = CompanionPhotoManagementSupport.makeDeleteAckPayload(
            requestID: requestID,
            storedFileName: storedFileName,
            status: status,
            errorCode: errorCode
        )
        deliverCompanionManagementPayload(payload)
    }

    private func deliverCompanionManagementPayload(_ payload: [String: Any]) {
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(payload, replyHandler: nil) { _ in
                session.transferUserInfo(payload)
            }
        } else {
            session.transferUserInfo(payload)
        }
    }

    @discardableResult
    private func ingestIncomingPayload(_ payload: [String: Any]) -> AckContext? {
        if handleCompanionManagementPayload(payload) {
            return nil
        }
        do {
            let parsed = try WatchDiveSyncCodec.parsePayload(from: payload)
            let session = parsed.session
            if logStore?.isDeleted(id: session.id) == true {
                rememberCompanionSession(id: session.id)
                lastSyncStatus = String(localized: "Import iPhone ignorato: tombstone presente")
                return AckContext(sessionID: session.id, issuedAt: parsed.issuedAt)
            }
            if importedFromCompanionIDs.contains(session.id) {
                lastSyncStatus = String(localized: "Immersione iPhone duplicata ignorata")
                return AckContext(sessionID: session.id, issuedAt: parsed.issuedAt)
            }
            guard let logStore else {
                failedTransferCount += 1
                lastSyncStatus = String(localized: "Errore import iPhone: log store non disponibile")
                return nil
            }
            rememberCompanionSession(id: session.id)
            logStore.addFromCompanion(session)
            lastSyncStatus = String(localized: "Immersione ricevuta da iPhone")
            recordActivity(title: String(localized: "sync.activity.received_from_iphone"), detail: sessionSummary(session))
            return AckContext(sessionID: session.id, issuedAt: parsed.issuedAt)
        } catch {
            failedTransferCount += 1
            lastSyncStatus = String(format: String(localized: "Errore import iPhone: %@"), error.localizedDescription)
            Self.logger.error("Watch import from companion failed: \(error.localizedDescription, privacy: .private)")
            return nil
        }
    }

    private func rememberCompanionSession(id: UUID) {
        importedFromCompanionIDs.insert(id)
        importedFromCompanionCount = importedFromCompanionIDs.count
        WatchDiveSyncCodec.saveImportedFromCompanionIDs(importedFromCompanionIDs)
    }

    private func ingestCompanionContext(_ context: [String: Any]) {
        switch WatchSyncAuth.ingestSharedSecretFromContext(context) {
        case .rejectedMismatch:
            lastSyncStatus = String(localized: "sync.trust.mismatch")
        case .acceptedFirstTrust, .unchanged:
            break
        }
        if let units = context[WatchSyncKeys.unitsPreferenceKey] as? String,
           DIRUnitPreference(rawValue: units) != nil {
            UserDefaults.standard.set(units, forKey: DIRUnitPreference.storageKey)
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
        Self.logger.info("Flushing \(queue.count, privacy: .public) pending Watch→iPhone session(s)")
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
                        if signedOK {
                            self.removePendingSession(id: session.id)
                            self.acknowledgedTransferCount += 1
                            self.lastSyncStatus = String(localized: "Delivered/acknowledged: ack firmato dal companion")
                            self.recordActivity(title: String(localized: "sync.activity.delivered_to_iphone"), detail: self.sessionSummary(session))
                        } else {
                            self.failedTransferCount += 1
                            self.lastSyncStatus = String(localized: "Failed: iPhone non ha confermato con ack firmato; pending conservato")
                        }
                    }
                } errorHandler: { [weak self] error in
                    Task { @MainActor in
                        guard let self else { return }
                        self.failedTransferCount += 1
                        self.lastSyncStatus = String(format: String(localized: "Failed: diretto non riuscito; sent via coda, ack pending: %@"), error.localizedDescription)
                        self.sentTransferCount += 1
                        WCSession.default.transferUserInfo(envelope.message)
                        self.recordActivity(title: String(localized: "sync.activity.queued_to_iphone"), detail: self.sessionSummary(session))
                    }
                }
                sentTransferCount += 1
                lastSyncStatus = String(localized: "Sent: messaggio diretto inviato, attendo ack")
                recordActivity(title: String(localized: "sync.activity.sent_to_iphone"), detail: sessionSummary(session))
            } else {
                WCSession.default.transferUserInfo(envelope.message)
                sentTransferCount += 1
                lastSyncStatus = String(localized: "Sent: coda WatchConnectivity, ack pending")
                recordActivity(title: String(localized: "sync.activity.queued_to_iphone"), detail: sessionSummary(session))
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
        let normalizedSession = DiveSessionMerge.preferred(session, session)
        pendingSessions.removeAll { $0.id == normalizedSession.id }
        pendingSessions.append(normalizedSession)
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
            return decoded.map { DiveSessionMerge.preferred($0, $0) }
        }

        guard let legacyData = UserDefaults.standard.data(forKey: legacyPendingSessionsKey) else { return [] }
        let migrated = ((try? decoder.decode([DiveSession].self, from: legacyData)) ?? [])
            .map { DiveSessionMerge.preferred($0, $0) }
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
        let normalizedValue = value.map { DiveSessionMerge.preferred($0, $0) }
        guard let data = try? encoder.encode(normalizedValue) else { return }
        do {
            try data.write(to: pendingFileURL(), options: [.atomic, .completeFileProtection])
        } catch {
            Self.logger.error("Persist watch-sync pending sessions failed: \(error.localizedDescription, privacy: .private)")
        }
    }

    private func importCompanionPhoto(from sourceURL: URL, metadata: [String: Any]) {
        let photoID = metadata[WatchSyncKeys.companionPhotoIDKey] as? String
        let fileName = (metadata[WatchSyncKeys.companionPhotoFileNameKey] as? String)
            ?? sourceURL.lastPathComponent
        guard FileManager.default.fileExists(atPath: sourceURL.path) else {
            deliverCompanionPhotoAck(
                photoID: photoID,
                status: CompanionPhotoImportSupport.ackStatusRejected,
                errorCode: "missingFile"
            )
            return
        }
        do {
            let storedFileName = try UserImageStore.importCompanionPhoto(from: sourceURL, fileName: fileName)
            lastSyncStatus = String(localized: "Foto iPhone ricevuta")
            recordActivity(title: String(localized: "sync.activity.photo_from_iphone"), detail: storedFileName)
            deliverCompanionPhotoAck(
                photoID: photoID,
                status: CompanionPhotoImportSupport.ackStatusImported,
                storedFileName: storedFileName
            )
            publishUploadedImageInventory()
        } catch {
            lastSyncStatus = String(localized: "Errore foto iPhone")
            deliverCompanionPhotoAck(
                photoID: photoID,
                status: CompanionPhotoImportSupport.ackStatusRejected,
                errorCode: CompanionPhotoImportSupport.errorCode(for: error)
            )
        }
    }

    private func rejectCompanionPhoto(metadata: [String: Any], errorCode: String) {
        let photoID = metadata[WatchSyncKeys.companionPhotoIDKey] as? String
        lastSyncStatus = String(localized: "Errore foto iPhone")
        deliverCompanionPhotoAck(
            photoID: photoID,
            status: CompanionPhotoImportSupport.ackStatusRejected,
            errorCode: errorCode
        )
    }

    /// Copies the incoming WCSession file before the delegate returns — the system deletes `file.fileURL` afterward.
    nonisolated private static func stageIncomingCompanionPhoto(_ file: WCSessionFile) -> (url: URL, metadata: [String: Any])? {
        let metadata = file.metadata ?? [:]
        let sourceURL = file.fileURL
        guard FileManager.default.fileExists(atPath: sourceURL.path) else { return nil }

        let stagingURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("DIRDivingIncomingPhoto_\(UUID().uuidString)_\(sourceURL.lastPathComponent)")
        do {
            if FileManager.default.fileExists(atPath: stagingURL.path) {
                try FileManager.default.removeItem(at: stagingURL)
            }
            try FileManager.default.copyItem(at: sourceURL, to: stagingURL)
            return (stagingURL, metadata)
        } catch {
            return nil
        }
    }

    private func deliverCompanionPhotoAck(
        photoID: String?,
        status: String,
        storedFileName: String? = nil,
        errorCode: String? = nil
    ) {
        guard let photoID, !photoID.isEmpty else { return }
        guard WCSession.isSupported() else { return }

        let payload = CompanionPhotoImportSupport.makeAckPayload(
            photoID: photoID,
            status: status,
            storedFileName: storedFileName,
            errorCode: errorCode
        )
        let session = WCSession.default
        if activationState == .activated, session.isReachable {
            session.sendMessage(payload, replyHandler: nil) { [weak self] _ in
                Task { @MainActor in
                    session.transferUserInfo(payload)
                    self?.recordActivity(
                        title: String(localized: "sync.activity.photo_from_iphone"),
                        detail: "ack:\(status)"
                    )
                }
            }
        } else {
            session.transferUserInfo(payload)
        }
    }

    private func sessionSummary(_ session: DiveSession) -> String {
        let started = Self.activityDateFormatter.string(from: session.startDate)
        let minutes = Int((session.durationSeconds / 60).rounded())
        return "\(started) · \(Formatters.one(session.maxDepthMeters)) m · \(minutes) min"
    }

    private func recordActivity(title: String, detail: String) {
        let normalizedDetail = detail.isEmpty ? "—" : detail
        recentActivity.insert(
            SyncActivityItem(title: title, detail: normalizedDetail, timestamp: Date()),
            at: 0
        )
        recentActivity = Array(recentActivity.prefix(6))
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
            if self.handleCompanionManagementPayload(message, replyHandler: replyHandler) {
                return
            }
            if let ackContext = self.ingestIncomingPayload(message) {
                replyHandler([
                    "status": "acknowledged",
                    "ackSignature": WatchDiveSyncCodec.ackSignature(
                        sessionID: ackContext.sessionID,
                        issuedAt: ackContext.issuedAt
                    )
                ])
            } else {
                replyHandler(["status": "failed"])
            }
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

    nonisolated func session(_ session: WCSession, didReceive file: WCSessionFile) {
        let staged = Self.stageIncomingCompanionPhoto(file)
        Task { @MainActor in
            guard let staged else {
                self.rejectCompanionPhoto(metadata: file.metadata ?? [:], errorCode: "missingFile")
                return
            }
            defer { try? FileManager.default.removeItem(at: staged.url) }
            self.importCompanionPhoto(from: staged.url, metadata: staged.metadata)
        }
    }
}
