import Foundation
import CryptoKit

enum DivePlanPackageCodec {
    static let currentSchemaVersion = 1
    static let algorithmVersion = "buhlmann-gf-shared-1"
    static let defaultTTL: TimeInterval = 7 * 24 * 60 * 60
    static let maxIssuedAtSkew: TimeInterval = 5 * 60

    static func canonicalBodyData(_ body: DivePlanPackageBody) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(body)
    }

    static func checksum(for body: DivePlanPackageBody) throws -> String {
        let data = try canonicalBodyData(body)
        return sha256Hex(data)
    }

    static func seal(_ body: DivePlanPackageBody) throws -> DivePlanPackage {
        DivePlanPackage(body: body, payloadChecksumSHA256: try checksum(for: body))
    }

    static func encode(_ package: DivePlanPackage) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(package)
    }

    static func decode(_ data: Data) throws -> DivePlanPackage {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(DivePlanPackage.self, from: data)
    }

    static func validate(_ package: DivePlanPackage, now: Date = Date()) throws {
        guard package.body.schemaVersion <= currentSchemaVersion else {
            throw DivePlanPackageValidationError.futureSchema
        }
        guard package.body.schemaVersion >= 1 else {
            throw DivePlanPackageValidationError.unsupportedSchema
        }
        let expected = try checksum(for: package.body)
        guard expected == package.payloadChecksumSHA256 else {
            throw DivePlanPackageValidationError.checksumMismatch
        }
        if let expiresAt = package.body.expiresAt, expiresAt < now {
            throw DivePlanPackageValidationError.expired
        }
        guard package.body.gfLow.isFinite,
              package.body.gfHigh.isFinite,
              package.body.gfLow < package.body.gfHigh,
              package.body.gfLow >= BuhlmannCoreConfiguration.minGradientFactor,
              package.body.gfHigh <= BuhlmannCoreConfiguration.maxGradientFactor else {
            throw DivePlanPackageValidationError.invalidGradientFactors
        }
        guard package.body.capabilities.minimumWatchSchemaVersion <= currentSchemaVersion else {
            throw DivePlanPackageValidationError.unsupportedCapabilities
        }
        guard package.body.gases.contains(where: { $0.role == .bottom }) else {
            throw DivePlanPackageValidationError.invalidGases
        }
        for gas in package.body.gases {
            guard gas.oxygenFraction.isFinite,
                  gas.heliumFraction.isFinite,
                  gas.oxygenFraction >= 0,
                  gas.heliumFraction >= 0,
                  gas.oxygenFraction + gas.heliumFraction <= 1.01 else {
                throw DivePlanPackageValidationError.invalidGases
            }
        }
    }

    static func ackCanonical(
        planID: UUID,
        revision: Int,
        checksum: String,
        issuedAt: Date
    ) -> String {
        "fcPlanAck|\(planID.uuidString)|\(revision)|\(checksum)|\(issuedAt.timeIntervalSince1970)"
    }

    static func sha256Hex(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}
