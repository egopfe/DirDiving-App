import Foundation

enum FullComputerRuntimeEngineState: String, Codable, Hashable {
    case valid
    case degraded
    case unavailable
    case recovered
}

struct FullComputerRuntimeSnapshot: Hashable {
    let engineState: FullComputerRuntimeEngineState
    let tissueState: BuhlmannTissueState
    let activeGas: BuhlmannGas
    let gfLow: Double
    let gfHigh: Double
    let monotonicElapsedSeconds: TimeInterval
    let lastSampleTimestamp: Date?
    let depthMeters: Double
    let ambientPressureBar: Double
    let ndlMinutes: Double?
    let rawCeilingMeters: Double
    let operationalCeilingMeters: Double
    let controllingCompartmentRaw: Int
    let controllingCompartmentOperational: Int
    let ttsMinutes: Int
    let stops: [BuhlmannDecompressionStop]
    let modelState: BuhlmannModelState
    let diagnostics: [String]
    let decoPresentation: FullComputerDecoPresentation
}

enum FullComputerRuntimeStartupFailure: Error, Equatable {
    case invalidPlan([String])
    case selfCheckFailed([String])
}
