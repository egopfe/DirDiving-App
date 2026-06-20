import Foundation
import CryptoKit

/// Software-verifiable TOFU trust posture metadata (MAIN-DCA-013). Never stores or logs raw secrets.
enum WatchSyncTrustStatePolicy {
    static let trustStateVersion = 1
    private static let fingerprintKey = "dirdiving_watch_sync_trust_fingerprint"
    private static let epochKey = "dirdiving_watch_sync_trust_epoch"
    private static let establishedAtKey = "dirdiving_watch_sync_trust_established_at"

    static func peerSecretFingerprint(_ secret: Data) -> String {
        let digest = SHA256.hash(data: secret)
        return digest.prefix(8).map { String(format: "%02x", $0) }.joined()
    }

    static func recordEstablishedTrust(peerSecret: Data) {
        UserDefaults.standard.set(peerSecretFingerprint(peerSecret), forKey: fingerprintKey)
        UserDefaults.standard.set(trustStateVersion, forKey: "dirdiving_watch_sync_trust_state_version")
        if UserDefaults.standard.object(forKey: establishedAtKey) == nil {
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: establishedAtKey)
        }
    }

    static var storedFingerprint: String? {
        UserDefaults.standard.string(forKey: fingerprintKey)
    }

    static var trustEpoch: Int {
        max(1, UserDefaults.standard.integer(forKey: epochKey))
    }

    static func incrementTrustEpochOnReset() {
        let next = trustEpoch + 1
        UserDefaults.standard.set(next, forKey: epochKey)
        UserDefaults.standard.removeObject(forKey: fingerprintKey)
        UserDefaults.standard.removeObject(forKey: establishedAtKey)
        UserDefaults.standard.removeObject(forKey: "dirdiving_watch_sync_trust_state_version")
    }

    static func resetForTests() {
        UserDefaults.standard.removeObject(forKey: fingerprintKey)
        UserDefaults.standard.removeObject(forKey: epochKey)
        UserDefaults.standard.removeObject(forKey: establishedAtKey)
        UserDefaults.standard.removeObject(forKey: "dirdiving_watch_sync_trust_state_version")
    }

    static let acceptedResidualLimitation =
        "First-use peer secret via WC applicationContext; mismatch pins trust; reset clears epoch."
}
