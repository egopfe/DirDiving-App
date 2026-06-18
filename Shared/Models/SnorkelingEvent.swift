import Foundation

enum SnorkelingEventKind: String, Codable, CaseIterable, Hashable, Sendable {
    case sessionStarted
    case sessionEnded
    case dipStarted
    case dipEnded
    case markerPlaced
    case waypointReached
    case returnStarted
    case alarmTriggered
    case gpsLost
    case gpsRecovered
    case depthUnavailable
    case manualNote
}

struct SnorkelingEvent: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var kind: SnorkelingEventKind
    var monotonicRelativeTimestampSeconds: TimeInterval
    var wallClockTimestamp: Date?
    var latitude: Double?
    var longitude: Double?
    var depthMeters: Double?
    var note: String?
    var relatedAlarmID: UUID?
    var relatedMarkerID: UUID?
    var relatedWaypointID: UUID?
    var relatedDipID: UUID?

    init(
        id: UUID = UUID(),
        kind: SnorkelingEventKind,
        monotonicRelativeTimestampSeconds: TimeInterval,
        wallClockTimestamp: Date? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        depthMeters: Double? = nil,
        note: String? = nil,
        relatedAlarmID: UUID? = nil,
        relatedMarkerID: UUID? = nil,
        relatedWaypointID: UUID? = nil,
        relatedDipID: UUID? = nil
    ) {
        self.id = id
        self.kind = kind
        self.monotonicRelativeTimestampSeconds = monotonicRelativeTimestampSeconds
        self.wallClockTimestamp = wallClockTimestamp
        self.latitude = latitude
        self.longitude = longitude
        self.depthMeters = depthMeters
        self.note = note
        self.relatedAlarmID = relatedAlarmID
        self.relatedMarkerID = relatedMarkerID
        self.relatedWaypointID = relatedWaypointID
        self.relatedDipID = relatedDipID
    }
}
