import Foundation

enum SnorkelingReturnAdvisor {
    static func captureEntryPointIfNeeded(
        from acceptedFix: SnorkelingGPSAcceptedFix?,
        capturedAt: Date,
        isUnderwater: Bool,
        state: inout SnorkelingNavigationRuntimeState
    ) {
        guard state.entryPoint == nil, !isUnderwater, let acceptedFix else { return }
        guard let entry = SnorkelingEntryPoint(acceptedFix: acceptedFix, capturedAt: capturedAt) else { return }
        state.entryPoint = entry
    }

    static func overrideEntryPoint(_ entry: SnorkelingEntryPoint, state: inout SnorkelingNavigationRuntimeState) {
        guard SnorkelingDomainSupport.isValidCoordinate(latitude: entry.latitude, longitude: entry.longitude) else {
            return
        }
        state.entryPoint = entry
        state.alternateEntryTarget = nil
    }

    static func setAlternateSafeTarget(_ target: SnorkelingEntryPoint?, state: inout SnorkelingNavigationRuntimeState) {
        guard let target else {
            state.alternateEntryTarget = nil
            return
        }
        guard SnorkelingDomainSupport.isValidCoordinate(latitude: target.latitude, longitude: target.longitude) else {
            return
        }
        state.alternateEntryTarget = target
    }

    static func activateManualAdvisor(state: inout SnorkelingNavigationRuntimeState) {
        state.manualReturnAdvisorActive = true
    }

    static func evaluateReturnNavigation(
        state: SnorkelingNavigationRuntimeState,
        position: SnorkelingNavigationPositionInput,
        heading: SnorkelingNavigationHeadingInput,
        sessionElapsedSeconds: TimeInterval,
        batteryFraction: Double?,
        now: Date,
        configuration: SnorkelingReturnAdvisorConfiguration = .default,
        navigationConfiguration: SnorkelingNavigationConfiguration = .default
    ) -> (snapshot: SnorkelingReturnNavigationSnapshot, state: SnorkelingNavigationRuntimeState) {
        var updated = state
        let headingQ = SnorkelingNavigationEngine.headingQuality(heading: heading, configuration: navigationConfiguration)
        let target = updated.alternateEntryTarget ?? updated.entryPoint
        let entryAge = target.map { now.timeIntervalSince($0.capturedAt) }

        guard let target else {
            let snapshot = SnorkelingReturnNavigationSnapshot(
                entryPoint: updated.entryPoint,
                alternateTarget: updated.alternateEntryTarget,
                entryPointAgeSeconds: entryAge,
                distanceToEntryMeters: nil,
                bearingToEntryDegrees: nil,
                currentHeadingDegrees: heading.headingDegrees,
                signedAngularDeltaDegrees: nil,
                turnInstruction: .unavailable,
                advisorReason: advisorReason(
                    state: updated,
                    distanceToTargetMeters: nil,
                    sessionElapsedSeconds: sessionElapsedSeconds,
                    batteryFraction: batteryFraction,
                    configuration: configuration
                ),
                advisorActive: false,
                gpsPresentationState: position.gpsPresentationState,
                headingQuality: headingQ,
                informationalMessageKey: "snorkeling.return.advisor.unavailable"
            )
            updated.lastReturnNavigation = snapshot
            return (snapshot, updated)
        }

        let distance: Double?
        let bearing: Double?
        if let latitude = position.latitude,
           let longitude = position.longitude,
           SnorkelingDomainSupport.isValidCoordinate(latitude: latitude, longitude: longitude) {
            let current = (latitude: latitude, longitude: longitude)
            let entry = (latitude: target.latitude, longitude: target.longitude)
            distance = SnorkelingDomainSupport.distanceMeters(from: current, to: entry)
            bearing = SnorkelingDomainSupport.bearingDegrees(from: current, to: entry)
        } else {
            distance = nil
            bearing = nil
        }

        let reason = advisorReason(
            state: updated,
            distanceToTargetMeters: distance,
            sessionElapsedSeconds: sessionElapsedSeconds,
            batteryFraction: batteryFraction,
            configuration: configuration
        )
        let advisorActive = reason != .none
        let permitsPrecise = SnorkelingNavigationEngine.permitsPreciseTurnGuidance(
            position: position,
            headingQuality: headingQ,
            configuration: navigationConfiguration
        )
        let signedDelta: Double?
        let instruction: SnorkelingTurnInstruction
        if permitsPrecise, let bearing, let headingDegrees = heading.headingDegrees {
            let delta = SnorkelingDomainSupport.signedAngularDeltaDegrees(heading: headingDegrees, bearing: bearing)
            signedDelta = delta
            instruction = SnorkelingNavigationEngine.turnInstruction(
                signedDeltaDegrees: delta,
                configuration: navigationConfiguration
            )
        } else {
            signedDelta = nil
            instruction = .unavailable
        }

        let messageKey = informationalMessageKey(
            reason: reason,
            gpsPresentationState: position.gpsPresentationState,
            headingQuality: headingQ,
            distanceToEntryMeters: distance,
            configuration: configuration
        )

        let snapshot = SnorkelingReturnNavigationSnapshot(
            entryPoint: updated.entryPoint,
            alternateTarget: updated.alternateEntryTarget,
            entryPointAgeSeconds: entryAge,
            distanceToEntryMeters: distance,
            bearingToEntryDegrees: bearing,
            currentHeadingDegrees: heading.headingDegrees,
            signedAngularDeltaDegrees: signedDelta,
            turnInstruction: instruction,
            advisorReason: reason,
            advisorActive: advisorActive,
            gpsPresentationState: position.gpsPresentationState,
            headingQuality: headingQ,
            informationalMessageKey: messageKey
        )
        updated.lastReturnNavigation = snapshot
        return (snapshot, updated)
    }

    // MARK: - Private

    private static func advisorReason(
        state: SnorkelingNavigationRuntimeState,
        distanceToTargetMeters: Double?,
        sessionElapsedSeconds: TimeInterval,
        batteryFraction: Double?,
        configuration: SnorkelingReturnAdvisorConfiguration
    ) -> SnorkelingReturnAdvisorReason {
        if state.manualReturnAdvisorActive {
            return .manualActivation
        }
        if let distanceToTargetMeters,
           distanceToTargetMeters >= configuration.adviseReturnDistanceMeters {
            return .distanceThreshold
        }
        if sessionElapsedSeconds >= configuration.adviseReturnDurationSeconds {
            return .durationThreshold
        }
        if let batteryFraction,
           batteryFraction.isFinite,
           batteryFraction <= configuration.adviseReturnBatteryFraction {
            return .batteryThreshold
        }
        return .none
    }

    private static func informationalMessageKey(
        reason: SnorkelingReturnAdvisorReason,
        gpsPresentationState: SnorkelingGPSPresentationState,
        headingQuality: SnorkelingHeadingQuality,
        distanceToEntryMeters: Double?,
        configuration: SnorkelingReturnAdvisorConfiguration
    ) -> String? {
        if gpsPresentationState == .underwaterUnavailable || gpsPresentationState == .unavailable {
            return "snorkeling.return.gps.unavailable"
        }
        if headingQuality == .stale {
            return "snorkeling.return.heading.stale"
        }
        if gpsPresentationState == .degraded || gpsPresentationState == .stale {
            return "snorkeling.return.gps.degraded"
        }
        switch reason {
        case .none:
            if let distanceToEntryMeters, distanceToEntryMeters <= configuration.entryReachedRadiusMeters {
                return "snorkeling.return.near.entry"
            }
            return nil
        case .distanceThreshold:
            return "snorkeling.return.advisor.distance"
        case .durationThreshold:
            return "snorkeling.return.advisor.duration"
        case .batteryThreshold:
            return "snorkeling.return.advisor.battery"
        case .manualActivation:
            return "snorkeling.return.advisor.manual"
        }
    }
}
