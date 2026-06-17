import Foundation

enum ApneaEventKind: String, Codable, CaseIterable, Hashable, Sendable {
    case surface
    case descentStart
    case maxDepthReached
    case ascentStart
    case diveEnd
    case alarmTriggered
    case recoveryStart
    case recoveryComplete
    case markerReached
    case targetReached
    case manualNote
}

struct ApneaEvent: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var kind: ApneaEventKind
    var monotonicRelativeTimestampSeconds: TimeInterval
    var wallClockTimestamp: Date?
    var depthMeters: Double?
    var note: String?
    var relatedAlarmID: UUID?
    var relatedMarkerID: UUID?
    var relatedTargetID: UUID?

    init(
        id: UUID = UUID(),
        kind: ApneaEventKind,
        monotonicRelativeTimestampSeconds: TimeInterval,
        wallClockTimestamp: Date? = nil,
        depthMeters: Double? = nil,
        note: String? = nil,
        relatedAlarmID: UUID? = nil,
        relatedMarkerID: UUID? = nil,
        relatedTargetID: UUID? = nil
    ) {
        self.id = id
        self.kind = kind
        self.monotonicRelativeTimestampSeconds = monotonicRelativeTimestampSeconds
        self.wallClockTimestamp = wallClockTimestamp
        self.depthMeters = depthMeters
        self.note = note
        self.relatedAlarmID = relatedAlarmID
        self.relatedMarkerID = relatedMarkerID
        self.relatedTargetID = relatedTargetID
    }
}
