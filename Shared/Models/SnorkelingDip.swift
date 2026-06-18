import Foundation

struct SnorkelingDip: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var startedAtMonotonicSeconds: TimeInterval
    var endedAtMonotonicSeconds: TimeInterval?
    var startedAtWallClock: Date?
    var endedAtWallClock: Date?
    var durationSeconds: TimeInterval
    var maxDepthMeters: Double
    var averageDepthMeters: Double
    var samples: [SnorkelingDipSample]
    var events: [SnorkelingEvent]

    init(
        id: UUID = UUID(),
        startedAtMonotonicSeconds: TimeInterval,
        endedAtMonotonicSeconds: TimeInterval? = nil,
        startedAtWallClock: Date? = nil,
        endedAtWallClock: Date? = nil,
        durationSeconds: TimeInterval = 0,
        maxDepthMeters: Double = 0,
        averageDepthMeters: Double = 0,
        samples: [SnorkelingDipSample] = [],
        events: [SnorkelingEvent] = []
    ) {
        self.id = id
        self.startedAtMonotonicSeconds = startedAtMonotonicSeconds
        self.endedAtMonotonicSeconds = endedAtMonotonicSeconds
        self.startedAtWallClock = startedAtWallClock
        self.endedAtWallClock = endedAtWallClock
        self.durationSeconds = durationSeconds
        self.maxDepthMeters = maxDepthMeters
        self.averageDepthMeters = averageDepthMeters
        self.samples = samples
        self.events = events
    }
}
