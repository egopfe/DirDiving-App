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
    @Published private(set) var lastQueuePersistenceError: String?

    private var pendingTransfers: [WatchSyncPendingTransfer] = []
    private var pendingUserInfoTransferSessionIDs: [ObjectIdentifier: UUID] = [:]
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
        pendingTransfers = loadPendingTransfers()
        pendingTransferCount = pendingTransfers.count
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
        pendingTransfers.removeAll()
        pendingUserInfoTransferSessionIDs.removeAll()
        pendingTransferCount = 0
        sentTransferCount = 0
        acknowledgedTransferCount = 0
        failedTransferCount = 0
        savePendingTransfers()
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
            guard CompanionPhotoManagementSupport.verifySignedRequest(payload) else {
                lastSyncStatus = String(localized: "sync.trust.mismatch")
                replyHandler?(["status": "rejected"])
                return true
            }
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
            guard CompanionPhotoManagementSupport.verifySignedRequest(payload) else {
                lastSyncStatus = String(localized: "sync.trust.mismatch")
                replyHandler?(["status": "rejected"])
                return true
            }
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

    private func deliverImportAck(sessionID: UUID, issuedAt: Date) {
        guard WCSession.isSupported(), activationState == .activated else { return }
        let payload = WatchDiveSyncCodec.makeImportAckPayload(sessionID: sessionID, issuedAt: issuedAt)
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
        guard WatchSyncAuth.hasPeerSecret(), !pendingTransfers.isEmpty else { return }
        let queue = pendingTransfers
        Self.logger.info("Flushing \(queue.count, privacy: .public) pending Watch→iPhone session(s)")
        for entry in queue.reversed() {
            sendQueued(entry.session)
        }
    }

    /// Removes a pending transfer after a verified signed companion ACK (direct message path).
    func confirmSignedAck(sessionID: UUID, issuedAt: Date, signature: String) {
        guard WatchDiveSyncCodec.verifyAckSignature(signature, sessionID: sessionID, issuedAt: issuedAt) else {
            failedTransferCount += 1
            lastSyncStatus = String(localized: "Failed: ack firmato non valido; pending conservato")
            return
        }
        guard pendingTransfers.contains(where: { $0.session.id == sessionID }) else { return }
        removePendingTransfer(sessionID: sessionID)
        acknowledgedTransferCount += 1
        lastSyncStatus = String(localized: "Delivered/acknowledged: ack firmato dal companion")
        recordActivity(title: String(localized: "sync.activity.delivered_to_iphone"), detail: sessionID.uuidString)
    }

    private func sendQueued(_ session: DiveSession) {
        do {
            let envelope = try WatchDiveSyncCodec.makePayload(session: session)
            recordPendingAttempt(sessionID: session.id, issuedAt: envelope.issuedAt)

            if WCSession.default.isReachable {
                WCSession.default.sendMessage(envelope.message) { [weak self] reply in
                    Task { @MainActor in
                        guard let self else { return }
                        let providedSignature = reply["ackSignature"] as? String
                        if WatchDiveSyncCodec.verifyAckSignature(
                            providedSignature,
                            sessionID: envelope.sessionID,
                            issuedAt: envelope.issuedAt
                        ) {
                            self.confirmSignedAck(
                                sessionID: envelope.sessionID,
                                issuedAt: envelope.issuedAt,
                                signature: providedSignature ?? ""
                            )
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
                        self.queueViaUserInfo(envelope: envelope, sessionID: session.id)
                        self.recordActivity(title: String(localized: "sync.activity.queued_to_iphone"), detail: self.sessionSummary(session))
                    }
                }
                sentTransferCount += 1
                lastSyncStatus = String(localized: "Sent: messaggio diretto inviato, attendo ack")
                recordActivity(title: String(localized: "sync.activity.sent_to_iphone"), detail: sessionSummary(session))
            } else {
                queueViaUserInfo(envelope: envelope, sessionID: session.id)
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

    private func queueViaUserInfo(envelope: WatchDiveSyncCodec.PayloadEnvelope, sessionID: UUID) {
        let transfer = WCSession.default.transferUserInfo(envelope.message)
        pendingUserInfoTransferSessionIDs[ObjectIdentifier(transfer)] = sessionID
        markUserInfoQueued(sessionID: sessionID)
    }

    private func recordPendingAttempt(sessionID: UUID, issuedAt: Date) {
        guard let index = pendingTransfers.firstIndex(where: { $0.session.id == sessionID }) else { return }
        pendingTransfers[index].lastIssuedAt = issuedAt
        pendingTransfers[index].lastAttemptAt = Date()
        pendingTransfers[index].attemptCount += 1
        if pendingTransfers[index].isRetentionExpired || pendingTransfers[index].exceededAttemptBudget {
            lastSyncStatus = String(localized: "sync.pending.retention_warning")
        }
        savePendingTransfers()
    }

    private func markUserInfoQueued(sessionID: UUID) {
        guard let index = pendingTransfers.firstIndex(where: { $0.session.id == sessionID }) else { return }
        pendingTransfers[index].lastAttemptAt = Date()
        savePendingTransfers()
    }

    private func markUserInfoDelivered(sessionID: UUID, error: Error?) {
        guard let index = pendingTransfers.firstIndex(where: { $0.session.id == sessionID }) else { return }
        if let error {
            failedTransferCount += 1
            lastSyncStatus = String(format: String(localized: "Failed: transferUserInfo non completato: %@"), error.localizedDescription)
            return
        }
        pendingTransfers[index].userInfoDeliveredAt = Date()
        lastSyncStatus = String(localized: "Sent: transferUserInfo completato, attendo ack firmato companion")
        savePendingTransfers()
    }

    private func enqueuePendingSession(_ session: DiveSession) {
        let normalizedSession = DiveSessionMerge.preferred(session, session)
        pendingTransfers.removeAll { $0.session.id == normalizedSession.id }
        pendingTransfers.append(WatchSyncPendingTransfer(session: normalizedSession))
        pendingTransfers = WatchSyncPendingQueuePolicy.normalizedTransfers(pendingTransfers)
        pendingTransferCount = pendingTransfers.count
        savePendingTransfers()
    }

    private func removePendingTransfer(sessionID: UUID) {
        pendingTransfers = WatchSyncPendingQueuePolicy.dequeueAfterSignedAck(
            transfers: pendingTransfers,
            sessionID: sessionID
        )
        pendingTransferCount = pendingTransfers.count
        savePendingTransfers()
    }

    private func pendingFileURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(pendingFileName)
    }

    private func loadPendingTransfers() -> [WatchSyncPendingTransfer] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let url = pendingFileURL()
        if FileManager.default.fileExists(atPath: url.path),
           let data = try? Data(contentsOf: url) {
            if let decoded = try? decoder.decode([WatchSyncPendingTransfer].self, from: data) {
                return WatchSyncPendingQueuePolicy.normalizedTransfers(decoded)
            }
            if let legacySessions = try? decoder.decode([DiveSession].self, from: data) {
                return WatchSyncPendingQueuePolicy.normalizedTransfers(
                    legacySessions.map { WatchSyncPendingTransfer(session: $0) }
                )
            }
        }

        guard let legacyData = UserDefaults.standard.data(forKey: legacyPendingSessionsKey) else { return [] }
        let migrated = ((try? decoder.decode([DiveSession].self, from: legacyData)) ?? [])
            .map { WatchSyncPendingTransfer(session: $0) }
        if !migrated.isEmpty {
            persistPendingTransfers(WatchSyncPendingQueuePolicy.normalizedTransfers(migrated))
        }
        UserDefaults.standard.removeObject(forKey: legacyPendingSessionsKey)
        return migrated
    }

    private func savePendingTransfers() {
        persistPendingTransfers(pendingTransfers)
    }

    private func persistPendingTransfers(_ value: [WatchSyncPendingTransfer]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let normalizedValue = WatchSyncPendingQueuePolicy.normalizedTransfers(value)
        guard let data = try? encoder.encode(normalizedValue) else {
            lastQueuePersistenceError = String(localized: "sync.pending.encode_failed")
            return
        }
        do {
            try data.write(to: pendingFileURL(), options: [.atomic, .completeFileProtection])
            lastQueuePersistenceError = nil
        } catch {
            lastQueuePersistenceError = error.localizedDescription
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
            lastSyncStatus = String(localized: "watch.sync.photo.received")
            recordActivity(title: String(localized: "sync.activity.photo_from_iphone"), detail: storedFileName)
            deliverCompanionPhotoAck(
                photoID: photoID,
                status: CompanionPhotoImportSupport.ackStatusImported,
                storedFileName: storedFileName
            )
            publishUploadedImageInventory()
        } catch {
            lastSyncStatus = String(localized: "watch.sync.photo.error")
            deliverCompanionPhotoAck(
                photoID: photoID,
                status: CompanionPhotoImportSupport.ackStatusRejected,
                errorCode: CompanionPhotoImportSupport.errorCode(for: error)
            )
        }
    }

    private func rejectCompanionPhoto(metadata: [String: Any], errorCode: String) {
        let photoID = metadata[WatchSyncKeys.companionPhotoIDKey] as? String
        lastSyncStatus = String(localized: "watch.sync.photo.error")
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
}

// MARK: - Algorithm test hooks

extension WatchSyncService {
    func testHook_resetPendingQueueForTests() {
        pendingTransfers = []
        pendingUserInfoTransferSessionIDs = [:]
        pendingTransferCount = 0
        acknowledgedTransferCount = 0
        failedTransferCount = 0
        sentTransferCount = 0
        lastQueuePersistenceError = nil
        savePendingTransfers()
    }

    var testHook_pendingSessionIDs: [UUID] {
        pendingTransfers.map(\.session.id)
    }

    var testHook_pendingTransfers: [WatchSyncPendingTransfer] {
        pendingTransfers
    }

    func testHook_enqueueSession(_ session: DiveSession) {
        enqueuePendingSession(session)
    }

    func testHook_confirmSignedAck(sessionID: UUID, issuedAt: Date, signature: String) {
        confirmSignedAck(sessionID: sessionID, issuedAt: issuedAt, signature: signature)
    }

    func testHook_markUserInfoDelivered(sessionID: UUID, error: Error?) {
        markUserInfoDelivered(sessionID: sessionID, error: error)
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
            if let ackContext = self.ingestIncomingPayload(userInfo) {
                self.deliverImportAck(sessionID: ackContext.sessionID, issuedAt: ackContext.issuedAt)
            }
        }
    }

    nonisolated func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        Task { @MainActor in
            let sessionID = self.pendingUserInfoTransferSessionIDs.removeValue(forKey: ObjectIdentifier(userInfoTransfer))
            if let sessionID {
                self.markUserInfoDelivered(sessionID: sessionID, error: error)
            } else if let error {
                self.failedTransferCount += 1
                self.lastSyncStatus = String(format: String(localized: "Failed: transferUserInfo non completato: %@"), error.localizedDescription)
            } else {
                self.lastSyncStatus = String(localized: "Sent: transferUserInfo completato, attendo ack firmato companion")
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
