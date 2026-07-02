import Foundation

struct SnorkelingRouteRuntimeState: Equatable, Sendable {
    var plannedReturnAlertState = SnorkelingPlannedRouteReturnAlertEngine.State()
    var returnAlertTriggered = false
    var offRouteHapticFiredForCurrentEvent = false
    var offRouteEventCount = 0
    var maxOffRouteDistanceMeters: Double?
    var timeOffRouteSeconds: TimeInterval = 0
    var wasOffRoute = false
    var accuracySamples: [Double] = []
    var gapsDetected = 0
}

struct SnorkelingRouteRuntimeEvaluation: Equatable, Sendable {
    var gpsQualityBand: SnorkelingWatchGPSPresentationBand?
    var routeProgressPercent: Double?
    var offRouteDistanceMeters: Double?
    var isOffRoute: Bool
    var offRouteWarningPaused: Bool
    var plannedReturnAlertTriggered: Bool
    var hapticCues: [SnorkelingHapticCue]
}

enum SnorkelingRouteRuntimeEvaluator {
    static let plannedReturnAlertSourceID = UUID(uuidString: "A1B2C3D4-E5F6-7890-ABCD-EF1234567890")!
    static let offRouteAlertSourceID = UUID(uuidString: "B2C3D4E5-F6A7-8901-BCDE-F12345678901")!

    static func evaluate(
        metadata: SnorkelingRoutePlanningMetadata?,
        routeCoordinates: [SnorkelingCoordinate],
        currentCoordinate: SnorkelingCoordinate?,
        horizontalAccuracyMeters: Double?,
        fixAgeSeconds: TimeInterval?,
        sessionElapsedSeconds: TimeInterval,
        traveledDistanceMeters: Double,
        monotonicNow: TimeInterval,
        state: inout SnorkelingRouteRuntimeState
    ) -> SnorkelingRouteRuntimeEvaluation {
        let hasCoordinate = currentCoordinate != nil
        let gpsThresholds = gpsQualityThresholds(from: metadata)
        let gpsBand = SnorkelingGPSQualityEvaluator.evaluate(
            horizontalAccuracyMeters: horizontalAccuracyMeters,
            fixAgeSeconds: fixAgeSeconds,
            hasCoordinate: hasCoordinate,
            thresholds: gpsThresholds
        )

        if let accuracy = horizontalAccuracyMeters, accuracy.isFinite, accuracy >= 0 {
            state.accuracySamples.append(accuracy)
        }

        let progress: Double?
        let offRouteDistance: Double?
        let isOffRoute: Bool
        let offRoutePaused: Bool

        if routeCoordinates.count >= 2, let currentCoordinate {
            progress = SnorkelingRouteProgressCalculator.progressPercent(
                current: currentCoordinate,
                routePoints: routeCoordinates
            )
            offRouteDistance = SnorkelingOffRouteDetector.distanceFromRouteMeters(
                current: currentCoordinate,
                routePoints: routeCoordinates
            )
            let gpsReliable = gpsBand == .good || gpsBand == .medium
            let offRouteThreshold = metadata?.offRouteThresholdMeters ?? SnorkelingOffRouteDetector.defaultThresholdMeters
            isOffRoute = gpsReliable && SnorkelingOffRouteDetector.isOffRoute(
                current: currentCoordinate,
                routePoints: routeCoordinates,
                thresholdMeters: offRouteThreshold
            )
            offRoutePaused = !gpsReliable && (offRouteDistance ?? 0) > offRouteThreshold
        } else {
            progress = nil
            offRouteDistance = nil
            isOffRoute = false
            offRoutePaused = false
        }

        updateOffRouteAccumulation(
            isOffRoute: isOffRoute,
            offRouteDistance: offRouteDistance,
            state: &state
        )

        var hapticCues: [SnorkelingHapticCue] = []
        var plannedTriggered = false
        if let metadata {
            let shouldFire = SnorkelingPlannedRouteReturnAlertEngine.shouldTrigger(
                policy: metadata.returnAlertPolicy,
                plannedDurationSeconds: metadata.estimatedDurationSeconds,
                plannedDistanceMeters: metadata.estimatedDistanceMeters,
                elapsedSeconds: sessionElapsedSeconds,
                traveledDistanceMeters: traveledDistanceMeters,
                state: &state.plannedReturnAlertState
            )
            if shouldFire {
                state.returnAlertTriggered = true
                plannedTriggered = true
                hapticCues.append(
                    SnorkelingHapticCue(
                        pattern: .returnAdvised,
                        atMonotonicSeconds: monotonicNow,
                        sourceID: plannedReturnAlertSourceID
                    )
                )
            }
        }

        if isOffRoute, !state.offRouteHapticFiredForCurrentEvent {
            state.offRouteHapticFiredForCurrentEvent = true
            hapticCues.append(
                SnorkelingHapticCue(
                    pattern: .alarmWarning,
                    atMonotonicSeconds: monotonicNow,
                    sourceID: offRouteAlertSourceID
                )
            )
        } else if !isOffRoute {
            state.offRouteHapticFiredForCurrentEvent = false
        }

        return SnorkelingRouteRuntimeEvaluation(
            gpsQualityBand: gpsBand,
            routeProgressPercent: progress,
            offRouteDistanceMeters: offRouteDistance,
            isOffRoute: isOffRoute,
            offRouteWarningPaused: offRoutePaused,
            plannedReturnAlertTriggered: plannedTriggered,
            hapticCues: hapticCues
        )
    }

    static func makeRuntimeSummary(
        state: SnorkelingRouteRuntimeState,
        gpsQualityBand: SnorkelingWatchGPSPresentationBand?,
        routeProgressPercent: Double?,
        trackPointCount: Int
    ) -> SnorkelingSessionRuntimeSummary {
        let averageAccuracy: Double?
        if state.accuracySamples.isEmpty {
            averageAccuracy = nil
        } else {
            averageAccuracy = state.accuracySamples.reduce(0, +) / Double(state.accuracySamples.count)
        }
        let maxAccuracy = state.accuracySamples.max()
        return SnorkelingSessionRuntimeSummary(
            gpsQualityBand: gpsQualityBand,
            trackPointCount: trackPointCount,
            gapsDetected: state.gapsDetected,
            averageAccuracyMeters: averageAccuracy,
            maxAccuracyMeters: maxAccuracy,
            routeCompletedPercentage: routeProgressPercent,
            returnAlertTriggered: state.returnAlertTriggered,
            offRouteEventCount: state.offRouteEventCount,
            maxOffRouteDistanceMeters: state.maxOffRouteDistanceMeters,
            timeOffRouteSeconds: state.timeOffRouteSeconds
        )
    }

    private static func gpsQualityThresholds(from metadata: SnorkelingRoutePlanningMetadata?) -> SnorkelingGPSQualityThresholds {
        guard let accuracy = metadata?.gpsQualityWarningAccuracyMeters, accuracy.isFinite, accuracy > 0 else {
            return .default
        }
        return SnorkelingGPSQualityThresholds(
            goodAccuracyMeters: 15,
            mediumAccuracyMeters: max(15, accuracy),
            goodFixAgeSeconds: 10,
            mediumFixAgeSeconds: 20,
            lostFixAgeSeconds: 60
        )
    }

    private static func updateOffRouteAccumulation(
        isOffRoute: Bool,
        offRouteDistance: Double?,
        state: inout SnorkelingRouteRuntimeState
    ) {
        if isOffRoute {
            if !state.wasOffRoute {
                state.offRouteEventCount += 1
            }
            state.timeOffRouteSeconds += 1
            if let offRouteDistance {
                state.maxOffRouteDistanceMeters = max(state.maxOffRouteDistanceMeters ?? 0, offRouteDistance)
            }
        }
        state.wasOffRoute = isOffRoute
    }
}
