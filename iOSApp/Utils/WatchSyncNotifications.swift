import Foundation

extension Notification.Name {
    // F8: canonical name now uses the `dirdiving` prefix; in-process only, never persisted.
    static let watchSyncPeerSecretDidUpdate = Notification.Name("dirdiving.watchSyncPeerSecretDidUpdate")
}
