import Foundation
import Combine
import WatchConnectivity
import CryptoKit
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
    @Published private(set) var lastSyncStatus = String(localized: "sync.status.companion_not_synced")
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
    private weak var plannerBriefingStore: PlannerBriefingCardStore?
    private weak var apneaLogbookStore: ApneaLogbookStore?
    private weak var snorkelingLogbookStore: SnorkelingLogbookStore?
    var isApneaSessionInProgress = false
    var isSnorkelingSessionInProgress = false
    private var importedFromCompanionIDs: Set<UUID> = []
    private var pendingApneaTransfers: [ApneaSyncPendingTransfer] = []
    private var pendingApneaUserInfoSessionIDs: [ObjectIdentifier: UUID] = [:]
    private var inFlightApneaSessionIDs: Set<UUID> = []
    private let pendingApneaFileName = "dirdiving_watch_pending_apnea_sync_sessions.json"
    private var pendingSnorkelingTransfers: [SnorkelingSyncPendingTransfer] = []
    private var pendingSnorkelingUserInfoSessionIDs: [ObjectIdentifier: UUID] = [:]
    private var inFlightSnorkelingSessionIDs: Set<UUID> = []
    private let pendingSnorkelingFileName = "dirdiving_watch_pending_snorkeling_sync_sessions.json"
    private var peerSecretObserver: NSObjectProtocol?
    private var pendingPhotoManagementResponses: [PendingPhotoManagementResponse] = []
    private var inFlightSessionIDs: Set<UUID> = []

    private static let logger = Logger(subsystem: "com.egopfe.dirdiving", category: "WatchSyncService")
    private static let activityDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM HH:mm"
        return formatter
    }()

    private override init() {
        super.init()
        WatchDiveSyncCodec.bootstrapReplayCacheIfNeeded()
        ApneaSessionSyncCodec.bootstrapReplayCacheIfNeeded()
        SnorkelingSessionSyncCodec.bootstrapReplayCacheIfNeeded()
        pendingTransfers = loadPendingTransfers()
        pendingApneaTransfers = loadPendingApneaTransfers()
        pendingSnorkelingTransfers = loadPendingSnorkelingTransfers()
        pendingTransferCount = pendingTransfers.count
        importedFromCompanionIDs = WatchDiveSyncCodec.loadImportedFromCompanionIDs()
        importedFromCompanionCount = importedFromCompanionIDs.count
        pendingPhotoManagementResponses = PendingPhotoManagementResponseQueue.load()
        peerSecretObserver = NotificationCenter.default.addObserver(
            forName: .watchSyncPeerSecretDidUpdate,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.flushPendingTransfers()
                self?.flushPendingApneaTransfers()
                self?.flushPendingSnorkelingTransfers()
            }
        }
        activate()
    }

    func attachLogStore(_ store: DiveLogStore) {
        logStore = store
    }

    func attachPlannerBriefingStore(_ store: PlannerBriefingCardStore) {
        plannerBriefingStore = store
    }

    func attachApneaLogbookStore(_ store: ApneaLogbookStore) {
        apneaLogbookStore = store
    }

    func attachSnorkelingLogbookStore(_ store: SnorkelingLogbookStore) {
        snorkelingLogbookStore = store
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
            flushPendingApneaTransfers()
            flushPendingSnorkelingTransfers()
        } else {
            WatchSyncAuth.publishSharedSecretIfNeeded()
            lastSyncStatus = String(format: String(localized: "sync.queue.pending_sync_key"), pendingTransferCount)
        }
    }

    func transferSnorkelingSession(_ session: SnorkelingSession) {
        guard WCSession.isSupported() else { return }
        enqueuePendingSnorkelingSession(session)
        recordActivity(title: String(localized: "snorkeling.sync.activity.pending_to_iphone"), detail: snorkelingSessionSummary(session))
        if WatchSyncAuth.hasPeerSecret() {
            flushPendingSnorkelingTransfers()
        } else {
            WatchSyncAuth.publishSharedSecretIfNeeded()
            lastSyncStatus = String(localized: "snorkeling.sync.queue.pending_key")
        }
    }

    func transferApneaSession(_ session: ApneaSession) {
        guard WCSession.isSupported() else { return }
        enqueuePendingApneaSession(session)
        recordActivity(title: String(localized: "apnea.sync.activity.pending_to_iphone"), detail: apneaSessionSummary(session))
        if WatchSyncAuth.hasPeerSecret() {
            flushPendingApneaTransfers()
        } else {
            WatchSyncAuth.publishSharedSecretIfNeeded()
            lastSyncStatus = String(localized: "apnea.sync.queue.pending_key")
        }
    }

    /// Broadcast Diving tombstone UUIDs to iPhone via applicationContext (merge-safe).
    func publishDeletedSessionIDs(_ ids: Set<UUID>) {
        publishDeletedTombstones(ids, activity: .diving) { _ in
            Int(Date().timeIntervalSince1970)
        }
    }

    func publishDeletedApneaSessionIDs(_ ids: Set<UUID>) {
        publishDeletedTombstones(ids, activity: .apnea) { id in
            ActivitySyncRevisionPolicy.sessionRevision(for: Date())
        }
    }

    func publishDeletedSnorkelingSessionIDs(_ ids: Set<UUID>) {
        publishDeletedTombstones(ids, activity: .snorkeling) { id in
            snorkelingLogbookStore?.revision(for: id) ?? ActivitySyncRevisionPolicy.sessionRevision(for: Date())
        }
    }

    private func publishDeletedTombstones(
        _ ids: Set<UUID>,
        activity: ActivitySyncActivityType,
        revisionForSession: (UUID) -> Int
    ) {
        guard WCSession.isSupported(), !ids.isEmpty, WatchSyncAuth.hasPeerSecret() else {
            if !ids.isEmpty {
                publishLegacyDivingUUIDTombstones(ids, activity: activity)
            }
            return
        }
        guard let syncKey = try? WatchSyncAuth.deriveSyncKey(peerBundleID: "com.egopfe.dirdiving.ios") else {
            publishLegacyDivingUUIDTombstones(ids, activity: activity)
            return
        }
        let bundleID = Bundle.main.bundleIdentifier ?? "com.egopfe.dirdiving.ios.watch"
        guard let signed = try? ActivitySyncTombstoneBroadcast.makeSignedTombstones(
            sessionIDs: ids,
            activity: activity,
            revisionForSession: revisionForSession,
            syncKey: syncKey,
            bundleID: bundleID
        ), !signed.isEmpty else {
            publishLegacyDivingUUIDTombstones(ids, activity: activity)
            return
        }
        let context = WCSession.default.applicationContext
        let payload = ActivitySyncTombstoneBroadcast.mergeBroadcastPayload(
            existing: context,
            incoming: signed,
            activity: activity
        )
        if activity == .diving {
            var legacy = Set((context[WatchSyncKeys.deletedSessionBroadcastKey] as? [String]) ?? [])
            legacy.formUnion(ids.map(\.uuidString))
            var merged = payload
            merged[WatchSyncKeys.deletedSessionBroadcastKey] = Array(legacy)
            WatchSyncAuth.mergeApplicationContext(merged)
        } else {
            WatchSyncAuth.mergeApplicationContext(payload)
        }
        lastSyncStatus = String(format: String(localized: "Tombstone inviata a iPhone (%lld)"), ids.count)
    }

    private func publishLegacyDivingUUIDTombstones(_ ids: Set<UUID>, activity: ActivitySyncActivityType) {
        guard activity == .diving, WCSession.isSupported(), !ids.isEmpty else { return }
        var existing = Set((WCSession.default.applicationContext[WatchSyncKeys.deletedSessionBroadcastKey] as? [String]) ?? [])
        existing.formUnion(ids.map(\.uuidString))
        WatchSyncAuth.mergeApplicationContext([WatchSyncKeys.deletedSessionBroadcastKey: Array(existing)])
    }

    func publishUnitsPreference(_ value: String) {
        guard DIRUnitPreference(rawValue: value) != nil else { return }
        guard WCSession.isSupported() else { return }
        WatchSyncAuth.mergeApplicationContext([WatchSyncKeys.unitsPreferenceKey: value])
    }

    func publishGaugeTTVPreference(_ showsTTV: Bool) {
        guard WCSession.isSupported() else { return }
        WatchSyncAuth.mergeApplicationContext([WatchSyncKeys.gaugeShowTTVKey: showsTTV])
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
            flushPendingApneaTransfers()
            flushPendingSnorkelingTransfers()
        } else {
            lastSyncStatus = String(format: String(localized: "sync.queue.pending_companion_key"), pendingTransferCount)
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

    private func ingestSignedTombstones(
        from context: [String: Any],
        activity: ActivitySyncActivityType,
        apply: (Set<UUID>) -> Void
    ) {
        guard WatchSyncAuth.hasPeerSecret(),
              let syncKey = try? WatchSyncAuth.deriveSyncKey(peerBundleID: "com.egopfe.dirdiving.ios") else {
            return
        }
        let ids = ActivitySyncTombstoneBroadcast.verifiedSessionIDs(
            from: context,
            activity: activity,
            syncKey: syncKey,
            expectedBundleID: "com.egopfe.dirdiving.ios"
        )
        guard !ids.isEmpty else { return }
        apply(ids)
    }

    private struct AckContext {
        let sessionID: UUID
        let issuedAt: Date
    }

    func publishUploadedImageInventory(requestID: String? = nil) {
        queueInventoryPublish(requestID: requestID)
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
        let payload = CompanionPhotoManagementSupport.makeDeleteAckPayload(
            requestID: requestID,
            storedFileName: storedFileName,
            status: status,
            errorCode: errorCode
        )
        guard WCSession.isSupported(), activationState == .activated else {
            if let queued = PendingPhotoManagementResponse.deleteAck(
                requestID: requestID,
                storedFileName: storedFileName,
                status: status,
                errorCode: errorCode,
                payload: payload
            ) {
                pendingPhotoManagementResponses = PendingPhotoManagementResponseQueue.enqueue(
                    queued,
                    existing: pendingPhotoManagementResponses
                )
                PendingPhotoManagementResponseQueue.save(pendingPhotoManagementResponses)
            }
            return
        }
        deliverCompanionManagementPayload(payload)
    }

    private func queueInventoryPublish(requestID: String? = nil) {
        let payload = CompanionPhotoManagementSupport.makeInventoryResponsePayload(
            requestID: requestID,
            items: UserImageStore.buildUploadedInventory()
        )
        guard WCSession.isSupported(), activationState == .activated else {
            if let queued = PendingPhotoManagementResponse.inventoryPublish(requestID: requestID, payload: payload) {
                pendingPhotoManagementResponses = PendingPhotoManagementResponseQueue.enqueue(
                    queued,
                    existing: pendingPhotoManagementResponses
                )
                PendingPhotoManagementResponseQueue.save(pendingPhotoManagementResponses)
            }
            return
        }
        deliverCompanionManagementPayload(payload)
    }

    func flushPendingPhotoManagementResponses() {
        guard WCSession.isSupported(), activationState == .activated else { return }
        var remaining = pendingPhotoManagementResponses
        for entry in pendingPhotoManagementResponses {
            guard PendingPhotoManagementResponseQueue.shouldRetry(entry) else {
                remaining = PendingPhotoManagementResponseQueue.dequeue(id: entry.id, from: remaining)
                continue
            }
            deliverCompanionManagementPayload(entry.wirePayload)
            remaining = PendingPhotoManagementResponseQueue.dequeue(id: entry.id, from: remaining)
        }
        pendingPhotoManagementResponses = remaining
        PendingPhotoManagementResponseQueue.save(pendingPhotoManagementResponses)
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
                lastSyncStatus = String(localized: "sync.dive.duplicate_ignored_iphone")
                return AckContext(sessionID: session.id, issuedAt: parsed.issuedAt)
            }
            guard let logStore else {
                failedTransferCount += 1
                lastSyncStatus = String(localized: "watchsync.import.error.log_store_unavailable")
                return nil
            }
            rememberCompanionSession(id: session.id)
            logStore.addFromCompanion(session)
            lastSyncStatus = String(localized: "sync.dive.received_from_iphone")
            recordActivity(title: String(localized: "sync.activity.received_from_iphone"), detail: sessionSummary(session))
            return AckContext(sessionID: session.id, issuedAt: parsed.issuedAt)
        } catch {
            failedTransferCount += 1
            lastSyncStatus = String(format: String(localized: "sync.dive.import_error_format"), error.localizedDescription)
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
        if let showsTTV = context[WatchSyncKeys.gaugeShowTTVKey] as? Bool {
            DIRStartupSelectionPolicy.applySyncedGaugeShowsTTV(showsTTV)
        }
        if let strings = context[WatchSyncKeys.deletedSessionBroadcastKey] as? [String] {
            let ids = Set(strings.compactMap(UUID.init(uuidString:)))
            if !ids.isEmpty {
                logStore?.applyRemoteDeletedSessionIDs(ids)
                lastSyncStatus = String(format: String(localized: "Tombstone iPhone applicata (%lld)"), ids.count)
            }
        }
        ingestSignedTombstones(from: context, activity: .diving) { ids in
            logStore?.applyRemoteDeletedSessionIDs(ids)
        }
        ingestSignedTombstones(from: context, activity: .apnea) { ids in
            apneaLogbookStore?.applyRemoteDeletedSessionIDs(ids)
        }
        ingestSignedTombstones(from: context, activity: .snorkeling) { ids in
            snorkelingLogbookStore?.applyRemoteDeletedSessionIDs(ids)
        }
        DivePlanPackageWatchReceiver.importSnapshot(context, store: FullComputerImportedPlanStore.shared)
        ApneaSyncWatchReceiver.importSnapshot(
            context,
            store: ApneaImportedPlanStore.shared,
            sessionInProgress: isApneaSessionInProgress
        )
        SnorkelingRouteWatchReceiver.importSnapshot(
            context,
            store: SnorkelingImportedRouteStore.shared,
            sessionInProgress: isSnorkelingSessionInProgress
        )
    }

    private func flushPendingTransfers() {
        guard WatchSyncAuth.hasPeerSecret(), !pendingTransfers.isEmpty else { return }
        let eligible = WatchSyncPendingFlushPolicy.sessionsEligibleForSend(
            transfers: pendingTransfers,
            sessionID: { $0.session.id },
            lastAttemptAt: { $0.lastAttemptAt },
            inFlightSessionIDs: inFlightSessionIDs
        )
        Self.logger.info("Flushing \(eligible.count, privacy: .public) pending Watch→iPhone session(s)")
        for entry in eligible.reversed() {
            inFlightSessionIDs.insert(entry.session.id)
            sendQueued(entry.session)
        }
    }

    /// Removes a pending transfer after a verified signed companion ACK (direct message path).
    func confirmSignedAck(sessionID: UUID, issuedAt: Date, signature: String) {
        guard WatchDiveSyncCodec.verifyAckSignature(signature, sessionID: sessionID, issuedAt: issuedAt) else {
            failedTransferCount += 1
            lastSyncStatus = String(localized: "watchsync.diagnostic.failed_signed_ack")
            return
        }
        guard pendingTransfers.contains(where: { $0.session.id == sessionID }) else { return }
        inFlightSessionIDs.remove(sessionID)
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
                        let providedSignature = reply[WatchSyncReplyHandlerPolicy.ackSignatureKey] as? String ?? ""
                        if WatchSyncReplyHandlerPolicy.mayDequeuePendingTransfer(
                            reply: reply,
                            expectedSessionID: envelope.sessionID,
                            expectedIssuedAt: envelope.issuedAt,
                            verifySignature: { signature, sessionID, issuedAt in
                                WatchDiveSyncCodec.verifyAckSignature(signature, sessionID: sessionID, issuedAt: issuedAt)
                            }
                        ) {
                            self.confirmSignedAck(
                                sessionID: envelope.sessionID,
                                issuedAt: envelope.issuedAt,
                                signature: providedSignature
                            )
                        } else if WatchSyncReplyHandlerPolicy.disposition(for: reply) == .transportHintOnly {
                            self.inFlightSessionIDs.remove(envelope.sessionID)
                        } else {
                            self.inFlightSessionIDs.remove(envelope.sessionID)
                            self.failedTransferCount += 1
                            self.lastSyncStatus = String(localized: "watchsync.diagnostic.failed_iphone_no_ack")
                        }
                    }
                } errorHandler: { [weak self] error in
                    Task { @MainActor in
                        guard let self else { return }
                        self.failedTransferCount += 1
                        self.lastSyncStatus = String(format: String(localized: "watchsync.diagnostic.failed_direct_sent_queue_format"), error.localizedDescription)
                        self.sentTransferCount += 1
                        self.queueViaUserInfo(envelope: envelope, sessionID: session.id)
                        self.recordActivity(title: String(localized: "sync.activity.queued_to_iphone"), detail: self.sessionSummary(session))
                    }
                }
                sentTransferCount += 1
                lastSyncStatus = String(localized: "watchsync.diagnostic.sent_direct_awaiting_ack")
                recordActivity(title: String(localized: "sync.activity.sent_to_iphone"), detail: sessionSummary(session))
            } else {
                queueViaUserInfo(envelope: envelope, sessionID: session.id)
                sentTransferCount += 1
                lastSyncStatus = String(localized: "watchsync.diagnostic.sent_queue_ack_pending")
                recordActivity(title: String(localized: "sync.activity.queued_to_iphone"), detail: sessionSummary(session))
            }
        } catch WatchDiveSyncError.missingPeerSecret {
            enqueuePendingSession(session)
            WatchSyncAuth.publishSharedSecretIfNeeded()
            lastSyncStatus = String(localized: "sync.queue.pending_companion_sync_key")
        } catch {
            failedTransferCount += 1
            lastSyncStatus = String(format: String(localized: "watchsync.diagnostic.failed_encoding_format"), error.localizedDescription)
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
            lastSyncStatus = String(format: String(localized: "watchsync.diagnostic.failed_transfer_user_info_format"), error.localizedDescription)
            return
        }
        pendingTransfers[index].userInfoDeliveredAt = Date()
        lastSyncStatus = String(localized: "watchsync.diagnostic.sent_transfer_user_info_awaiting_ack")
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
        migrateLegacyPendingFileIfNeeded(activity: "Diving", fileName: pendingFileName)
    }

    private func pendingApneaFileURL() -> URL {
        migrateLegacyPendingFileIfNeeded(activity: "Apnea", fileName: pendingApneaFileName)
    }

    private func pendingSnorkelingFileURL() -> URL {
        migrateLegacyPendingFileIfNeeded(activity: "Snorkeling", fileName: pendingSnorkelingFileName)
    }

    private func migrateLegacyPendingFileIfNeeded(activity: String, fileName: String) -> URL {
        let legacyDoc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
        guard let target = try? ProtectedSensitiveFileStore.fileURL(activity: activity, fileName: fileName) else {
            return legacyDoc
        }
        if !FileManager.default.fileExists(atPath: target.path),
           FileManager.default.fileExists(atPath: legacyDoc.path),
           let data = try? Data(contentsOf: legacyDoc) {
            try? ProtectedSensitiveFileStore.saveData(data, to: target)
            try? FileManager.default.removeItem(at: legacyDoc)
        }
        _ = ProtectedSensitiveFileStore.migrateUserDefaultsData(
            key: legacyPendingSessionsKey,
            to: target,
            removeLegacyAfterVerifiedWrite: activity == "Diving"
        )
        return target
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
            try? FileManager.default.setAttributes(
                [.protectionKey: FileProtectionType.complete],
                ofItemAtPath: stagingURL.path
            )
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

    private func apneaSessionSummary(_ session: ApneaSession) -> String {
        let dives = session.dives.count
        let maxDepth = Formatters.one(session.statistics.sessionMaxDepthMeters)
        return "\(dives) dives · \(maxDepth) m"
    }

    private func flushPendingApneaTransfers() {
        guard WatchSyncAuth.hasPeerSecret(), !pendingApneaTransfers.isEmpty else { return }
        for entry in pendingApneaTransfers.reversed() {
            guard !inFlightApneaSessionIDs.contains(entry.session.id) else { continue }
            inFlightApneaSessionIDs.insert(entry.session.id)
            sendQueuedApnea(entry.session)
        }
    }

    private func sendQueuedApnea(_ session: ApneaSession) {
        do {
            let envelope = try ApneaSessionSyncCodec.makePayload(session: session)
            recordPendingApneaAttempt(sessionID: session.id, issuedAt: envelope.issuedAt)
            if WCSession.default.isReachable {
                WCSession.default.sendMessage(envelope.message) { [weak self] reply in
                    Task { @MainActor in
                        guard let self else { return }
                        let providedSignature = reply["ackSignature"] as? String
                        if ApneaSessionSyncCodec.verifyAckSignature(
                            providedSignature,
                            sessionID: envelope.sessionID,
                            issuedAt: envelope.issuedAt
                        ) {
                            self.confirmApneaSignedAck(
                                sessionID: envelope.sessionID,
                                issuedAt: envelope.issuedAt,
                                signature: providedSignature ?? ""
                            )
                        } else {
                            self.inFlightApneaSessionIDs.remove(envelope.sessionID)
                            self.failedTransferCount += 1
                            self.queueApneaViaUserInfo(envelope: envelope, sessionID: session.id)
                        }
                    }
                } errorHandler: { [weak self] _ in
                    Task { @MainActor in
                        guard let self else { return }
                        self.inFlightApneaSessionIDs.remove(envelope.sessionID)
                        self.queueApneaViaUserInfo(envelope: envelope, sessionID: session.id)
                    }
                }
                sentTransferCount += 1
            } else {
                queueApneaViaUserInfo(envelope: envelope, sessionID: session.id)
            }
        } catch {
            inFlightApneaSessionIDs.remove(session.id)
            failedTransferCount += 1
        }
    }

    private func queueApneaViaUserInfo(envelope: ApneaSessionSyncCodec.PayloadEnvelope, sessionID: UUID) {
        let transfer = WCSession.default.transferUserInfo(envelope.message)
        pendingApneaUserInfoSessionIDs[ObjectIdentifier(transfer)] = sessionID
        sentTransferCount += 1
        savePendingApneaTransfers()
    }

    func confirmApneaSignedAck(sessionID: UUID, issuedAt: Date, signature: String) {
        guard ApneaSessionSyncCodec.verifyAckSignature(signature, sessionID: sessionID, issuedAt: issuedAt) else {
            failedTransferCount += 1
            return
        }
        inFlightApneaSessionIDs.remove(sessionID)
        removePendingApneaTransfer(sessionID: sessionID)
        acknowledgedTransferCount += 1
        recordActivity(title: String(localized: "apnea.sync.activity.delivered_to_iphone"), detail: sessionID.uuidString)
    }

    private func handleApneaImportAck(_ payload: [String: Any]) {
        guard let parsed = ApneaSessionSyncCodec.parseImportAck(from: payload) else { return }
        confirmApneaSignedAck(sessionID: parsed.sessionID, issuedAt: parsed.issuedAt, signature: parsed.signature)
    }

    private func enqueuePendingApneaSession(_ session: ApneaSession) {
        let normalized = ApneaLogbookPolicy.normalizedSession(session)
        pendingApneaTransfers.removeAll { $0.session.id == normalized.id }
        pendingApneaTransfers.append(ApneaSyncPendingTransfer(session: normalized))
        savePendingApneaTransfers()
    }

    private func removePendingApneaTransfer(sessionID: UUID) {
        pendingApneaTransfers.removeAll { $0.session.id == sessionID }
        savePendingApneaTransfers()
    }

    private func recordPendingApneaAttempt(sessionID: UUID, issuedAt: Date) {
        guard let index = pendingApneaTransfers.firstIndex(where: { $0.session.id == sessionID }) else { return }
        pendingApneaTransfers[index].lastIssuedAt = issuedAt
        pendingApneaTransfers[index].lastAttemptAt = Date()
        pendingApneaTransfers[index].attemptCount += 1
        savePendingApneaTransfers()
    }

    private func loadPendingApneaTransfers() -> [ApneaSyncPendingTransfer] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let data = try? Data(contentsOf: pendingApneaFileURL()) else { return [] }
        return (try? decoder.decode([ApneaSyncPendingTransfer].self, from: data)) ?? []
    }

    private func savePendingApneaTransfers() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(pendingApneaTransfers) else { return }
        try? data.write(to: pendingApneaFileURL(), options: [.atomic, .completeFileProtection])
    }

    private func snorkelingSessionSummary(_ session: SnorkelingSession) -> String {
        let dips = session.dips.count
        let maxDepth = Formatters.one(session.statistics.sessionMaxDepthMeters)
        return "\(dips) dips · \(maxDepth) m"
    }

    private func flushPendingSnorkelingTransfers() {
        guard WatchSyncAuth.hasPeerSecret(), !pendingSnorkelingTransfers.isEmpty else { return }
        for entry in pendingSnorkelingTransfers.reversed() {
            guard !inFlightSnorkelingSessionIDs.contains(entry.session.id) else { continue }
            inFlightSnorkelingSessionIDs.insert(entry.session.id)
            sendQueuedSnorkeling(entry.session)
        }
    }

    private func sendQueuedSnorkeling(_ session: SnorkelingSession) {
        do {
            let envelope = try SnorkelingSessionSyncCodec.makePayload(session: session)
            recordPendingSnorkelingAttempt(sessionID: session.id, issuedAt: envelope.issuedAt)
            if WCSession.default.isReachable {
                WCSession.default.sendMessage(envelope.message) { [weak self] reply in
                    Task { @MainActor in
                        guard let self else { return }
                        let providedSignature = reply["ackSignature"] as? String
                        if SnorkelingSessionSyncCodec.verifyAckSignature(
                            providedSignature,
                            sessionID: envelope.sessionID,
                            issuedAt: envelope.issuedAt
                        ) {
                            self.confirmSnorkelingSignedAck(
                                sessionID: envelope.sessionID,
                                issuedAt: envelope.issuedAt,
                                signature: providedSignature ?? ""
                            )
                        } else {
                            self.inFlightSnorkelingSessionIDs.remove(envelope.sessionID)
                            self.failedTransferCount += 1
                            self.queueSnorkelingViaUserInfo(envelope: envelope, sessionID: session.id)
                        }
                    }
                } errorHandler: { [weak self] _ in
                    Task { @MainActor in
                        guard let self else { return }
                        self.inFlightSnorkelingSessionIDs.remove(envelope.sessionID)
                        self.queueSnorkelingViaUserInfo(envelope: envelope, sessionID: session.id)
                    }
                }
                sentTransferCount += 1
            } else {
                queueSnorkelingViaUserInfo(envelope: envelope, sessionID: session.id)
            }
        } catch {
            inFlightSnorkelingSessionIDs.remove(session.id)
            failedTransferCount += 1
        }
    }

    private func queueSnorkelingViaUserInfo(envelope: SnorkelingSessionSyncCodec.PayloadEnvelope, sessionID: UUID) {
        let transfer = WCSession.default.transferUserInfo(envelope.message)
        pendingSnorkelingUserInfoSessionIDs[ObjectIdentifier(transfer)] = sessionID
        sentTransferCount += 1
        savePendingSnorkelingTransfers()
    }

    func confirmSnorkelingSignedAck(sessionID: UUID, issuedAt: Date, signature: String) {
        guard SnorkelingSessionSyncCodec.verifyAckSignature(signature, sessionID: sessionID, issuedAt: issuedAt) else {
            failedTransferCount += 1
            return
        }
        inFlightSnorkelingSessionIDs.remove(sessionID)
        removePendingSnorkelingTransfer(sessionID: sessionID)
        acknowledgedTransferCount += 1
        recordActivity(title: String(localized: "snorkeling.sync.activity.delivered_to_iphone"), detail: sessionID.uuidString)
    }

    private func handleSnorkelingImportAck(_ payload: [String: Any]) {
        guard let parsed = SnorkelingSessionSyncCodec.parseImportAck(from: payload) else { return }
        confirmSnorkelingSignedAck(sessionID: parsed.sessionID, issuedAt: parsed.issuedAt, signature: parsed.signature)
    }

    private func enqueuePendingSnorkelingSession(_ session: SnorkelingSession) {
        let normalized = SnorkelingLogbookPolicy.normalizedSession(session)
        pendingSnorkelingTransfers.removeAll { $0.session.id == normalized.id }
        pendingSnorkelingTransfers.append(SnorkelingSyncPendingTransfer(session: normalized))
        savePendingSnorkelingTransfers()
    }

    private func removePendingSnorkelingTransfer(sessionID: UUID) {
        pendingSnorkelingTransfers.removeAll { $0.session.id == sessionID }
        savePendingSnorkelingTransfers()
    }

    private func recordPendingSnorkelingAttempt(sessionID: UUID, issuedAt: Date) {
        guard let index = pendingSnorkelingTransfers.firstIndex(where: { $0.session.id == sessionID }) else { return }
        pendingSnorkelingTransfers[index].lastIssuedAt = issuedAt
        pendingSnorkelingTransfers[index].lastAttemptAt = Date()
        pendingSnorkelingTransfers[index].attemptCount += 1
        savePendingSnorkelingTransfers()
    }

    private func loadPendingSnorkelingTransfers() -> [SnorkelingSyncPendingTransfer] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let data = try? Data(contentsOf: pendingSnorkelingFileURL()) else { return [] }
        return (try? decoder.decode([SnorkelingSyncPendingTransfer].self, from: data)) ?? []
    }

    private func savePendingSnorkelingTransfers() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(pendingSnorkelingTransfers) else { return }
        try? data.write(to: pendingSnorkelingFileURL(), options: [.atomic, .completeFileProtection])
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

    var testHook_pendingPhotoManagementResponses: [PendingPhotoManagementResponse] {
        pendingPhotoManagementResponses
    }

    func testHook_flushPendingPhotoManagementResponses() {
        flushPendingPhotoManagementResponses()
    }

    func testHook_setActivationStateForTests(_ state: WCSessionActivationState) {
        activationState = state
    }

    func testHook_resetSnorkelingPendingQueueForTests() {
        pendingSnorkelingTransfers = []
        pendingSnorkelingUserInfoSessionIDs = [:]
        inFlightSnorkelingSessionIDs = []
        savePendingSnorkelingTransfers()
    }

    var testHook_pendingSnorkelingSessionIDs: [UUID] {
        pendingSnorkelingTransfers.map(\.session.id)
    }

    var testHook_pendingSnorkelingTransfers: [SnorkelingSyncPendingTransfer] {
        pendingSnorkelingTransfers
    }

    func testHook_enqueueSnorkelingSession(_ session: SnorkelingSession) {
        enqueuePendingSnorkelingSession(session)
    }

    func testHook_confirmSnorkelingSignedAck(sessionID: UUID, issuedAt: Date, signature: String) {
        confirmSnorkelingSignedAck(sessionID: sessionID, issuedAt: issuedAt, signature: signature)
    }

    func testHook_reloadSnorkelingPendingFromPersistence() -> [SnorkelingSyncPendingTransfer] {
        pendingSnorkelingTransfers = loadPendingSnorkelingTransfers()
        return pendingSnorkelingTransfers
    }

    func testHook_markImportedFromCompanionSession(_ id: UUID) {
        importedFromCompanionIDs.insert(id)
        importedFromCompanionCount = importedFromCompanionIDs.count
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
                self.flushPendingPhotoManagementResponses()
                self.flushPendingTransfers()
                self.flushPendingApneaTransfers()
                self.flushPendingSnorkelingTransfers()
            }
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor in
            self.ingestCompanionContext(applicationContext)
            self.flushPendingTransfers()
            self.flushPendingApneaTransfers()
            self.flushPendingSnorkelingTransfers()
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
            if WatchDiveSyncCodec.isImportAck(userInfo) {
                self.handleCompanionImportAck(userInfo)
                return
            }
            if DivePlanPackageTransferSupport.isPackageTransfer(userInfo) {
                if let ack = DivePlanPackageWatchReceiver.importPayload(
                    userInfo,
                    store: FullComputerImportedPlanStore.shared
                ) {
                    DivePlanPackageWatchReceiver.deliverAck(ack)
                }
                return
            }
            if ApneaSyncTransferSupport.isPackageTransfer(userInfo) {
                if let ack = ApneaSyncWatchReceiver.importPayload(
                    userInfo,
                    store: ApneaImportedPlanStore.shared,
                    sessionInProgress: isApneaSessionInProgress
                ) {
                    ApneaSyncWatchReceiver.deliverAck(ack)
                }
                return
            }
            if SnorkelingRouteSyncTransferSupport.isPackageTransfer(userInfo) {
                if let ack = SnorkelingRouteWatchReceiver.importPayload(
                    userInfo,
                    store: SnorkelingImportedRouteStore.shared,
                    sessionInProgress: isSnorkelingSessionInProgress
                ) {
                    SnorkelingRouteWatchReceiver.deliverAck(ack)
                }
                return
            }
            if ApneaSessionSyncCodec.isImportAck(userInfo) {
                handleApneaImportAck(userInfo)
                return
            }
            if SnorkelingSessionSyncCodec.isImportAck(userInfo) {
                handleSnorkelingImportAck(userInfo)
                return
            }
            if let ackContext = self.ingestIncomingPayload(userInfo) {
                self.deliverImportAck(sessionID: ackContext.sessionID, issuedAt: ackContext.issuedAt)
            }
        }
    }

    private func handleCompanionImportAck(_ payload: [String: Any]) {
        guard let parsed = WatchDiveSyncCodec.parseImportAck(from: payload) else {
            failedTransferCount += 1
            lastSyncStatus = String(localized: "watchsync.diagnostic.failed_signed_ack")
            return
        }
        confirmSignedAck(sessionID: parsed.sessionID, issuedAt: parsed.issuedAt, signature: parsed.signature)
    }

    nonisolated func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        Task { @MainActor in
            let sessionID = self.pendingUserInfoTransferSessionIDs.removeValue(forKey: ObjectIdentifier(userInfoTransfer))
            if let sessionID {
                self.markUserInfoDelivered(sessionID: sessionID, error: error)
            } else if let error {
                self.failedTransferCount += 1
                self.lastSyncStatus = String(format: String(localized: "watchsync.diagnostic.failed_transfer_user_info_format"), error.localizedDescription)
            } else {
                self.lastSyncStatus = String(localized: "watchsync.diagnostic.sent_transfer_user_info_awaiting_ack")
            }
        }
    }

    private func deliverPlannerBriefingAck(payload: [String: Any]) {
        guard WCSession.isSupported(), activationState == .activated else { return }
        _ = WCSession.default.transferUserInfo(payload)
    }

    nonisolated func session(_ session: WCSession, didReceive file: WCSessionFile) {
        let metadata = file.metadata ?? [:]
        let staged = Self.stageIncomingCompanionPhoto(file)
        Task { @MainActor in
            guard let staged else {
                if PlannerBriefingWatchReceiver.isPlannerBriefingTransfer(metadata) {
                    if let packageId = PlannerBriefingTransferSupport.packageId(from: metadata) {
                        self.deliverPlannerBriefingAck(payload: [
                            "type": PlannerBriefingTransferSupport.ackType,
                            PlannerBriefingTransferSupport.packageIdKey: packageId.uuidString,
                            PlannerBriefingTransferSupport.ackStatusKey: PlannerBriefingTransferSupport.ackStatusRejected,
                            PlannerBriefingTransferSupport.ackErrorCodeKey: "missingFile",
                        ])
                    }
                } else {
                    self.rejectCompanionPhoto(metadata: metadata, errorCode: "missingFile")
                }
                return
            }
            defer { try? FileManager.default.removeItem(at: staged.url) }
            if PlannerBriefingWatchReceiver.isPlannerBriefingTransfer(staged.metadata),
               let store = self.plannerBriefingStore {
                if let ack = PlannerBriefingWatchReceiver.importFile(
                    from: staged.url,
                    metadata: staged.metadata,
                    store: store
                ) {
                    self.deliverPlannerBriefingAck(payload: ack)
                    if ack[PlannerBriefingTransferSupport.ackStatusKey] as? String == PlannerBriefingTransferSupport.ackStatusImported {
                        self.recordActivity(
                            title: String(localized: "watch.sync.planner_briefing.received"),
                            detail: staged.metadata[PlannerBriefingTransferSupport.fileNameKey] as? String ?? "briefing"
                        )
                    }
                }
                return
            }
            self.importCompanionPhoto(from: staged.url, metadata: staged.metadata)
        }
    }
}
