import Foundation

/// Planned depth checkpoint for an Apnea dive (training line, plate, target depth).
struct ApneaDepthMarker: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var label: String
    var depthMeters: Double
    var toleranceMeters: Double

    init(
        id: UUID = UUID(),
        label: String,
        depthMeters: Double,
        toleranceMeters: Double = 0.5
    ) {
        self.id = id
        self.label = label
        self.depthMeters = depthMeters
        self.toleranceMeters = toleranceMeters
    }
}
