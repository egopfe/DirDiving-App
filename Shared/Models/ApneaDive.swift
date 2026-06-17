import Foundation

/// One completed or in-progress Apnea dive within a session.
struct ApneaDive: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var startedAtMonotonicSeconds: TimeInterval
    var endedAtMonotonicSeconds: TimeInterval?
    var startedAtWallClock: Date?
    var endedAtWallClock: Date?
    var durationSeconds: TimeInterval
    /// Maximum depth reached during this single dive (not session max, not personal best).
    var maxDepthMeters: Double
    var averageDepthMeters: Double
    var samples: [ApneaSample]
    var events: [ApneaEvent]
    var targets: [ApneaTarget]
    var markers: [ApneaDepthMarker]
    var reachedTargetIDs: [UUID]
    var reachedMarkerIDs: [UUID]
    var recoveryBefore: ApneaRecoveryInterval?
    var recoveryAfter: ApneaRecoveryInterval?

    init(
        id: UUID = UUID(),
        startedAtMonotonicSeconds: TimeInterval,
        endedAtMonotonicSeconds: TimeInterval? = nil,
        startedAtWallClock: Date? = nil,
        endedAtWallClock: Date? = nil,
        durationSeconds: TimeInterval = 0,
        maxDepthMeters: Double = 0,
        averageDepthMeters: Double = 0,
        samples: [ApneaSample] = [],
        events: [ApneaEvent] = [],
        targets: [ApneaTarget] = [],
        markers: [ApneaDepthMarker] = [],
        reachedTargetIDs: [UUID] = [],
        reachedMarkerIDs: [UUID] = [],
        recoveryBefore: ApneaRecoveryInterval? = nil,
        recoveryAfter: ApneaRecoveryInterval? = nil
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
        self.targets = targets
        self.markers = markers
        self.reachedTargetIDs = reachedTargetIDs
        self.reachedMarkerIDs = reachedMarkerIDs
        self.recoveryBefore = recoveryBefore
        self.recoveryAfter = recoveryAfter
    }

    /// Sort samples by monotonic timestamp and keep the first occurrence per sample ID.
    func normalizedSamples() -> [ApneaSample] {
        ApneaDomainSupport.normalizedSamples(samples)
    }

    /// Recompute dive max/average from samples when present.
    func recomputedDepthMetrics() -> (maxDepthMeters: Double, averageDepthMeters: Double) {
        ApneaDomainSupport.depthMetrics(from: samples)
    }
}
