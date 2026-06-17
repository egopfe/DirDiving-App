import Foundation

enum ApneaRecoveryPhaseKind: String, Codable, CaseIterable, Hashable, Sendable {
    case surfaceRest
    case oxygenInterval
    case heartRateGate
    case custom
}

/// Configurable recovery policy for Apnea sessions (not an "intelligent recovery" product claim).
struct ApneaRecoveryPolicy: Codable, Hashable, Sendable {
    var minimumSurfaceSeconds: TimeInterval
    var recommendedSurfaceSeconds: TimeInterval
    var phases: [ApneaRecoveryPhaseKind]
    var allowEarlyDiveWhenIncomplete: Bool

    static let `default` = ApneaRecoveryPolicy(
        minimumSurfaceSeconds: 60,
        recommendedSurfaceSeconds: 120,
        phases: [.surfaceRest],
        allowEarlyDiveWhenIncomplete: false
    )

    init(
        minimumSurfaceSeconds: TimeInterval,
        recommendedSurfaceSeconds: TimeInterval,
        phases: [ApneaRecoveryPhaseKind] = [.surfaceRest],
        allowEarlyDiveWhenIncomplete: Bool = false
    ) {
        self.minimumSurfaceSeconds = minimumSurfaceSeconds
        self.recommendedSurfaceSeconds = recommendedSurfaceSeconds
        self.phases = phases
        self.allowEarlyDiveWhenIncomplete = allowEarlyDiveWhenIncomplete
    }
}

/// Recovery interval before or after a single Apnea dive.
struct ApneaRecoveryInterval: Codable, Hashable, Sendable {
    var startedAtMonotonicSeconds: TimeInterval?
    var endedAtMonotonicSeconds: TimeInterval?
    var plannedSeconds: TimeInterval
    var completedSeconds: TimeInterval?
    var wasSkipped: Bool

    init(
        startedAtMonotonicSeconds: TimeInterval? = nil,
        endedAtMonotonicSeconds: TimeInterval? = nil,
        plannedSeconds: TimeInterval,
        completedSeconds: TimeInterval? = nil,
        wasSkipped: Bool = false
    ) {
        self.startedAtMonotonicSeconds = startedAtMonotonicSeconds
        self.endedAtMonotonicSeconds = endedAtMonotonicSeconds
        self.plannedSeconds = plannedSeconds
        self.completedSeconds = completedSeconds
        self.wasSkipped = wasSkipped
    }
}
