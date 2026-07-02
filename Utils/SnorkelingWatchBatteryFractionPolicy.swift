import Foundation

enum SnorkelingWatchBatteryFractionPolicy {
    /// Maps `WKInterfaceDevice.current().batteryLevel` to presentation fraction, or nil when unknown.
    static func fraction(fromBatteryLevel level: Float) -> Double? {
        guard level >= 0 else { return nil }
        return Double(level)
    }
}
