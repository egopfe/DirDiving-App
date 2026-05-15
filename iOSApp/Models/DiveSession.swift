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

    static let demoNotesLabel = "Demo dive"

    var isDemoDive: Bool { notes == Self.demoNotesLabel }
}
