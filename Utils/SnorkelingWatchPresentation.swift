import Foundation

enum SnorkelingWatchStage: String, Equatable, CaseIterable {
    case ready
    case surfaceDashboard
    case dipInProgress
    case navigation
    case returnToEntry
    case saveMarker
    case sessionSummary
}

enum SnorkelingWatchOverlayPresentation: Equatable {
    case operational(SnorkelingOperationalOverlay)
    case sensorDegraded
    case gpsDegradedUnderwater
}

struct SnorkelingWatchPresentationInput: Equatable {
    var phase: SnorkelingLifecyclePhase
    var isSessionArmed: Bool
    var isSessionStarted: Bool
    var showSessionSummary: Bool
    var showSaveMarker: Bool
    var currentDepthMeters: Double?
    var currentTemperatureCelsius: Double?
    var verticalSpeedMetersPerSecond: Double
    var sessionElapsedSeconds: TimeInterval
    var surfaceElapsedSeconds: TimeInterval
    var underwaterTimeSeconds: TimeInterval
    var activeDipElapsedSeconds: TimeInterval
    var dipCount: Int
    var sessionMaxDepthMeters: Double
    var activeDipMaxDepthMeters: Double
    var accumulatedDistanceMeters: Double
    var averageSpeedMetersPerSecond: Double
    var gpsPresentationState: SnorkelingGPSPresentationState
    var depthPresentationState: SnorkelingDepthPresentationState
    var sensorHealth: SnorkelingSensorHealth
    var entryPointCaptured: Bool
    var entryDistanceMeters: Double?
    var targetDurationSeconds: TimeInterval?
    var maxDistanceMeters: Double?
    var missionModeEnabled: Bool
    var hapticsEnabled: Bool
    var buddyReminderEnabled: Bool
    var batteryFraction: Double?
    var markerCount: Int
    var minimumWaterTemperatureCelsius: Double?
    var waypointNavigation: SnorkelingWaypointNavigationSnapshot
    var returnNavigation: SnorkelingReturnNavigationSnapshot
    var activeOverlays: [SnorkelingOperationalOverlay]
    var isUnderwater: Bool
    var animationsEnabled: Bool
    var selectedMarkerCategory: SnorkelingMarkerCategory
    var markerPositionQualityLabel: String
    var markerDistanceFromEntryText: String?
    var sessionSaveState: SnorkelingWatchSessionSaveState
    var isRecoveredSession: Bool
    var recoveryWarning: String?
}

enum SnorkelingWatchSessionSaveState: String, Equatable {
    case notSaved
    case saved
    case syncPending
    case failed
}

struct SnorkelingWatchPresentationOutput: Equatable {
    var stage: SnorkelingWatchStage
    var startEnabled: Bool
    var startDisabledReason: String?
    var headerTitle: String
    var headerSubtitle: String
    var heroValue: String
    var heroUnit: String?
    var heroAccessibilityLabel: String
    var runtimeText: String
    var distanceText: String
    var surfaceSpeedText: String
    var waterTemperatureText: String
    var dipCountText: String
    var entryDistanceText: String
    var gpsStatusText: String
    var gpsStatusColorToken: SnorkelingWatchColorToken
    var depthSensorText: String
    var entryPointText: String
    var targetDurationText: String
    var maxDistanceText: String
    var missionModeText: String
    var buddyText: String
    var dipDurationText: String
    var dipMaxDepthText: String
    var verticalSpeedText: String
    var dipNumberText: String
    var waypointNameText: String
    var waypointDistanceText: String
    var turnInstructionText: String
    var turnInstructionAccessibility: String
    var bearingDeltaDegrees: Double?
    var headingDegrees: Double?
    var navigationAccentToken: SnorkelingWatchColorToken
    var returnDistanceText: String
    var returnAdvisorText: String?
    var returnBearingText: String
    var showReturnAdvisor: Bool
    var markerCategoryLabels: [String]
    var selectedMarkerCategoryIndex: Int
    var saveMarkerEnabled: Bool
    var summaryTotalTimeText: String
    var summaryDistanceText: String
    var summaryMaxDepthText: String
    var summaryUnderwaterTimeText: String
    var summaryDipCountText: String
    var summaryMarkerCountText: String
    var summaryAverageSpeedText: String
    var summaryMinTemperatureText: String
    var summaryFooterText: String
    var overlay: SnorkelingWatchOverlayPresentation?
    var showsLiveGPSCoordinates: Bool
    var animationsEnabled: Bool
    var recoveredSessionBannerText: String?
    var recoveryWarningText: String?
}

enum SnorkelingWatchColorToken: String, Equatable {
    case primary
    case blue
    case green
    case yellow
    case orange
    case red
    case secondary
}

enum SnorkelingWatchPresentation {
    static func make(_ input: SnorkelingWatchPresentationInput) -> SnorkelingWatchPresentationOutput {
        let stage = resolveStage(input)
        let gps = gpsPresentation(for: input.gpsPresentationState, underwater: input.isUnderwater)
        let startEnabled = canStart(input)
        let turn = turnPresentation(
            instruction: navigationTurnInstruction(for: input, stage: stage),
            headingQuality: navigationHeadingQuality(for: input, stage: stage)
        )
        let navAccent: SnorkelingWatchColorToken = turn.instruction == .onLine ? .green : (turn.instruction == .unavailable ? .secondary : .yellow)
        let hero = heroPresentation(for: input, stage: stage)
        let overlay = resolveOverlay(input, stage: stage)

        return SnorkelingWatchPresentationOutput(
            stage: stage,
            startEnabled: startEnabled,
            startDisabledReason: startEnabled ? nil : String(localized: "snorkeling.ready.sensor_unavailable"),
            headerTitle: headerTitle(for: stage),
            headerSubtitle: headerSubtitle(for: input, stage: stage),
            heroValue: hero.value,
            heroUnit: hero.unit,
            heroAccessibilityLabel: hero.accessibility,
            runtimeText: Formatters.time(input.sessionElapsedSeconds),
            distanceText: "\(Formatters.zero(input.accumulatedDistanceMeters)) m",
            surfaceSpeedText: "\(Formatters.one(input.averageSpeedMetersPerSecond)) m/s",
            waterTemperatureText: temperatureText(input.currentTemperatureCelsius),
            dipCountText: "\(input.dipCount)",
            entryDistanceText: entryDistanceText(input.entryDistanceMeters),
            gpsStatusText: gps.text,
            gpsStatusColorToken: gps.color,
            depthSensorText: depthSensorText(input.depthPresentationState, health: input.sensorHealth),
            entryPointText: entryPointText(input.entryPointCaptured),
            targetDurationText: durationLimitText(input.targetDurationSeconds),
            maxDistanceText: distanceLimitText(input.maxDistanceMeters),
            missionModeText: input.missionModeEnabled
                ? String(localized: "mission_mode.a11y.active")
                : String(localized: "mission_mode.a11y.inactive"),
            buddyText: input.buddyReminderEnabled
                ? String(localized: "snorkeling.buddy.on")
                : String(localized: "snorkeling.buddy.off"),
            dipDurationText: Formatters.time(input.activeDipElapsedSeconds),
            dipMaxDepthText: "\(Formatters.one(input.activeDipMaxDepthMeters)) m",
            verticalSpeedText: verticalSpeedText(input.verticalSpeedMetersPerSecond),
            dipNumberText: String(format: String(localized: "snorkeling.dip.number"), max(1, input.dipCount)),
            waypointNameText: input.waypointNavigation.waypointName?.uppercased() ?? String(localized: "snorkeling.nav.no_waypoint"),
            waypointDistanceText: distanceText(input.waypointNavigation.distanceToTargetMeters),
            turnInstructionText: turn.text,
            turnInstructionAccessibility: turn.accessibility,
            bearingDeltaDegrees: bearingDelta(for: input, stage: stage),
            headingDegrees: navigationHeading(for: input, stage: stage),
            navigationAccentToken: navAccent,
            returnDistanceText: distanceText(input.returnNavigation.distanceToEntryMeters),
            returnAdvisorText: returnAdvisorText(input),
            returnBearingText: bearingText(input.returnNavigation.bearingToEntryDegrees),
            showReturnAdvisor: input.returnNavigation.advisorActive,
            markerCategoryLabels: SnorkelingMarkerCategory.allCases.map(markerCategoryLabel),
            selectedMarkerCategoryIndex: SnorkelingMarkerCategory.allCases.firstIndex(of: input.selectedMarkerCategory) ?? 0,
            saveMarkerEnabled: input.isSessionStarted && input.phase != .ended,
            summaryTotalTimeText: Formatters.time(input.sessionElapsedSeconds),
            summaryDistanceText: "\(Formatters.zero(input.accumulatedDistanceMeters)) m",
            summaryMaxDepthText: "\(Formatters.one(input.sessionMaxDepthMeters)) m",
            summaryUnderwaterTimeText: Formatters.time(input.underwaterTimeSeconds),
            summaryDipCountText: "\(input.dipCount)",
            summaryMarkerCountText: "\(input.markerCount)",
            summaryAverageSpeedText: "\(Formatters.one(input.averageSpeedMetersPerSecond)) m/s",
            summaryMinTemperatureText: temperatureText(input.minimumWaterTemperatureCelsius),
            summaryFooterText: summaryFooter(input.sessionSaveState),
            overlay: overlay,
            showsLiveGPSCoordinates: !input.isUnderwater && input.gpsPresentationState == .tracking,
            animationsEnabled: input.animationsEnabled,
            recoveredSessionBannerText: input.isRecoveredSession
                ? String(localized: "snorkeling.recovery.banner")
                : nil,
            recoveryWarningText: input.recoveryWarning
        )
    }

    // MARK: - Stage

    private static func resolveStage(_ input: SnorkelingWatchPresentationInput) -> SnorkelingWatchStage {
        if input.showSessionSummary || input.phase == .ended {
            return .sessionSummary
        }
        if input.showSaveMarker, input.isSessionStarted {
            return .saveMarker
        }
        if !input.isSessionStarted {
            return .ready
        }
        switch input.phase {
        case .navigation:
            return .navigation
        case .returnMode:
            return .returnToEntry
        case .dipping, .resurfacing:
            return .dipInProgress
        case .surfaceActive, .recovered, .paused, .sensorDegraded, .ready:
            return .surfaceDashboard
        case .idle, .ended:
            return input.isSessionStarted ? .surfaceDashboard : .ready
        }
    }

    private static func canStart(_ input: SnorkelingWatchPresentationInput) -> Bool {
        guard input.depthPresentationState != .unavailable else { return false }
        guard input.sensorHealth != .manualFallback || input.isSessionArmed else { return true }
        return input.sensorHealth != .manualFallback
    }

    // MARK: - Hero

    private static func heroPresentation(
        for input: SnorkelingWatchPresentationInput,
        stage: SnorkelingWatchStage
    ) -> (value: String, unit: String?, accessibility: String) {
        switch stage {
        case .ready:
            return (String(localized: "snorkeling.ready.title"), nil, String(localized: "snorkeling.ready.title"))
        case .surfaceDashboard:
            return (Formatters.time(input.sessionElapsedSeconds), String(localized: "snorkeling.metric.runtime"), String(localized: "snorkeling.a11y.runtime"))
        case .dipInProgress:
            let depth = input.currentDepthMeters ?? 0
            return ("\(Formatters.one(depth))", "m", String(format: String(localized: "snorkeling.a11y.depth"), Formatters.one(depth)))
        case .navigation:
            return (distanceText(input.waypointNavigation.distanceToTargetMeters), "m", String(localized: "snorkeling.a11y.waypoint_distance"))
        case .returnToEntry:
            return (distanceText(input.returnNavigation.distanceToEntryMeters), "m", String(localized: "snorkeling.a11y.return_distance"))
        case .saveMarker:
            return (markerCategoryLabel(input.selectedMarkerCategory), nil, markerCategoryLabel(input.selectedMarkerCategory))
        case .sessionSummary:
            return (Formatters.time(input.sessionElapsedSeconds), nil, String(localized: "snorkeling.summary.title"))
        }
    }

    // MARK: - Navigation / return

    private static func navigationTurnInstruction(
        for input: SnorkelingWatchPresentationInput,
        stage: SnorkelingWatchStage
    ) -> SnorkelingTurnInstruction {
        switch stage {
        case .navigation:
            return input.waypointNavigation.turnInstruction
        case .returnToEntry:
            return input.returnNavigation.turnInstruction
        default:
            return .unavailable
        }
    }

    private static func navigationHeadingQuality(
        for input: SnorkelingWatchPresentationInput,
        stage: SnorkelingWatchStage
    ) -> SnorkelingHeadingQuality {
        switch stage {
        case .navigation:
            return input.waypointNavigation.headingQuality
        case .returnToEntry:
            return input.returnNavigation.headingQuality
        default:
            return .unavailable
        }
    }

    private static func bearingDelta(for input: SnorkelingWatchPresentationInput, stage: SnorkelingWatchStage) -> Double? {
        switch stage {
        case .navigation:
            return input.waypointNavigation.signedAngularDeltaDegrees
        case .returnToEntry:
            return input.returnNavigation.signedAngularDeltaDegrees
        default:
            return nil
        }
    }

    private static func navigationHeading(for input: SnorkelingWatchPresentationInput, stage: SnorkelingWatchStage) -> Double? {
        switch stage {
        case .navigation:
            return input.waypointNavigation.currentHeadingDegrees
        case .returnToEntry:
            return input.returnNavigation.currentHeadingDegrees
        default:
            return nil
        }
    }

    private static func turnPresentation(
        instruction: SnorkelingTurnInstruction,
        headingQuality: SnorkelingHeadingQuality
    ) -> (instruction: SnorkelingTurnInstruction, text: String, accessibility: String) {
        if headingQuality == .unavailable || instruction == .unavailable {
            let text = String(localized: "snorkeling.nav.gps_unavailable")
            return (.unavailable, text, text)
        }
        let text: String
        let accessibility: String
        switch instruction {
        case .turnLeft:
            text = String(localized: "snorkeling.nav.turn_left")
            accessibility = String(localized: "snorkeling.a11y.turn_left")
        case .turnRight:
            text = String(localized: "snorkeling.nav.turn_right")
            accessibility = String(localized: "snorkeling.a11y.turn_right")
        case .onLine:
            text = String(localized: "snorkeling.nav.on_line")
            accessibility = String(localized: "snorkeling.a11y.on_line")
        case .unavailable:
            text = String(localized: "snorkeling.nav.gps_unavailable")
            accessibility = text
        }
        return (instruction, text, accessibility)
    }

    // MARK: - Labels

    private static func headerTitle(for stage: SnorkelingWatchStage) -> String {
        switch stage {
        case .ready: return String(localized: "snorkeling.ready.header")
        case .surfaceDashboard: return String(localized: "snorkeling.surface.header")
        case .dipInProgress: return String(localized: "snorkeling.dip.header")
        case .navigation: return String(localized: "snorkeling.nav.header")
        case .returnToEntry: return String(localized: "snorkeling.return.header")
        case .saveMarker: return String(localized: "snorkeling.marker.header")
        case .sessionSummary: return String(localized: "snorkeling.summary.header")
        }
    }

    private static func headerSubtitle(for input: SnorkelingWatchPresentationInput, stage: SnorkelingWatchStage) -> String {
        if input.isRecoveredSession {
            return String(localized: "snorkeling.recovery.subtitle")
        }
        if input.phase == .paused { return String(localized: "snorkeling.phase.paused") }
        if input.phase == .sensorDegraded || input.sensorHealth == .manualFallback {
            return String(localized: "snorkeling.sensor.degraded")
        }
        return input.phase.rawValue.uppercased()
    }

    private static func gpsPresentation(
        for state: SnorkelingGPSPresentationState,
        underwater: Bool
    ) -> (text: String, color: SnorkelingWatchColorToken) {
        if underwater {
            return (String(localized: "snorkeling.gps.underwater"), .secondary)
        }
        switch state {
        case .tracking:
            return (String(localized: "snorkeling.gps.tracking"), .green)
        case .degraded:
            return (String(localized: "snorkeling.gps.degraded"), .orange)
        case .stale:
            return (String(localized: "snorkeling.gps.stale"), .yellow)
        case .unavailable, .underwaterUnavailable:
            return (String(localized: "snorkeling.gps.unavailable"), .red)
        }
    }

    private static func depthSensorText(
        _ state: SnorkelingDepthPresentationState,
        health: SnorkelingSensorHealth
    ) -> String {
        if health == .manualFallback { return String(localized: "snorkeling.sensor.manual") }
        switch state {
        case .valid:
            return String(localized: "snorkeling.sensor.ok")
        case .degraded:
            return String(localized: "snorkeling.sensor.degraded")
        case .unavailable:
            return String(localized: "snorkeling.sensor.unavailable")
        }
    }

    private static func entryPointText(_ captured: Bool) -> String {
        captured
            ? String(localized: "snorkeling.entry.set")
            : String(localized: "snorkeling.entry.auto")
    }

    private static func durationLimitText(_ seconds: TimeInterval?) -> String {
        guard let seconds, seconds.isFinite, seconds > 0 else { return "--" }
        return Formatters.time(seconds)
    }

    private static func distanceLimitText(_ meters: Double?) -> String {
        guard let meters, meters.isFinite, meters > 0 else { return "--" }
        return "\(Formatters.zero(meters)) m"
    }

    private static func entryDistanceText(_ meters: Double?) -> String {
        guard let meters, meters.isFinite else { return "--" }
        return "\(Formatters.zero(meters)) m"
    }

    private static func distanceText(_ meters: Double?) -> String {
        guard let meters, meters.isFinite else { return "--" }
        return "\(Formatters.zero(meters))"
    }

    private static func bearingText(_ degrees: Double?) -> String {
        guard let degrees, degrees.isFinite else { return "--" }
        return "\(Formatters.zero(degrees))\u{00B0}"
    }

    private static func temperatureText(_ celsius: Double?) -> String {
        guard let celsius, celsius.isFinite else { return "--" }
        return "\(Formatters.one(celsius))°"
    }

    private static func verticalSpeedText(_ speed: Double) -> String {
        let arrow = speed > 0.05 ? "↑" : (speed < -0.05 ? "↓" : "→")
        return "\(arrow) \(Formatters.one(abs(speed)))"
    }

    private static func markerCategoryLabel(_ category: SnorkelingMarkerCategory) -> String {
        switch category {
        case .marineLife: return String(localized: "snorkeling.marker.marine_life")
        case .reef: return String(localized: "snorkeling.marker.reef")
        case .wreck: return String(localized: "snorkeling.marker.wreck")
        case .photoSpot: return String(localized: "snorkeling.marker.photo")
        case .buoy: return String(localized: "snorkeling.marker.buoy")
        case .custom: return String(localized: "snorkeling.marker.custom")
        }
    }

    private static func returnAdvisorText(_ input: SnorkelingWatchPresentationInput) -> String? {
        guard input.returnNavigation.advisorActive else { return nil }
        if let key = input.returnNavigation.informationalMessageKey {
            return String(localized: String.LocalizationValue(key))
        }
        return String(localized: "snorkeling.return.advised")
    }

    private static func summaryFooter(_ state: SnorkelingWatchSessionSaveState) -> String {
        switch state {
        case .notSaved: return String(localized: "snorkeling.summary.not_saved")
        case .saved: return String(localized: "snorkeling.summary.saved")
        case .syncPending: return String(localized: "snorkeling.summary.sync_pending")
        case .failed: return String(localized: "snorkeling.summary.save_failed")
        }
    }

    private static func resolveOverlay(
        _ input: SnorkelingWatchPresentationInput,
        stage: SnorkelingWatchStage
    ) -> SnorkelingWatchOverlayPresentation? {
        if input.sensorHealth == .degraded || input.phase == .sensorDegraded {
            return .sensorDegraded
        }
        if input.isUnderwater,
           input.gpsPresentationState == .unavailable || input.gpsPresentationState == .underwaterUnavailable {
            return .gpsDegradedUnderwater
        }
        if let overlay = input.activeOverlays.last {
            return .operational(overlay)
        }
        return nil
    }
}
