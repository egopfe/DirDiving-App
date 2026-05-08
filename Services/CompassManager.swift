import Foundation
import CoreLocation

@MainActor
final class CompassManager: NSObject, ObservableObject {
    @Published private(set) var headingDegrees: Double = 0
    @Published var bearingDegrees: Double?
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.headingFilter = 1
    }

    func start() {
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.headingAvailable() { locationManager.startUpdatingHeading() }
    }

    func stop() { locationManager.stopUpdatingHeading() }
    func setBearing() { bearingDegrees = headingDegrees }
    func clearBearing() { bearingDegrees = nil }

    var cardinal: String {
        let directions = ["N","NE","E","SE","S","SW","W","NW"]
        return directions[Int((headingDegrees + 22.5) / 45.0) % directions.count]
    }
}

extension CompassManager: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        Task { @MainActor in headingDegrees = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading }
    }
}
