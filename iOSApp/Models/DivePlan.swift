import Foundation

struct DecoStop: Identifiable, Hashable {
    let id = UUID()
    let depthMeters: Double
    let minutes: Int
    let gas: String
    let ppO2: Double
}

struct DivePlanResult: Hashable {
    let ndlMinutes: Double
    let ttrMinutes: Int
    let decoStops: [DecoStop]
    let cnsPercent: Double
    let otu: Double
    let warnings: [String]
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
