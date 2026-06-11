import Foundation

struct DecoStop: Identifiable, Hashable {
    let id = UUID()
    let depthMeters: Double
    let minutes: Int
    let gas: String
    let ppO2: Double
    let maxPPO2: Double
    let states: [PlannerResultState]

    init(depthMeters: Double, minutes: Int, gas: String, ppO2: Double, maxPPO2: Double = 1.6, states: [PlannerResultState] = []) {
        self.depthMeters = depthMeters
        self.minutes = minutes
        self.gas = gas
        self.ppO2 = ppO2
        self.maxPPO2 = maxPPO2
        self.states = states
    }
}

enum DiveSegmentKind: String, CaseIterable, Identifiable, Codable {
    case descent = "Discesa"
    case bottom = "Fondo"
    case ascent = "Risalita"
    case stop = "Sosta"
    case gasSwitch = "Gas switch"

    var id: String { rawValue }

    /// User-facing runtime row label for planner/CCR schedule presentation.
    var runtimeRowTitle: String {
        switch self {
        case .descent:
            return DIRIOSLocalizer.string("planner.runtime.row.descent")
        case .bottom:
            return DIRIOSLocalizer.string("planner.runtime.row.bottom")
        case .ascent:
            return DIRIOSLocalizer.string("planner.runtime.row.ascent")
        case .stop:
            return DIRIOSLocalizer.string("planner.runtime.row.deco_stop")
        case .gasSwitch:
            return DIRIOSLocalizer.string("planner.runtime.row.travel")
        }
    }
}

struct DivePlanSegment: Identifiable, Codable, Hashable {
    var id = UUID()
    var kind: DiveSegmentKind
    var depthMeters: Double
    var minutes: Double
    var gas: String
    var note: String
}

struct GFComparison: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let gfLow: Double
    let gfHigh: Double
    let ttsMinutes: Int
    let stopCount: Int
    let conservatismNote: String
}

enum ContingencyScenario: String, CaseIterable, Identifiable, Codable {
    case lostGas = "Lost gas"
    case delayedAscent = "Delayed ascent"
    case extendedBottom = "Extended bottom"

    var id: String { rawValue }
}

struct ContingencyPlan: Identifiable, Hashable {
    let id = UUID()
    let scenario: ContingencyScenario
    let ttsMinutes: Int
    let gasRequiredLiters: Double
    let action: String
    let warning: String
}

struct TeamGasMatch: Identifiable, Hashable {
    let id = UUID()
    let diverName: String
    let sacLitersMinute: Double
    let availableLiters: Double
    let reserveLiters: Double
    let status: String
}

struct DivePlanResult: Hashable {
    let ndlMinutes: Double
    let ttsMinutes: Int
    let totalRuntimeMinutes: Int
    let calculationCompleteness: PlanCalculationCompleteness
    let decoStops: [DecoStop]
    let ascentTableRows: [PlannerAscentTableRow]
    let tissueHistory: BuhlmannTissueHistory
    let depthProfilePoints: [DepthProfilePoint]
    let cnsPercent: Double
    let otu: Double
    let gasAnalysis: TechnicalGasAnalysis
    let segments: [DivePlanSegment]
    let gfComparisons: [GFComparison]
    let contingencyPlans: [ContingencyPlan]
    let teamMatches: [TeamGasMatch]
    let briefingLines: [String]
    let modValidationIssues: [MODValidationIssue]
    let states: [PlannerResultState]
    let buhlmannState: BuhlmannModelState
    let resultHeader: PlannerResultHeader
    let repetitiveContext: RepetitivePlanningContext?
    let environmentSummary: PlannerEnvironmentSummary?
    let gasLedger: GasConsumptionLedger?
    let gasLedgerFailure: GasLedgerFailureReason?
    let userFacingWarnings: [PlannerUserFacingMessage]
    let plannerMode: PlannerMode
    let modeGuidanceMessage: PlannerUserFacingMessage?
    let ratioDeco: RatioDecoPlanningBundle?
}

struct NDLPoint: Identifiable, Hashable {
    let id = UUID()
    let depthMeters: Double
    let ndlMinutes: Double
    /// Depth-band label for chart UX only — not the controlling ZH-L16C compartment.
    let depthBand: String
}

struct BuhlmannPlanResult: Hashable {
    let depthMeters: Double
    let gasO2Fraction: Double
    let heliumFraction: Double
    let nitrogenFraction: Double
    let ndlMinutes: Double
    let curve: [NDLPoint]
    let warning: String?
    let modelState: BuhlmannModelState
}
