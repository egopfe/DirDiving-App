import CoreLocation

enum WatchLocationPermissionState: Equatable, Sendable {
    case authorized
    case notDetermined
    case denied
    case restricted

    static func map(_ status: CLAuthorizationStatus) -> WatchLocationPermissionState {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return .authorized
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        @unknown default:
            return .notDetermined
        }
    }

    var isAuthorized: Bool {
        self == .authorized
    }

    var isDeniedOrRestricted: Bool {
        self == .denied || self == .restricted
    }
}
