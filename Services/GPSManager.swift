import Foundation
import Combine
import CoreLocation

@MainActor
final class GPSManager: NSObject, ObservableObject {
    @Published private(set) var lastPoint: GPSPoint?
    @Published private(set) var lastSpeedMetersPerSecond: Double = 0
    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published private(set) var fallbackQuality: GPSFallbackQuality = .unavailable
    private let locationManager = CLLocationManager()
    private var previousSpeedSample: (point: GPSPoint, date: Date)?
    private var bestEffortCapture: BestEffortCapture?
    var testHook_holdBestEffortCapture = false
    private var heldBestEffortCompletion: (@MainActor (GPSPoint?) -> Void)?

    func testHook_completeHeldBestEffortCapture(with point: GPSPoint? = nil) {
        guard let completion = heldBestEffortCompletion else { return }
        heldBestEffortCompletion = nil
        completion(point)
    }

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
    }

    func requestAuthorization() { locationManager.requestWhenInUseAuthorization() }
    func start() { requestAuthorization(); locationManager.startUpdatingLocation() }
    func stop() { locationManager.stopUpdatingLocation() }
    func currentBestPoint() -> GPSPoint? {
        let assessment = GPSFallbackPolicy.assess(lastPoint)
        fallbackQuality = assessment.quality
        return assessment.point
    }

    /// Starts a timed best-effort capture. When `stopUpdatesWhenComplete` is true, location updates stop after completion.
    /// Dive session entry/exit capture leaves updates running because `DiveManager` owns the broader GPS lifecycle.
    func captureBestEffortPoint(
        for seconds: TimeInterval,
        stopUpdatesWhenComplete: Bool = false,
        completion: @escaping @MainActor (GPSPoint?) -> Void
    ) {
        let captureDuration = seconds.isFinite ? min(60, max(0, seconds)) : 0
        requestAuthorization()
        locationManager.startUpdatingLocation()

        // Complete any in-flight capture before replacing it so callers are never stranded.
        finishBestEffortCapture()

        if testHook_holdBestEffortCapture {
            heldBestEffortCompletion = completion
            return
        }

        let capture = BestEffortCapture(
            deadline: Date().addingTimeInterval(captureDuration),
            bestPoint: currentBestPoint(),
            stopUpdatesWhenComplete: stopUpdatesWhenComplete,
            completion: completion
        )
        bestEffortCapture = capture

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(captureDuration * 1_000_000_000))
            guard self.bestEffortCapture === capture else { return }
            self.finishBestEffortCapture()
        }
    }

    private func finishBestEffortCapture() {
        guard let capture = bestEffortCapture else { return }
        bestEffortCapture = nil
        capture.completion(capture.bestPoint)
        if capture.stopUpdatesWhenComplete {
            locationManager.stopUpdatingLocation()
        }
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
            guard GPSFallbackPolicy.isStructurallyValid(point) else { return }
            let assessment = GPSFallbackPolicy.assess(point)
            fallbackQuality = assessment.quality
            if let previous = previousSpeedSample {
                let delta = location.timestamp.timeIntervalSince(previous.date)
                if delta > 0.25 {
                    let previousLocation = CLLocation(
                        latitude: previous.point.latitude,
                        longitude: previous.point.longitude
                    )
                    lastSpeedMetersPerSecond = max(0, location.distance(from: previousLocation) / delta)
                    previousSpeedSample = (point, location.timestamp)
                }
            } else {
                previousSpeedSample = (point, location.timestamp)
                lastSpeedMetersPerSecond = 0
            }
            lastPoint = point
            if let capture = bestEffortCapture {
                guard let usablePoint = assessment.point else { return }
                if let current = capture.bestPoint {
                    let hasBetterAccuracy = usablePoint.horizontalAccuracy < current.horizontalAccuracy
                    let isNewerEqualAccuracy = usablePoint.horizontalAccuracy == current.horizontalAccuracy && usablePoint.timestamp > current.timestamp
                    if hasBetterAccuracy || isNewerEqualAccuracy { capture.bestPoint = usablePoint }
                } else {
                    capture.bestPoint = usablePoint
                }

                if Date() >= capture.deadline { finishBestEffortCapture() }
            }
        }
    }
}

private final class BestEffortCapture {
    let deadline: Date
    var bestPoint: GPSPoint?
    let stopUpdatesWhenComplete: Bool
    let completion: @MainActor (GPSPoint?) -> Void

    init(
        deadline: Date,
        bestPoint: GPSPoint?,
        stopUpdatesWhenComplete: Bool,
        completion: @escaping @MainActor (GPSPoint?) -> Void
    ) {
        self.deadline = deadline
        self.bestPoint = bestPoint
        self.stopUpdatesWhenComplete = stopUpdatesWhenComplete
        self.completion = completion
    }
}
