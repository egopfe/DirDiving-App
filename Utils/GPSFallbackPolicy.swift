import Foundation

enum GPSFallbackQuality: String, Codable, Equatable {
    case unavailable
    case usable
    case stale
    case lowAccuracy
}

struct GPSFallbackAssessment: Equatable {
    let point: GPSPoint?
    let quality: GPSFallbackQuality

    var isUsable: Bool {
        quality == .usable && point != nil
    }
}

enum GPSFallbackPolicy {
    static func assess(_ point: GPSPoint?, now: Date = Date()) -> GPSFallbackAssessment {
        guard let point, isStructurallyValid(point) else {
            return GPSFallbackAssessment(point: nil, quality: .unavailable)
        }

        let age = now.timeIntervalSince(point.timestamp)
        guard age.isFinite,
              age >= 0,
              age <= DiveAlgorithmConfiguration.maximumGPSFallbackAgeSeconds else {
            return GPSFallbackAssessment(point: nil, quality: .stale)
        }

        guard point.horizontalAccuracy <= DiveAlgorithmConfiguration.maximumGPSFallbackHorizontalAccuracyMeters else {
            return GPSFallbackAssessment(point: nil, quality: .lowAccuracy)
        }

        return GPSFallbackAssessment(point: point, quality: .usable)
    }

    static func isStructurallyValid(_ point: GPSPoint) -> Bool {
        point.latitude.isFinite
            && point.longitude.isFinite
            && point.horizontalAccuracy.isFinite
            && point.horizontalAccuracy >= 0
            && (-90...90).contains(point.latitude)
            && (-180...180).contains(point.longitude)
    }
}

