import Foundation

enum WatchSyncKeys {
    static let deletedSessionIDsKey = "dirdiving_shared_deleted_session_ids"
    /// WatchConnectivity `applicationContext` broadcast of tombstone UUID strings.
    static let deletedSessionBroadcastKey = "dirdiving_deleted_session_ids"
    static let unitsPreferenceKey = "units"
}
