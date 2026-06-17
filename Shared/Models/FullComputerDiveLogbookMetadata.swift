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
}
