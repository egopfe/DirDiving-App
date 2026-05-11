import Foundation

enum PressureUnit: String, CaseIterable, Identifiable, Codable {
    case bar = "BAR"
    case psi = "PSI"
    var id: String { rawValue }
}

enum PlannerMode: String, CaseIterable, Identifiable {
    case simple = "Semplice"
    case advanced = "Avanzato"
    case technical = "Tecnico"
    var id: String { rawValue }
}

struct GasMix: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var oxygen: Double
    var helium: Double
    var maxPPO2: Double
    var nitrogen: Double { max(0, 1.0 - oxygen - helium) }
    var modMeters: Double { max(0, ((maxPPO2 / max(oxygen, 0.01)) - 1.0) * 10.0) }
    var label: String {
        if helium > 0 { return "TX \(Int(oxygen*100))/\(Int(helium*100))" }
        if oxygen > 0.21 { return "EAN\(Int(oxygen*100))" }
        return "AIR"
    }
}

struct GasPlanInput: Codable, Hashable {
    var cylinderVolumeLiters: Double = 12
    var startPressure: Double = 200
    var reservePressure: Double = 50
    var pressureUnit: PressureUnit = .bar
    var sacLitersPerMinute: Double = 18
    var plannedDepthMeters: Double = 40
    var plannedBottomMinutes: Double = 20
    var waterTemperatureCelsius: Double = 24
    var bottomGas = GasMix(name: "Gas di Fondo", oxygen: 0.18, helium: 0.45, maxPPO2: 1.40)
    var decoGas1 = GasMix(name: "Gas Deco 1", oxygen: 0.50, helium: 0.0, maxPPO2: 1.60)
    var decoGas2 = GasMix(name: "Gas Deco 2", oxygen: 0.80, helium: 0.0, maxPPO2: 1.60)
    var startPressureBar: Double { pressureUnit == .bar ? startPressure : startPressure / 14.5038 }
    var reservePressureBar: Double { pressureUnit == .bar ? reservePressure : reservePressure / 14.5038 }
    var availableGasLiters: Double { max(0, cylinderVolumeLiters * (startPressureBar - reservePressureBar)) }
    var ambientPressureBar: Double { plannedDepthMeters / 10.0 + 1.0 }
    var estimatedConsumptionLiters: Double { sacLitersPerMinute * ambientPressureBar * plannedBottomMinutes }
    var estimatedRemainingLiters: Double { availableGasLiters - estimatedConsumptionLiters }
    var estimatedRemainingBar: Double { estimatedRemainingLiters / max(cylinderVolumeLiters, 0.1) }
    var estimatedRemainingPSI: Double { estimatedRemainingBar * 14.5038 }
}
