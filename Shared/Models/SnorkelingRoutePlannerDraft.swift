import Foundation

enum SnorkelingRoutePointRole: String, Codable, CaseIterable, Hashable, Sendable {
    case entry
    case waypoint
    case exit
}

struct SnorkelingRoutePlannerPoint: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var name: String
    var role: SnorkelingRoutePointRole
    var latitude: Double
    var longitude: Double
    var routeOrder: Int

    init(
        id: UUID = UUID(),
        name: String,
        role: SnorkelingRoutePointRole,
        latitude: Double,
        longitude: Double,
        routeOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.role = role
        self.latitude = latitude
        self.longitude = longitude
        self.routeOrder = routeOrder
    }
}

struct SnorkelingRoutePlannerDraft: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var name: String
    var profileID: UUID?
    var entryPoint: SnorkelingRoutePlannerPoint?
    var exitPoint: SnorkelingRoutePlannerPoint?
    var waypoints: [SnorkelingRoutePlannerPoint]
    var maxDistanceLimitMeters: Double?
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String = "",
        profileID: UUID? = nil,
        entryPoint: SnorkelingRoutePlannerPoint? = nil,
        exitPoint: SnorkelingRoutePlannerPoint? = nil,
        waypoints: [SnorkelingRoutePlannerPoint] = [],
        maxDistanceLimitMeters: Double? = nil,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.profileID = profileID
        self.entryPoint = entryPoint
        self.exitPoint = exitPoint
        self.waypoints = waypoints
        self.maxDistanceLimitMeters = maxDistanceLimitMeters
        self.updatedAt = updatedAt
    }

    var orderedPoints: [SnorkelingRoutePlannerPoint] {
        var points: [SnorkelingRoutePlannerPoint] = []
        if let entryPoint {
            var entry = entryPoint
            entry.role = .entry
            points.append(entry)
        }
        let sortedWaypoints = waypoints
            .filter { $0.role == .waypoint }
            .sorted { $0.routeOrder < $1.routeOrder }
            .enumerated()
            .map { index, point -> SnorkelingRoutePlannerPoint in
                var copy = point
                copy.role = .waypoint
                copy.routeOrder = index + 1
                return copy
            }
        points.append(contentsOf: sortedWaypoints)
        if let exitPoint {
            var exit = exitPoint
            exit.role = .exit
            exit.routeOrder = points.count
            points.append(exit)
        }
        return points.enumerated().map { index, point in
            var copy = point
            copy.routeOrder = index
            return copy
        }
    }

    func asRoutePlan() -> SnorkelingRoutePlan {
        let waypoints = orderedPoints.map { point in
            SnorkelingWaypoint(
                id: point.id,
                name: point.name,
                category: category(for: point.role),
                latitude: point.latitude,
                longitude: point.longitude,
                routeOrder: point.routeOrder,
                colorName: colorName(for: point.role)
            )
        }
        return SnorkelingRoutePlan(
            id: id,
            name: name.isEmpty ? "snorkeling.route.unnamed" : name,
            waypoints: waypoints,
            offlineCacheReady: false,
            syncReady: false
        )
    }

    private func category(for role: SnorkelingRoutePointRole) -> SnorkelingMarkerCategory {
        switch role {
        case .entry, .exit: return .buoy
        case .waypoint: return .custom
        }
    }

    private func colorName(for role: SnorkelingRoutePointRole) -> String {
        switch role {
        case .entry: return "green"
        case .exit: return "orange"
        case .waypoint: return "cyan"
        }
    }
}
