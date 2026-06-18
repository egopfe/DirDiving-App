import Foundation

/// Explicit coordinate quality for a saved snorkeling marker.
enum SnorkelingMarkerPositionQuality: String, Codable, CaseIterable, Hashable, Sendable {
    case measured
    case degraded
    case unavailable
    case noFix
}
