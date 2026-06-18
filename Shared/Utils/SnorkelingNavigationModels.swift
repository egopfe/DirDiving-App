import Foundation

enum SnorkelingTurnInstruction: String, Codable, CaseIterable, Hashable, Sendable {
    case turnLeft
    case turnRight
    case onLine
    case unavailable
}

enum SnorkelingHeadingQuality: String, Codable, CaseIterable, Hashable, Sendable {
    case valid
    case stale
    case unavailable
}

enum SnorkelingReturnAdvisorReason: String, Codable, CaseIterable, Hashable, Sendable {
    case none
    case distanceThreshold
    case durationThreshold
    case batteryThreshold
    case manualActivation
}

struct SnorkelingEntryPoint: Codable, Equatable, Hashable, Sendable {
    var latitude: Double
    var longitude: Double
    var capturedAt: Date
    var monotonicRelativeTimestampSeconds: TimeInterval
    var gpsQuality: SnorkelingGPSQuality
    var horizontalAccuracyMeters: Double?

    init(
        latitude: Double,
        longitude: Double,
        capturedAt: Date,
        monotonicRelativeTimestampSeconds: TimeInterval,
        gpsQuality: SnorkelingGPSQuality,
        horizontalAccuracyMeters: Double? = nil
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.capturedAt = capturedAt
        self.monotonicRelativeTimestampSeconds = monotonicRelativeTimestampSeconds
        self.gpsQuality = gpsQuality
        self.horizontalAccuracyMeters = horizontalAccuracyMeters
    }

    init?(acceptedFix: SnorkelingGPSAcceptedFix, capturedAt: Date) {
        guard acceptedFix.gpsQuality.isMeasuredSurfaceFix else { return nil }
        latitude = acceptedFix.latitude
        longitude = acceptedFix.longitude
        self.capturedAt = capturedAt
        monotonicRelativeTimestampSeconds = acceptedFix.monotonicRelativeTimestampSeconds
        gpsQuality = acceptedFix.gpsQuality
        horizontalAccuracyMeters = acceptedFix.horizontalAccuracyMeters
    }
}

struct SnorkelingNavigationConfiguration: Codable, Hashable, Sendable {
    var onLineToleranceDegrees: Double
    var turnThresholdDegrees: Double
    var waypointReachedRadiusMeters: Double
    var autoAdvanceToNextWaypoint: Bool
    var staleHeadingMaximumAgeSeconds: TimeInterval
    var preciseTurnRequiresMeasuredGPS: Bool

    static let `default` = SnorkelingNavigationConfiguration(
        onLineToleranceDegrees: 12,
        turnThresholdDegrees: 12,
        waypointReachedRadiusMeters: 15,
        autoAdvanceToNextWaypoint: true,
        staleHeadingMaximumAgeSeconds: 5,
        preciseTurnRequiresMeasuredGPS: true
    )
}

struct SnorkelingReturnAdvisorConfiguration: Codable, Hashable, Sendable {
    var adviseReturnDistanceMeters: Double
    var adviseReturnDurationSeconds: TimeInterval
    var adviseReturnBatteryFraction: Double
    var entryReachedRadiusMeters: Double
    var alternateSafeTargetMaximumDistanceMeters: Double

    static let `default` = SnorkelingReturnAdvisorConfiguration(
        adviseReturnDistanceMeters: 200,
        adviseReturnDurationSeconds: 3_600,
        adviseReturnBatteryFraction: 0.20,
        entryReachedRadiusMeters: 25,
        alternateSafeTargetMaximumDistanceMeters: 50
    )
}

struct SnorkelingWaypointNavigationSnapshot: Equatable, Hashable, Sendable, Codable {
    var waypointID: UUID?
    var waypointName: String?
    var waypointCategory: SnorkelingMarkerCategory?
    var targetBearingDegrees: Double?
    var currentHeadingDegrees: Double?
    var signedAngularDeltaDegrees: Double?
    var turnInstruction: SnorkelingTurnInstruction
    var distanceToTargetMeters: Double?
    var gpsPresentationState: SnorkelingGPSPresentationState
    var headingQuality: SnorkelingHeadingQuality
    var surfaceSpeedMetersPerSecond: Double?
    var waypointReached: Bool
    var hasNextWaypoint: Bool
    var skippedWaypointIDs: [UUID]

    static let unavailable = SnorkelingWaypointNavigationSnapshot(
        waypointID: nil,
        waypointName: nil,
        waypointCategory: nil,
        targetBearingDegrees: nil,
        currentHeadingDegrees: nil,
        signedAngularDeltaDegrees: nil,
        turnInstruction: .unavailable,
        distanceToTargetMeters: nil,
        gpsPresentationState: .unavailable,
        headingQuality: .unavailable,
        surfaceSpeedMetersPerSecond: nil,
        waypointReached: false,
        hasNextWaypoint: false,
        skippedWaypointIDs: []
    )
}

struct SnorkelingReturnNavigationSnapshot: Equatable, Hashable, Sendable, Codable {
    var entryPoint: SnorkelingEntryPoint?
    var alternateTarget: SnorkelingEntryPoint?
    var entryPointAgeSeconds: TimeInterval?
    var distanceToEntryMeters: Double?
    var bearingToEntryDegrees: Double?
    var currentHeadingDegrees: Double?
    var signedAngularDeltaDegrees: Double?
    var turnInstruction: SnorkelingTurnInstruction
    var advisorReason: SnorkelingReturnAdvisorReason
    var advisorActive: Bool
    var gpsPresentationState: SnorkelingGPSPresentationState
    var headingQuality: SnorkelingHeadingQuality
    var informationalMessageKey: String?

    static let unavailable = SnorkelingReturnNavigationSnapshot(
        entryPoint: nil,
        alternateTarget: nil,
        entryPointAgeSeconds: nil,
        distanceToEntryMeters: nil,
        bearingToEntryDegrees: nil,
        currentHeadingDegrees: nil,
        signedAngularDeltaDegrees: nil,
        turnInstruction: .unavailable,
        advisorReason: .none,
        advisorActive: false,
        gpsPresentationState: .unavailable,
        headingQuality: .unavailable,
        informationalMessageKey: nil
    )
}

struct SnorkelingNavigationPositionInput: Equatable, Hashable, Sendable {
    var latitude: Double?
    var longitude: Double?
    var gpsQuality: SnorkelingGPSQuality
    var gpsPresentationState: SnorkelingGPSPresentationState
    var isUnderwater: Bool
    var surfaceSpeedMetersPerSecond: Double?
    var fixAgeSeconds: TimeInterval?
}

struct SnorkelingNavigationHeadingInput: Equatable, Hashable, Sendable {
    var headingDegrees: Double?
    var ageSeconds: TimeInterval?
}

struct SnorkelingNavigationRuntimeState: Codable, Hashable, Sendable {
    var activeRoutePlanID: UUID?
    var orderedWaypointIDs: [UUID]
    var currentWaypointID: UUID?
    var completedWaypointIDs: [UUID]
    var skippedWaypointIDs: [UUID]
    var manualWaypointSelectionID: UUID?
    var entryPoint: SnorkelingEntryPoint?
    var alternateEntryTarget: SnorkelingEntryPoint?
    var manualReturnAdvisorActive: Bool
    var routePlanWaypointSignature: String?
    var lastWaypointNavigation: SnorkelingWaypointNavigationSnapshot
    var lastReturnNavigation: SnorkelingReturnNavigationSnapshot

    static let initial = SnorkelingNavigationRuntimeState(
        activeRoutePlanID: nil,
        orderedWaypointIDs: [],
        currentWaypointID: nil,
        completedWaypointIDs: [],
        skippedWaypointIDs: [],
        manualWaypointSelectionID: nil,
        entryPoint: nil,
        alternateEntryTarget: nil,
        manualReturnAdvisorActive: false,
        routePlanWaypointSignature: nil,
        lastWaypointNavigation: .unavailable,
        lastReturnNavigation: .unavailable
    )
}
