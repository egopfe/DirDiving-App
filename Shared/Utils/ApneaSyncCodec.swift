import Foundation
import CryptoKit

enum ApneaSyncCodec {
    static let currentSchemaVersion = 1
    static let algorithmVersion = "apnea-sync-shared-1"
    static let defaultTTL: TimeInterval = 7 * 24 * 60 * 60
    static let maxIssuedAtSkew: TimeInterval = 5 * 60

    static func canonicalBodyData(_ body: ApneaSyncPackageBody) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(body)
    }

    static func checksum(for body: ApneaSyncPackageBody) throws -> String {
        sha256Hex(try canonicalBodyData(body))
    }

    static func seal(_ body: ApneaSyncPackageBody) throws -> ApneaSyncPackage {
        ApneaSyncPackage(body: body, payloadChecksumSHA256: try checksum(for: body))
    }

    static func encode(_ package: ApneaSyncPackage) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(package)
    }

    static func decode(_ data: Data) throws -> ApneaSyncPackage {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(ApneaSyncPackage.self, from: data)
    }

    static func validate(_ package: ApneaSyncPackage, now: Date = Date()) throws {
        guard package.body.schemaVersion <= currentSchemaVersion else {
            throw ApneaSyncValidationError.futureSchema
        }
        guard package.body.schemaVersion >= 1 else {
            throw ApneaSyncValidationError.unsupportedSchema
        }
        let expected = try checksum(for: package.body)
        guard expected == package.payloadChecksumSHA256 else {
            throw ApneaSyncValidationError.checksumMismatch
        }
        if let expiresAt = package.body.expiresAt, expiresAt < now {
            throw ApneaSyncValidationError.expired
        }
        guard package.body.capabilities.minimumWatchSchemaVersion <= currentSchemaVersion else {
            throw ApneaSyncValidationError.unsupportedCapabilities
        }
        guard ApneaSessionPlanValidator.isValid(package.body.plan) else {
            throw ApneaSyncValidationError.invalidPlan
        }
    }

    static func ackCanonical(
        packageID: UUID,
        revision: Int,
        checksum: String,
        issuedAt: Date
    ) -> String {
        "apneaPlanAck|\(packageID.uuidString)|\(revision)|\(checksum)|\(issuedAt.timeIntervalSince1970)"
    }

    static func sha256Hex(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}
