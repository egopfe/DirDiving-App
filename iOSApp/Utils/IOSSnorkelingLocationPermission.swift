import CoreLocation

enum IOSSnorkelingLocationPermission {
    static func currentState() -> ApneaMapPermissionState {
        IOSLocationPermissionService.map(CLLocationManager.authorizationStatus())
    }
}
