import Foundation

/// Depth reading quality for snorkeling (shallow / surface-adjacent).
enum SnorkelingDepthQuality: String, Codable, CaseIterable, Hashable, Sendable {
    case measured
    case unavailable
    /// Shallow estimate when sensor is unreliable underwater.
    case shallowEstimate
    case invalid

    var isAuthoritative: Bool {
        self == .measured
    }
}
