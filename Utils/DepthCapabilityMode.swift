import Foundation

/// Resolved Apple depth entitlement tier — separate from user-selected sensor source.
enum DepthCapabilityMode: String, Codable, Equatable, Sendable {
    case none
    case simulation
    case appleShallow
    case appleFull
}

extension DepthCapabilityMode {
    var localizedLabel: String {
        switch self {
        case .none:
            return String(localized: "watch.depth_capability.none")
        case .simulation:
            return String(localized: "watch.depth_capability.simulation")
        case .appleShallow:
            return String(localized: "watch.depth_capability.shallow")
        case .appleFull:
            return String(localized: "watch.depth_capability.full")
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .appleShallow:
            return String(localized: "watch.depth_capability.apple_shallow.a11y")
        case .appleFull:
            return String(localized: "watch.depth_capability.apple_full.a11y")
        default:
            return localizedLabel
        }
    }
}
