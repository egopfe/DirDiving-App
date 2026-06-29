import MapKit
import SwiftUI

enum IOSSnorkelingMapStyleMapper {
    /// Satellite (user) → `.hybrid` when available on iOS 17+ MapKit SwiftUI.
    /// Explore (user) → `.standard`.
    static func mapStyle(for type: SnorkelingMapType) -> MapStyle {
        switch SnorkelingMapStyleMapper.styleKind(for: type) {
        case .hybrid:
            return .hybrid
        case .standard:
            return .standard
        }
    }
}
