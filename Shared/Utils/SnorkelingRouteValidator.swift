import Foundation

enum SnorkelingRouteValidator {
    static func validate(
        draft: SnorkelingRoutePlannerDraft,
        profile: SnorkelingCompanionProfile?,
        gpsPermissionKnown: Bool = true
    ) -> SnorkelingRouteValidationResult {
        var issues = SnorkelingRoutePlanValidator.validationIssues(for: draft)
        if draft.resolvedRouteType == .differentExit, draft.exitPoint == nil, !issues.contains(.missingExit) {
            issues.append(.missingExit)
        }
        if draft.entryPoint == nil, !issues.contains(.missingEntry) {
            issues.append(.missingEntry)
        }
        if !gpsPermissionKnown, !issues.contains(.insufficientPoints) {
            // GPS state unknown does not block route geometry validation.
        }

        let warnings = warningIssues(for: draft, profile: profile)
        let blocking: Set<SnorkelingRouteValidationIssue> = [
            .invalidCoordinate, .duplicatePoint
        ]
        let incomplete: Set<SnorkelingRouteValidationIssue> = [
            .emptyName, .missingEntry, .missingExit, .insufficientPoints
        ]

        let status: SnorkelingRouteValidationStatus
        if issues.contains(where: { blocking.contains($0) }) {
            status = .blocked
        } else if issues.contains(where: { incomplete.contains($0) }) {
            status = .incomplete
        } else if !warnings.isEmpty || issues.contains(.exceedsMaxDistance) {
            status = .warning
        } else if draft.routingPoints.count < 2 {
            status = .incomplete
        } else {
            status = .ready
        }

        return SnorkelingRouteValidationResult(status: status, issues: issues, warnings: warnings)
    }

    private static func warningIssues(
        for draft: SnorkelingRoutePlannerDraft,
        profile: SnorkelingCompanionProfile?
    ) -> [SnorkelingRouteValidationWarning] {
        var warnings: [SnorkelingRouteValidationWarning] = []
        let distance = SnorkelingDistanceCalculator.distanceMeters(points: draft.routingPoints)
        let duration = SnorkelingDurationEstimator.estimatedDurationSeconds(
            distanceMeters: distance,
            draft: draft,
            profile: profile
        )

        let kind = draft.routeProfileKind ?? .relaxBeginner
        let maxDistance = profile?.maxDistanceMeters ?? kind.recommendedMaxDistanceMeters
        let maxDuration = profile?.targetDurationSeconds ?? (kind.recommendedMaxDurationMinutes * 60)
        if maxDistance > 0, distance > maxDistance {
            warnings.append(.exceedsProfileDistance)
        }
        if maxDuration > 0, duration > maxDuration {
            warnings.append(.exceedsProfileDuration)
        }

        if draft.resolvedRouteType == .differentExit,
           let entry = draft.entryPoint,
           let exit = draft.exitPoint {
            let separation = SnorkelingDomainSupport.distanceMeters(
                from: (entry.latitude, entry.longitude),
                to: (exit.latitude, exit.longitude)
            )
            if separation > max(100, maxDistance * 0.75) {
                warnings.append(.exitFarFromEntry)
            }
        }

        let sortedWaypoints = draft.waypoints.sorted { $0.routeOrder < $1.routeOrder }
        for index in 1 ..< sortedWaypoints.count {
            let previous = sortedWaypoints[index - 1]
            let current = sortedWaypoints[index]
            let spacing = SnorkelingDomainSupport.distanceMeters(
                from: (previous.latitude, previous.longitude),
                to: (current.latitude, current.longitude)
            )
            if spacing > 250 {
                warnings.append(.waypointSpacingLarge)
                break
            }
        }

        return warnings
    }
}
