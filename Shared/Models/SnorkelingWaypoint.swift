import Foundation

struct SnorkelingWaypoint: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var name: String
    var category: SnorkelingMarkerCategory
    var latitude: Double
    var longitude: Double
    var routeOrder: Int
    var colorName: String
    /// Snapshot bearing/distance at plan time (optional).
    var targetBearingDegrees: Double?
    var distanceMeters: Double?

    init(
        id: UUID = UUID(),
        name: String,
        category: SnorkelingMarkerCategory,
        latitude: Double,
        longitude: Double,
        routeOrder: Int = 0,
        colorName: String = "cyan",
        targetBearingDegrees: Double? = nil,
        distanceMeters: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.latitude = latitude
        self.longitude = longitude
        self.routeOrder = routeOrder
        self.colorName = colorName
        self.targetBearingDegrees = targetBearingDegrees
        self.distanceMeters = distanceMeters
    }
}
