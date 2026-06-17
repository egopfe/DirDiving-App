import Foundation

enum FullComputerDecoPresentationMode: String, Hashable, Codable {
    case noDecompression
    case decompression
}

enum FullComputerNDLAccent: String, Hashable, Codable {
    case green
    case yellow
    case red
}

enum FullComputerImmersionAccent: String, Hashable, Codable {
    case diving
    case decompression
    case ceilingViolation
}

struct FullComputerDecoPresentation: Hashable, Codable {
    let mode: FullComputerDecoPresentationMode
    let immersionAccent: FullComputerImmersionAccent
    let immersionStatusKey: String

    let ndlDisplayMinutes: Int?
    let ndlAccent: FullComputerNDLAccent?

    let ttsMinutes: Int
    let runtimeMinutes: Int
    let ceilingMetersExact: Double
    let ceilingMetersRounded: Double
    let nextStopDepthMeters: Double?
    let nextStopMinutes: Int?
    let remainingStopCount: Int
    let ceilingViolation: Bool
    let ascentAllowedBetweenStops: Bool
    let showDecoStopPanel: Bool
    let showCeilingViolationBanner: Bool
    let usedConservativeFallback: Bool
    let diagnostics: [String]

    let stopState: FullComputerDecoStopState?
    let stopDirection: FullComputerDecoStopDirection
    let stopPanelAccent: FullComputerDecoStopPanelAccent
    let stopPanelTitleKey: String
    let stopInstructionKey: String?
    let stopRemainingSeconds: Int?
    let activeGasLabel: String?
    let showDecoProgressPanel: Bool
    let hideManualStopwatch: Bool
    let timerAccruing: Bool
}

struct FullComputerDecoSolverInput: Hashable {
    let tissueState: BuhlmannTissueState
    let depthMeters: Double
    let plan: FullComputerRuntimePlan
    let runtimeMinutes: Int
}
