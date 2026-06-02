import CoreMotion

/// Availability probe only — does not instantiate `CMWaterSubmersionManager`.
enum AppleDepthSensorAvailability {
    static var isAvailable: Bool {
        CMWaterSubmersionManager.waterSubmersionAvailable
    }
}
