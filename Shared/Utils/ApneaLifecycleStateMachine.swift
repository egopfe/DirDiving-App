import Foundation

/// Runtime lifecycle phases for Apnea depth-driven sessions (distinct from persisted `ApneaSessionState`).
enum ApneaLifecyclePhase: String, Codable, CaseIterable, Hashable, Sendable {
    case idle
    case ready
    case surface
    case descending
    case submerged
    case ascending
    case surfaced
    case recovery
    case ended
    case sensorDegraded
    case recovered
}

struct ApneaLifecycleConfiguration: Codable, Hashable, Sendable {
    var immersionStartDepthMeters: Double
    var surfaceDepthMeters: Double
    var immersionHysteresisMeters: Double
    var surfaceHysteresisMeters: Double
    var immersionDebounceSeconds: TimeInterval
    var surfaceStableDwellSeconds: TimeInterval
    var descendingSpeedThresholdMetersPerSecond: Double
    var ascendingSpeedThresholdMetersPerSecond: Double
    var sensorLossTimeoutSeconds: TimeInterval
    var recoveryMinimumSeconds: TimeInterval
    var minimumDiveDurationSeconds: TimeInterval

    static let `default` = ApneaLifecycleConfiguration(
        immersionStartDepthMeters: 1.0,
        surfaceDepthMeters: 0.5,
        immersionHysteresisMeters: 0.3,
        surfaceHysteresisMeters: 0.3,
        immersionDebounceSeconds: 1.0,
        surfaceStableDwellSeconds: 3.0,
        descendingSpeedThresholdMetersPerSecond: 0.15,
        ascendingSpeedThresholdMetersPerSecond: 0.15,
        sensorLossTimeoutSeconds: 5.0,
        recoveryMinimumSeconds: 60,
        minimumDiveDurationSeconds: 3.0
    )
}

struct ApneaLifecycleTracker: Hashable, Codable {
    var phase: ApneaLifecyclePhase
    var phaseBeforeSensorDegraded: ApneaLifecyclePhase?
    var immersionCandidateSince: TimeInterval?
    var surfaceDwellSince: TimeInterval?
    var recoveryStartedAt: TimeInterval?
    var diveMaxDepthMeters: Double
    var diveStartedAt: TimeInterval?
    var lastMeasurementMonotonic: TimeInterval?

    static let initial = ApneaLifecycleTracker(
        phase: .idle,
        phaseBeforeSensorDegraded: nil,
        immersionCandidateSince: nil,
        surfaceDwellSince: nil,
        recoveryStartedAt: nil,
        diveMaxDepthMeters: 0,
        diveStartedAt: nil,
        lastMeasurementMonotonic: nil
    )
}

enum ApneaLifecycleTransitionEvent: Hashable, Sendable {
    case phaseChanged(from: ApneaLifecyclePhase, to: ApneaLifecyclePhase)
    case diveStarted(atMonotonic: TimeInterval)
    case diveEnded(atMonotonic: TimeInterval, startedAtMonotonic: TimeInterval, maxDepthMeters: Double)
    case recoveryStarted(atMonotonic: TimeInterval)
    case recoveryCompleted(atMonotonic: TimeInterval)
    case sensorDegraded
    case sensorRecovered
}

struct ApneaLifecycleMachineInput: Hashable {
    let configuration: ApneaLifecycleConfiguration
    let monotonicNow: TimeInterval
    let wallClockNow: Date
    let acceptedDepthMeters: Double?
    let verticalSpeedMetersPerSecond: Double
    let feedAccepted: Bool
    let sensorAvailable: Bool
    let manualFallbackActive: Bool
    let manualDescentTriggered: Bool
    let manualSurfaceTriggered: Bool
    let sessionArmed: Bool
    let endSessionRequested: Bool
    let tickOnly: Bool
}

struct ApneaLifecycleMachineOutput: Hashable {
    var tracker: ApneaLifecycleTracker
    var events: [ApneaLifecycleTransitionEvent]
}

/// Pure Apnea lifecycle state machine — no SwiftUI, no Dive lifecycle reuse.
enum ApneaLifecycleStateMachine {
    static func evaluate(
        input: ApneaLifecycleMachineInput,
        tracker: ApneaLifecycleTracker
    ) -> ApneaLifecycleMachineOutput {
        var tracker = tracker
        var events: [ApneaLifecycleTransitionEvent] = []

        if input.endSessionRequested, tracker.phase != .ended {
            return transition(&tracker, &events, to: .ended)
        }

        if input.sessionArmed, tracker.phase == .idle {
            return transition(&tracker, &events, to: .ready)
        }

        restorePhaseAfterSensorRecovery(&tracker, &events)

        if !input.sensorAvailable,
           !input.manualFallbackActive,
           tracker.phase != .idle,
           tracker.phase != .ended,
           tracker.phase != .ready {
            if tracker.phase != .sensorDegraded {
                tracker.phaseBeforeSensorDegraded = operationalPhase(for: tracker)
                events.append(.sensorDegraded)
                return transition(&tracker, &events, to: .sensorDegraded)
            }
            return ApneaLifecycleMachineOutput(tracker: tracker, events: events)
        }

        if tracker.phase == .sensorDegraded, input.sensorAvailable || input.manualFallbackActive {
            events.append(.sensorRecovered)
            tracker.phase = .recovered
            events.append(.phaseChanged(from: .sensorDegraded, to: .recovered))
            restorePhaseAfterSensorRecovery(&tracker, &events)
        }

        if input.tickOnly {
            return evaluateTimeouts(input: input, tracker: &tracker, events: &events)
        }

        guard input.feedAccepted, let depth = input.acceptedDepthMeters else {
            return evaluateTimeouts(input: input, tracker: &tracker, events: &events)
        }

        tracker.lastMeasurementMonotonic = input.monotonicNow
        tracker.diveMaxDepthMeters = max(tracker.diveMaxDepthMeters, depth)

        switch tracker.phase {
        case .idle, .ended:
            break

        case .ready:
            if input.manualDescentTriggered {
                startDive(at: input.monotonicNow, depth: depth, tracker: &tracker, events: &events)
                transition(&tracker, &events, to: .descending)
            } else if depth <= input.configuration.surfaceDepthMeters + input.configuration.surfaceHysteresisMeters {
                transition(&tracker, &events, to: .surface)
            }

        case .surface:
            if input.manualDescentTriggered || shouldStartImmersion(depth: depth, input: input, tracker: &tracker) {
                tracker.immersionCandidateSince = nil
                startDive(at: input.monotonicNow, depth: depth, tracker: &tracker, events: &events)
                transition(&tracker, &events, to: .descending)
            } else if depth <= input.configuration.immersionStartDepthMeters {
                clearImmersionCandidate(&tracker)
            }

        case .descending:
            if input.manualSurfaceTriggered || depth <= input.configuration.surfaceDepthMeters {
                closeDiveEarly(input: input, tracker: &tracker, events: &events)
            } else if depth >= input.configuration.immersionStartDepthMeters + input.configuration.immersionHysteresisMeters {
                transition(&tracker, &events, to: .submerged)
            }

        case .submerged:
            if input.manualSurfaceTriggered {
                transition(&tracker, &events, to: .ascending)
            } else if input.verticalSpeedMetersPerSecond <= -input.configuration.ascendingSpeedThresholdMetersPerSecond {
                transition(&tracker, &events, to: .ascending)
            } else if depth <= input.configuration.surfaceDepthMeters + input.configuration.surfaceHysteresisMeters {
                transition(&tracker, &events, to: .ascending)
            }

        case .ascending:
            if depth <= input.configuration.surfaceDepthMeters + input.configuration.surfaceHysteresisMeters {
                tracker.surfaceDwellSince = tracker.surfaceDwellSince ?? input.monotonicNow
                transition(&tracker, &events, to: .surfaced)
            }

        case .surfaced:
            if let dwellSince = tracker.surfaceDwellSince,
               input.monotonicNow - dwellSince >= input.configuration.surfaceStableDwellSeconds {
                finishDive(input: input, tracker: &tracker, events: &events)
            } else if depth > input.configuration.immersionStartDepthMeters + input.configuration.immersionHysteresisMeters {
                tracker.surfaceDwellSince = nil
                transition(&tracker, &events, to: .descending)
            }

        case .recovery:
            if let started = tracker.recoveryStartedAt,
               input.monotonicNow - started >= input.configuration.recoveryMinimumSeconds {
                tracker.recoveryStartedAt = nil
                events.append(.recoveryCompleted(atMonotonic: input.monotonicNow))
                transition(&tracker, &events, to: .surface)
            }

        case .sensorDegraded, .recovered:
            break
        }

        return ApneaLifecycleMachineOutput(tracker: tracker, events: events)
    }

    private static func restorePhaseAfterSensorRecovery(
        _ tracker: inout ApneaLifecycleTracker,
        _ events: inout [ApneaLifecycleTransitionEvent]
    ) {
        guard tracker.phase == .recovered, let restore = tracker.phaseBeforeSensorDegraded else { return }
        tracker.phaseBeforeSensorDegraded = nil
        if tracker.phase != restore {
            events.append(.phaseChanged(from: .recovered, to: restore))
            tracker.phase = restore
        }
    }

    private static func operationalPhase(for tracker: ApneaLifecycleTracker) -> ApneaLifecyclePhase {
        tracker.phase == .recovered ? (tracker.phaseBeforeSensorDegraded ?? .surface) : tracker.phase
    }

    private static func startDive(
        at monotonic: TimeInterval,
        depth: Double,
        tracker: inout ApneaLifecycleTracker,
        events: inout [ApneaLifecycleTransitionEvent]
    ) {
        tracker.diveStartedAt = monotonic
        tracker.diveMaxDepthMeters = depth
        events.append(.diveStarted(atMonotonic: monotonic))
    }

    private static func evaluateTimeouts(
        input: ApneaLifecycleMachineInput,
        tracker: inout ApneaLifecycleTracker,
        events: inout [ApneaLifecycleTransitionEvent]
    ) -> ApneaLifecycleMachineOutput {
        if let last = tracker.lastMeasurementMonotonic,
           input.monotonicNow - last >= input.configuration.sensorLossTimeoutSeconds,
           !input.manualFallbackActive,
           tracker.phase != .sensorDegraded,
           tracker.phase != .idle,
           tracker.phase != .ended,
           tracker.phase != .ready {
            tracker.phaseBeforeSensorDegraded = operationalPhase(for: tracker)
            events.append(.sensorDegraded)
            transition(&tracker, &events, to: .sensorDegraded)
        }

        if tracker.phase == .surfaced,
           let dwellSince = tracker.surfaceDwellSince,
           input.monotonicNow - dwellSince >= input.configuration.surfaceStableDwellSeconds {
            finishDive(input: input, tracker: &tracker, events: &events)
        }

        if tracker.phase == .recovery,
           let started = tracker.recoveryStartedAt,
           input.monotonicNow - started >= input.configuration.recoveryMinimumSeconds {
            tracker.recoveryStartedAt = nil
            events.append(.recoveryCompleted(atMonotonic: input.monotonicNow))
            transition(&tracker, &events, to: .surface)
        }

        return ApneaLifecycleMachineOutput(tracker: tracker, events: events)
    }

    private static func shouldStartImmersion(
        depth: Double,
        input: ApneaLifecycleMachineInput,
        tracker: inout ApneaLifecycleTracker
    ) -> Bool {
        guard depth > input.configuration.immersionStartDepthMeters else {
            clearImmersionCandidate(&tracker)
            return false
        }
        if tracker.immersionCandidateSince == nil {
            tracker.immersionCandidateSince = input.monotonicNow
        }
        guard let candidate = tracker.immersionCandidateSince else { return false }
        return input.monotonicNow - candidate >= input.configuration.immersionDebounceSeconds
    }

    private static func clearImmersionCandidate(_ tracker: inout ApneaLifecycleTracker) {
        tracker.immersionCandidateSince = nil
    }

    private static func closeDiveEarly(
        input: ApneaLifecycleMachineInput,
        tracker: inout ApneaLifecycleTracker,
        events: inout [ApneaLifecycleTransitionEvent]
    ) {
        tracker.surfaceDwellSince = input.monotonicNow
        transition(&tracker, &events, to: .surfaced)
    }

    private static func finishDive(
        input: ApneaLifecycleMachineInput,
        tracker: inout ApneaLifecycleTracker,
        events: inout [ApneaLifecycleTransitionEvent]
    ) {
        let diveDuration = (tracker.diveStartedAt.map { input.monotonicNow - $0 }) ?? 0
        if diveDuration >= input.configuration.minimumDiveDurationSeconds,
           let startedAt = tracker.diveStartedAt {
            events.append(
                .diveEnded(
                    atMonotonic: input.monotonicNow,
                    startedAtMonotonic: startedAt,
                    maxDepthMeters: tracker.diveMaxDepthMeters
                )
            )
        }
        tracker.diveStartedAt = nil
        tracker.diveMaxDepthMeters = 0
        tracker.surfaceDwellSince = nil
        tracker.recoveryStartedAt = input.monotonicNow
        events.append(.recoveryStarted(atMonotonic: input.monotonicNow))
        transition(&tracker, &events, to: .recovery)
    }

    private static func transition(
        _ tracker: inout ApneaLifecycleTracker,
        _ events: inout [ApneaLifecycleTransitionEvent],
        to phase: ApneaLifecyclePhase
    ) -> ApneaLifecycleMachineOutput {
        let from = tracker.phase
        if from != phase {
            events.append(.phaseChanged(from: from, to: phase))
            tracker.phase = phase
        }
        return ApneaLifecycleMachineOutput(tracker: tracker, events: events)
    }
}
