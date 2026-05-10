import Foundation
import Combine
import CoreLocation

@MainActor
final class GPSManager: NSObject, ObservableObject {
    @Published private(set) var lastPoint: GPSPoint?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    private let locationManager = CLLocationManager()
    private var bestEffortCapture: BestEffortCapture?

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

    func captureBestEffortPoint(for seconds: TimeInterval, completion: @MainActor @escaping (GPSPoint?) -> Void) {
        requestAuthorization()
        locationManager.startUpdatingLocation()

        let capture = BestEffortCapture(deadline: Date().addingTimeInterval(seconds), bestPoint: lastPoint, completion: completion)
        bestEffortCapture = capture

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            guard self.bestEffortCapture === capture else { return }
            self.finishBestEffortCapture()
        }
    }

    private func finishBestEffortCapture() {
        guard let capture = bestEffortCapture else { return }
        bestEffortCapture = nil
        capture.completion(capture.bestPoint)
    }
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
            let point = GPSPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, horizontalAccuracy: location.horizontalAccuracy, timestamp: location.timestamp)
            lastPoint = point
            if let capture = bestEffortCapture {
                if let current = capture.bestPoint {
                    let hasBetterAccuracy = point.horizontalAccuracy >= 0 && point.horizontalAccuracy < current.horizontalAccuracy
                    let isNewerUnknownAccuracy = current.horizontalAccuracy < 0 && point.timestamp > current.timestamp
                    if hasBetterAccuracy || isNewerUnknownAccuracy { capture.bestPoint = point }
                } else {
                    capture.bestPoint = point
                }

                if Date() >= capture.deadline { finishBestEffortCapture() }
            }
        }
    }
}

private final class BestEffortCapture {
    let deadline: Date
    var bestPoint: GPSPoint?
    let completion: @MainActor (GPSPoint?) -> Void

    init(deadline: Date, bestPoint: GPSPoint?, completion: @MainActor @escaping (GPSPoint?) -> Void) {
        self.deadline = deadline
        self.bestPoint = bestPoint
        self.completion = completion
    }
}
