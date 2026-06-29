import CoreLocation

enum IOSApneaLocationPermission {
    static func currentState() -> ApneaMapPermissionState {
        IOSLocationPermissionService.map(CLLocationManager.authorizationStatus())
    }
}
