import Foundation

enum GPSFixSource: String, Codable, Hashable {
    case fix
    case fallback
    case noFix
}

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
    let entryGPSFixSource: GPSFixSource
    let exitGPSFixSource: GPSFixSource
    let samples: [DiveSample]

    init(id: UUID = UUID(), startDate: Date, endDate: Date, durationSeconds: TimeInterval, maxDepthMeters: Double, avgDepthMeters: Double, avgWaterTemperatureCelsius: Double?, minWaterTemperatureCelsius: Double?, maxWaterTemperatureCelsius: Double?, ttv: Double, entryGPS: GPSPoint?, exitGPS: GPSPoint?, entryGPSFixSource: GPSFixSource? = nil, exitGPSFixSource: GPSFixSource? = nil, samples: [DiveSample]) {
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
        self.entryGPSFixSource = entryGPSFixSource ?? (entryGPS == nil ? .noFix : .fix)
        self.exitGPSFixSource = exitGPSFixSource ?? (exitGPS == nil ? .noFix : .fix)
        self.samples = samples
    }

    enum CodingKeys: String, CodingKey {
        case id, startDate, endDate, durationSeconds, maxDepthMeters, avgDepthMeters
        case avgWaterTemperatureCelsius, minWaterTemperatureCelsius, maxWaterTemperatureCelsius, ttv
        case entryGPS, exitGPS, entryGPSFixSource, exitGPSFixSource, samples
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decode(Date.self, forKey: .endDate)
        durationSeconds = try container.decode(TimeInterval.self, forKey: .durationSeconds)
        maxDepthMeters = try container.decode(Double.self, forKey: .maxDepthMeters)
        avgDepthMeters = try container.decode(Double.self, forKey: .avgDepthMeters)
        avgWaterTemperatureCelsius = try container.decodeIfPresent(Double.self, forKey: .avgWaterTemperatureCelsius)
        minWaterTemperatureCelsius = try container.decodeIfPresent(Double.self, forKey: .minWaterTemperatureCelsius)
        maxWaterTemperatureCelsius = try container.decodeIfPresent(Double.self, forKey: .maxWaterTemperatureCelsius)
        ttv = try container.decode(Double.self, forKey: .ttv)
        entryGPS = try container.decodeIfPresent(GPSPoint.self, forKey: .entryGPS)
        exitGPS = try container.decodeIfPresent(GPSPoint.self, forKey: .exitGPS)
        entryGPSFixSource = try container.decodeIfPresent(GPSFixSource.self, forKey: .entryGPSFixSource) ?? (entryGPS == nil ? .noFix : .fix)
        exitGPSFixSource = try container.decodeIfPresent(GPSFixSource.self, forKey: .exitGPSFixSource) ?? (exitGPS == nil ? .noFix : .fix)
        samples = try container.decode([DiveSample].self, forKey: .samples)
    }
}
