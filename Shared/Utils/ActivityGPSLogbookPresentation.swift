import Foundation

enum ActivityGPSLogbookPresentation {
    static func statusLocalizationKey(for quality: ActivityGPSQuality) -> String {
        switch quality {
        case .measured: return "gps.status.available"
        case .stale: return "gps.status.stale"
        case .unavailable: return "gps.status.unavailable"
        case .denied: return "gps.status.denied"
        case .restricted: return "gps.status.denied"
        case .failed: return "gps.status.no_fix"
        }
    }

    static func statusLocalizationKey(for source: WatchSurfaceLocationFixSource) -> String {
        switch source {
        case .measured: return "gps.status.available"
        case .stale: return "gps.status.stale"
        case .unavailable: return "gps.status.unavailable"
        case .denied: return "gps.status.denied"
        case .restricted: return "gps.status.denied"
        case .failed: return "gps.status.no_fix"
        }
    }

    static func divingFixSourceLocalizationKey(_ source: GPSFixSource) -> String {
        switch source {
        case .fix: return "gps.status.available"
        case .fallback: return "gps.status.stale"
        case .noFix: return "gps.status.no_fix"
        }
    }

    static func snorkelTrackCounts(_ points: [SnorkelingTrackPoint]) -> (measured: Int, stale: Int, unavailable: Int) {
        var measured = 0
        var stale = 0
        var unavailable = 0
        for point in points {
            switch point.gpsQuality {
            case .measured: measured += 1
            case .stale: stale += 1
            case .estimated, .unavailable, .invalid: unavailable += 1
            }
        }
        return (measured, stale, unavailable)
    }

    static func apneaStartEndAvailability(points: [ApneaSurfaceGPSPoint]) -> (start: String, end: String) {
        guard !points.isEmpty else {
            return ("gps.status.unavailable", "gps.status.unavailable")
        }
        let startKey = "gps.status.available"
        if points.count >= 2 {
            return (startKey, "gps.status.available")
        }
        return (startKey, "gps.status.unavailable")
    }
}

enum ActivityGPSLogbookPolicy {
    static func divingSessionRemainsValidWithoutGPS(_ session: DiveSession) -> Bool {
        (try? DiveSessionAlgorithmValidator.validate(session)) != nil
    }

    static func snorkelingSessionRemainsValidWithoutGPS(_ session: SnorkelingSession) -> Bool {
        SnorkelingLogbookPolicy.classify(session) == .exportable || session.trackPoints.isEmpty
    }

    static func apneaSessionRemainsValidWithoutGPS(_ session: ApneaSession) -> Bool {
        ApneaLogbookPolicy.classify(session) == .exportable
    }
}
