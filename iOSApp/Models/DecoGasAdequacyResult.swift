import Foundation

struct DecoGasAdequacyResult: Codable, Equatable, Sendable, Hashable, Identifiable {
    let gasName: String
    let requiredLitersPrimaryDiver: Double
    let requiredLitersBuddy: Double
    let requiredLitersTotal: Double
    let availableLiters: Double
    let isAdequate: Bool
    let reserveLiters: Double
    let shortfallLiters: Double
    let reserveBar: Double?
    let shortfallBar: Double?
    let buddyIncluded: Bool
    let cylinderWaterCapacityLiters: Double?

    var id: String { gasName }
}

struct EmergencyDecoGasAdequacyReport: Codable, Equatable, Sendable, Hashable {
    let buddyIncluded: Bool
    let perGasResults: [DecoGasAdequacyResult]
    let isOverallAdequate: Bool

    var hasDecoGasChecks: Bool { !perGasResults.isEmpty }
}
