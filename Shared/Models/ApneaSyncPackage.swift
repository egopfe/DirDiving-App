import Foundation

struct ApneaSyncCapabilities: Codable, Hashable, Sendable {
    var minimumWatchSchemaVersion: Int
    var supportsMissionMode: Bool
    var supportsMarkers: Bool

    static let current = ApneaSyncCapabilities(
        minimumWatchSchemaVersion: 1,
        supportsMissionMode: true,
        supportsMarkers: true
    )
}

struct ApneaSyncPackageBody: Codable, Hashable, Sendable {
    var schemaVersion: Int
    var packageID: UUID
    var revision: Int
    var createdAt: Date
    var expiresAt: Date?
    var plan: ApneaSessionPlan
    var profile: ApneaCompanionProfile?
    var settings: ApneaCompanionSettings
    var capabilities: ApneaSyncCapabilities
}

struct ApneaSyncPackage: Codable, Hashable, Sendable {
    var body: ApneaSyncPackageBody
    var payloadChecksumSHA256: String
}

enum ApneaSyncValidationError: Error, Equatable {
    case futureSchema
    case unsupportedSchema
    case checksumMismatch
    case expired
    case invalidPlan
    case unsupportedCapabilities
    case decodeFailed
}
