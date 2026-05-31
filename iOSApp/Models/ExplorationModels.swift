import Foundation
import SwiftUI

enum ExplorationMarkerCategory: String, CaseIterable, Identifiable, Codable {
    case reef = "Reef"
    case wreck = "Relitto"
    case marineLife = "Fauna"
    case photography = "Fotografia"
    case buoy = "Boa"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .reef: return "water.waves"
        case .wreck: return "ferry"
        case .marineLife: return "fish"
        case .photography: return "camera"
        case .buoy: return "mappin.circle"
        }
    }

    var color: Color {
        switch self {
        case .reef: return DIRTheme.cyan
        case .wreck: return DIRTheme.yellow
        case .marineLife: return DIRTheme.green
        case .photography: return .white
        case .buoy: return DIRTheme.orange
        }
    }
}

struct ExplorationWaypoint: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var category: ExplorationMarkerCategory
    var latitude: Double
    var longitude: Double
    var colorName: String
    var routeOrder: Int

    init(
        id: UUID = UUID(),
        name: String,
        category: ExplorationMarkerCategory,
        latitude: Double,
        longitude: Double,
        colorName: String = "cyan",
        routeOrder: Int
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.latitude = latitude
        self.longitude = longitude
        self.colorName = colorName
        self.routeOrder = routeOrder
    }
}

struct SnorkelingRoutePlan: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var waypoints: [ExplorationWaypoint]
    var offlineCacheReady: Bool
    var syncReady: Bool

    init(id: UUID = UUID(), name: String, waypoints: [ExplorationWaypoint], offlineCacheReady: Bool, syncReady: Bool) {
        self.id = id
        self.name = name
        self.waypoints = waypoints
        self.offlineCacheReady = offlineCacheReady
        self.syncReady = syncReady
    }
}

struct ApneaTrainingSummary: Identifiable {
    let id = UUID()
    var title: String
    var value: String
    var trend: String
    var color: Color
}

struct ApneaChartPoint: Identifiable, Hashable {
    let id = UUID()
    var label: String
    var value: Double
}

struct ExplorationSettings: Hashable, Codable {
    var distanceUnit: String = "km"
    var depthUnit: String = "m"
    var temperatureUnit: String = "C"
    var pressureUnit: String = "BAR"
    var apneaDurationWarningSeconds: Double = 120
    var recoveryRatio: Double = 2.0
    var driftThresholdMeters: Double = 300
    var waypointAutoSwitchMeters: Double = 25
}
