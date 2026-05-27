import Foundation

enum PressureUnit: String, CaseIterable, Identifiable, Codable {
    case bar = "BAR"
    case psi = "PSI"
    var id: String { rawValue }
}

enum PlannerMode: String, CaseIterable, Identifiable, Codable {
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
    var nitrogen: Double { GasMixValidator.fractions(for: self)?.nitrogen ?? Double.nan }
    var modMeters: Double { GasMixValidator.modMeters(for: self) ?? 0 }
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
    var startPressureBar: Double { pressureUnit == .bar ? startPressure : IOSUnitConversions.bar(fromPSI: startPressure) }
    var reservePressureBar: Double { pressureUnit == .bar ? reservePressure : IOSUnitConversions.bar(fromPSI: reservePressure) }
    var availableGasLiters: Double {
        guard cylinderVolumeLiters.isFinite, cylinderVolumeLiters > 0 else { return Double.nan }
        return cylinderVolumeLiters * (startPressureBar - reservePressureBar)
    }
    var ambientPressureBar: Double { IOSUnitConversions.ambientPressureBar(depthMeters: plannedDepthMeters) }
    var estimatedConsumptionLiters: Double { sacLitersPerMinute * ambientPressureBar * plannedBottomMinutes }
    var estimatedRemainingLiters: Double { availableGasLiters - estimatedConsumptionLiters }
    var estimatedRemainingBar: Double {
        guard cylinderVolumeLiters.isFinite, cylinderVolumeLiters > 0 else { return Double.nan }
        return estimatedRemainingLiters / cylinderVolumeLiters
    }
    var estimatedRemainingPSI: Double { IOSUnitConversions.psi(fromBar: estimatedRemainingBar) }
}
