import Foundation

struct SnorkelingRouteSyncCapabilities: Codable, Hashable, Sendable {
    var minimumWatchSchemaVersion: Int
    var supportsMissionMode: Bool
    var supportsRouteNavigation: Bool

    static let current = SnorkelingRouteSyncCapabilities(
        minimumWatchSchemaVersion: 1,
        supportsMissionMode: true,
        supportsRouteNavigation: true
    )
}

struct SnorkelingRouteSyncPackageBody: Codable, Hashable, Sendable {
    var schemaVersion: Int
    var packageID: UUID
    var revision: Int
    var createdAt: Date
    var expiresAt: Date?
    var routePlan: SnorkelingRoutePlan
    var profile: SnorkelingCompanionProfile?
    var maxDistanceLimitMeters: Double?
    var planningMetadata: SnorkelingRoutePlanningMetadata?
    var capabilities: SnorkelingRouteSyncCapabilities
}

struct SnorkelingRouteSyncPackage: Codable, Hashable, Sendable {
    var body: SnorkelingRouteSyncPackageBody
    var payloadChecksumSHA256: String
}

enum SnorkelingRouteSyncValidationError: Error, Equatable {
    case futureSchema
    case unsupportedSchema
    case checksumMismatch
    case expired
    case invalidRoute
    case unsupportedCapabilities
    case decodeFailed
}
