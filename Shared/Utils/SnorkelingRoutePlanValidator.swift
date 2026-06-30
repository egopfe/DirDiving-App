import Foundation

enum SnorkelingRouteValidationIssue: String, Codable, CaseIterable, Hashable, Sendable {
    case emptyName
    case missingEntry
    case missingExit
    case insufficientPoints
    case invalidCoordinate
    case exceedsMaxDistance
    case duplicatePoint
}

enum SnorkelingRoutePlanValidator {
    static let defaultSwimSpeedMetersPerSecond: Double = 0.6
    static let minimumPoints = 2
    static let maxWaypoints = 24

    static func isValid(_ plan: SnorkelingRoutePlan) -> Bool {
        validationIssues(for: plan).isEmpty
    }

    static func isValid(draft: SnorkelingRoutePlannerDraft) -> Bool {
        validationIssues(for: draft).isEmpty
    }

    static func validationIssues(for plan: SnorkelingRoutePlan) -> [SnorkelingRouteValidationIssue] {
        var issues: [SnorkelingRouteValidationIssue] = []
        let trimmed = plan.name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { issues.append(.emptyName) }
        let ordered = plan.waypoints.sorted { $0.routeOrder < $1.routeOrder }
        if ordered.count < minimumPoints { issues.append(.insufficientPoints) }
        for point in ordered {
            if !SnorkelingDomainSupport.isValidCoordinate(latitude: point.latitude, longitude: point.longitude) {
                issues.append(.invalidCoordinate)
            }
        }
        return issues
    }

    static func validationIssues(for draft: SnorkelingRoutePlannerDraft) -> [SnorkelingRouteValidationIssue] {
        var issues: [SnorkelingRouteValidationIssue] = []
        let trimmed = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { issues.append(.emptyName) }
        if draft.entryPoint == nil { issues.append(.missingEntry) }
        if draft.resolvedRouteType == .differentExit, draft.exitPoint == nil {
            issues.append(.missingExit)
        }
        let ordered = draft.orderedPoints
        if ordered.count < minimumPoints { issues.append(.insufficientPoints) }
        if draft.waypoints.count > maxWaypoints { issues.append(.insufficientPoints) }
        for point in ordered {
            if !SnorkelingDomainSupport.isValidCoordinate(latitude: point.latitude, longitude: point.longitude) {
                issues.append(.invalidCoordinate)
            }
        }
        let distance = routeDistanceMeters(ordered)
        if let limit = draft.maxDistanceLimitMeters, limit > 0, distance > limit {
            issues.append(.exceedsMaxDistance)
        }
        return issues
    }

    static func routeDistanceMeters(_ points: [SnorkelingRoutePlannerPoint]) -> Double {
        let ordered = points.sorted { $0.routeOrder < $1.routeOrder }
        guard ordered.count >= 2 else { return 0 }
        var total: Double = 0
        for index in 1 ..< ordered.count {
            let previous = ordered[index - 1]
            let current = ordered[index]
            total += SnorkelingDomainSupport.distanceMeters(
                from: (previous.latitude, previous.longitude),
                to: (current.latitude, current.longitude)
            )
        }
        return max(0, total)
    }

    static func routeDistanceMeters(_ plan: SnorkelingRoutePlan) -> Double {
        let ordered = plan.waypoints.sorted { $0.routeOrder < $1.routeOrder }
        guard ordered.count >= 2 else { return 0 }
        var total: Double = 0
        for index in 1 ..< ordered.count {
            let previous = ordered[index - 1]
            let current = ordered[index]
            total += SnorkelingDomainSupport.distanceMeters(
                from: (previous.latitude, previous.longitude),
                to: (current.latitude, current.longitude)
            )
        }
        return max(0, total)
    }

    static func estimatedDurationSeconds(
        distanceMeters: Double,
        swimSpeedMetersPerSecond: Double = defaultSwimSpeedMetersPerSecond
    ) -> TimeInterval {
        guard distanceMeters.isFinite, distanceMeters > 0, swimSpeedMetersPerSecond > 0 else { return 0 }
        return distanceMeters / swimSpeedMetersPerSecond
    }

    static func estimatedDurationSeconds(for draft: SnorkelingRoutePlannerDraft, profile: SnorkelingCompanionProfile? = nil) -> TimeInterval {
        SnorkelingDurationEstimator.estimatedDurationSeconds(
            distanceMeters: routeDistanceMeters(draft.routingPoints),
            draft: draft,
            profile: profile
        )
    }

    static func moveWaypoint(in draft: inout SnorkelingRoutePlannerDraft, from source: Int, to destination: Int) {
        var sorted = draft.waypoints.sorted { $0.routeOrder < $1.routeOrder }
        guard source != destination,
              (0 ..< sorted.count).contains(source),
              (0 ... sorted.count).contains(destination) else { return }
        let item = sorted.remove(at: source)
        let insertIndex = min(destination, sorted.count)
        sorted.insert(item, at: insertIndex)
        draft.waypoints = sorted.enumerated().map { index, point in
            var copy = point
            copy.routeOrder = index
            return copy
        }
        draft.updatedAt = Date()
    }
}
