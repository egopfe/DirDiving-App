import Foundation

/// Planned depth checkpoint for an Apnea dive (training line, plate, target depth).
struct ApneaDepthMarker: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var label: String
    var depthMeters: Double
    var toleranceMeters: Double
    var direction: ApneaEventDirection
    var isEnabled: Bool

    init(
        id: UUID = UUID(),
        label: String,
        depthMeters: Double,
        toleranceMeters: Double = 0.5,
        direction: ApneaEventDirection = .both,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.label = label
        self.depthMeters = depthMeters
        self.toleranceMeters = toleranceMeters
        self.direction = direction
        self.isEnabled = isEnabled
    }
}
