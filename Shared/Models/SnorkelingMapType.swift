import Foundation

enum SnorkelingMapType: String, Codable, CaseIterable, Identifiable, Sendable {
    case satellite
    case explore

    var id: String { rawValue }

    static let defaultValue: SnorkelingMapType = .satellite

    var displayNameKey: String {
        switch self {
        case .satellite:
            return "snorkeling.map_type.satellite"
        case .explore:
            return "snorkeling.map_type.explore"
        }
    }

    var descriptionKey: String {
        switch self {
        case .satellite:
            return "snorkeling.map_type.satellite.description"
        case .explore:
            return "snorkeling.map_type.explore.description"
        }
    }
}
