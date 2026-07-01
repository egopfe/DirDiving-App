import Foundation

/// Activity-safe surface GPS helper wrapping `GPSManager` (When In Use only; no fabricated coordinates).
@MainActor
final class WatchSurfaceLocationService {
    private weak var gpsManager: GPSManager?

    func attach(gpsManager: GPSManager) {
        self.gpsManager = gpsManager
        gpsManager.refreshAuthorizationStatus()
    }

    var permissionState: WatchLocationPermissionState {
        gpsManager?.locationPermissionState ?? .notDetermined
    }

    func requestWhenInUseAuthorization() {
        gpsManager?.requestAuthorization()
    }

    func startSurfaceUpdates() {
        gpsManager?.start()
    }

    func stopSurfaceUpdates() {
        gpsManager?.stop()
    }

    func lastKnownSurfaceFix(now: Date = Date()) -> WatchSurfaceLocationFix? {
        guard let gpsManager else { return nil }
        gpsManager.refreshAuthorizationStatus()
        return WatchSurfaceLocationBridge.fix(
            from: gpsManager.currentBestPoint(),
            permission: gpsManager.locationPermissionState,
            now: now
        )
    }

    func captureOneShot(
        for seconds: TimeInterval = 6,
        stopUpdatesWhenComplete: Bool = false,
        completion: @escaping @MainActor (WatchSurfaceLocationFix?) -> Void
    ) {
        guard let gpsManager else {
            completion(nil)
            return
        }
        gpsManager.refreshAuthorizationStatus()
        let permission = gpsManager.locationPermissionState
        if permission == .denied || permission == .restricted {
            completion(nil)
            return
        }

        let immediate = WatchSurfaceLocationBridge.fix(
            from: gpsManager.currentBestPoint(),
            permission: permission
        )

        gpsManager.captureBestEffortPoint(
            for: seconds,
            stopUpdatesWhenComplete: stopUpdatesWhenComplete
        ) { [weak self] point in
            guard let self else {
                completion(immediate)
                return
            }
            let captured = WatchSurfaceLocationBridge.fix(
                from: point,
                permission: self.gpsManager?.locationPermissionState ?? permission
            )
            completion(captured ?? immediate)
        }
    }
}
