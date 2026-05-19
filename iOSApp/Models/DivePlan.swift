import Foundation

struct DecoStop: Identifiable, Hashable {
    let id = UUID()
    let depthMeters: Double
    let minutes: Int
    let gas: String
    let ppO2: Double
}

enum DiveSegmentKind: String, CaseIterable, Identifiable, Codable {
    case descent = "Discesa"
    case bottom = "Fondo"
    case ascent = "Risalita"
    case stop = "Sosta"
    case gasSwitch = "Gas switch"

    var id: String { rawValue }
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
    let ttrMinutes: Int
    let decoStops: [DecoStop]
    let cnsPercent: Double
    let otu: Double
    let gasAnalysis: TechnicalGasAnalysis
    let segments: [DivePlanSegment]
    let gfComparisons: [GFComparison]
    let contingencyPlans: [ContingencyPlan]
    let teamMatches: [TeamGasMatch]
    let briefingLines: [String]
}

struct NDLPoint: Identifiable, Hashable {
    let id = UUID()
    let depthMeters: Double
    let ndlMinutes: Double
    let compartmentGroup: String
}

struct BuhlmannPlanResult: Hashable {
    let depthMeters: Double
    let gasO2Fraction: Double
    let nitrogenFraction: Double
    let ndlMinutes: Double
    let curve: [NDLPoint]
    let warning: String?
}
