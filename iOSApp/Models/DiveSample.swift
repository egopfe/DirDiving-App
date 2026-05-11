import Foundation

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
