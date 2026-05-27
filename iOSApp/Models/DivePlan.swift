import Foundation

struct DecoStop: Identifiable, Hashable {
    let id = UUID()
    let depthMeters: Double
    let minutes: Int
    let gas: String
    let ppO2: Double
    let maxPPO2: Double
    let isPPO2Exceeded: Bool
}

struct DivePlanResult: Hashable {
    let ndlMinutes: Double
    let ttrMinutes: Int
    let decoStops: [DecoStop]
    let cnsPercent: Double
    let otu: Double
    let warnings: [String]
    let states: Set<PlannerResultState>
    let modelState: BuhlmannModelState
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
    let modelState: BuhlmannModelState
}
