import Foundation
import SwiftUI

enum DIRActivityMode: String, CaseIterable, Identifiable, Codable {
    case diving = "DIVING"
    case apnea = "APNEA"
    case snorkeling = "SNORKELING"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .diving: return "Diving"
        case .apnea: return "Apnea"
        case .snorkeling: return "Snorkeling"
        }
    }

    var symbol: String {
        switch self {
        case .diving: return "water.waves"
        case .apnea: return "lungs"
        case .snorkeling: return "figure.pool.swim"
        }
    }

    var accent: Color {
        switch self {
        case .diving: return DiveUI.blue
        case .apnea: return DiveUI.yellow
        case .snorkeling: return DiveUI.green
        }
    }
}

enum ExplorationSessionState: String, Codable {
    case idle = "IDLE"
    case preDive = "PRE-DIVE"
    case active = "ACTIVE"
    case navigation = "NAV"
    case returnMode = "RETURN"
    case ended = "ENDED"
    case surface = "SURFACE"
    case dive = "DIVE"
    case warning = "WARNING"
}

enum GPSMarkerCategory: String, CaseIterable, Identifiable, Codable {
    case marineLife = "FAUNA"
    case reef = "REEF"
    case wreck = "RELITTO"
    case photoSpot = "FOTO"
    case buoy = "BOA"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .marineLife: return "fish"
        case .reef: return "water.waves"
        case .wreck: return "ferry"
        case .photoSpot: return "camera"
        case .buoy: return "mappin"
        }
    }
}

struct SnorkelingWaypoint: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var category: GPSMarkerCategory
    var latitude: Double
    var longitude: Double
    var targetBearing: Double
    var distanceMeters: Double

    init(
        id: UUID = UUID(),
        name: String,
        category: GPSMarkerCategory,
        latitude: Double,
        longitude: Double,
        targetBearing: Double,
        distanceMeters: Double
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.latitude = latitude
        self.longitude = longitude
        self.targetBearing = targetBearing
        self.distanceMeters = distanceMeters
    }
}

struct GPSInterestMarker: Identifiable, Hashable, Codable {
    let id: UUID
    var category: GPSMarkerCategory
    var timestamp: Date
    var latitude: Double?
    var longitude: Double?
    var depthMeters: Double
    var temperatureCelsius: Double?
    var distanceFromEntryMeters: Double
    var bearingDegrees: Double
    var activeWaypointName: String?
    var sessionID: String?
    var isEnriched: Bool

    init(
        id: UUID = UUID(),
        category: GPSMarkerCategory,
        timestamp: Date = Date(),
        latitude: Double?,
        longitude: Double?,
        depthMeters: Double,
        temperatureCelsius: Double? = nil,
        distanceFromEntryMeters: Double,
        bearingDegrees: Double,
        activeWaypointName: String? = nil,
        sessionID: String? = nil,
        isEnriched: Bool = false
    ) {
        self.id = id
        self.category = category
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
        self.depthMeters = depthMeters
        self.temperatureCelsius = temperatureCelsius
        self.distanceFromEntryMeters = distanceFromEntryMeters
        self.bearingDegrees = bearingDegrees
        self.activeWaypointName = activeWaypointName
        self.sessionID = sessionID
        self.isEnriched = isEnriched
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case category
        case timestamp
        case latitude
        case longitude
        case depthMeters
        case temperatureCelsius
        case distanceFromEntryMeters
        case bearingDegrees
        case activeWaypointName
        case sessionID
        case isEnriched
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        category = try container.decodeIfPresent(GPSMarkerCategory.self, forKey: .category) ?? .reef
        timestamp = try container.decodeIfPresent(Date.self, forKey: .timestamp) ?? Date()
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        depthMeters = try container.decodeIfPresent(Double.self, forKey: .depthMeters) ?? 0
        temperatureCelsius = try container.decodeIfPresent(Double.self, forKey: .temperatureCelsius)
        distanceFromEntryMeters = try container.decodeIfPresent(Double.self, forKey: .distanceFromEntryMeters) ?? 0
        bearingDegrees = try container.decodeIfPresent(Double.self, forKey: .bearingDegrees) ?? 0
        activeWaypointName = try container.decodeIfPresent(String.self, forKey: .activeWaypointName)
        sessionID = try container.decodeIfPresent(String.self, forKey: .sessionID)
        isEnriched = try container.decodeIfPresent(Bool.self, forKey: .isEnriched) ?? false
    }
}

struct ApneaDiveRecord: Identifiable, Hashable, Codable {
    let id: UUID
    var durationSeconds: TimeInterval
    var maxDepthMeters: Double
    var recoverySeconds: TimeInterval

    init(id: UUID = UUID(), durationSeconds: TimeInterval, maxDepthMeters: Double, recoverySeconds: TimeInterval) {
        self.id = id
        self.durationSeconds = durationSeconds
        self.maxDepthMeters = maxDepthMeters
        self.recoverySeconds = recoverySeconds
    }
}
