import Foundation
import Combine
import CoreLocation

@MainActor
final class CompassManager: NSObject, ObservableObject {
    static private(set) weak var shared: CompassManager?

    @Published private(set) var headingDegrees: Double = 0
    @Published var bearingDegrees: Double?
    @Published private(set) var statusMessage = String(localized: "Bussola pronta")
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
            statusMessage = String(localized: "Bussola attiva")
            locationManager.startUpdatingHeading()
        } else {
            statusMessage = String(localized: "Bussola non disponibile")
        }
    }

    func stop() { locationManager.stopUpdatingHeading() }
    func setBearing() { bearingDegrees = DiveAlgorithm.normalizedDegrees(headingDegrees) }
    func clearBearing() { bearingDegrees = nil }

    var cardinal: String {
        let directions = ["N","NE","E","SE","S","SW","W","NW"]
        let normalized = DiveAlgorithm.normalizedDegrees(headingDegrees)
        return directions[Int((normalized + 22.5) / 45.0) % directions.count]
    }
}

extension CompassManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            switch manager.authorizationStatus {
            case .denied, .restricted:
                statusMessage = String(localized: "Permesso posizione negato")
            case .authorizedAlways, .authorizedWhenInUse:
                statusMessage = CLLocationManager.headingAvailable()
                    ? String(localized: "Bussola attiva")
                    : String(localized: "Bussola non disponibile")
            case .notDetermined:
                statusMessage = String(localized: "In attesa permesso posizione")
            @unknown default:
                statusMessage = String(localized: "Stato bussola sconosciuto")
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        Task { @MainActor in
            let rawHeading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
            guard rawHeading.isFinite else {
                statusMessage = String(localized: "Bussola non disponibile")
                return
            }
            headingDegrees = DiveAlgorithm.normalizedDegrees(rawHeading)
            if newHeading.headingAccuracy < 0 {
                statusMessage = String(localized: "compass.status.calibration_required")
            } else {
                statusMessage = String(localized: "Bussola attiva")
            }
        }
    }
}
