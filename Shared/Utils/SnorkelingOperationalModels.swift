import Foundation

enum SnorkelingHapticPattern: String, Codable, CaseIterable, Hashable, Sendable {
    case markerSaved
    case waypointReached
    case returnAdvised
    case alarmInfo
    case alarmWarning
    case alarmCritical
}

struct SnorkelingHapticCue: Codable, Hashable, Sendable {
    var pattern: SnorkelingHapticPattern
    var atMonotonicSeconds: TimeInterval
    var sourceID: UUID?
}

struct SnorkelingOperationalOverlay: Codable, Hashable, Sendable {
    enum Kind: String, Codable, CaseIterable, Hashable, Sendable {
        case markerSaved
        case alarm
        case returnAdvised
        case sensorDegraded
        case gpsDegraded
    }

    var kind: Kind
    var titleKey: String
    var subtitle: String
    var severity: SnorkelingOperationalSeverity
    var eventID: UUID
}

enum SnorkelingOperationalSeverity: String, Codable, CaseIterable, Hashable, Sendable {
    case info
    case caution
    case warning
    case critical
}

struct SnorkelingOperationalEventContext: Codable, Hashable, Sendable {
    var monotonicNow: TimeInterval
    var wallClockNow: Date
    var sessionElapsedSeconds: TimeInterval
    var activeDipElapsedSeconds: TimeInterval
    var distanceFromEntryMeters: Double?
    var batteryFraction: Double?
    var temperatureCelsius: Double?
    var gpsPresentationState: SnorkelingGPSPresentationState
    var sensorHealth: SnorkelingSensorHealth
    var missionModeEnabled: Bool
    var hapticsEnabled: Bool
}

struct SnorkelingOperationalEventState: Codable, Hashable, Sendable {
    var armedAlarmIDs: Set<UUID>
    var lastAlarmFireMonotonic: [UUID: TimeInterval]
    var activeHapticUntilMonotonic: TimeInterval?
    var gpsWasAvailable: Bool

    static let initial = SnorkelingOperationalEventState(
        armedAlarmIDs: [],
        lastAlarmFireMonotonic: [:],
        activeHapticUntilMonotonic: nil,
        gpsWasAvailable: false
    )
}

struct SnorkelingOperationalEventOutput: Codable, Hashable, Sendable {
    var events: [SnorkelingEvent]
    var overlays: [SnorkelingOperationalOverlay]
    var hapticCues: [SnorkelingHapticCue]

    static let empty = SnorkelingOperationalEventOutput(events: [], overlays: [], hapticCues: [])
}

struct SnorkelingMissionModePresentationProfile: Codable, Hashable, Sendable {
    var animationsEnabled: Bool
    var minimumPresentationRefreshSeconds: TimeInterval

    static let standard = SnorkelingMissionModePresentationProfile(
        animationsEnabled: true,
        minimumPresentationRefreshSeconds: 1.0
    )

    static let mission = SnorkelingMissionModePresentationProfile(
        animationsEnabled: false,
        minimumPresentationRefreshSeconds: 2.5
    )

    func shouldRefreshPresentation(now: TimeInterval, lastRefresh: TimeInterval?) -> Bool {
        guard let lastRefresh else { return true }
        return now - lastRefresh >= minimumPresentationRefreshSeconds
    }
}

enum SnorkelingMarkerCaptureRejection: String, Codable, CaseIterable, Hashable, Sendable {
    case invalidCategory
    case noteTooLong
    case coordinateRequired
    case underwaterMeasuredGPSRejected
    case invalidCustomCategory
}

struct SnorkelingMarkerCaptureRequest: Codable, Hashable, Sendable {
    var category: SnorkelingMarkerCategory
    var customCategoryLabel: String?
    var note: String?
    var allowSaveWithoutCoordinates: Bool
    var photoReferenceID: UUID?
}

struct SnorkelingMarkerCaptureResult: Codable, Hashable, Sendable {
    var marker: SnorkelingMarker?
    var event: SnorkelingEvent?
    var rejection: SnorkelingMarkerCaptureRejection?
    var overlay: SnorkelingOperationalOverlay?
    var hapticCue: SnorkelingHapticCue?
}
