import Foundation

/// Dry-gas density contribution per bar partial pressure (g/L per bar).
enum CCRGasDensityConstants {
    static let oxygenGramsPerLiterPerBar = 1.429
    static let nitrogenGramsPerLiterPerBar = 1.251
    static let heliumGramsPerLiterPerBar = 0.1786
}

enum CCRGasDensityUnavailableReason: String, Codable, Hashable, CaseIterable {
    case invalidSetpoint
    case invalidDepth
    case invalidEnvironment
    case setpointAboveDryAmbient
    case nonFiniteInput
    case inspiredGasUnavailable
}

enum CCRGasDensityResult: Equatable, Hashable {
    case available(valueGramsPerLiter: Double)
    case unavailable(reason: CCRGasDensityUnavailableReason)

    var gramsPerLiter: Double? {
        if case .available(let value) = self { return value }
        return nil
    }

    func classification(
        warningThreshold: Double = IOSAlgorithmConfiguration.gasDensityWarningGramsPerLiter,
        dangerThreshold: Double = IOSAlgorithmConfiguration.gasDensityDangerGramsPerLiter
    ) -> CCRGasDensityClassification? {
        guard case .available(let value) = self else { return nil }
        if value >= dangerThreshold { return .danger }
        if value >= warningThreshold { return .warning }
        return .ok
    }
}

enum CCRGasDensityClassification: Equatable {
    case ok
    case warning
    case danger
}
