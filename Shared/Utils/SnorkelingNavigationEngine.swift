import Foundation

enum SnorkelingNavigationEngine {
    static func turnInstruction(
        signedDeltaDegrees: Double,
        configuration: SnorkelingNavigationConfiguration
    ) -> SnorkelingTurnInstruction {
        let absDelta = abs(signedDeltaDegrees)
        if absDelta <= configuration.onLineToleranceDegrees {
            return .onLine
        }
        if absDelta < configuration.turnThresholdDegrees {
            return .onLine
        }
        return signedDeltaDegrees > 0 ? .turnRight : .turnLeft
    }

    static func headingQuality(
        heading: SnorkelingNavigationHeadingInput,
        configuration: SnorkelingNavigationConfiguration
    ) -> SnorkelingHeadingQuality {
        guard let headingDegrees = heading.headingDegrees, headingDegrees.isFinite else {
            return .unavailable
        }
        guard let age = heading.ageSeconds, age.isFinite, age >= 0 else {
            return .unavailable
        }
        if age > configuration.staleHeadingMaximumAgeSeconds {
            return .stale
        }
        return .valid
    }

    static func permitsPreciseTurnGuidance(
        position: SnorkelingNavigationPositionInput,
        headingQuality: SnorkelingHeadingQuality,
        configuration: SnorkelingNavigationConfiguration
    ) -> Bool {
        if position.isUnderwater { return false }
        if headingQuality != .valid { return false }
        if configuration.preciseTurnRequiresMeasuredGPS {
            return position.gpsQuality == .measured && position.gpsPresentationState == .tracking
        }
        return position.gpsQuality.permitsNavigation && position.gpsPresentationState != .unavailable
    }

    static func evaluateWaypointNavigation(
        routePlan: SnorkelingRoutePlan?,
        state: SnorkelingNavigationRuntimeState,
        position: SnorkelingNavigationPositionInput,
        heading: SnorkelingNavigationHeadingInput,
        configuration: SnorkelingNavigationConfiguration = .default
    ) -> (snapshot: SnorkelingWaypointNavigationSnapshot, state: SnorkelingNavigationRuntimeState) {
        var updated = state
        guard let routePlan else {
            updated.lastWaypointNavigation = .unavailable
            return (updated.lastWaypointNavigation, updated)
        }

        let signature = routePlanWaypointSignature(routePlan)
        let ordered: [SnorkelingWaypoint]
        if signature == updated.routePlanWaypointSignature,
           !updated.orderedWaypointIDs.isEmpty {
            let byID = Dictionary(uniqueKeysWithValues: routePlan.waypoints.map { ($0.id, $0) })
            ordered = updated.orderedWaypointIDs.compactMap { byID[$0] }
                .filter { SnorkelingDomainValidator.validate(waypoint: $0).isEmpty }
        } else {
            ordered = SnorkelingDomainSupport.orderedWaypoints(routePlan.waypoints)
                .filter { SnorkelingDomainValidator.validate(waypoint: $0).isEmpty }
            updated.orderedWaypointIDs = ordered.map(\.id)
            updated.routePlanWaypointSignature = signature
        }
        updated.activeRoutePlanID = routePlan.id

        let currentWaypoint = resolveCurrentWaypoint(
            ordered: ordered,
            state: updated
        )
        updated.currentWaypointID = currentWaypoint?.id

        guard let waypoint = currentWaypoint,
              let latitude = position.latitude,
              let longitude = position.longitude,
              SnorkelingDomainSupport.isValidCoordinate(latitude: latitude, longitude: longitude) else {
            let snapshot = SnorkelingWaypointNavigationSnapshot(
                waypointID: currentWaypoint?.id,
                waypointName: currentWaypoint?.name,
                waypointCategory: currentWaypoint?.category,
                targetBearingDegrees: nil,
                currentHeadingDegrees: heading.headingDegrees,
                signedAngularDeltaDegrees: nil,
                turnInstruction: .unavailable,
                distanceToTargetMeters: nil,
                gpsPresentationState: position.gpsPresentationState,
                headingQuality: headingQuality(heading: heading, configuration: configuration),
                surfaceSpeedMetersPerSecond: position.surfaceSpeedMetersPerSecond,
                waypointReached: false,
                hasNextWaypoint: hasNextWaypoint(after: currentWaypoint, ordered: ordered, state: updated),
                skippedWaypointIDs: updated.skippedWaypointIDs
            )
            updated.lastWaypointNavigation = snapshot
            return (snapshot, updated)
        }

        let currentCoordinate = (latitude: latitude, longitude: longitude)
        let targetCoordinate = (latitude: waypoint.latitude, longitude: waypoint.longitude)
        let distance = SnorkelingDomainSupport.distanceMeters(from: currentCoordinate, to: targetCoordinate)
        let bearing = SnorkelingDomainSupport.bearingDegrees(from: currentCoordinate, to: targetCoordinate)
        let headingQ = headingQuality(heading: heading, configuration: configuration)
        let reached = waypointReached(
            distanceMeters: distance,
            position: position,
            configuration: configuration
        )

        if reached {
            if !updated.completedWaypointIDs.contains(waypoint.id) {
                updated.completedWaypointIDs.append(waypoint.id)
            }
            if configuration.autoAdvanceToNextWaypoint {
                updated.manualWaypointSelectionID = nil
                updated.currentWaypointID = nextWaypointID(after: waypoint, ordered: ordered, state: updated)
            }
        }

        let permitsPrecise = permitsPreciseTurnGuidance(
            position: position,
            headingQuality: headingQ,
            configuration: configuration
        )
        let signedDelta: Double?
        let instruction: SnorkelingTurnInstruction
        if permitsPrecise, let bearing, let headingDegrees = heading.headingDegrees {
            let delta = SnorkelingDomainSupport.signedAngularDeltaDegrees(heading: headingDegrees, bearing: bearing)
            signedDelta = delta
            instruction = turnInstruction(signedDeltaDegrees: delta, configuration: configuration)
        } else {
            signedDelta = nil
            instruction = .unavailable
        }

        let snapshot = SnorkelingWaypointNavigationSnapshot(
            waypointID: waypoint.id,
            waypointName: waypoint.name,
            waypointCategory: waypoint.category,
            targetBearingDegrees: bearing,
            currentHeadingDegrees: heading.headingDegrees,
            signedAngularDeltaDegrees: signedDelta,
            turnInstruction: instruction,
            distanceToTargetMeters: distance,
            gpsPresentationState: position.gpsPresentationState,
            headingQuality: headingQ,
            surfaceSpeedMetersPerSecond: position.surfaceSpeedMetersPerSecond,
            waypointReached: reached,
            hasNextWaypoint: hasNextWaypoint(after: waypoint, ordered: ordered, state: updated),
            skippedWaypointIDs: updated.skippedWaypointIDs
        )
        updated.lastWaypointNavigation = snapshot
        return (snapshot, updated)
    }

    static func selectWaypoint(id: UUID, state: inout SnorkelingNavigationRuntimeState) {
        state.manualWaypointSelectionID = id
        state.currentWaypointID = id
    }

    static func skipWaypoint(id: UUID, routePlan: SnorkelingRoutePlan?, state: inout SnorkelingNavigationRuntimeState) {
        if !state.skippedWaypointIDs.contains(id) {
            state.skippedWaypointIDs.append(id)
        }
        if state.currentWaypointID == id {
            state.manualWaypointSelectionID = nil
            let ordered = SnorkelingDomainSupport.orderedWaypoints(routePlan?.waypoints ?? [])
            if let waypoint = ordered.first(where: { $0.id == id }) {
                state.currentWaypointID = nextWaypointID(after: waypoint, ordered: ordered, state: state)
            }
        }
    }

    static func reorderRoutePlan(_ routePlan: SnorkelingRoutePlan, state: inout SnorkelingNavigationRuntimeState) {
        let ordered = SnorkelingDomainSupport.orderedWaypoints(routePlan.waypoints)
        state.orderedWaypointIDs = ordered.map(\.id)
        if let current = state.currentWaypointID, !ordered.contains(where: { $0.id == current }) {
            state.currentWaypointID = ordered.first(where: { !state.skippedWaypointIDs.contains($0.id) })?.id
        }
    }

    // MARK: - Private

    private static func resolveCurrentWaypoint(
        ordered: [SnorkelingWaypoint],
        state: SnorkelingNavigationRuntimeState
    ) -> SnorkelingWaypoint? {
        if let manualID = state.manualWaypointSelectionID,
           let manual = ordered.first(where: { $0.id == manualID }) {
            return manual
        }
        if let currentID = state.currentWaypointID,
           let current = ordered.first(where: { $0.id == currentID }),
           !state.skippedWaypointIDs.contains(currentID) {
            return current
        }
        return ordered.first(where: { waypoint in
            !state.skippedWaypointIDs.contains(waypoint.id) && !state.completedWaypointIDs.contains(waypoint.id)
        })
    }

    private static func waypointReached(
        distanceMeters: Double,
        position: SnorkelingNavigationPositionInput,
        configuration: SnorkelingNavigationConfiguration
    ) -> Bool {
        guard distanceMeters <= configuration.waypointReachedRadiusMeters else { return false }
        guard !position.isUnderwater else { return false }
        guard position.gpsQuality == .measured, position.gpsPresentationState == .tracking else { return false }
        return true
    }

    private static func hasNextWaypoint(
        after waypoint: SnorkelingWaypoint?,
        ordered: [SnorkelingWaypoint],
        state: SnorkelingNavigationRuntimeState
    ) -> Bool {
        guard let waypoint else { return false }
        return nextWaypointID(after: waypoint, ordered: ordered, state: state) != nil
    }

    private static func nextWaypointID(
        after waypoint: SnorkelingWaypoint,
        ordered: [SnorkelingWaypoint],
        state: SnorkelingNavigationRuntimeState
    ) -> UUID? {
        guard let index = ordered.firstIndex(where: { $0.id == waypoint.id }) else { return nil }
        let remaining = ordered[(index + 1)...]
        return remaining.first(where: { candidate in
            !state.skippedWaypointIDs.contains(candidate.id) && !state.completedWaypointIDs.contains(candidate.id)
        })?.id
    }

    private static func routePlanWaypointSignature(_ routePlan: SnorkelingRoutePlan) -> String {
        let ordered = SnorkelingDomainSupport.orderedWaypoints(routePlan.waypoints)
        return routePlan.id.uuidString + ":" + ordered.map { "\($0.id.uuidString)-\($0.routeOrder)" }.joined(separator: ",")
    }
}
