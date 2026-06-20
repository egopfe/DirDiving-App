import Foundation

/// Bootstrap metadata for TOFU peer-secret exchange via WC applicationContext (SEC-P2-003).
enum WatchSyncTrustBootstrapPolicy {
    static let bootstrapVersion = 1
    static let bootstrapVersionKey = "dirdiving_watch_sync_bootstrap_version"
    static let bootstrapIssuedAtKey = "dirdiving_watch_sync_bootstrap_issued_at"
    static let bootstrapEpochKey = "dirdiving_watch_sync_bootstrap_epoch"
    static let bootstrapTTLSeconds: TimeInterval = 86_400

    enum BootstrapValidationResult: Equatable {
        case valid
        case missingMetadata
        case stale
        case futureVersion
        case epochMismatch
    }

    static func bootstrapMetadata(for epoch: Int, issuedAt: Date = Date()) -> [String: Any] {
        [
            bootstrapVersionKey: bootstrapVersion,
            bootstrapIssuedAtKey: issuedAt.timeIntervalSince1970,
            bootstrapEpochKey: epoch
        ]
    }

    static func validateBootstrapMetadata(
        _ context: [String: Any],
        expectedEpoch: Int
    ) -> BootstrapValidationResult {
        guard let version = context[bootstrapVersionKey] as? Int else {
            return .missingMetadata
        }
        guard version <= bootstrapVersion else {
            return .futureVersion
        }
        guard let issuedRaw = context[bootstrapIssuedAtKey] as? TimeInterval else {
            return .missingMetadata
        }
        let issuedAt = Date(timeIntervalSince1970: issuedRaw)
        if Date().timeIntervalSince(issuedAt) > bootstrapTTLSeconds {
            return .stale
        }
        if issuedAt.timeIntervalSinceNow > 300 {
            return .stale
        }
        if let epoch = context[bootstrapEpochKey] as? Int, epoch != expectedEpoch {
            return .epochMismatch
        }
        return .valid
    }

    static func shouldAcceptSecretBootstrap(
        context: [String: Any],
        trustEpoch: Int,
        hasExistingPeerSecret: Bool
    ) -> Bool {
        if hasExistingPeerSecret {
            return false
        }
        switch validateBootstrapMetadata(context, expectedEpoch: trustEpoch) {
        case .valid:
            return true
        case .missingMetadata:
            // Backward-compatible grace: legacy builds published secret without metadata.
            return true
        case .stale, .futureVersion, .epochMismatch:
            return false
        }
    }

    static func sanitizedContextAfterTrustEstablished(_ context: [String: Any]) -> [String: Any] {
        var sanitized = context
        sanitized.removeValue(forKey: WatchSyncAuthContext.secretKey)
        sanitized.removeValue(forKey: bootstrapVersionKey)
        sanitized.removeValue(forKey: bootstrapIssuedAtKey)
        sanitized.removeValue(forKey: bootstrapEpochKey)
        return sanitized
    }
}

/// Shared context key reference usable from Shared without importing platform WatchSyncAuth.
enum WatchSyncAuthContext {
    static let secretKey = "dirdiving_watch_sync_secret"
}
