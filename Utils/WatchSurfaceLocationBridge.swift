import Foundation

enum WatchSurfaceGPSQualityEvaluator {
    static func classify(
        horizontalAccuracyMeters: Double?,
        fixAgeSeconds: TimeInterval?,
        authorizationDenied: Bool,
        authorizationRestricted: Bool = false
    ) -> ActivityGPSQuality {
        if authorizationDenied { return .denied }
        if authorizationRestricted { return .restricted }
        guard let horizontalAccuracyMeters,
              horizontalAccuracyMeters.isFinite,
              horizontalAccuracyMeters >= 0 else {
            return .unavailable
        }
        if horizontalAccuracyMeters > DiveAlgorithmConfiguration.maximumGPSFallbackHorizontalAccuracyMeters {
            return .failed
        }
        if let fixAgeSeconds,
           fixAgeSeconds > DiveAlgorithmConfiguration.maximumGPSFallbackAgeSeconds {
            return .stale
        }
        return .measured
    }
}

enum WatchSurfaceLocationBridge {
    static func fix(from point: GPSPoint?, permission: WatchLocationPermissionState, now: Date = Date()) -> WatchSurfaceLocationFix? {
        switch permission {
        case .denied, .restricted:
            return nil
        case .notDetermined, .authorized:
            break
        }

        guard let point, GPSFallbackPolicy.isStructurallyValid(point) else { return nil }
        let age = now.timeIntervalSince(point.timestamp)
        let quality = WatchSurfaceGPSQualityEvaluator.classify(
            horizontalAccuracyMeters: point.horizontalAccuracy,
            fixAgeSeconds: age,
            authorizationDenied: permission == .denied,
            authorizationRestricted: permission == .restricted
        )

        let source: WatchSurfaceLocationFixSource
        switch quality {
        case .measured: source = .measured
        case .stale: source = .stale
        case .denied: source = .denied
        case .restricted: source = .restricted
        case .failed, .unavailable: source = .unavailable
        }

        guard source == .measured || source == .stale else { return nil }

        return WatchSurfaceLocationFix(
            latitude: point.latitude,
            longitude: point.longitude,
            horizontalAccuracyMeters: point.horizontalAccuracy,
            altitudeMeters: nil,
            speedMetersPerSecond: nil,
            courseDegrees: nil,
            capturedAt: point.timestamp,
            source: source
        )
    }

    static func apneaSurfacePoint(from fix: WatchSurfaceLocationFix) -> ApneaSurfaceGPSPoint {
        ApneaSurfaceGPSPoint(
            latitude: fix.latitude,
            longitude: fix.longitude,
            horizontalAccuracyMeters: fix.horizontalAccuracyMeters,
            capturedAt: fix.capturedAt
        )
    }
}
