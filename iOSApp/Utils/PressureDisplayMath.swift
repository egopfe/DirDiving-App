import Foundation

enum PressureDisplayMath {
    static func pressureUnit(for units: IOSUnitPreference) -> PressureUnit {
        units == .imperial ? .psi : .bar
    }

    static func parsePressureBar(from text: String, inputUnit: PressureUnit) -> Double? {
        var trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        trimmed = trimmed.replacingOccurrences(of: ",", with: ".")
        trimmed = trimmed.replacingOccurrences(of: "bar", with: "", options: .caseInsensitive)
        trimmed = trimmed.replacingOccurrences(of: "psi", with: "", options: .caseInsensitive)
        trimmed = trimmed.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let value = Double(trimmed),
              value.isFinite, value >= 0 else {
            return nil
        }
        switch inputUnit {
        case .bar:
            return value
        case .psi:
            return IOSUnitConversions.bar(fromPSI: value)
        }
    }

    static func formatPressureValue(_ bar: Double, units: IOSUnitPreference) -> String {
        guard bar.isFinite else { return "" }
        if units == .imperial {
            return Formatters.one(IOSUnitConversions.psi(fromBar: bar))
        }
        return Formatters.one(bar)
    }

    static func consumedDisplay(
        entryText: String,
        exitText: String,
        entryBar: Double?,
        exitBar: Double?,
        units: IOSUnitPreference
    ) -> String? {
        if let entryBar, let exitBar, entryBar.isFinite, exitBar.isFinite {
            return consumedDisplay(entryBar: entryBar, exitBar: exitBar, units: units)
        }
        let inferredUnit = inferLegacyPressureUnit(entryText: entryText, exitText: exitText)
            ?? pressureUnit(for: units)
        guard let entry = parsePressureBar(from: entryText, inputUnit: inferredUnit),
              let exit = parsePressureBar(from: exitText, inputUnit: inferredUnit) else {
            return nil
        }
        return consumedDisplay(entryBar: entry, exitBar: exit, units: units)
    }

    static func consumedPressureInDisplayUnits(entryBar: Double, exitBar: Double, units: IOSUnitPreference) -> Double? {
        guard entryBar.isFinite, exitBar.isFinite else { return nil }
        let consumedBar = max(0, entryBar - exitBar)
        return units == .imperial ? IOSUnitConversions.psi(fromBar: consumedBar) : consumedBar
    }

    static func consumedDisplay(entryBar: Double, exitBar: Double, units: IOSUnitPreference) -> String? {
        guard let consumed = consumedPressureInDisplayUnits(entryBar: entryBar, exitBar: exitBar, units: units) else {
            return nil
        }
        let displayValue: String
        if units == .imperial {
            displayValue = "\(Formatters.one(consumed)) psi"
        } else {
            displayValue = "\(Formatters.one(consumed)) bar"
        }
        return String(format: String(localized: "detail.gas.consumed_format"), displayValue)
    }

    static func inferLegacyPressureUnit(entryText: String, exitText: String) -> PressureUnit? {
        let combined = "\(entryText) \(exitText)".lowercased()
        if combined.contains("psi") { return .psi }
        if combined.contains("bar") { return .bar }
        return nil
    }
}
