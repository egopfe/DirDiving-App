import Foundation

enum ApneaHapticPattern: String, Codable, Hashable, Sendable {
    case markerReached
    case targetReached
    case alarmInfo
    case alarmWarning
    case alarmCritical
}

struct ApneaHapticCue: Codable, Hashable, Sendable {
    var pattern: ApneaHapticPattern
    var atMonotonicSeconds: TimeInterval
    var sourceID: UUID?
}

struct ApneaOperationalOverlay: Codable, Hashable, Sendable {
    enum Kind: String, Codable, Hashable, Sendable {
        case markerReached
        case targetReached
        case alarm
    }

    var kind: Kind
    var title: String
    var subtitle: String
    var depthMeters: Double?
    var eventID: UUID
}

struct ApneaOperationalEventOutput: Codable, Hashable, Sendable {
    var events: [ApneaEvent]
    var overlays: [ApneaOperationalOverlay]
    var hapticCues: [ApneaHapticCue]
    var reachedMarkerIDs: [UUID]
    var reachedTargetIDs: [UUID]

    static let empty = ApneaOperationalEventOutput(events: [], overlays: [], hapticCues: [], reachedMarkerIDs: [], reachedTargetIDs: [])
}

struct ApneaOperationalEventContext: Codable, Hashable, Sendable {
    var monotonicNow: TimeInterval
    var wallClockNow: Date
    var diveElapsedSeconds: TimeInterval
    var sessionElapsedSeconds: TimeInterval
    var recoveryCompleted: Bool
    var batteryPercent: Double?
    var sensorDegraded: Bool
    var missionModeEnabled: Bool
    var hapticsEnabled: Bool
}

struct ApneaOperationalEventState: Codable, Hashable, Sendable {
    var armedMarkerCrossingIDs: Set<UUID>
    var armedTargetCrossingIDs: Set<UUID>
    var lastAlarmFireMonotonic: [UUID: TimeInterval]
    var activeHapticUntilMonotonic: TimeInterval?

    static let initial = ApneaOperationalEventState(
        armedMarkerCrossingIDs: [],
        armedTargetCrossingIDs: [],
        lastAlarmFireMonotonic: [:],
        activeHapticUntilMonotonic: nil
    )
}

enum ApneaOperationalEventEngine {
    static func evaluate(
        previousDepthMeters: Double?,
        currentDepthMeters: Double,
        verticalSpeedMetersPerSecond: Double,
        alarms: [ApneaAlarm],
        targets: [ApneaTarget],
        markers: [ApneaDepthMarker],
        state: inout ApneaOperationalEventState,
        context: ApneaOperationalEventContext
    ) -> ApneaOperationalEventOutput {
        var output = ApneaOperationalEventOutput.empty
        let previous = previousDepthMeters ?? currentDepthMeters

        for marker in markers where marker.isEnabled {
            if crossed(previous: previous, current: currentDepthMeters, threshold: marker.depthMeters, direction: marker.direction, verticalSpeed: verticalSpeedMetersPerSecond), !state.armedMarkerCrossingIDs.contains(marker.id) {
                let event = ApneaEvent(
                    kind: .markerReached,
                    monotonicRelativeTimestampSeconds: context.monotonicNow,
                    wallClockTimestamp: context.wallClockNow,
                    depthMeters: currentDepthMeters,
                    note: marker.label,
                    relatedMarkerID: marker.id
                )
                output.events.append(event)
                output.overlays.append(
                    ApneaOperationalOverlay(
                        kind: .markerReached,
                        title: "MARKER",
                        subtitle: "\(Int(marker.depthMeters.rounded())) m raggiunto",
                        depthMeters: marker.depthMeters,
                        eventID: event.id
                    )
                )
                output.reachedMarkerIDs.append(marker.id)
                if shouldEmitHaptic(context: context, state: &state, at: context.monotonicNow) {
                    output.hapticCues.append(ApneaHapticCue(pattern: .markerReached, atMonotonicSeconds: context.monotonicNow, sourceID: marker.id))
                }
                state.armedMarkerCrossingIDs.insert(marker.id)
            } else if rearmed(previous: previous, current: currentDepthMeters, threshold: marker.depthMeters, hysteresis: marker.toleranceMeters) {
                state.armedMarkerCrossingIDs.remove(marker.id)
            }
        }

        for target in targets where target.isEnabled {
            guard let targetDepth = target.targetDepthMeters else { continue }
            if crossed(previous: previous, current: currentDepthMeters, threshold: targetDepth, direction: target.direction, verticalSpeed: verticalSpeedMetersPerSecond), !state.armedTargetCrossingIDs.contains(target.id) {
                let event = ApneaEvent(
                    kind: .targetReached,
                    monotonicRelativeTimestampSeconds: context.monotonicNow,
                    wallClockTimestamp: context.wallClockNow,
                    depthMeters: currentDepthMeters,
                    note: target.reachedMessage ?? target.label,
                    relatedTargetID: target.id
                )
                output.events.append(event)
                output.overlays.append(
                    ApneaOperationalOverlay(
                        kind: .targetReached,
                        title: "TARGET",
                        subtitle: "\(Int(targetDepth.rounded())) m raggiunto",
                        depthMeters: targetDepth,
                        eventID: event.id
                    )
                )
                output.reachedTargetIDs.append(target.id)
                if shouldEmitHaptic(context: context, state: &state, at: context.monotonicNow) {
                    output.hapticCues.append(ApneaHapticCue(pattern: .targetReached, atMonotonicSeconds: context.monotonicNow, sourceID: target.id))
                }
                state.armedTargetCrossingIDs.insert(target.id)
            } else if rearmed(previous: previous, current: currentDepthMeters, threshold: targetDepth, hysteresis: target.hysteresisMeters) {
                state.armedTargetCrossingIDs.remove(target.id)
            }
        }

        for alarm in alarms where alarm.isEnabled {
            guard alarm.direction.matches(verticalSpeedMetersPerSecond: verticalSpeedMetersPerSecond) else { continue }
            guard evaluate(alarm: alarm, depth: currentDepthMeters, speed: verticalSpeedMetersPerSecond, context: context) else { continue }
            let last = state.lastAlarmFireMonotonic[alarm.id] ?? -.greatestFiniteMagnitude
            guard context.monotonicNow - last >= max(0.2, alarm.minimumRepeatSeconds) else { continue }

            state.lastAlarmFireMonotonic[alarm.id] = context.monotonicNow
            let event = ApneaEvent(
                kind: .alarmTriggered,
                monotonicRelativeTimestampSeconds: context.monotonicNow,
                wallClockTimestamp: context.wallClockNow,
                depthMeters: currentDepthMeters,
                note: alarm.label,
                relatedAlarmID: alarm.id
            )
            output.events.append(event)
            output.overlays.append(
                ApneaOperationalOverlay(
                    kind: .alarm,
                    title: "ALLARME",
                    subtitle: alarm.label,
                    depthMeters: alarm.thresholdDepthMeters,
                    eventID: event.id
                )
            )
            if shouldEmitHaptic(context: context, state: &state, at: context.monotonicNow) {
                output.hapticCues.append(ApneaHapticCue(pattern: hapticPattern(for: alarm.kind), atMonotonicSeconds: context.monotonicNow, sourceID: alarm.id))
            }
        }

        return output
    }

    private static func crossed(
        previous: Double,
        current: Double,
        threshold: Double,
        direction: ApneaEventDirection,
        verticalSpeed: Double
    ) -> Bool {
        switch direction {
        case .descending:
            return previous < threshold && current >= threshold && verticalSpeed >= 0
        case .ascending:
            return previous > threshold && current <= threshold && verticalSpeed <= 0
        case .both:
            return (previous < threshold && current >= threshold) || (previous > threshold && current <= threshold)
        }
    }

    private static func rearmed(previous: Double, current: Double, threshold: Double, hysteresis: Double) -> Bool {
        let lower = threshold - max(0, hysteresis)
        let upper = threshold + max(0, hysteresis)
        return (previous <= lower && current <= lower) || (previous >= upper && current >= upper)
    }

    private static func evaluate(alarm: ApneaAlarm, depth: Double, speed: Double, context: ApneaOperationalEventContext) -> Bool {
        switch alarm.kind {
        case .depth:
            return depth >= (alarm.thresholdDepthMeters ?? .greatestFiniteMagnitude)
        case .duration:
            return context.diveElapsedSeconds >= (alarm.thresholdDurationSeconds ?? .greatestFiniteMagnitude)
        case .descentRate:
            return speed >= (alarm.thresholdVerticalSpeedMetersPerSecond ?? .greatestFiniteMagnitude)
        case .ascentRate:
            return -speed >= (alarm.thresholdVerticalSpeedMetersPerSecond ?? .greatestFiniteMagnitude)
        case .recoveryInsufficient:
            return !context.recoveryCompleted
        case .battery:
            guard let battery = context.batteryPercent else { return false }
            return battery <= (alarm.thresholdBatteryPercent ?? -1)
        case .sensorDegraded:
            return context.sensorDegraded
        case .sessionProlonged:
            return context.sessionElapsedSeconds >= (alarm.thresholdDurationSeconds ?? .greatestFiniteMagnitude)
        case .custom:
            return false
        }
    }

    private static func shouldEmitHaptic(
        context: ApneaOperationalEventContext,
        state: inout ApneaOperationalEventState,
        at monotonicNow: TimeInterval
    ) -> Bool {
        guard context.hapticsEnabled else { return false }
        if let activeUntil = state.activeHapticUntilMonotonic, activeUntil > monotonicNow {
            return false
        }
        state.activeHapticUntilMonotonic = monotonicNow + 0.25
        return true
    }

    private static func hapticPattern(for kind: ApneaAlarmKind) -> ApneaHapticPattern {
        switch kind {
        case .sensorDegraded, .ascentRate, .battery:
            return .alarmCritical
        case .recoveryInsufficient, .sessionProlonged, .descentRate:
            return .alarmWarning
        case .depth, .duration, .custom:
            return .alarmInfo
        }
    }
}
