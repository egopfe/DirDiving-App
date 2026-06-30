import Foundation

struct SnorkelingMapCenterRegion: Equatable, Sendable {
    let latitude: Double
    let longitude: Double
    let latitudeDelta: Double
    let longitudeDelta: Double

    static let plannerDefaultSpan = 0.006
}

enum SnorkelingRoutePlannerMapCenterOutcome: Equatable, Sendable {
    case center(SnorkelingMapCenterRegion)
    case requestPermission
    case notice(key: String)
}

enum SnorkelingRoutePlannerMapCenterPolicy {
    static func resolve(
        permissionState: ApneaMapPermissionState,
        currentLatitude: Double?,
        currentLongitude: Double?,
        spanDelta: Double = SnorkelingMapCenterRegion.plannerDefaultSpan
    ) -> SnorkelingRoutePlannerMapCenterOutcome {
        switch permissionState {
        case .authorized:
            guard let currentLatitude, let currentLongitude else {
                return .notice(key: "snorkeling.map.current_location_unavailable")
            }
            return .center(
                SnorkelingMapCenterRegion(
                    latitude: currentLatitude,
                    longitude: currentLongitude,
                    latitudeDelta: spanDelta,
                    longitudeDelta: spanDelta
                )
            )
        case .notDetermined:
            return .requestPermission
        case .denied, .restricted:
            return .notice(key: "snorkeling.map.location_permission_required_to_center")
        }
    }
}
