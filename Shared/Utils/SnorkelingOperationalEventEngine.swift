import Foundation

enum SnorkelingOperationalEventEngine {
    static let minimumAlarmRepeatSeconds: TimeInterval = 0.25
    static let hapticCooldownSeconds: TimeInterval = 0.25

    static func evaluate(
        alarms: [SnorkelingAlarm],
        depthMeters: Double?,
        verticalSpeedMetersPerSecond: Double,
        state: inout SnorkelingOperationalEventState,
        context: SnorkelingOperationalEventContext
    ) -> SnorkelingOperationalEventOutput {
        var output = SnorkelingOperationalEventOutput.empty
        let depth = depthMeters ?? 0

        for alarm in alarms where alarm.isEnabled {
            let isActive = evaluate(alarm: alarm, depth: depth, verticalSpeed: verticalSpeedMetersPerSecond, context: context)
            if isActive {
                state.armedAlarmIDs.insert(alarm.id)
                output.overlays.append(
                    SnorkelingOperationalOverlay(
                        kind: .alarm,
                        titleKey: "snorkeling.alarm.title",
                        subtitle: alarm.label,
                        severity: severity(for: alarm.kind),
                        eventID: alarm.id
                    )
                )
                guard shouldFireAlarm(alarm: alarm, state: &state, monotonicNow: context.monotonicNow) else { continue }
                let event = SnorkelingEvent(
                    kind: .alarmTriggered,
                    monotonicRelativeTimestampSeconds: context.monotonicNow,
                    wallClockTimestamp: context.wallClockNow,
                    depthMeters: depthMeters,
                    note: alarm.label,
                    relatedAlarmID: alarm.id
                )
                output.events.append(event)
                if let cue = makeHapticCue(pattern: hapticPattern(for: alarm.kind), context: context, state: &state, sourceID: alarm.id) {
                    output.hapticCues.append(cue)
                }
            } else if state.armedAlarmIDs.contains(alarm.id), rearmed(alarm: alarm, depth: depth, verticalSpeed: verticalSpeedMetersPerSecond, context: context) {
                state.armedAlarmIDs.remove(alarm.id)
            }
        }

        evaluateGPSTransitions(context: context, state: &state, output: &output)
        return output
    }

    // MARK: - Private

    private static func evaluate(
        alarm: SnorkelingAlarm,
        depth: Double,
        verticalSpeed: Double,
        context: SnorkelingOperationalEventContext
    ) -> Bool {
        switch alarm.kind {
        case .maxDepth:
            return depth >= (alarm.thresholdDepthMeters ?? .greatestFiniteMagnitude)
        case .maxDuration:
            return context.sessionElapsedSeconds >= (alarm.thresholdDurationSeconds ?? .greatestFiniteMagnitude)
        case .maxDistance:
            return (context.distanceFromEntryMeters ?? 0) >= (alarm.thresholdDistanceMeters ?? .greatestFiniteMagnitude)
        case .maxDipDuration:
            return context.activeDipElapsedSeconds >= (alarm.thresholdDipDurationSeconds ?? .greatestFiniteMagnitude)
        case .maxAscentRate:
            let ascent = max(0, -verticalSpeed)
            return ascent >= (alarm.thresholdAscentRateMetersPerSecond ?? .greatestFiniteMagnitude)
        case .batteryLow:
            guard let battery = context.batteryFraction else { return false }
            return battery <= (alarm.thresholdBatteryPercent ?? -1)
        case .temperatureOutOfRange:
            guard let temperature = context.temperatureCelsius,
                  let threshold = alarm.thresholdTemperatureCelsius else { return false }
            return temperature <= threshold
        case .gpsDegraded:
            return context.gpsPresentationState == .degraded || context.gpsPresentationState == .stale
        case .gpsLost:
            return context.gpsPresentationState == .unavailable || context.gpsPresentationState == .underwaterUnavailable
        case .sensorDegraded:
            return context.sensorHealth == .degraded || context.sensorHealth == .manualFallback
        case .custom:
            return false
        }
    }

    private static func rearmed(
        alarm: SnorkelingAlarm,
        depth: Double,
        verticalSpeed: Double,
        context: SnorkelingOperationalEventContext
    ) -> Bool {
        switch alarm.kind {
        case .maxDepth:
            let hysteresis = alarm.hysteresisMeters ?? 0.3
            return depth <= (alarm.thresholdDepthMeters ?? 0) - hysteresis
        case .maxDuration, .maxDipDuration:
            let hysteresis = alarm.hysteresisSeconds ?? 5
            let threshold = alarm.kind == .maxDipDuration
                ? (alarm.thresholdDipDurationSeconds ?? 0)
                : (alarm.thresholdDurationSeconds ?? 0)
            let elapsed = alarm.kind == .maxDipDuration ? context.activeDipElapsedSeconds : context.sessionElapsedSeconds
            return elapsed <= threshold - hysteresis
        case .maxDistance:
            let hysteresis = alarm.hysteresisMeters ?? 10
            return (context.distanceFromEntryMeters ?? 0) <= (alarm.thresholdDistanceMeters ?? 0) - hysteresis
        case .maxAscentRate:
            return max(0, -verticalSpeed) <= (alarm.thresholdAscentRateMetersPerSecond ?? 0) * 0.8
        case .batteryLow:
            guard let battery = context.batteryFraction else { return true }
            return battery > (alarm.thresholdBatteryPercent ?? 0) + 0.03
        case .temperatureOutOfRange:
            guard let temperature = context.temperatureCelsius,
                  let threshold = alarm.thresholdTemperatureCelsius else { return true }
            return temperature > threshold + 0.5
        case .gpsDegraded, .gpsLost, .sensorDegraded, .custom:
            return true
        }
    }

    private static func shouldFireAlarm(
        alarm: SnorkelingAlarm,
        state: inout SnorkelingOperationalEventState,
        monotonicNow: TimeInterval
    ) -> Bool {
        let last = state.lastAlarmFireMonotonic[alarm.id] ?? -.greatestFiniteMagnitude
        let repeatInterval = max(minimumAlarmRepeatSeconds, alarm.minimumRepeatSeconds)
        guard monotonicNow - last >= repeatInterval else { return false }
        state.lastAlarmFireMonotonic[alarm.id] = monotonicNow
        return true
    }

    private static func evaluateGPSTransitions(
        context: SnorkelingOperationalEventContext,
        state: inout SnorkelingOperationalEventState,
        output: inout SnorkelingOperationalEventOutput
    ) {
        let gpsAvailable = context.gpsPresentationState == .tracking || context.gpsPresentationState == .degraded
        if state.gpsWasAvailable && !gpsAvailable {
            output.events.append(
                SnorkelingEvent(
                    kind: .gpsLost,
                    monotonicRelativeTimestampSeconds: context.monotonicNow,
                    wallClockTimestamp: context.wallClockNow
                )
            )
            output.overlays.append(
                SnorkelingOperationalOverlay(
                    kind: .gpsDegraded,
                    titleKey: "snorkeling.gps.lost",
                    subtitle: "GPS unavailable",
                    severity: .warning,
                    eventID: UUID()
                )
            )
        } else if !state.gpsWasAvailable && gpsAvailable {
            output.events.append(
                SnorkelingEvent(
                    kind: .gpsRecovered,
                    monotonicRelativeTimestampSeconds: context.monotonicNow,
                    wallClockTimestamp: context.wallClockNow
                )
            )
        }
        state.gpsWasAvailable = gpsAvailable
    }

    private static func makeHapticCue(
        pattern: SnorkelingHapticPattern,
        context: SnorkelingOperationalEventContext,
        state: inout SnorkelingOperationalEventState,
        sourceID: UUID?
    ) -> SnorkelingHapticCue? {
        guard context.hapticsEnabled else { return nil }
        if let activeUntil = state.activeHapticUntilMonotonic, activeUntil > context.monotonicNow {
            return nil
        }
        state.activeHapticUntilMonotonic = context.monotonicNow + hapticCooldownSeconds
        return SnorkelingHapticCue(pattern: pattern, atMonotonicSeconds: context.monotonicNow, sourceID: sourceID)
    }

    private static func hapticPattern(for kind: SnorkelingAlarmKind) -> SnorkelingHapticPattern {
        switch kind {
        case .maxAscentRate, .batteryLow, .gpsLost, .sensorDegraded:
            return .alarmCritical
        case .gpsDegraded, .temperatureOutOfRange, .maxDipDuration:
            return .alarmWarning
        case .maxDepth, .maxDuration, .maxDistance, .custom:
            return .alarmInfo
        }
    }

    private static func severity(for kind: SnorkelingAlarmKind) -> SnorkelingOperationalSeverity {
        switch kind {
        case .maxAscentRate, .batteryLow, .gpsLost, .sensorDegraded:
            return .critical
        case .gpsDegraded, .temperatureOutOfRange, .maxDipDuration:
            return .warning
        case .maxDepth, .maxDuration, .maxDistance, .custom:
            return .caution
        }
    }
}
