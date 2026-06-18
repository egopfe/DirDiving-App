import Foundation

/// GPS fix quality for snorkeling surface navigation.
enum SnorkelingGPSQuality: String, Codable, CaseIterable, Hashable, Sendable {
    /// Valid surface fix with acceptable accuracy.
    case measured
    /// Last known fix; position may be stale.
    case stale
    /// Position inferred without a current fix (e.g. dead reckoning).
    case estimated
    /// No fix available; coordinates must not be treated as measured surface GPS.
    case unavailable
    /// Rejected or invalid reading.
    case invalid

    var isMeasuredSurfaceFix: Bool {
        self == .measured
    }

    var permitsNavigation: Bool {
        switch self {
        case .measured, .stale:
            return true
        case .estimated, .unavailable, .invalid:
            return false
        }
    }
}
