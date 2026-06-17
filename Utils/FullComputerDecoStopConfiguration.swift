import Foundation

enum FullComputerDecoStopConfiguration {
    /// Shallow edge of the valid stop window (`D - shallowMargin`).
    static let shallowMarginMeters = 0.5
    /// Deep edge of the valid stop window (`D + deepMargin`).
    static let deepMarginMeters = 1.0
    /// Depth beyond stop depth that invalidates accrued stop progress (`D + resetMargin`).
    static let resetDepthMarginMeters = 2.0
    /// Hysteresis applied on zone transitions to reduce sensor oscillation.
    static let hysteresisMeters = 0.15
}
