import Foundation
import CryptoKit

/// Shared encode/decode helpers for activity session sync codecs.
enum ActivitySyncCodecSupport {
    static func acceptedVersions() -> Set<Int> {
        [
            ActivitySyncSignedTransport.legacySchemaVersion,
            ActivitySyncSignedTransport.nonceRequiredFromVersion,
            ActivitySyncSignedTransport.envelopeSchemaVersion,
        ]
    }

    static func validateVersion(_ version: Int) -> Bool {
        acceptedVersions().contains(version)
    }

    static func validateTransport(
        _ transport: ActivitySyncSignedTransport,
        payloadKey: String,
        expectedActivity: ActivitySyncActivityType
    ) throws {
        guard validateVersion(transport.version) else {
            throw ActivitySyncCodecSupportError.unsupportedVersion
        }
        if transport.version > ActivitySyncSignedTransport.envelopeSchemaVersion {
            throw ActivitySyncCodecSupportError.unsupportedVersion
        }
        try ActivitySyncRoutingGuard.validate(payloadKey: payloadKey, transport: transport)
        try ActivitySyncRoutingGuard.rejectCrossRoute(
            expectedActivity: expectedActivity,
            payloadKey: payloadKey,
            transport: transport
        )
    }

    static func revision(for updatedAt: Date?) -> Int {
        ActivitySyncRevisionPolicy.sessionRevision(for: updatedAt ?? Date())
    }
}

enum ActivitySyncCodecSupportError: Error, Equatable {
    case unsupportedVersion
    case envelopeMismatch
}
