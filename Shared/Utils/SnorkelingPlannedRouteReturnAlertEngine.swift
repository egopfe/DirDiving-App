import Foundation

enum SnorkelingPlannedRouteReturnAlertEngine {
    struct State: Equatable, Sendable {
        var alreadyTriggered = false
    }

    static func shouldTrigger(
        policy: SnorkelingReturnAlertPolicy,
        plannedDurationSeconds: TimeInterval,
        plannedDistanceMeters: Double,
        elapsedSeconds: TimeInterval,
        traveledDistanceMeters: Double,
        state: inout State
    ) -> Bool {
        guard !state.alreadyTriggered else { return false }
        guard plannedDurationSeconds > 0 || plannedDistanceMeters > 0 else { return false }

        let shouldFire: Bool
        switch policy {
        case .off:
            shouldFire = false
        case .halfPlannedTime:
            shouldFire = plannedDurationSeconds > 0 && elapsedSeconds >= plannedDurationSeconds * 0.5
        case .halfPlannedDistance:
            shouldFire = plannedDistanceMeters > 0 && traveledDistanceMeters >= plannedDistanceMeters * 0.5
        }

        if shouldFire {
            state.alreadyTriggered = true
        }
        return shouldFire
    }
}
