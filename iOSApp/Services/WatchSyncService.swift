import Foundation
import Combine
import WatchConnectivity
import os

@MainActor
final class WatchSyncService: NSObject, ObservableObject {
    struct SyncConflict: Identifiable, Codable, Hashable {
        let id: UUID
        let detectedAt: Date
        let localSummary: String
        let incoming: DiveSession
    }

    struct SyncActivityItem: Identifiable, Hashable {
        let id = UUID()
        let title: String
        let detail: String
        let timestamp: Date
    }

    @Published var isSupported = WCSession.isSupported()
    @Published var activationState: WCSessionActivationState = .notActivated
    @Published var lastMessage = String(localized: "Non sincronizzato")
    @Published private(set) var importedSessionCount = 0
    @Published private(set) var failedImportCount = 0
    @Published private(set) var conflicts: [SyncConflict] = []
    @Published private(set) var recentActivity: [SyncActivityItem] = []
    @Published private(set) var lastSuccessfulSyncDate: Date?
    @Published private(set) var companionPhotoTransfer: CompanionPhotoTransferStatus?
    @Published private(set) var watchImageInventory: [WatchUserImageInventoryItem] = []
    @Published private(set) var watchImageInventoryStatus: WatchImageInventoryStatus = .unknown
    @Published private(set) var lastInventoryRefreshDate: Date?
    @Published private(set) var inventoryErrorMessage: String?
    @Published private(set) var pendingDeleteRequests: [String: WatchPhotoDeleteRequestState] = [:]
    private weak var logStore: DiveLogStore?
    private var photoIDByTransferFilePath: [String: String] = [:]
    private var companionPhotoTransfersByID: [String: CompanionPhotoTransferStatus] = [:]
    private var pendingPhotoImportVerificationTasks: [String: Task<Void, Never>] = [:]
    private var pendingInventoryRequestID: String?
    private var handledDeleteAckRequestIDs: Set<String> = []

    var pendingWatchQueueCount: Int { pendingOutboundSessions.count }
    private var importedSessionIDs: Set<UUID> = []
    private var pushedToWatchSessionIDs: Set<UUID> = []
    private var pendingOutboundSessions: [DiveSession] = []
    private let pushedToWatchIDsKey = "dirdiving_ios_pushed_to_watch_session_ids"
    private let pendingOutboundFileName = "dirdiving_ios_pending_watch_sync_sessions.json"
    private static let maxPhotoTransferBytes = 10 * 1_024 * 1_024
    private static let allowedPhotoExtensions: Set<String> = ["png", "jpg", "jpeg", "heic"]

    // F9: conflicts persisted to a Documents/ file with `.completeFileProtection`
    // instead of UserDefaults. UserDefaults is not covered by Data Protection on a
    // locked device, and conflicts carry full DiveSession content (GPS included).
    // The legacy UserDefaults key is migrated once on init.
    private let legacyConflictsKey = "dirdiving_ios_watch_sync_conflicts"
    private let conflictsFileName = "dirdiving_ios_watch_sync_conflicts.json"

    private static let logger = Logger(subsystem: "com.egopfe.dirdiving.ios", category: "WatchSyncService")
    private static let activityDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM HH:mm"
        return formatter
    }()

    var userVisibleState: String {
        if !isSupported { return String(localized: "Non supportato") }
        if WatchSyncAuth.peerSecretMismatchDetected { return String(localized: "sync.trust.mismatch") }
        if failedImportCount > 0 { return String(localized: "Errore import: retry disponibile") }
        if activationState == .activated, !WCSession.default.isPaired {
            return String(localized: "sync.watch_not_paired.status")
        }
        if activationState == .activated, !WCSession.default.isWatchAppInstalled {
            return String(localized: "sync.watch_app_not_installed.status")
        }
        if activationState == .activated, !WatchSyncAuth.hasPeerSecret() { return String(localized: "Associazione Watch non verificata") }
        if activationState == .activated { return String(localized: "Attivo") }
        return String(localized: "In attesa attivazione")
    }

    private func refreshCompanionSyncAvailabilityMessage(session: WCSession = .default) {
        guard activationState == .activated else { return }
        if !session.isPaired {
            lastMessage = String(localized: "sync.watch_not_paired")
        } else if !session.isWatchAppInstalled {
            lastMessage = String(localized: "sync.watch_app_not_installed")
        } else {
            lastMessage = String(localized: "Sessione Watch attiva")
        }
    }

    func activate(logStore: DiveLogStore) {
        self.logStore = logStore
        importedSessionIDs = WatchDiveSyncCodec.loadImportedSessionIDs()
        importedSessionCount = importedSessionIDs.count
        pushedToWatchSessionIDs = loadPushedToWatchSessionIDs()
        pendingOutboundSessions = mergedPendingOutbound(pendingOutboundSessions + loadPendingOutboundSessions())
        conflicts = loadConflicts()
        guard WCSession.isSupported() else {
            lastMessage = String(localized: "WatchConnectivity non supportato")
            return
        }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func retryActivation(logStore: DiveLogStore) {
        failedImportCount = 0
        lastMessage = String(localized: "Retry Watch Sync richiesto")
        activate(logStore: logStore)
    }

    func resetPairingTrust(logStore: DiveLogStore) {
        WatchSyncAuth.resetPeerTrust()
        failedImportCount = 0
        lastMessage = String(localized: "Trust Watch resettato: attendi una nuova associazione verificata.")
        activate(logStore: logStore)
    }

    /// Push a logbook session to the paired Watch (skips demo dives and sessions received from Watch).
    func transferToWatch(_ session: DiveSession) {
        guard WCSession.isSupported() else { return }
        guard !session.isDemoDive else { return }
        guard !importedSessionIDs.contains(session.id) else { return }
        guard !pushedToWatchSessionIDs.contains(session.id) else { return }
        enqueueOutboundSession(session)
        if WatchSyncAuth.hasPeerSecret() {
            flushOutboundTransfers()
        } else {
            WatchSyncAuth.publishSharedSecretIfNeeded()
            lastMessage = String(format: String(localized: "In coda verso Watch (%lld) — attendi associazione"), pendingOutboundSessions.count)
        }
    }

    /// Incremental sync: push sessions not yet sent and not imported from Watch.
    func syncUnpushedSessionsToWatch() {
        guard let sessions = logStore?.sessions else { return }
        for session in sessions where !session.isDemoDive {
            transferToWatch(session)
        }
    }

    func publishDeletedSessionIDs(_ ids: Set<UUID>) {
        guard WCSession.isSupported(), !ids.isEmpty else { return }
        guard WatchSyncAuth.canPublishApplicationContext() else {
            refreshCompanionSyncAvailabilityMessage()
            return
        }
        var existing = Set((WCSession.default.applicationContext[WatchSyncKeys.deletedSessionBroadcastKey] as? [String]) ?? [])
        existing.formUnion(ids.map(\.uuidString))
        guard WatchSyncAuth.mergeApplicationContext([WatchSyncKeys.deletedSessionBroadcastKey: Array(existing)]) else {
            refreshCompanionSyncAvailabilityMessage()
            return
        }
        lastMessage = String(format: String(localized: "Tombstone inviata al Watch (%lld)"), ids.count)
    }

    func pushUnitsPreference(_ value: String) {
        let preference = IOSUnitPreference.fromStorage(value)
        guard WCSession.isSupported() else { return }
        guard WatchSyncAuth.mergeApplicationContext([WatchSyncKeys.unitsPreferenceKey: preference.syncCode]) else {
            refreshCompanionSyncAvailabilityMessage()
            return
        }
    }

    func sendPhotoToWatch(_ imageData: Data, fileName: String, photoID: String) {
        guard WCSession.isSupported(), !imageData.isEmpty else { return }
        guard WCSession.default.isPaired, WCSession.default.isWatchAppInstalled else {
            refreshCompanionSyncAvailabilityMessage()
            updateCompanionPhotoTransfer(
                photoID: photoID,
                fileName: fileName,
                state: .failed,
                errorMessage: String(localized: "sync.watch_app_not_installed")
            )
            return
        }
        guard imageData.count <= Self.maxPhotoTransferBytes,
              let sanitized = Self.sanitizedPhotoFileName(fileName) else {
            failedImportCount += 1
            updateCompanionPhotoTransfer(
                photoID: photoID,
                fileName: fileName,
                state: .failed,
                errorMessage: String(localized: "Errore invio foto Watch: file non valido")
            )
            return
        }

        updateCompanionPhotoTransfer(photoID: photoID, fileName: sanitized, state: .sending)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("DIRDivingPhoto_\(photoID)_\(sanitized)")
        do {
            try imageData.write(to: url, options: .atomic)
            _ = WCSession.default.transferFile(
                url,
                metadata: CompanionPhotoTransferSupport.makeTransferMetadata(photoID: photoID, fileName: sanitized)
            )
            photoIDByTransferFilePath[url.path] = photoID
            updateCompanionPhotoTransfer(photoID: photoID, fileName: sanitized, state: .queued)
            lastMessage = String(localized: "watch_photo_status_queued")
            recordActivity(title: String(localized: "sync.activity.photo_to_watch"), detail: sanitized)
        } catch {
            updateCompanionPhotoTransfer(
                photoID: photoID,
                fileName: sanitized,
                state: .failed,
                errorMessage: error.localizedDescription
            )
            lastMessage = String(localized: "watch_photo_status_failed")
        }
    }

    private func updateCompanionPhotoTransfer(
        photoID: String,
        fileName: String,
        state: CompanionPhotoTransferStatus.State,
        errorMessage: String? = nil,
        storedFileNameOnWatch: String? = nil,
        rejectionErrorCode: String? = nil
    ) {
        if var current = companionPhotoTransfersByID[photoID] {
            current.state = state
            current.errorMessage = errorMessage
            if let storedFileNameOnWatch {
                current.storedFileNameOnWatch = storedFileNameOnWatch
            }
            if let rejectionErrorCode {
                current.rejectionErrorCode = rejectionErrorCode
            }
            companionPhotoTransfersByID[photoID] = current
        } else {
            companionPhotoTransfersByID[photoID] = CompanionPhotoTransferStatus(
                photoID: photoID,
                fileName: fileName,
                state: state,
                errorMessage: errorMessage,
                storedFileNameOnWatch: storedFileNameOnWatch,
                rejectionErrorCode: rejectionErrorCode
            )
        }
        companionPhotoTransfer = companionPhotoTransfersByID[photoID]
    }

    private func markPhotoImportedOnWatch(photoID: String, storedFileName: String?) {
        cancelPhotoImportVerification(for: photoID)
        guard var transfer = companionPhotoTransfersByID[photoID] else { return }
        transfer.state = .importedOnWatch
        transfer.storedFileNameOnWatch = storedFileName ?? transfer.storedFileNameOnWatch
        transfer.errorMessage = nil
        transfer.rejectionErrorCode = nil
        companionPhotoTransfersByID[photoID] = transfer
        companionPhotoTransfer = transfer
        lastMessage = String(localized: "watch_photo_status_imported")
        recordActivity(
            title: String(localized: "sync.activity.photo_to_watch"),
            detail: transfer.storedFileNameOnWatch ?? transfer.fileName,
            marksSuccess: true
        )
        requestWatchImageInventory()
    }

    private func schedulePhotoImportVerification(photoID: String, expectedFileName: String) {
        cancelPhotoImportVerification(for: photoID)
        pendingPhotoImportVerificationTasks[photoID] = Task { @MainActor [weak self] in
            guard let self else { return }
            for delay in [2.0, 5.0, 10.0] {
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                guard !Task.isCancelled else { return }
                guard let transfer = self.companionPhotoTransfersByID[photoID] else { return }
                if transfer.state == .importedOnWatch || transfer.state == .rejectedByWatch || transfer.state == .failed {
                    return
                }
                self.requestWatchImageInventory()
            }
        }
    }

    private func cancelPhotoImportVerification(for photoID: String) {
        pendingPhotoImportVerificationTasks[photoID]?.cancel()
        pendingPhotoImportVerificationTasks[photoID] = nil
    }

    private func removeStagingFile(at path: String) {
        try? FileManager.default.removeItem(atPath: path)
    }

    func requestWatchImageInventory() {
        guard WCSession.isSupported() else {
            watchImageInventoryStatus = .failed
            inventoryErrorMessage = String(localized: "watch_photo.inventory.failed")
            return
        }
        guard WCSession.default.isPaired, WCSession.default.isWatchAppInstalled, activationState == .activated else {
            watchImageInventoryStatus = .watchUnavailable
            inventoryErrorMessage = String(localized: "watch_photo.inventory.watch_unavailable")
            return
        }
        let requestID = UUID().uuidString
        pendingInventoryRequestID = requestID
        watchImageInventoryStatus = .loading
        inventoryErrorMessage = nil
        let payload = CompanionPhotoManagementSupport.makeInventoryRequestPayload(requestID: requestID)
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(payload, replyHandler: { [weak self] reply in
                Task { @MainActor in
                    self?.handleWatchImageInventoryResponse(reply)
                }
            }, errorHandler: { [weak self] _ in
                Task { @MainActor in
                    session.transferUserInfo(payload)
                    self?.watchImageInventoryStatus = .stale
                    self?.inventoryErrorMessage = String(localized: "watch_photo.inventory.stale")
                }
            })
        } else {
            session.transferUserInfo(payload)
            watchImageInventoryStatus = .stale
            inventoryErrorMessage = String(localized: "watch_photo.inventory.stale")
        }
    }

    func requestDeletePhotoOnWatch(storedFileName: String) {
        guard let sanitized = Self.sanitizedPhotoFileName(storedFileName) else {
            inventoryErrorMessage = String(localized: "watch_photo.delete.status.failed")
            return
        }
        guard WCSession.isSupported(), WCSession.default.isPaired, WCSession.default.isWatchAppInstalled, activationState == .activated else {
            inventoryErrorMessage = String(localized: "watch_photo.delete.status.watch_unavailable")
            return
        }
        let requestID = UUID().uuidString
        let request = WatchPhotoDeleteRequestState(
            id: requestID,
            storedFileName: sanitized,
            state: .sending,
            errorCode: nil,
            createdAt: Date()
        )
        pendingDeleteRequests[requestID] = request
        let payload = CompanionPhotoManagementSupport.makeDeleteRequestPayload(
            requestID: requestID,
            storedFileName: sanitized
        )
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(payload, replyHandler: nil) { [weak self] _ in
                Task { @MainActor in
                    session.transferUserInfo(payload)
                    self?.updateDeleteRequest(requestID: requestID, state: .deliveredToConnectivity)
                }
            }
            updateDeleteRequest(requestID: requestID, state: .sending)
        } else {
            session.transferUserInfo(payload)
            updateDeleteRequest(requestID: requestID, state: .deliveredToConnectivity)
            watchImageInventoryStatus = .stale
            inventoryErrorMessage = String(localized: "watch_photo.inventory.stale")
        }
    }

    private func updateDeleteRequest(requestID: String, state: WatchPhotoDeleteRequestState.State, errorCode: String? = nil) {
        guard var request = pendingDeleteRequests[requestID] else { return }
        request.state = state
        request.errorCode = errorCode
        pendingDeleteRequests[requestID] = request
    }

    private func handleWatchImageInventoryResponse(_ payload: [String: Any]) {
        guard let response = CompanionPhotoManagementSupport.parseInventoryResponse(payload) else {
            watchImageInventoryStatus = .failed
            inventoryErrorMessage = String(localized: "watch_photo.inventory.failed")
            return
        }
        if let requestID = response.requestID, requestID == pendingInventoryRequestID {
            pendingInventoryRequestID = nil
        }
        if response.status == CompanionPhotoManagementSupport.inventoryStatusOK {
            watchImageInventory = response.items.filter(\.isDeletable)
            watchImageInventoryStatus = .loaded
            lastInventoryRefreshDate = response.generatedAt ?? Date()
            inventoryErrorMessage = nil
            reconcilePhotoTransfers(with: watchImageInventory)
        } else {
            watchImageInventoryStatus = .failed
            inventoryErrorMessage = String(localized: "watch_photo.inventory.failed")
        }
    }

    private func handleWatchPhotoDeleteAck(_ payload: [String: Any]) {
        guard let ack = CompanionPhotoManagementSupport.parseDeleteAck(payload) else { return }
        guard !handledDeleteAckRequestIDs.contains(ack.requestID) else { return }
        guard var request = pendingDeleteRequests[ack.requestID] else { return }
        guard let mappedState = CompanionPhotoManagementSupport.deleteStatus(for: ack.status) else { return }
        request.state = mappedState
        request.errorCode = ack.errorCode
        pendingDeleteRequests[ack.requestID] = request
        handledDeleteAckRequestIDs.insert(ack.requestID)
        if mappedState == .deletedOnWatch || mappedState == .notFound {
            watchImageInventory.removeAll { $0.storedFileName == ack.storedFileName }
            requestWatchImageInventory()
        }
    }

    private func reconcilePhotoTransfers(with inventory: [WatchUserImageInventoryItem]) {
        let storedNames = Set(inventory.map(\.storedFileName))
        for (photoID, transfer) in companionPhotoTransfersByID {
            guard transfer.state == .deliveredToConnectivity || transfer.state == .queued || transfer.state == .sending else {
                continue
            }
            if let matched = matchingInventoryName(for: transfer, in: storedNames) {
                markPhotoImportedOnWatch(photoID: photoID, storedFileName: matched)
            }
        }
    }

    private func matchingInventoryName(for transfer: CompanionPhotoTransferStatus, in storedNames: Set<String>) -> String? {
        let candidates = [transfer.storedFileNameOnWatch, transfer.fileName].compactMap { $0 }
        for candidate in candidates where storedNames.contains(candidate) {
            return candidate
        }
        let stem = URL(fileURLWithPath: transfer.fileName).deletingPathExtension().lastPathComponent
        return storedNames.first { $0.hasPrefix(stem) }
    }

    func reportCompanionPhotoFailure(message: String, fileName: String = "companion.jpg") {
        updateCompanionPhotoTransfer(
            photoID: UUID().uuidString,
            fileName: fileName,
            state: .failed,
            errorMessage: message
        )
        lastMessage = String(localized: "watch_photo_status_failed")
    }

    private func handleCompanionPhotoAck(_ payload: [String: Any]) {
        guard let ack = CompanionPhotoTransferSupport.parseCompanionPhotoAck(payload) else { return }
        var transfer = companionPhotoTransfersByID[ack.photoID]
        if transfer == nil, companionPhotoTransfer?.photoID == ack.photoID {
            transfer = companionPhotoTransfer
        }
        guard transfer != nil else { return }
        var optionalTransfer: CompanionPhotoTransferStatus? = transfer
        CompanionPhotoTransferSupport.applyAck(ack, to: &optionalTransfer)
        guard let updated = optionalTransfer else { return }
        companionPhotoTransfersByID[ack.photoID] = updated
        companionPhotoTransfer = updated
        switch updated.state {
        case .importedOnWatch:
            cancelPhotoImportVerification(for: ack.photoID)
            lastMessage = String(localized: "watch_photo_status_imported")
            recordActivity(
                title: String(localized: "sync.activity.photo_to_watch"),
                detail: updated.storedFileNameOnWatch ?? updated.fileName,
                marksSuccess: true
            )
            requestWatchImageInventory()
        case .rejectedByWatch:
            cancelPhotoImportVerification(for: ack.photoID)
            lastMessage = String(localized: "watch_photo_status_rejected")
            recordActivity(
                title: String(localized: "sync.activity.photo_to_watch"),
                detail: updated.rejectionErrorCode ?? updated.fileName
            )
        default:
            break
        }
    }

    private static func sanitizedPhotoFileName(_ fileName: String) -> String? {
        let lastPathComponent = URL(fileURLWithPath: fileName).lastPathComponent
        let url = URL(fileURLWithPath: lastPathComponent)
        let pathExtension = url.pathExtension.lowercased()
        guard allowedPhotoExtensions.contains(pathExtension) else { return nil }

        let rawBaseName = url.deletingPathExtension().lastPathComponent
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_ "))
        let cleanedScalars = rawBaseName.unicodeScalars.map { scalar in
            allowedCharacters.contains(scalar) ? Character(scalar) : "_"
        }
        let cleanedBaseName = String(cleanedScalars)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .prefix(80)
        guard !cleanedBaseName.isEmpty else { return nil }
        return "\(cleanedBaseName).\(pathExtension)"
    }

    private func ingestCompanionContext(_ context: [String: Any]) {
        switch WatchSyncAuth.ingestSharedSecretFromContext(context) {
        case .rejectedMismatch:
            lastMessage = String(localized: "sync.trust.mismatch")
        case .acceptedFirstTrust, .unchanged:
            break
        }
        if let units = context[WatchSyncKeys.unitsPreferenceKey] as? String {
            let preference = IOSUnitPreference.fromSyncCode(units)
            UserDefaults.standard.set(preference.rawValue, forKey: IOSUnitPreference.storageKey)
        }
        if let strings = context[WatchSyncKeys.deletedSessionBroadcastKey] as? [String] {
            let ids = Set(strings.compactMap(UUID.init(uuidString:)))
            if !ids.isEmpty {
                logStore?.applyRemoteDeletedSessionIDs(ids)
                lastMessage = String(format: String(localized: "Tombstone Watch applicata (%lld)"), ids.count)
            }
        }
    }

    private struct AckContext {
        let sessionID: UUID
        let issuedAt: Date
    }

    @discardableResult
    private func importSessionPayload(_ payload: [String: Any]) -> AckContext? {
        do {
            let parsed = try WatchDiveSyncCodec.parsePayload(from: payload)
            let session = parsed.session
            if let existing = logStore?.session(id: session.id) {
                if WatchSyncSessionDiff.hasSignificantDifference(local: existing, incoming: session) {
                    storeConflict(local: existing, incoming: session)
                    lastMessage = String(localized: "Conflitto sync salvato per revisione")
                    recordActivity(title: String(localized: "sync.activity.conflict"), detail: sessionSummary(session))
                    return AckContext(sessionID: session.id, issuedAt: parsed.issuedAt)
                }
                logStore?.add(session, suppressWatchPush: true)
                importedSessionIDs = WatchSyncBoundedIDStore.merge(
                    session.id,
                    into: importedSessionIDs,
                    maxCount: WatchSyncBoundedIDStore.maxImportedSessionIDs
                )
                WatchDiveSyncCodec.saveImportedSessionIDs(importedSessionIDs)
                importedSessionCount = importedSessionIDs.count
                lastMessage = String(localized: "Immersione aggiornata dal Watch")
                recordActivity(title: String(localized: "sync.activity.received_from_watch"), detail: sessionSummary(session), marksSuccess: true)
                return AckContext(sessionID: session.id, issuedAt: parsed.issuedAt)
            }
            guard !importedSessionIDs.contains(session.id) else {
                lastMessage = String(localized: "Immersione duplicata ignorata")
                return AckContext(sessionID: session.id, issuedAt: parsed.issuedAt)
            }
            logStore?.add(session, suppressWatchPush: true)
            importedSessionIDs = WatchSyncBoundedIDStore.merge(
                session.id,
                into: importedSessionIDs,
                maxCount: WatchSyncBoundedIDStore.maxImportedSessionIDs
            )
            WatchDiveSyncCodec.saveImportedSessionIDs(importedSessionIDs)
            importedSessionCount = importedSessionIDs.count
            lastMessage = String(localized: "Immersione ricevuta dal Watch")
            recordActivity(title: String(localized: "sync.activity.received_from_watch"), detail: sessionSummary(session), marksSuccess: true)
            return AckContext(sessionID: session.id, issuedAt: parsed.issuedAt)
        } catch {
            failedImportCount += 1
            lastMessage = String(format: String(localized: "Errore sync Watch: %@"), error.localizedDescription)
            Self.logger.error("Watch sync import failed: \(error.localizedDescription, privacy: .private)")
            return nil
        }
    }

    func resolveConflictUsingIncoming(_ conflict: SyncConflict) {
        logStore?.add(conflict.incoming, suppressWatchPush: true)
        importedSessionIDs.insert(conflict.id)
        WatchDiveSyncCodec.saveImportedSessionIDs(importedSessionIDs)
        importedSessionCount = importedSessionIDs.count
        removeConflict(conflict)
        lastMessage = String(localized: "Conflitto risolto: usata versione Watch")
    }

    func resolveConflictKeepingLocal(_ conflict: SyncConflict) {
        importedSessionIDs.insert(conflict.id)
        WatchDiveSyncCodec.saveImportedSessionIDs(importedSessionIDs)
        importedSessionCount = importedSessionIDs.count
        removeConflict(conflict)
        if let local = logStore?.session(id: conflict.id), !local.isDemoDive {
            pushedToWatchSessionIDs.remove(conflict.id)
            savePushedToWatchSessionIDs()
            transferToWatch(local)
            lastMessage = String(localized: "more.sync.keep_local_repushed")
        } else {
            lastMessage = String(localized: "more.sync.keep_local_only")
        }
    }

    private func storeConflict(local: DiveSession, incoming: DiveSession) {
        conflicts.removeAll { $0.id == incoming.id }
        conflicts.insert(
            SyncConflict(
                id: incoming.id,
                detectedAt: Date(),
                localSummary: WatchSyncSessionDiff.conflictSummary(local: local, incoming: incoming),
                incoming: incoming
            ),
            at: 0
        )
        saveConflicts()
    }

    private func removeConflict(_ conflict: SyncConflict) {
        conflicts.removeAll { $0.id == conflict.id }
        saveConflicts()
    }

    private func conflictsFileURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(conflictsFileName)
    }

    private func loadConflicts() -> [SyncConflict] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        // Primary source: Documents/ file (with Data Protection).
        let url = conflictsFileURL()
        if FileManager.default.fileExists(atPath: url.path),
           let data = try? Data(contentsOf: url),
           let decoded = try? decoder.decode([SyncConflict].self, from: data) {
            return decoded
        }

        // F9 migration: import once from UserDefaults, then write to the new file
        // and clear the legacy key to keep PII out of UserDefaults going forward.
        guard let legacyData = UserDefaults.standard.data(forKey: legacyConflictsKey) else { return [] }
        let migrated = (try? decoder.decode([SyncConflict].self, from: legacyData)) ?? []
        if !migrated.isEmpty {
            persistConflicts(migrated)
        }
        UserDefaults.standard.removeObject(forKey: legacyConflictsKey)
        return migrated
    }

    private func saveConflicts() {
        persistConflicts(conflicts)
    }

    private func enqueueOutboundSession(_ session: DiveSession) {
        pendingOutboundSessions.removeAll { $0.id == session.id }
        pendingOutboundSessions.append(session)
        pendingOutboundSessions.sort { $0.startDate > $1.startDate }
        savePendingOutboundSessions()
        recordActivity(title: String(localized: "sync.activity.pending_to_watch"), detail: sessionSummary(session))
    }

    private func removeOutboundSession(id: UUID) {
        pendingOutboundSessions.removeAll { $0.id == id }
        savePendingOutboundSessions()
    }

    private func flushOutboundTransfers() {
        guard WatchSyncAuth.hasPeerSecret(), !pendingOutboundSessions.isEmpty else { return }
        let queue = pendingOutboundSessions
        for session in queue.reversed() {
            sendOutbound(session)
        }
    }

    private func sendOutbound(_ session: DiveSession) {
        do {
            let envelope = try WatchDiveSyncCodec.makePayload(session: session)
            if WCSession.default.isReachable {
                WCSession.default.sendMessage(envelope.message) { [weak self] reply in
                    Task { @MainActor in
                        guard let self else { return }
                        let signedOK = WatchDiveSyncCodec.verifyAckSignature(
                            reply["ackSignature"] as? String,
                            sessionID: envelope.sessionID,
                            issuedAt: envelope.issuedAt
                        )
                        guard signedOK else {
                            self.failedImportCount += 1
                            self.lastMessage = String(localized: "sync.watch.pending_ack")
                            self.recordActivity(title: String(localized: "sync.activity.pending_to_watch"), detail: self.sessionSummary(session))
                            return
                        }
                        self.markPushedToWatch(session.id)
                        self.removeOutboundSession(id: session.id)
                        self.lastMessage = String(localized: "Immersione inviata al Watch")
                        self.recordActivity(title: String(localized: "sync.activity.sent_to_watch"), detail: self.sessionSummary(session), marksSuccess: true)
                    }
                } errorHandler: { [weak self] _ in
                    Task { @MainActor in
                        WCSession.default.transferUserInfo(envelope.message)
                        self?.lastMessage = String(localized: "Invio Watch in coda (transferUserInfo)")
                        self?.recordActivity(title: String(localized: "sync.activity.queued_to_watch"), detail: self?.sessionSummary(session) ?? "")
                    }
                }
            } else {
                WCSession.default.transferUserInfo(envelope.message)
                lastMessage = String(localized: "Invio Watch in coda (Watch non raggiungibile)")
                recordActivity(title: String(localized: "sync.activity.queued_to_watch"), detail: sessionSummary(session))
            }
            Self.logger.info("Outbound session push queued id=\(session.id.uuidString, privacy: .public)")
        } catch {
            failedImportCount += 1
            lastMessage = String(format: String(localized: "Errore invio Watch: %@"), error.localizedDescription)
            Self.logger.error("Outbound Watch push failed: \(error.localizedDescription, privacy: .private)")
        }
    }

    private func savePushedToWatchSessionIDs() {
        var order = loadPushedToWatchSessionIDOrder().filter { pushedToWatchSessionIDs.contains($0) }
        for id in pushedToWatchSessionIDs where !order.contains(id) {
            order.append(id)
        }
        if order.count > WatchSyncBoundedIDStore.maxPushedToWatchSessionIDs {
            order.removeFirst(order.count - WatchSyncBoundedIDStore.maxPushedToWatchSessionIDs)
        }
        UserDefaults.standard.set(order.map(\.uuidString), forKey: pushedToWatchIDsKey)
        pushedToWatchSessionIDs = Set(order)
    }

    private func loadPushedToWatchSessionIDs() -> Set<UUID> {
        Set(loadPushedToWatchSessionIDOrder())
    }

    private func loadPushedToWatchSessionIDOrder() -> [UUID] {
        guard let strings = UserDefaults.standard.stringArray(forKey: pushedToWatchIDsKey) else { return [] }
        return strings.compactMap(UUID.init(uuidString:))
    }

    private func markPushedToWatch(_ id: UUID) {
        pushedToWatchSessionIDs = WatchSyncBoundedIDStore.merge(
            id,
            into: pushedToWatchSessionIDs,
            maxCount: WatchSyncBoundedIDStore.maxPushedToWatchSessionIDs
        )
        savePushedToWatchSessionIDs()
    }

    private func pendingOutboundFileURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(pendingOutboundFileName)
    }

    private func loadPendingOutboundSessions() -> [DiveSession] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let url = pendingOutboundFileURL()
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let decoded = try? decoder.decode([DiveSession].self, from: data) else {
            return []
        }
        return mergedPendingOutbound(decoded)
    }

    private func savePendingOutboundSessions() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let value = mergedPendingOutbound(pendingOutboundSessions)
        guard let data = try? encoder.encode(value) else { return }
        do {
            try data.write(to: pendingOutboundFileURL(), options: [.atomic, .completeFileProtection])
        } catch {
            Self.logger.error("Persist iOS pending Watch sync sessions failed: \(error.localizedDescription, privacy: .private)")
        }
    }

    private func mergedPendingOutbound(_ sessions: [DiveSession]) -> [DiveSession] {
        var byID: [UUID: DiveSession] = [:]
        for session in sessions {
            if let existing = byID[session.id] {
                byID[session.id] = DiveSessionMerge.preferred(existing, session)
            } else {
                byID[session.id] = session
            }
        }
        return byID.values.sorted { $0.startDate > $1.startDate }
    }

    private func persistConflicts(_ value: [SyncConflict]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(value) else { return }
        do {
            try data.write(to: conflictsFileURL(), options: [.atomic, .completeFileProtection])
        } catch {
            Self.logger.error("Persist watch-sync conflicts failed: \(error.localizedDescription, privacy: .private)")
        }
    }

    private func sessionSummary(_ session: DiveSession) -> String {
        let started = Self.activityDateFormatter.string(from: session.startDate)
        let minutes = Int((session.durationSeconds / 60).rounded())
        return String(
            format: String(localized: "sync.activity.session_summary"),
            started,
            Formatters.one(session.maxDepthMeters),
            minutes
        )
    }

    private func recordActivity(title: String, detail: String, marksSuccess: Bool = false) {
        let normalizedDetail = detail.isEmpty ? "—" : detail
        let timestamp = Date()
        recentActivity.insert(
            SyncActivityItem(title: title, detail: normalizedDetail, timestamp: timestamp),
            at: 0
        )
        recentActivity = Array(recentActivity.prefix(6))
        if marksSuccess {
            lastSuccessfulSyncDate = timestamp
        }
    }
}

extension WatchSyncService: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        let context = session.receivedApplicationContext
        Task { @MainActor in
            self.activationState = activationState
            if let error {
                self.lastMessage = error.localizedDescription
            } else if activationState == .activated {
                self.refreshCompanionSyncAvailabilityMessage(session: session)
            } else {
                self.lastMessage = String(localized: "In attesa attivazione")
            }
            if activationState == .activated {
                self.ingestCompanionContext(context)
                if WatchSyncAuth.canPublishApplicationContext(session: session) {
                    WatchSyncAuth.publishSharedSecretIfNeeded(session: session)
                    self.flushOutboundTransfers()
                }
            }
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor in
            self.ingestCompanionContext(applicationContext)
            WatchSyncAuth.publishSharedSecretIfNeeded()
            self.flushOutboundTransfers()
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        Task { @MainActor in
            if CompanionPhotoManagementSupport.isInventoryResponse(message) {
                self.handleWatchImageInventoryResponse(message)
                return
            }
            if CompanionPhotoManagementSupport.isDeleteAck(message) {
                self.handleWatchPhotoDeleteAck(message)
                return
            }
            if CompanionPhotoTransferSupport.isCompanionPhotoAck(message) {
                self.handleCompanionPhotoAck(message)
                return
            }
            _ = self.importSessionPayload(message)
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        Task { @MainActor in
            if CompanionPhotoManagementSupport.isInventoryResponse(message) {
                self.handleWatchImageInventoryResponse(message)
                replyHandler(["status": "acknowledged"])
                return
            }
            if CompanionPhotoManagementSupport.isDeleteAck(message) {
                self.handleWatchPhotoDeleteAck(message)
                replyHandler(["status": "acknowledged"])
                return
            }
            if CompanionPhotoTransferSupport.isCompanionPhotoAck(message) {
                self.handleCompanionPhotoAck(message)
                replyHandler(["status": "acknowledged"])
                return
            }
            let beforeFailures = self.failedImportCount
            let ackContext = self.importSessionPayload(message)
            let acknowledged = self.failedImportCount == beforeFailures
            var reply: [String: Any] = ["status": acknowledged ? "acknowledged" : "failed"]
            if acknowledged, let ackContext {
                // SYNC-001/SYNC-003: signed ack lets the Watch confirm that this
                // reply was produced by the same trusted iOS peer.
                reply["ackSignature"] = WatchDiveSyncCodec.ackSignature(
                    sessionID: ackContext.sessionID,
                    issuedAt: ackContext.issuedAt
                )
            }
            replyHandler(reply)
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        Task { @MainActor in
            if CompanionPhotoManagementSupport.isInventoryResponse(userInfo) {
                self.handleWatchImageInventoryResponse(userInfo)
                return
            }
            if CompanionPhotoManagementSupport.isDeleteAck(userInfo) {
                self.handleWatchPhotoDeleteAck(userInfo)
                return
            }
            if CompanionPhotoTransferSupport.isCompanionPhotoAck(userInfo) {
                self.handleCompanionPhotoAck(userInfo)
                return
            }
            _ = self.importSessionPayload(userInfo)
        }
    }

    nonisolated func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        let filePath = fileTransfer.file.fileURL.path
        let fileName = (fileTransfer.file.metadata?[WatchSyncKeys.companionPhotoFileNameKey] as? String)
            ?? fileTransfer.file.fileURL.lastPathComponent
        Task { @MainActor in
            self.removeStagingFile(at: filePath)
            guard let photoID = self.photoIDByTransferFilePath.removeValue(forKey: filePath) else { return }
            if let error {
                self.cancelPhotoImportVerification(for: photoID)
                self.updateCompanionPhotoTransfer(
                    photoID: photoID,
                    fileName: fileName,
                    state: .failed,
                    errorMessage: error.localizedDescription
                )
                self.lastMessage = String(localized: "watch_photo_status_failed")
                return
            }
            self.updateCompanionPhotoTransfer(
                photoID: photoID,
                fileName: fileName,
                state: .deliveredToConnectivity
            )
            self.lastMessage = String(localized: "watch_photo_status_delivered_pending")
            self.schedulePhotoImportVerification(photoID: photoID, expectedFileName: fileName)
        }
    }

    nonisolated func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        Task { @MainActor in
            if let error {
                self.failedImportCount += 1
                self.lastMessage = String(format: String(localized: "Invio Watch in coda non completato: %@"), error.localizedDescription)
                return
            }
            guard let id = WatchDiveSyncCodec.sessionID(fromOutboundPayload: userInfoTransfer.userInfo) else {
                self.failedImportCount += 1
                self.lastMessage = String(localized: "Invio Watch completato ma sessione non identificabile")
                return
            }
            self.markPushedToWatch(id)
            self.removeOutboundSession(id: id)
            self.lastMessage = String(localized: "Immersione consegnata al Watch via coda")
            self.recordActivity(title: String(localized: "sync.activity.sent_to_watch"), detail: id.uuidString, marksSuccess: true)
        }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}
    nonisolated func sessionDidDeactivate(_ session: WCSession) { WCSession.default.activate() }
}
