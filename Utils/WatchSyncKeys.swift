import Foundation

enum WatchSyncKeys {
    static let deletedSessionIDsKey = "dirdiving_shared_deleted_session_ids"
    /// WatchConnectivity `applicationContext` broadcast of tombstone UUID strings (legacy Diving).
    static let deletedSessionBroadcastKey = "dirdiving_deleted_session_ids"
    /// Activity-scoped signed tombstone broadcast payloads (v1).
    static let deletedDivingSessionTombstonesKey = "dirdiving_deleted_diving_session_tombstones"
    static let deletedApneaSessionTombstonesKey = "dirdiving_deleted_apnea_session_tombstones"
    static let deletedSnorkelingSessionTombstonesKey = "dirdiving_deleted_snorkeling_session_tombstones"
    /// Legacy Apnea KVS tombstone UUID list (Watch local cloud sync).
    static let deletedApneaSessionIDsKey = "dirdiving_watch_deleted_apnea_session_ids"
    /// Local tombstone persistence filenames (per activity).
    static let snorkelingDeletedSessionIDsLocalKey = "dirdiving_snorkeling_deleted_session_ids"
    static let unitsPreferenceKey = "units"
    /// Watch Gauge optional TTV index visibility (default OFF); synced via applicationContext.
    static let gaugeShowTTVKey = "dirdiving_watch_gauge_show_ttv"
    static let companionPhotoFileNameKey = "photoFileName"
    static let companionPhotoIDKey = "photoID"
    static let companionPhotoAckType = "companionPhotoAck"
    static let companionPhotoAckStatusKey = "status"
    static let companionPhotoAckStoredFileNameKey = "storedFileName"
    static let companionPhotoAckErrorCodeKey = "errorCode"
    static let companionPhotoInventoryRequestType = "companionPhotoInventoryRequest"
    static let companionPhotoInventoryResponseType = "companionPhotoInventoryResponse"
    static let companionPhotoInventoryRequestIDKey = "requestID"
    static let companionPhotoInventoryItemsKey = "items"
    static let companionPhotoInventoryGeneratedAtKey = "generatedAt"
    static let companionPhotoInventoryStatusKey = "status"
    static let companionPhotoInventoryErrorCodeKey = "errorCode"
    static let companionPhotoDeleteRequestType = "companionPhotoDeleteRequest"
    static let companionPhotoDeleteAckType = "companionPhotoDeleteAck"
    static let companionPhotoDeleteRequestIDKey = "requestID"
    static let companionPhotoDeleteFileNameKey = "storedFileName"
    static let companionPhotoDeleteStatusKey = "status"
    static let companionPhotoDeleteErrorCodeKey = "errorCode"
    static let diveImportAckType = "diveImportAck"
    static let diveImportAckSessionIDKey = "sessionID"
    static let diveImportAckIssuedAtKey = "issuedAt"
    static let diveImportAckSignatureKey = "ackSignature"
    static let companionPhotoManagementIssuedAtKey = "issuedAt"
    static let companionPhotoManagementSignatureKey = "signature"
}
