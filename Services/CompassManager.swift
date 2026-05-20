import Foundation
import Combine
import CoreLocation

@MainActor
final class CompassManager: NSObject, ObservableObject {
    static private(set) weak var shared: CompassManager?

    @Published private(set) var headingDegrees: Double = 0
    @Published var bearingDegrees: Double?
    @Published private(set) var statusMessage = "Bussola pronta"
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        Self.shared = self
        locationManager.delegate = self
        locationManager.headingFilter = 1
    }

    func start() {
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.headingAvailable() {
            statusMessage = "Bussola attiva"
            locationManager.startUpdatingHeading()
        } else {
            statusMessage = "Bussola non disponibile"
        }
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
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            switch manager.authorizationStatus {
            case .denied, .restricted:
                statusMessage = "Permesso posizione negato"
            case .authorizedAlways, .authorizedWhenInUse:
                statusMessage = CLLocationManager.headingAvailable() ? "Bussola attiva" : "Bussola non disponibile"
            case .notDetermined:
                statusMessage = "In attesa permesso posizione"
            @unknown default:
                statusMessage = "Stato bussola sconosciuto"
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        Task { @MainActor in
            headingDegrees = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
            statusMessage = "Bussola attiva"
        }
    }
}
