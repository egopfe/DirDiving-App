import Foundation

/// Pure map-style kind for Snorkeling presentation (testable without SwiftUI MapKit).
enum SnorkelingRenderedMapStyle: String, Equatable, Sendable {
    case hybrid
    case standard
}

enum SnorkelingMapStyleMapper {
    /// User-facing Satellite → hybrid imagery + labels (coast, bays, entry/exit).
    /// User-facing Explore → standard cartographic basemap.
    static func styleKind(for type: SnorkelingMapType) -> SnorkelingRenderedMapStyle {
        switch type {
        case .satellite:
            return .hybrid
        case .explore:
            return .standard
        }
    }
}
