import Foundation

enum PressureDisplayMath {
    static func consumedDisplay(entryText: String, exitText: String, units: IOSUnitPreference) -> String? {
        let entry = entryText.trimmingCharacters(in: .whitespacesAndNewlines)
        let exit = exitText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !entry.isEmpty, !exit.isEmpty,
              let entryValue = Double(entry.replacingOccurrences(of: ",", with: ".")),
              let exitValue = Double(exit.replacingOccurrences(of: ",", with: ".")) else {
            return nil
        }
        let consumed = max(0, entryValue - exitValue)
        let unitLabel = units == .imperial ? "psi" : "bar"
        return String(format: String(localized: "detail.gas.consumed_format"), Formatters.one(consumed), unitLabel)
    }
}
