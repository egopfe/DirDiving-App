import Foundation

/// Tombstone publish surface for Snorkeling logbook deletes.
protocol SnorkelingSessionTombstonePublishing: AnyObject {
    func publishDeletedSnorkelingSessionIDs(_ ids: Set<UUID>)
}
