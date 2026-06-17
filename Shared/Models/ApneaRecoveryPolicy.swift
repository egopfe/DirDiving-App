import Foundation

enum ApneaRecoveryPhaseKind: String, Codable, CaseIterable, Hashable, Sendable {
    case surfaceRest
    case oxygenInterval
    case heartRateGate
    case custom
}

enum ApneaRecoveryComputationMode: String, Codable, CaseIterable, Hashable, Sendable {
    case informationalOnly
    case ratio1to1
    case ratio2to1
    case fixedDuration
    case customRatio
}

/// Configurable recovery policy for Apnea sessions (user setting, not universal medical prescription).
struct ApneaRecoveryPolicy: Codable, Hashable, Sendable {
    var mode: ApneaRecoveryComputationMode
    var minimumSurfaceSeconds: TimeInterval
    var recommendedSurfaceSeconds: TimeInterval
    var phases: [ApneaRecoveryPhaseKind]
    var allowEarlyDiveWhenIncomplete: Bool
    var fixedDurationSeconds: TimeInterval?
    var customRatio: Double?

    static let `default` = ApneaRecoveryPolicy(
        mode: .ratio2to1,
        minimumSurfaceSeconds: 60,
        recommendedSurfaceSeconds: 120,
        phases: [.surfaceRest],
        allowEarlyDiveWhenIncomplete: false,
        fixedDurationSeconds: nil,
        customRatio: nil
    )

    init(
        mode: ApneaRecoveryComputationMode,
        minimumSurfaceSeconds: TimeInterval,
        recommendedSurfaceSeconds: TimeInterval,
        phases: [ApneaRecoveryPhaseKind] = [.surfaceRest],
        allowEarlyDiveWhenIncomplete: Bool = false,
        fixedDurationSeconds: TimeInterval? = nil,
        customRatio: Double? = nil
    ) {
        self.mode = mode
        self.minimumSurfaceSeconds = minimumSurfaceSeconds
        self.recommendedSurfaceSeconds = recommendedSurfaceSeconds
        self.phases = phases
        self.allowEarlyDiveWhenIncomplete = allowEarlyDiveWhenIncomplete
        self.fixedDurationSeconds = fixedDurationSeconds
        self.customRatio = customRatio
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        mode = try c.decodeIfPresent(ApneaRecoveryComputationMode.self, forKey: .mode) ?? .ratio2to1
        minimumSurfaceSeconds = try c.decodeIfPresent(TimeInterval.self, forKey: .minimumSurfaceSeconds) ?? 60
        recommendedSurfaceSeconds = try c.decodeIfPresent(TimeInterval.self, forKey: .recommendedSurfaceSeconds) ?? 120
        phases = try c.decodeIfPresent([ApneaRecoveryPhaseKind].self, forKey: .phases) ?? [.surfaceRest]
        allowEarlyDiveWhenIncomplete = try c.decodeIfPresent(Bool.self, forKey: .allowEarlyDiveWhenIncomplete) ?? false
        fixedDurationSeconds = try c.decodeIfPresent(TimeInterval.self, forKey: .fixedDurationSeconds)
        customRatio = try c.decodeIfPresent(Double.self, forKey: .customRatio)
    }
}

enum ApneaRecoveryComputation {
    static func requiredRecoverySeconds(
        policy: ApneaRecoveryPolicy,
        lastDiveDurationSeconds: TimeInterval
    ) -> TimeInterval {
        let dive = max(0, lastDiveDurationSeconds)
        let candidate: TimeInterval
        switch policy.mode {
        case .informationalOnly:
            candidate = 0
        case .ratio1to1:
            candidate = dive
        case .ratio2to1:
            candidate = dive * 2
        case .fixedDuration:
            candidate = policy.fixedDurationSeconds ?? policy.recommendedSurfaceSeconds
        case .customRatio:
            candidate = dive * max(0, policy.customRatio ?? 1)
        }
        return max(policy.minimumSurfaceSeconds, candidate)
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
