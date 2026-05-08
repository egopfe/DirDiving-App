import Foundation
import CoreLocation

@MainActor
final class GPSManager: NSObject, ObservableObject {
    @Published private(set) var lastPoint: GPSPoint?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
    }

    func requestAuthorization() { locationManager.requestWhenInUseAuthorization() }
    func start() { requestAuthorization(); locationManager.startUpdatingLocation() }
    func stop() { locationManager.stopUpdatingLocation() }
    func currentBestPoint() -> GPSPoint? { lastPoint }
}

extension GPSManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
            if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse { manager.startUpdatingLocation() }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            lastPoint = GPSPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, horizontalAccuracy: location.horizontalAccuracy, timestamp: location.timestamp)
        }
    }
}
