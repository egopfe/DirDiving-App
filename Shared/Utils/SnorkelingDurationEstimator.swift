import Foundation

enum SnorkelingDurationEstimator {
    static func speedMetersPerMinute(
        draft: SnorkelingRoutePlannerDraft,
        profile: SnorkelingCompanionProfile?
    ) -> Double {
        if let profileSpeed = profile?.estimatedSpeedMetersPerMinute {
            guard profileSpeed > 0 else { return 0 }
            return profileSpeed
        }
        if let kind = draft.routeProfileKind {
            return kind.estimatedSpeedMetersPerMinute
        }
        return SnorkelingRouteProfileKind.relaxBeginner.estimatedSpeedMetersPerMinute
    }

    static func estimatedDurationSeconds(
        distanceMeters: Double,
        draft: SnorkelingRoutePlannerDraft,
        profile: SnorkelingCompanionProfile?
    ) -> TimeInterval {
        let speed = speedMetersPerMinute(draft: draft, profile: profile)
        guard distanceMeters.isFinite, distanceMeters > 0, speed > 0 else { return 0 }
        return (distanceMeters / speed) * 60
    }
}
