import Foundation

/// Persisted depth sensor metadata for activity-owned logbooks.
struct DepthSensorSessionMetadata: Codable, Equatable, Sendable {
    var depthSampleSource: String?
    var depthCapabilityMode: String?
}
