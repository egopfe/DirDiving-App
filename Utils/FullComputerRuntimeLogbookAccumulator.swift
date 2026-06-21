import Foundation

/// Tracks Full Computer runtime extremes and events during an active dive for logbook export.
struct FullComputerRuntimeLogbookAccumulator: Hashable {
    private(set) var minimumNDLMinutes: Double?
    private(set) var maximumCeilingMeters: Double = 0
    private(set) var maximumTTSMinutes: Int = 0
    private(set) var plannedStopDepthsMeters: Set<Int> = []
    private(set) var completedStopDepthsMeters: Set<Int> = []
    private(set) var stopViolationCount: Int = 0
    private(set) var ceilingViolationCount: Int = 0
    private(set) var recoveryEventCount: Int = 0
    private(set) var recoveryDiagnostics: [String] = []

    mutating func recordRecovery(diagnostic: String) {
        recoveryEventCount += 1
        if !recoveryDiagnostics.contains(diagnostic) {
            recoveryDiagnostics.append(diagnostic)
        }
    }

    mutating func ingest(snapshot: FullComputerRuntimeSnapshot, gasSwitchTracker: FullComputerGasSwitchTracker) {
        if let ndl = snapshot.ndlMinutes, ndl.isFinite {
            minimumNDLMinutes = min(minimumNDLMinutes ?? ndl, ndl)
        }
        maximumCeilingMeters = max(
            maximumCeilingMeters,
            max(snapshot.rawCeilingMeters, snapshot.operationalCeilingMeters)
        )
        maximumTTSMinutes = max(maximumTTSMinutes, snapshot.ttsMinutes)
        for stop in snapshot.stops {
            let key = Int((stop.depthMeters * 10).rounded())
            plannedStopDepthsMeters.insert(key)
        }
        if snapshot.decoPresentation.mode == .decompression,
           let engaged = snapshot.decoPresentation.nextStopDepthMeters {
            let key = Int((engaged * 10).rounded())
            if snapshot.decoPresentation.stopState == .stopCompleted {
                completedStopDepthsMeters.insert(key)
            }
        }
        if snapshot.decoPresentation.ceilingViolation {
            ceilingViolationCount += 1
        }
        if snapshot.decoPresentation.stopState == .tooShallow
            || snapshot.decoPresentation.stopState == .tooDeep
            || snapshot.decoPresentation.stopState == .ceilingViolation {
            stopViolationCount += 1
        }
        _ = gasSwitchTracker
    }

    func export(
        watchDivingMode: String,
        gfLow: Double,
        gfHigh: Double,
        gasSwitchEvents: [FullComputerLogbookGasSwitchEvent],
        unavailableGasMixIds: [UUID],
        algorithmVersion: String,
        environmentRecord: FullComputerEnvironmentRecord?
    ) -> FullComputerDiveLogbookMetadata {
        FullComputerDiveLogbookMetadata(
            watchDivingMode: watchDivingMode,
            gfLow: gfLow,
            gfHigh: gfHigh,
            gasSwitchEvents: gasSwitchEvents,
            minimumNDLMinutes: minimumNDLMinutes,
            maximumCeilingMeters: maximumCeilingMeters,
            maximumTTSMinutes: maximumTTSMinutes,
            plannedStopDepthsMeters: plannedStopDepthsMeters.map { Double($0) / 10.0 }.sorted(by: >),
            completedStopDepthsMeters: completedStopDepthsMeters.map { Double($0) / 10.0 }.sorted(by: >),
            stopViolationCount: stopViolationCount,
            ceilingViolationCount: ceilingViolationCount,
            unavailableGasMixIds: unavailableGasMixIds,
            recoveryEventCount: recoveryEventCount,
            recoveryDiagnostics: recoveryDiagnostics,
            algorithmVersion: algorithmVersion,
            environmentSchemaVersion: environmentRecord?.schemaVersion,
            altitudeMeters: environmentRecord?.altitudeMeters,
            surfacePressureBar: environmentRecord?.surfacePressureBar,
            salinityRaw: environmentRecord?.salinityRaw,
            waterDensityKgPerM3: environmentRecord?.waterDensityKgPerM3,
            environmentSourceRaw: environmentRecord?.source.rawValue,
            environmentCapturedAt: environmentRecord?.capturedAt,
            environmentSensorAccuracyMeters: environmentRecord?.sensorAccuracyMeters,
            environmentSensorPrecisionMeters: environmentRecord?.sensorPrecisionMeters
        )
    }
}
