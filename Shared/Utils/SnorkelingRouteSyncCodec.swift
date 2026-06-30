import Foundation
import CryptoKit

enum SnorkelingRouteSyncCodec {
    static let currentSchemaVersion = 1
    static let algorithmVersion = "snorkeling-route-sync-1"
    static let defaultTTL: TimeInterval = 7 * 24 * 60 * 60
    static let maxIssuedAtSkew: TimeInterval = 5 * 60

    static func canonicalBodyData(_ body: SnorkelingRouteSyncPackageBody) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(body)
    }

    static func checksum(for body: SnorkelingRouteSyncPackageBody) throws -> String {
        sha256Hex(try canonicalBodyData(body))
    }

    static func seal(_ body: SnorkelingRouteSyncPackageBody) throws -> SnorkelingRouteSyncPackage {
        SnorkelingRouteSyncPackage(body: body, payloadChecksumSHA256: try checksum(for: body))
    }

    static func encode(_ package: SnorkelingRouteSyncPackage) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(package)
    }

    static func decode(_ data: Data) throws -> SnorkelingRouteSyncPackage {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(SnorkelingRouteSyncPackage.self, from: data)
    }

    static func validate(_ package: SnorkelingRouteSyncPackage, now: Date = Date()) throws {
        guard package.body.schemaVersion <= currentSchemaVersion else {
            throw SnorkelingRouteSyncValidationError.futureSchema
        }
        guard package.body.schemaVersion >= 1 else {
            throw SnorkelingRouteSyncValidationError.unsupportedSchema
        }
        let expected = try checksum(for: package.body)
        guard expected == package.payloadChecksumSHA256 else {
            throw SnorkelingRouteSyncValidationError.checksumMismatch
        }
        if let expiresAt = package.body.expiresAt, expiresAt < now {
            throw SnorkelingRouteSyncValidationError.expired
        }
        guard package.body.capabilities.minimumWatchSchemaVersion <= currentSchemaVersion else {
            throw SnorkelingRouteSyncValidationError.unsupportedCapabilities
        }
        guard SnorkelingRoutePlanValidator.isValid(package.body.routePlan) else {
            throw SnorkelingRouteSyncValidationError.invalidRoute
        }
    }

    static func ackCanonical(
        packageID: UUID,
        revision: Int,
        checksum: String,
        issuedAt: Date
    ) -> String {
        "snorkelRouteAck|\(packageID.uuidString)|\(revision)|\(checksum)|\(issuedAt.timeIntervalSince1970)"
    }

    static func sha256Hex(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}

enum SnorkelingRoutePackageBuilder {
    static func build(
        draft: SnorkelingRoutePlannerDraft,
        profile: SnorkelingCompanionProfile?,
        packageID: UUID,
        revision: Int,
        now: Date = Date()
    ) throws -> SnorkelingRouteSyncPackage {
        let routePlan = draft.asRoutePlan()
        guard SnorkelingRouteValidator.validate(draft: draft, profile: profile).allowsWatchTransfer else {
            throw SnorkelingRouteSyncValidationError.invalidRoute
        }
        let body = SnorkelingRouteSyncPackageBody(
            schemaVersion: SnorkelingRouteSyncCodec.currentSchemaVersion,
            packageID: packageID,
            revision: revision,
            createdAt: now,
            expiresAt: now.addingTimeInterval(SnorkelingRouteSyncCodec.defaultTTL),
            routePlan: routePlan,
            profile: profile,
            maxDistanceLimitMeters: draft.maxDistanceLimitMeters,
            planningMetadata: SnorkelingRoutePlanningMetadata.make(from: draft, profile: profile),
            capabilities: .current
        )
        return try SnorkelingRouteSyncCodec.seal(body)
    }
}
