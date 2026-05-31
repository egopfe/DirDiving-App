import Foundation

extension Notification.Name {
    // F8: canonical name now uses the `dirdiving` prefix.
    // NotificationCenter names are in-process only and never persisted, so the
    // legacy `dirmotion` string is kept solely as a literal reference for grep history.
    // Both Watch poster/observer stay aligned by referencing this single symbol.
    static let watchSyncPeerSecretDidUpdate = Notification.Name("dirdiving.watchSyncPeerSecretDidUpdate")
}
