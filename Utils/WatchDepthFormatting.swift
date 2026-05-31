import Foundation

enum WatchDepthFormatting {
    static func display(meters: Double, units: DIRUnitPreference) -> (valueText: String, unitLabel: String) {
        let display = units.depthDisplay(meters: meters)
        return (Formatters.one(display.value), display.unit)
    }
}
