import Foundation

/// Planner gas wheel-picker ranges, normalization, and MOD helpers (UI layer; no Bühlmann changes).
enum PlannerGasEditingSupport {
    static let minOxygenPercent = 1
    static let maxOxygenPercent = 100
    static let minHeliumPercent = 0
    static let maxHeliumPercent = 99
    static let ppo2Step = 0.1
    static let minPPO2 = 1.0
    static let maxPPO2 = 1.7

    static var ppo2PickerValues: [Double] {
        stride(from: minPPO2, through: maxPPO2, by: ppo2Step).map { ($0 * 10).rounded() / 10 }
    }

    static var oxygenPercentValues: [Int] {
        Array(minOxygenPercent...maxOxygenPercent)
    }

    static func heliumPercentValues(oxygenPercent: Int) -> [Int] {
        let upper = min(maxHeliumPercent, maxOxygenPercent - oxygenPercent)
        guard upper >= minHeliumPercent else { return [0] }
        return Array(minHeliumPercent...upper)
    }

    static func workingPressureValues(for unit: PressureUnit) -> [Int] {
        switch unit {
        case .bar:
            return Array(stride(from: 50, through: 350, by: 1))
        case .psi:
            return Array(stride(from: 700, through: 5_000, by: 10))
        }
    }

    static func normalizePPO2(_ value: Double) -> Double {
        let stepped = (value / ppo2Step).rounded() * ppo2Step
        return min(max(minPPO2, stepped), maxPPO2)
    }

    static func clampOxygenFraction(_ oxygen: Double, heliumFraction: Double) -> Double {
        let minFraction = Double(minOxygenPercent) / 100.0
        let maxFraction = max(minFraction, 1.0 - heliumFraction)
        return min(max(oxygen, minFraction), maxFraction)
    }

    static func clampHeliumFraction(_ helium: Double, oxygenFraction: Double) -> Double {
        let maxFraction = max(0, 1.0 - oxygenFraction)
        return min(max(helium, 0), maxFraction)
    }

    static func oxygenPercent(from mix: GasMix) -> Int {
        Int((mix.oxygen * 100).rounded())
    }

    static func heliumPercent(from mix: GasMix) -> Int {
        Int((mix.helium * 100).rounded())
    }

    static func nitrogenPercent(from mix: GasMix) -> Int {
        max(0, 100 - oxygenPercent(from: mix) - heliumPercent(from: mix))
    }

    static func modMeters(for mix: GasMix, environment: PlannerEnvironment) -> Double {
        PlannerMODValidator.modMeters(for: mix, environment: environment)
    }

    static func nearestWorkingPressure(_ value: Double, unit: PressureUnit) -> Int {
        let values = workingPressureValues(for: unit)
        let rounded = Int(value.rounded())
        return values.min(by: { abs($0 - rounded) < abs($1 - rounded) }) ?? values.first ?? 200
    }

    static func convertPressureUnit(on entry: inout PlannerCylinderEntry, to unit: PressureUnit) {
        guard entry.pressureUnit != unit else { return }
        switch unit {
        case .bar:
            entry.startPressure = IOSUnitConversions.bar(fromPSI: entry.startPressure)
            entry.reservePressure = IOSUnitConversions.bar(fromPSI: entry.reservePressure)
        case .psi:
            entry.startPressure = IOSUnitConversions.psi(fromBar: entry.startPressure)
            entry.reservePressure = IOSUnitConversions.psi(fromBar: entry.reservePressure)
        }
        entry.pressureUnit = unit
        entry.startPressure = Double(nearestWorkingPressure(entry.startPressure, unit: unit))
        entry.reservePressure = Double(nearestWorkingPressure(entry.reservePressure, unit: unit))
    }

    /// Whether switch depth or bottom depth exceeds this cylinder's MOD.
    static func hasMODConflict(
        entry: PlannerCylinderEntry,
        plannedDepthMeters: Double,
        environment: PlannerEnvironment
    ) -> Bool {
        switch entry.role {
        case .bottom, .ccrDiluent:
            let mod = modMeters(for: entry.gas, environment: environment)
            return plannedDepthMeters > mod + 0.05
        case .travel, .deco, .bailout, .ccrBailout:
            return entry.isSwitchDepthBeyondMOD(environment: environment)
        }
    }
}
