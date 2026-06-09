import Foundation

/// One depth reading in a dive profile. `timestamp` is the measurement event time (sensor or test injection), not monotonic runtime.
struct DiveSample: Identifiable, Codable, Hashable {
    let id: UUID
    let timestamp: Date
    let depthMeters: Double
    let temperatureCelsius: Double?

    init(id: UUID = UUID(), timestamp: Date = Date(), depthMeters: Double, temperatureCelsius: Double?) {
        self.id = id
        self.timestamp = timestamp
        self.depthMeters = depthMeters
        self.temperatureCelsius = temperatureCelsius
    }
}
