import Foundation

enum PressureUnit: String, CaseIterable, Identifiable, Codable {
    case bar = "BAR"
    case psi = "PSI"
    var id: String { rawValue }
}

enum PlannerMode: String, CaseIterable, Identifiable, Codable {
    case recreational = "Ricreativa"
    case advanced = "Avanzata"
    case technical = "Tecnica"
    case overhead = "Cave/Wreck"
    var id: String { rawValue }
}

enum SalinityMode: String, CaseIterable, Identifiable, Codable {
    case fresh = "Dolce"
    case salt = "Salata"
    var id: String { rawValue }
}

enum GasRole: String, CaseIterable, Identifiable, Codable {
    case bottom = "Fondo"
    case travel = "Travel"
    case deco = "Deco"
    case bailout = "Bailout"
    var id: String { rawValue }
}

struct GasMix: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var role: GasRole = .bottom
    var oxygen: Double
    var helium: Double
    var maxPPO2: Double
    var isOxygenNarcotic: Bool = true
    var nitrogen: Double { max(0, 1.0 - oxygen - helium) }
    var modMeters: Double { max(0, ((maxPPO2 / max(oxygen, 0.01)) - 1.0) * 10.0) }
    var surfaceDensityGramsLiter: Double {
        oxygen * 1.429 + nitrogen * 1.251 + helium * 0.1786
    }
    var label: String {
        if helium > 0 { return "TX \(Int(oxygen*100))/\(Int(helium*100))" }
        if oxygen > 0.21 { return "EAN\(Int(oxygen*100))" }
        return "AIR"
    }
}

struct Cylinder: Codable, Hashable {
    var name: String = "Back gas"
    var volumeLiters: Double = 12
    var startPressure: Double = 200
    var reservePressure: Double = 50
    var pressureUnit: PressureUnit = .bar

    var startPressureBar: Double { pressureUnit == .bar ? startPressure : startPressure / 14.5038 }
    var reservePressureBar: Double { pressureUnit == .bar ? reservePressure : reservePressure / 14.5038 }
    var availableGasLiters: Double { max(0, volumeLiters * (startPressureBar - reservePressureBar)) }
}

struct TeamMember: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var sacLitersPerMinute: Double
    var cylinder: Cylinder
}

struct TechnicalGasAnalysis: Hashable {
    let gas: GasMix
    let ppO2AtDepth: Double
    let densityAtDepth: Double
    let densityRating: GasDensityRating
    let endMeters: Double
    let eadMeters: Double?
    let consumptionLiters: Double
    let remainingLiters: Double
    let remainingBar: Double
    let rockBottomLiters: Double
    let minimumGasBar: Double
    let turnPressureBar: Double
    let cnsPercent: Double
    let otu: Double
    let warnings: [String]
}

enum GasDensityRating: String, Hashable {
    case green = "GREEN"
    case yellow = "WARNING"
    case red = "DANGER"
}

struct GasPlanInput: Codable, Hashable {
    var cylinder = Cylinder()
    var sacLitersPerMinute: Double = 18
    var emergencySacLitersPerMinute: Double = 30
    var teamSize: Double = 2
    var plannedDepthMeters: Double = 40
    var plannedBottomMinutes: Double = 20
    var waterTemperatureCelsius: Double = 24
    var salinity: SalinityMode = .salt
    var altitudeMeters: Double = 0
    var gfLow: Double = 30
    var gfHigh: Double = 70
    var densityWarningLimit: Double = 5.2
    var densityDangerLimit: Double = 6.2
    var bottomGas = GasMix(name: "Gas di Fondo", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.40)
    var decoGas1 = GasMix(name: "Gas Deco 1", role: .deco, oxygen: 0.50, helium: 0.0, maxPPO2: 1.60)
    var decoGas2 = GasMix(name: "Gas Deco 2", role: .deco, oxygen: 0.80, helium: 0.0, maxPPO2: 1.60)
    var teamMembers: [TeamMember] = [
        TeamMember(name: "Diver A", sacLitersPerMinute: 18, cylinder: Cylinder(name: "Back gas", volumeLiters: 12, startPressure: 200, reservePressure: 50, pressureUnit: .bar)),
        TeamMember(name: "Diver B", sacLitersPerMinute: 20, cylinder: Cylinder(name: "Back gas", volumeLiters: 12, startPressure: 190, reservePressure: 50, pressureUnit: .bar))
    ]
    var startPressureBar: Double { cylinder.startPressureBar }
    var reservePressureBar: Double { cylinder.reservePressureBar }
    var availableGasLiters: Double { cylinder.availableGasLiters }
    var ambientPressureBar: Double { plannedDepthMeters / 10.0 + 1.0 }
    var estimatedConsumptionLiters: Double { sacLitersPerMinute * ambientPressureBar * plannedBottomMinutes }
    var estimatedRemainingLiters: Double { availableGasLiters - estimatedConsumptionLiters }
    var estimatedRemainingBar: Double { estimatedRemainingLiters / max(cylinder.volumeLiters, 0.1) }
    var estimatedRemainingPSI: Double { estimatedRemainingBar * 14.5038 }
}
