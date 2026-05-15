import Foundation

enum DiveGasLabel: String, Codable, CaseIterable, Identifiable {
    case oc = "OC"
    case nitrox = "NITROX"
    case trimix = "TRIMIX"
    var id: String { rawValue }
}

struct DiveSession: Identifiable, Codable, Hashable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let durationSeconds: TimeInterval
    let maxDepthMeters: Double
    let avgDepthMeters: Double
    let avgWaterTemperatureCelsius: Double?
    let ttv: Double
    let entryGPS: GPSPoint?
    let exitGPS: GPSPoint?
    let samples: [DiveSample]
    var siteName: String?
    var buddy: String?
    var notes: String?
    var gasLabel: DiveGasLabel
    var sacLitersMinute: Double?
    var isDemo: Bool

    static let demoNotesLabel = "Demo dive"

    var isDemoDive: Bool { isDemo || DemoDiveCatalog.isDemoSession(id: id) }

    enum CodingKeys: String, CodingKey {
        case id, startDate, endDate, durationSeconds, maxDepthMeters, avgDepthMeters
        case avgWaterTemperatureCelsius, ttv, entryGPS, exitGPS, samples
        case siteName, buddy, notes, gasLabel, sacLitersMinute, isDemo
    }

    init(
        id: UUID = UUID(),
        startDate: Date,
        endDate: Date,
        durationSeconds: TimeInterval,
        maxDepthMeters: Double,
        avgDepthMeters: Double,
        avgWaterTemperatureCelsius: Double?,
        ttv: Double,
        entryGPS: GPSPoint?,
        exitGPS: GPSPoint?,
        samples: [DiveSample],
        siteName: String? = nil,
        buddy: String? = nil,
        notes: String? = nil,
        gasLabel: DiveGasLabel = .oc,
        sacLitersMinute: Double? = nil,
        isDemo: Bool = false
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.durationSeconds = durationSeconds
        self.maxDepthMeters = maxDepthMeters
        self.avgDepthMeters = avgDepthMeters
        self.avgWaterTemperatureCelsius = avgWaterTemperatureCelsius
        self.ttv = ttv
        self.entryGPS = entryGPS
        self.exitGPS = exitGPS
        self.samples = samples
        self.siteName = siteName
        self.buddy = buddy
        self.notes = notes
        self.gasLabel = gasLabel
        self.sacLitersMinute = sacLitersMinute
        self.isDemo = isDemo
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
        ttv = try container.decode(Double.self, forKey: .ttv)
        entryGPS = try container.decodeIfPresent(GPSPoint.self, forKey: .entryGPS)
        exitGPS = try container.decodeIfPresent(GPSPoint.self, forKey: .exitGPS)
        samples = try container.decode([DiveSample].self, forKey: .samples)
        siteName = try container.decodeIfPresent(String.self, forKey: .siteName)
        buddy = try container.decodeIfPresent(String.self, forKey: .buddy)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        gasLabel = try container.decodeIfPresent(DiveGasLabel.self, forKey: .gasLabel) ?? .oc
        sacLitersMinute = try container.decodeIfPresent(Double.self, forKey: .sacLitersMinute)
        let decodedDemo = try container.decodeIfPresent(Bool.self, forKey: .isDemo) ?? false
        isDemo = decodedDemo || DemoDiveCatalog.isDemoSession(id: id) || notes == Self.demoNotesLabel
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(durationSeconds, forKey: .durationSeconds)
        try container.encode(maxDepthMeters, forKey: .maxDepthMeters)
        try container.encode(avgDepthMeters, forKey: .avgDepthMeters)
        try container.encodeIfPresent(avgWaterTemperatureCelsius, forKey: .avgWaterTemperatureCelsius)
        try container.encode(ttv, forKey: .ttv)
        try container.encodeIfPresent(entryGPS, forKey: .entryGPS)
        try container.encodeIfPresent(exitGPS, forKey: .exitGPS)
        try container.encode(samples, forKey: .samples)
        try container.encodeIfPresent(siteName, forKey: .siteName)
        try container.encodeIfPresent(buddy, forKey: .buddy)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encode(gasLabel, forKey: .gasLabel)
        try container.encodeIfPresent(sacLitersMinute, forKey: .sacLitersMinute)
        try container.encode(isDemo, forKey: .isDemo)
    }
}
