import Foundation

struct GasLedgerDisplayValue: Hashable {
    let litersText: String
    let pressureSecondaryText: String
    let accessibilityLabel: String
}

enum GasLedgerDisplayFormatter {
    static func displayValue(
        liters: Double,
        pressureBar: Double?,
        cylinderVolumeLiters: Double,
        pressureUnit: PressureUnit
    ) -> GasLedgerDisplayValue {
        let litersText = "\(Formatters.zero(liters)) L"
        let resolvedBar: Double
        if let pressureBar, pressureBar.isFinite {
            resolvedBar = pressureBar
        } else if cylinderVolumeLiters.isFinite, cylinderVolumeLiters > 0 {
            resolvedBar = liters / cylinderVolumeLiters
        } else {
            resolvedBar = 0
        }
        let pressure = Formatters.pressure(fromBar: resolvedBar, unit: pressureUnit)
        let pressureSecondaryText = String(
            format: DIRIOSLocalizer.string("planner.gas_ledger.pressure_equivalent"),
            "\(pressure.value) \(pressure.unit)"
        )
        return GasLedgerDisplayValue(
            litersText: litersText,
            pressureSecondaryText: pressureSecondaryText,
            accessibilityLabel: "\(litersText), \(pressureSecondaryText)"
        )
    }

    static func cylinderVolumeLiters(for cylinderId: UUID, input: GasPlanInput) -> Double {
        input.plannerCylinders.first(where: { $0.id == cylinderId })?.cylinder.volumeLiters
            ?? input.primaryCylinder.volumeLiters
    }
}
