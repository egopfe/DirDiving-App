import Foundation

/// Runtime lifecycle phases for snorkeling sessions (distinct from persisted `SnorkelingSessionState`).
enum SnorkelingLifecyclePhase: String, Codable, CaseIterable, Hashable, Sendable {
    case idle
    case ready
    case surfaceActive
    case dipping
    case resurfacing
    case navigation
    case returnMode
    case paused
    case ended
    case sensorDegraded
    case recovered
}

struct SnorkelingLifecycleConfiguration: Codable, Hashable, Sendable {
    var dipStartDepthMeters: Double
    var surfaceDepthMeters: Double
    var dipHysteresisMeters: Double
    var surfaceHysteresisMeters: Double
    var dipStartDebounceSeconds: TimeInterval
    var surfaceStableDwellSeconds: TimeInterval
    var sensorLossTimeoutSeconds: TimeInterval
    var minimumDipDurationSeconds: TimeInterval
    var autoEndOutOfWaterSeconds: TimeInterval?
    var waterDetectionDepthMeters: Double

    static let `default` = SnorkelingLifecycleConfiguration(
        dipStartDepthMeters: 0.5,
        surfaceDepthMeters: 0.35,
        dipHysteresisMeters: 0.15,
        surfaceHysteresisMeters: 0.15,
        dipStartDebounceSeconds: 0.8,
        surfaceStableDwellSeconds: 2.0,
        sensorLossTimeoutSeconds: 8.0,
        minimumDipDurationSeconds: 2.0,
        autoEndOutOfWaterSeconds: nil,
        waterDetectionDepthMeters: 0.35
    )
}

struct SnorkelingLifecycleTracker: Hashable, Codable, Sendable {
    var phase: SnorkelingLifecyclePhase
    var phaseBeforePause: SnorkelingLifecyclePhase?
    var phaseBeforeSensorDegraded: SnorkelingLifecyclePhase?
    var dipCandidateSince: TimeInterval?
    var surfaceDwellSince: TimeInterval?
    var outOfWaterSince: TimeInterval?
    var dipStartedAt: TimeInterval?
    var dipMaxDepthMeters: Double
    var lastMeasurementMonotonic: TimeInterval?
    var totalUnderwaterSeconds: TimeInterval
    var totalSurfaceSeconds: TimeInterval
    var lastUnderwaterPhaseStart: TimeInterval?

    static let initial = SnorkelingLifecycleTracker(
        phase: .idle,
        phaseBeforePause: nil,
        phaseBeforeSensorDegraded: nil,
        dipCandidateSince: nil,
        surfaceDwellSince: nil,
        outOfWaterSince: nil,
        dipStartedAt: nil,
        dipMaxDepthMeters: 0,
        lastMeasurementMonotonic: nil,
        totalUnderwaterSeconds: 0,
        totalSurfaceSeconds: 0,
        lastUnderwaterPhaseStart: nil
    )
}

enum SnorkelingLifecycleTransitionEvent: Hashable, Sendable {
    case phaseChanged(from: SnorkelingLifecyclePhase, to: SnorkelingLifecyclePhase)
    case dipStarted(atMonotonic: TimeInterval)
    case dipEnded(atMonotonic: TimeInterval, startedAtMonotonic: TimeInterval, maxDepthMeters: Double)
    case sensorDegraded
    case sensorRecovered
    case sessionAutoEnded
}

struct SnorkelingLifecycleMachineInput: Hashable, Sendable {
    let configuration: SnorkelingLifecycleConfiguration
    let monotonicNow: TimeInterval
    let wallClockNow: Date
    let acceptedDepthMeters: Double?
    let verticalSpeedMetersPerSecond: Double
    let feedAccepted: Bool
    let sensorAvailable: Bool
    let manualFallbackActive: Bool
    let manualDipStartTriggered: Bool
    let manualDipEndTriggered: Bool
    let sessionArmed: Bool
    let sessionStarted: Bool
    let navigationRequested: Bool
    let returnModeRequested: Bool
    let exitNavigationRequested: Bool
    let pauseRequested: Bool
    let resumeRequested: Bool
    let endSessionRequested: Bool
    let tickOnly: Bool
}

struct SnorkelingLifecycleMachineOutput: Hashable, Sendable {
    var tracker: SnorkelingLifecycleTracker
    var events: [SnorkelingLifecycleTransitionEvent]
}

/// Pure snorkeling lifecycle state machine — UI-free, independent from ExplorationStore and Dive runtime.
enum SnorkelingLifecycleStateMachine {
    static func evaluate(
        input: SnorkelingLifecycleMachineInput,
        tracker: SnorkelingLifecycleTracker
    ) -> SnorkelingLifecycleMachineOutput {
        var tracker = tracker
        var events: [SnorkelingLifecycleTransitionEvent] = []

        if input.endSessionRequested, tracker.phase != .ended {
            closeUnderwaterAccounting(until: input.monotonicNow, tracker: &tracker)
            return transition(&tracker, &events, to: .ended)
        }

        if input.pauseRequested, isPausable(tracker.phase) {
            tracker.phaseBeforePause = operationalPhase(for: tracker)
            return transition(&tracker, &events, to: .paused)
        }

        if input.resumeRequested, tracker.phase == .paused {
            let restore = tracker.phaseBeforePause ?? .surfaceActive
            tracker.phaseBeforePause = nil
            return transition(&tracker, &events, to: restore)
        }

        if input.sessionArmed, tracker.phase == .idle {
            return transition(&tracker, &events, to: .ready)
        }

        if input.sessionStarted, tracker.phase == .ready {
            let target: SnorkelingLifecyclePhase
            if let depth = input.acceptedDepthMeters,
               input.feedAccepted,
               depth >= input.configuration.waterDetectionDepthMeters {
                target = .dipping
                startDip(at: input.monotonicNow, depth: depth, tracker: &tracker, events: &events)
                beginUnderwaterAccounting(at: input.monotonicNow, tracker: &tracker)
            } else {
                target = .surfaceActive
            }
            tracker.outOfWaterSince = input.monotonicNow
            return transition(&tracker, &events, to: target)
        }

        if input.navigationRequested, isOperational(tracker.phase) {
            return transition(&tracker, &events, to: .navigation)
        }

        if input.returnModeRequested, isOperational(tracker.phase) {
            return transition(&tracker, &events, to: .returnMode)
        }

        if input.exitNavigationRequested,
           tracker.phase == .navigation || tracker.phase == .returnMode {
            return transition(&tracker, &events, to: .surfaceActive)
        }

        restorePhaseAfterSensorRecovery(&tracker, &events)

        if !input.sensorAvailable,
           !input.manualFallbackActive,
           tracker.phase != .idle,
           tracker.phase != .ended,
           tracker.phase != .ready,
           tracker.phase != .paused {
            if tracker.phase != .sensorDegraded {
                closeUnderwaterAccounting(until: input.monotonicNow, tracker: &tracker)
                tracker.phaseBeforeSensorDegraded = operationalPhase(for: tracker)
                events.append(.sensorDegraded)
                return transition(&tracker, &events, to: .sensorDegraded)
            }
            return SnorkelingLifecycleMachineOutput(tracker: tracker, events: events)
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
        if isUnderwaterPhase(tracker.phase) {
            tracker.dipMaxDepthMeters = max(tracker.dipMaxDepthMeters, depth)
        }

        switch tracker.phase {
        case .idle, .ended, .ready, .paused, .sensorDegraded, .recovered:
            break

        case .surfaceActive, .navigation, .returnMode:
            tracker.outOfWaterSince = tracker.outOfWaterSince ?? input.monotonicNow
            if input.manualDipStartTriggered || shouldStartDip(depth: depth, input: input, tracker: &tracker) {
                tracker.dipCandidateSince = nil
                startDip(at: input.monotonicNow, depth: depth, tracker: &tracker, events: &events)
                beginUnderwaterAccounting(at: input.monotonicNow, tracker: &tracker)
                transition(&tracker, &events, to: .dipping)
            }

        case .dipping:
            if input.manualDipEndTriggered || depth <= input.configuration.surfaceDepthMeters + input.configuration.surfaceHysteresisMeters {
                tracker.surfaceDwellSince = tracker.surfaceDwellSince ?? input.monotonicNow
                transition(&tracker, &events, to: .resurfacing)
            }

        case .resurfacing:
            if depth > input.configuration.dipStartDepthMeters + input.configuration.dipHysteresisMeters {
                tracker.surfaceDwellSince = nil
                transition(&tracker, &events, to: .dipping)
            } else {
                tracker.surfaceDwellSince = tracker.surfaceDwellSince ?? input.monotonicNow
                if let dwellSince = tracker.surfaceDwellSince,
                   input.monotonicNow - dwellSince >= input.configuration.surfaceStableDwellSeconds {
                    finishDip(input: input, tracker: &tracker, events: &events)
                    closeUnderwaterAccounting(until: input.monotonicNow, tracker: &tracker)
                    tracker.outOfWaterSince = input.monotonicNow
                    transition(&tracker, &events, to: .surfaceActive)
                }
            }
        }

        return SnorkelingLifecycleMachineOutput(tracker: tracker, events: events)
    }

    private static func isOperational(_ phase: SnorkelingLifecyclePhase) -> Bool {
        switch phase {
        case .surfaceActive, .dipping, .resurfacing, .navigation, .returnMode, .recovered:
            return true
        case .idle, .ready, .paused, .ended, .sensorDegraded:
            return false
        }
    }

    private static func isPausable(_ phase: SnorkelingLifecyclePhase) -> Bool {
        switch phase {
        case .surfaceActive, .dipping, .resurfacing, .navigation, .returnMode:
            return true
        default:
            return false
        }
    }

    private static func isUnderwaterPhase(_ phase: SnorkelingLifecyclePhase) -> Bool {
        phase == .dipping || phase == .resurfacing
    }

    private static func restorePhaseAfterSensorRecovery(
        _ tracker: inout SnorkelingLifecycleTracker,
        _ events: inout [SnorkelingLifecycleTransitionEvent]
    ) {
        guard tracker.phase == .recovered, let restore = tracker.phaseBeforeSensorDegraded else { return }
        tracker.phaseBeforeSensorDegraded = nil
        if tracker.phase != restore {
            events.append(.phaseChanged(from: .recovered, to: restore))
            tracker.phase = restore
        }
    }

    private static func operationalPhase(for tracker: SnorkelingLifecycleTracker) -> SnorkelingLifecyclePhase {
        if tracker.phase == .recovered {
            return tracker.phaseBeforeSensorDegraded ?? .surfaceActive
        }
        if tracker.phase == .paused {
            return tracker.phaseBeforePause ?? .surfaceActive
        }
        return tracker.phase
    }

    private static func startDip(
        at monotonic: TimeInterval,
        depth: Double,
        tracker: inout SnorkelingLifecycleTracker,
        events: inout [SnorkelingLifecycleTransitionEvent]
    ) {
        tracker.dipStartedAt = monotonic
        tracker.dipMaxDepthMeters = depth
        tracker.surfaceDwellSince = nil
        events.append(.dipStarted(atMonotonic: monotonic))
    }

    private static func finishDip(
        input: SnorkelingLifecycleMachineInput,
        tracker: inout SnorkelingLifecycleTracker,
        events: inout [SnorkelingLifecycleTransitionEvent]
    ) {
        let dipDuration = (tracker.dipStartedAt.map { input.monotonicNow - $0 }) ?? 0
        if dipDuration >= input.configuration.minimumDipDurationSeconds,
           let startedAt = tracker.dipStartedAt {
            events.append(
                .dipEnded(
                    atMonotonic: input.monotonicNow,
                    startedAtMonotonic: startedAt,
                    maxDepthMeters: tracker.dipMaxDepthMeters
                )
            )
        }
        tracker.dipStartedAt = nil
        tracker.dipMaxDepthMeters = 0
        tracker.surfaceDwellSince = nil
        tracker.dipCandidateSince = nil
    }

    private static func shouldStartDip(
        depth: Double,
        input: SnorkelingLifecycleMachineInput,
        tracker: inout SnorkelingLifecycleTracker
    ) -> Bool {
        guard depth > input.configuration.dipStartDepthMeters else {
            tracker.dipCandidateSince = nil
            return false
        }
        if tracker.dipCandidateSince == nil {
            tracker.dipCandidateSince = input.monotonicNow
        }
        guard let candidate = tracker.dipCandidateSince else { return false }
        return input.monotonicNow - candidate >= input.configuration.dipStartDebounceSeconds
    }

    private static func beginUnderwaterAccounting(at monotonic: TimeInterval, tracker: inout SnorkelingLifecycleTracker) {
        tracker.lastUnderwaterPhaseStart = monotonic
        tracker.outOfWaterSince = nil
    }

    private static func closeUnderwaterAccounting(until monotonic: TimeInterval, tracker: inout SnorkelingLifecycleTracker) {
        if let started = tracker.lastUnderwaterPhaseStart {
            tracker.totalUnderwaterSeconds += max(0, monotonic - started)
            tracker.lastUnderwaterPhaseStart = nil
        }
    }

    private static func evaluateTimeouts(
        input: SnorkelingLifecycleMachineInput,
        tracker: inout SnorkelingLifecycleTracker,
        events: inout [SnorkelingLifecycleTransitionEvent]
    ) -> SnorkelingLifecycleMachineOutput {
        if let last = tracker.lastMeasurementMonotonic,
           input.monotonicNow - last >= input.configuration.sensorLossTimeoutSeconds,
           !input.manualFallbackActive,
           tracker.phase != .sensorDegraded,
           tracker.phase != .idle,
           tracker.phase != .ended,
           tracker.phase != .ready,
           tracker.phase != .paused {
            closeUnderwaterAccounting(until: input.monotonicNow, tracker: &tracker)
            tracker.phaseBeforeSensorDegraded = operationalPhase(for: tracker)
            events.append(.sensorDegraded)
            transition(&tracker, &events, to: .sensorDegraded)
        }

        if tracker.phase == .resurfacing,
           let dwellSince = tracker.surfaceDwellSince,
           input.monotonicNow - dwellSince >= input.configuration.surfaceStableDwellSeconds {
            finishDip(input: input, tracker: &tracker, events: &events)
            closeUnderwaterAccounting(until: input.monotonicNow, tracker: &tracker)
            tracker.outOfWaterSince = input.monotonicNow
            transition(&tracker, &events, to: .surfaceActive)
        }

        if let autoEnd = input.configuration.autoEndOutOfWaterSeconds,
           tracker.phase == .surfaceActive,
           let outOfWaterSince = tracker.outOfWaterSince,
           input.monotonicNow - outOfWaterSince >= autoEnd {
            events.append(.sessionAutoEnded)
            return transition(&tracker, &events, to: .ended)
        }

        if isUnderwaterPhase(tracker.phase), tracker.lastUnderwaterPhaseStart == nil {
            beginUnderwaterAccounting(at: input.monotonicNow, tracker: &tracker)
        }

        return SnorkelingLifecycleMachineOutput(tracker: tracker, events: events)
    }

    private static func transition(
        _ tracker: inout SnorkelingLifecycleTracker,
        _ events: inout [SnorkelingLifecycleTransitionEvent],
        to phase: SnorkelingLifecyclePhase
    ) -> SnorkelingLifecycleMachineOutput {
        let from = tracker.phase
        if from != phase {
            events.append(.phaseChanged(from: from, to: phase))
            tracker.phase = phase
        }
        return SnorkelingLifecycleMachineOutput(tracker: tracker, events: events)
    }
}
