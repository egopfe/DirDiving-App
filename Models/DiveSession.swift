import Foundation

struct DiveSession: Identifiable, Codable, Hashable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let durationSeconds: TimeInterval
    let maxDepthMeters: Double
    let avgDepthMeters: Double
    let avgWaterTemperatureCelsius: Double?
    let minWaterTemperatureCelsius: Double?
    let maxWaterTemperatureCelsius: Double?
    let ttv: Double
    let entryGPS: GPSPoint?
    let exitGPS: GPSPoint?
    let samples: [DiveSample]

    init(id: UUID = UUID(), startDate: Date, endDate: Date, durationSeconds: TimeInterval, maxDepthMeters: Double, avgDepthMeters: Double, avgWaterTemperatureCelsius: Double?, minWaterTemperatureCelsius: Double?, maxWaterTemperatureCelsius: Double?, ttv: Double, entryGPS: GPSPoint?, exitGPS: GPSPoint?, samples: [DiveSample]) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.durationSeconds = durationSeconds
        self.maxDepthMeters = maxDepthMeters
        self.avgDepthMeters = avgDepthMeters
        self.avgWaterTemperatureCelsius = avgWaterTemperatureCelsius
        self.minWaterTemperatureCelsius = minWaterTemperatureCelsius
        self.maxWaterTemperatureCelsius = maxWaterTemperatureCelsius
        self.ttv = ttv
        self.entryGPS = entryGPS
        self.exitGPS = exitGPS
        self.samples = samples
    }
}
