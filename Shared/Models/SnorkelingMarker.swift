import Foundation

struct SnorkelingMarker: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var category: SnorkelingMarkerCategory
    var monotonicRelativeTimestampSeconds: TimeInterval
    var wallClockTimestamp: Date?
    var latitude: Double
    var longitude: Double
    var horizontalAccuracyMeters: Double?
    var depthMeters: Double?
    var temperatureCelsius: Double?
    var headingDegrees: Double?
    var relatedWaypointID: UUID?
    var sessionID: UUID?
    var isEnriched: Bool
    var note: String?

    init(
        id: UUID = UUID(),
        category: SnorkelingMarkerCategory,
        monotonicRelativeTimestampSeconds: TimeInterval,
        wallClockTimestamp: Date? = nil,
        latitude: Double,
        longitude: Double,
        horizontalAccuracyMeters: Double? = nil,
        depthMeters: Double? = nil,
        temperatureCelsius: Double? = nil,
        headingDegrees: Double? = nil,
        relatedWaypointID: UUID? = nil,
        sessionID: UUID? = nil,
        isEnriched: Bool = false,
        note: String? = nil
    ) {
        self.id = id
        self.category = category
        self.monotonicRelativeTimestampSeconds = monotonicRelativeTimestampSeconds
        self.wallClockTimestamp = wallClockTimestamp
        self.latitude = latitude
        self.longitude = longitude
        self.horizontalAccuracyMeters = horizontalAccuracyMeters
        self.depthMeters = depthMeters
        self.temperatureCelsius = temperatureCelsius
        self.headingDegrees = headingDegrees
        self.relatedWaypointID = relatedWaypointID
        self.sessionID = sessionID
        self.isEnriched = isEnriched
        self.note = note
    }
}
