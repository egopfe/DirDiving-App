import Foundation

struct SnorkelingCoordinate: Codable, Equatable, Hashable, Sendable {
    let latitude: Double
    let longitude: Double

    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    init(_ point: SnorkelingRoutePlannerPoint) {
        latitude = point.latitude
        longitude = point.longitude
    }
}

enum SnorkelingRouteType: String, Codable, CaseIterable, Hashable, Sendable {
    case roundTrip
    case differentExit
}

enum SnorkelingReturnAlertPolicy: String, Codable, CaseIterable, Hashable, Sendable {
    case off
    case halfPlannedTime
    case halfPlannedDistance
}

enum SnorkelingRouteProfileKind: String, Codable, CaseIterable, Hashable, Sendable, Identifiable {
    case relaxBeginner
    case coastalExploration
    case trainingSwim
    case photoReefObservation
    case longRoute

    var id: String { rawValue }

    var estimatedSpeedMetersPerMinute: Double {
        switch self {
        case .relaxBeginner: return 15
        case .coastalExploration: return 18
        case .trainingSwim: return 25
        case .photoReefObservation: return 12
        case .longRoute: return 20
        }
    }

    var recommendedMaxDistanceMeters: Double {
        switch self {
        case .relaxBeginner: return 500
        case .coastalExploration: return 800
        case .trainingSwim: return 1_200
        case .photoReefObservation: return 400
        case .longRoute: return 1_500
        }
    }

    var recommendedMaxDurationMinutes: Double {
        switch self {
        case .relaxBeginner: return 30
        case .coastalExploration: return 45
        case .trainingSwim: return 60
        case .photoReefObservation: return 40
        case .longRoute: return 75
        }
    }

    var defaultReturnAlertPolicy: SnorkelingReturnAlertPolicy { .halfPlannedTime }

    var localizationKey: String {
        switch self {
        case .relaxBeginner: return "snorkeling.profile.relax_beginner"
        case .coastalExploration: return "snorkeling.profile.coastal_exploration"
        case .trainingSwim: return "snorkeling.profile.training_swim"
        case .photoReefObservation: return "snorkeling.profile.photo_reef"
        case .longRoute: return "snorkeling.profile.long_route"
        }
    }
}

enum SnorkelingRouteValidationStatus: String, Codable, CaseIterable, Hashable, Sendable {
    case ready
    case warning
    case incomplete
    case blocked
}

enum SnorkelingRouteValidationWarning: String, Codable, CaseIterable, Hashable, Sendable {
    case exceedsProfileDistance
    case exceedsProfileDuration
    case exitFarFromEntry
    case waypointSpacingLarge
}

struct SnorkelingRouteValidationResult: Equatable, Sendable {
    let status: SnorkelingRouteValidationStatus
    let issues: [SnorkelingRouteValidationIssue]
    let warnings: [SnorkelingRouteValidationWarning]

    var allowsWatchTransfer: Bool {
        status == .ready || status == .warning
    }

    var localizationKey: String {
        switch status {
        case .ready: return "snorkeling.route_safety.ready"
        case .warning: return "snorkeling.route_safety.warning"
        case .incomplete: return "snorkeling.route_safety.incomplete"
        case .blocked: return "snorkeling.route_safety.incomplete"
        }
    }
}

struct SnorkelingPreSnorkelingChecklist: Codable, Hashable, Sendable {
    var weatherChecked: Bool
    var currentAssessed: Bool
    var exitConfirmed: Bool
    var buddyPresent: Bool
    var surfaceMarkerBuoy: Bool
    var watchCharged: Bool

    static let `default` = SnorkelingPreSnorkelingChecklist(
        weatherChecked: false,
        currentAssessed: false,
        exitConfirmed: false,
        buddyPresent: false,
        surfaceMarkerBuoy: false,
        watchCharged: false
    )

    var completedCount: Int {
        [weatherChecked, currentAssessed, exitConfirmed, buddyPresent, surfaceMarkerBuoy, watchCharged]
            .filter { $0 }.count
    }
}

struct SnorkelingRoutePlanningMetadata: Codable, Hashable, Sendable {
    var routeType: SnorkelingRouteType
    var estimatedDistanceMeters: Double
    var estimatedDurationSeconds: TimeInterval
    var returnAlertPolicy: SnorkelingReturnAlertPolicy
    var routeProfileKind: SnorkelingRouteProfileKind?
    var checklistCompletedCount: Int

    static func make(
        from draft: SnorkelingRoutePlannerDraft,
        profile: SnorkelingCompanionProfile?
    ) -> SnorkelingRoutePlanningMetadata {
        let distance = SnorkelingDistanceCalculator.distanceMeters(points: draft.routingPoints)
        let duration = SnorkelingDurationEstimator.estimatedDurationSeconds(
            distanceMeters: distance,
            draft: draft,
            profile: profile
        )
        return SnorkelingRoutePlanningMetadata(
            routeType: draft.resolvedRouteType,
            estimatedDistanceMeters: distance,
            estimatedDurationSeconds: duration,
            returnAlertPolicy: draft.resolvedReturnAlertPolicy,
            routeProfileKind: draft.routeProfileKind,
            checklistCompletedCount: draft.resolvedChecklist.completedCount
        )
    }
}

struct SnorkelingReturnToEntryPreview: Equatable, Sendable {
    let distanceMeters: Double?
    let bearingDegrees: Double?
    let isAvailable: Bool
}

enum SnorkelingWatchGPSPresentationBand: String, Codable, CaseIterable, Hashable, Sendable {
    case good
    case medium
    case poor
    case lost

    var localizationKey: String {
        switch self {
        case .good: return "snorkeling.watch.gps.good"
        case .medium: return "snorkeling.watch.gps.medium"
        case .poor: return "snorkeling.watch.gps.poor"
        case .lost: return "snorkeling.watch.gps.lost"
        }
    }
}

struct SnorkelingSessionRuntimeSummary: Codable, Hashable, Sendable {
    var gpsQualityBand: SnorkelingWatchGPSPresentationBand?
    var trackPointCount: Int
    var gapsDetected: Int
    var averageAccuracyMeters: Double?
    var maxAccuracyMeters: Double?
    var routeCompletedPercentage: Double?
    var returnAlertTriggered: Bool
    var offRouteEventCount: Int
    var maxOffRouteDistanceMeters: Double?
    var timeOffRouteSeconds: TimeInterval

    static let empty = SnorkelingSessionRuntimeSummary(
        gpsQualityBand: nil,
        trackPointCount: 0,
        gapsDetected: 0,
        averageAccuracyMeters: nil,
        maxAccuracyMeters: nil,
        routeCompletedPercentage: nil,
        returnAlertTriggered: false,
        offRouteEventCount: 0,
        maxOffRouteDistanceMeters: nil,
        timeOffRouteSeconds: 0
    )
}
