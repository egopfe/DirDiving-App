import Foundation

enum FullComputerLogbookGasSwitchKind: String, Codable, Hashable {
    case confirmed
    case ignored
    case unavailable
    case offPlan
}

struct FullComputerLogbookGasSwitchEvent: Codable, Hashable, Identifiable {
    let id: UUID
    let timestamp: Date
    let kind: FullComputerLogbookGasSwitchKind
    let depthMeters: Double
    let fromGasMixId: UUID
    let toGasMixId: UUID?
    let note: String?
}

/// Post-dive Full Computer summary persisted on Watch logbook sessions and synced when present.
struct FullComputerDiveLogbookMetadata: Codable, Hashable {
    let watchDivingMode: String
    let gfLow: Double
    let gfHigh: Double
    let gasSwitchEvents: [FullComputerLogbookGasSwitchEvent]
    let minimumNDLMinutes: Double?
    let maximumCeilingMeters: Double
    let maximumTTSMinutes: Int
    let plannedStopDepthsMeters: [Double]
    let completedStopDepthsMeters: [Double]
    let stopViolationCount: Int
    let ceilingViolationCount: Int
    let unavailableGasMixIds: [UUID]
    let recoveryEventCount: Int
    let recoveryDiagnostics: [String]
    let algorithmVersion: String
    let environmentSchemaVersion: Int?
    let altitudeMeters: Double?
    let surfacePressureBar: Double?
    let salinityRaw: String?
    let waterDensityKgPerM3: Double?
    let environmentSourceRaw: String?
    let environmentCapturedAt: Date?
    let environmentSensorAccuracyMeters: Double?
    let environmentSensorPrecisionMeters: Double?
    let environmentSensorReceivedAt: Date?

    init(
        watchDivingMode: String,
        gfLow: Double,
        gfHigh: Double,
        gasSwitchEvents: [FullComputerLogbookGasSwitchEvent],
        minimumNDLMinutes: Double?,
        maximumCeilingMeters: Double,
        maximumTTSMinutes: Int,
        plannedStopDepthsMeters: [Double],
        completedStopDepthsMeters: [Double],
        stopViolationCount: Int,
        ceilingViolationCount: Int,
        unavailableGasMixIds: [UUID],
        recoveryEventCount: Int,
        recoveryDiagnostics: [String],
        algorithmVersion: String,
        environmentSchemaVersion: Int? = nil,
        altitudeMeters: Double? = nil,
        surfacePressureBar: Double? = nil,
        salinityRaw: String? = nil,
        waterDensityKgPerM3: Double? = nil,
        environmentSourceRaw: String? = nil,
        environmentCapturedAt: Date? = nil,
        environmentSensorAccuracyMeters: Double? = nil,
        environmentSensorPrecisionMeters: Double? = nil,
        environmentSensorReceivedAt: Date? = nil
    ) {
        self.watchDivingMode = watchDivingMode
        self.gfLow = gfLow
        self.gfHigh = gfHigh
        self.gasSwitchEvents = gasSwitchEvents
        self.minimumNDLMinutes = minimumNDLMinutes
        self.maximumCeilingMeters = maximumCeilingMeters
        self.maximumTTSMinutes = maximumTTSMinutes
        self.plannedStopDepthsMeters = plannedStopDepthsMeters
        self.completedStopDepthsMeters = completedStopDepthsMeters
        self.stopViolationCount = stopViolationCount
        self.ceilingViolationCount = ceilingViolationCount
        self.unavailableGasMixIds = unavailableGasMixIds
        self.recoveryEventCount = recoveryEventCount
        self.recoveryDiagnostics = recoveryDiagnostics
        self.algorithmVersion = algorithmVersion
        self.environmentSchemaVersion = environmentSchemaVersion
        self.altitudeMeters = altitudeMeters
        self.surfacePressureBar = surfacePressureBar
        self.salinityRaw = salinityRaw
        self.waterDensityKgPerM3 = waterDensityKgPerM3
        self.environmentSourceRaw = environmentSourceRaw
        self.environmentCapturedAt = environmentCapturedAt
        self.environmentSensorAccuracyMeters = environmentSensorAccuracyMeters
        self.environmentSensorPrecisionMeters = environmentSensorPrecisionMeters
        self.environmentSensorReceivedAt = environmentSensorReceivedAt
    }

    var environmentSource: FullComputerEnvironmentSource? {
        guard let environmentSourceRaw else { return nil }
        return FullComputerEnvironmentSource(rawValue: environmentSourceRaw)
    }

    var hasKnownEnvironment: Bool {
        environmentSchemaVersion != nil && altitudeMeters != nil && surfacePressureBar != nil
    }
}
