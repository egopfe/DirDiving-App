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
    var gpsQualityBand: SnorkelingWatchGPSPresentationBand?
    var routeProgressPercent: Double?
    var offRouteDistanceMeters: Double?
    var isOffRoute: Bool
    var offRouteWarningPaused: Bool
    var plannedReturnAlertActive: Bool
    var importedRoutePresentation: SnorkelingWatchImportedRoutePresentation
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
    var recoveredSessionAccessibilityLabel: String?
    var returnAdvisorAccessibilityLabel: String?
    var overlayAccessibilityLabel: String?
    var routeProgressText: String
    var offRouteText: String?
    var gpsQualityBandText: String?
    var plannedReturnAlertText: String?
    var routeStatusText: String
    var routeNameText: String?
    var routeRevisionText: String?
    var routePendingBannerText: String?
    var routePlannedSummaryText: String?
    var routeCompactSummaryText: String
    var returnPrimaryActionTitle: String
    var returnPrimaryActionEnabled: Bool
    var returnIsPrimaryAction: Bool
    var precheckSummaryText: String
    var batteryText: String?
    var batteryColorToken: SnorkelingWatchColorToken
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
        let gps = gpsPresentation(
            for: input.gpsPresentationState,
            underwater: input.isUnderwater,
            qualityBand: input.gpsQualityBand
        )
        let startEnabled = canStart(input)
        let turn = turnPresentation(
            instruction: navigationTurnInstruction(for: input, stage: stage),
            headingQuality: navigationHeadingQuality(for: input, stage: stage)
        )
        let navAccent: SnorkelingWatchColorToken = turn.instruction == .onLine ? .green : (turn.instruction == .unavailable ? .secondary : .yellow)
        let hero = heroPresentation(for: input, stage: stage)
        let overlay = resolveOverlay(input, stage: stage)
        let advisorText = returnAdvisorText(input)
        let route = input.importedRoutePresentation
        let battery = SnorkelingWatchReadyPresentationPolicy.batteryPresentation(fraction: input.batteryFraction)
        let routePlannedSummary = routePlannedSummaryText(for: route)
        let routeCompactSummary = SnorkelingWatchRouteSummaryPresentationPolicy.compactSummary(for: route)
        let returnAvailable = SnorkelingWatchReturnPrimaryActionPolicy.isReturnAvailable(returnNavigation: input.returnNavigation)
        let returnPrimaryTitle = SnorkelingWatchReturnPrimaryActionPolicy.returnButtonTitle(isAvailable: returnAvailable)
        let returnIsPrimary = SnorkelingWatchReturnPrimaryActionPolicy.returnIsPrimaryAction(
            isAvailable: returnAvailable,
            isSessionStarted: input.isSessionStarted
        )

        return SnorkelingWatchPresentationOutput(
            stage: stage,
            startEnabled: startEnabled,
            startDisabledReason: startEnabled ? nil : DIRWatchLocalizer.string("snorkeling.ready.sensor_unavailable"),
            headerTitle: headerTitle(for: stage),
            headerSubtitle: headerSubtitle(for: input, stage: stage),
            heroValue: hero.value,
            heroUnit: hero.unit,
            heroAccessibilityLabel: hero.accessibility,
            runtimeText: elapsedTimeText(input.sessionElapsedSeconds),
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
                ? DIRWatchLocalizer.string("mission_mode.a11y.active")
                : DIRWatchLocalizer.string("mission_mode.a11y.inactive"),
            buddyText: input.buddyReminderEnabled
                ? DIRWatchLocalizer.string("snorkeling.buddy.on")
                : DIRWatchLocalizer.string("snorkeling.buddy.off"),
            dipDurationText: elapsedTimeText(input.activeDipElapsedSeconds),
            dipMaxDepthText: "\(Formatters.one(input.activeDipMaxDepthMeters)) m",
            verticalSpeedText: verticalSpeedText(input.verticalSpeedMetersPerSecond),
            dipNumberText: DIRWatchLocalizer.formatted("snorkeling.dip.number", max(1, input.dipCount)),
            waypointNameText: input.waypointNavigation.waypointName?.uppercased() ?? DIRWatchLocalizer.string("snorkeling.nav.no_waypoint"),
            waypointDistanceText: distanceText(input.waypointNavigation.distanceToTargetMeters),
            turnInstructionText: turn.text,
            turnInstructionAccessibility: turn.accessibility,
            bearingDeltaDegrees: bearingDelta(for: input, stage: stage),
            headingDegrees: navigationHeading(for: input, stage: stage),
            navigationAccentToken: navAccent,
            returnDistanceText: distanceText(input.returnNavigation.distanceToEntryMeters),
            returnAdvisorText: advisorText,
            returnBearingText: bearingText(input.returnNavigation.bearingToEntryDegrees),
            showReturnAdvisor: input.returnNavigation.advisorActive,
            markerCategoryLabels: SnorkelingMarkerCategory.allCases.map(markerCategoryLabel),
            selectedMarkerCategoryIndex: SnorkelingMarkerCategory.allCases.firstIndex(of: input.selectedMarkerCategory) ?? 0,
            saveMarkerEnabled: input.isSessionStarted && input.phase != .ended,
            summaryTotalTimeText: elapsedTimeText(input.sessionElapsedSeconds),
            summaryDistanceText: "\(Formatters.zero(input.accumulatedDistanceMeters)) m",
            summaryMaxDepthText: "\(Formatters.one(input.sessionMaxDepthMeters)) m",
            summaryUnderwaterTimeText: elapsedTimeText(input.underwaterTimeSeconds),
            summaryDipCountText: "\(input.dipCount)",
            summaryMarkerCountText: "\(input.markerCount)",
            summaryAverageSpeedText: "\(Formatters.one(input.averageSpeedMetersPerSecond)) m/s",
            summaryMinTemperatureText: temperatureText(input.minimumWaterTemperatureCelsius),
            summaryFooterText: summaryFooter(input.sessionSaveState),
            overlay: overlay,
            showsLiveGPSCoordinates: !input.isUnderwater && input.gpsPresentationState == .tracking,
            animationsEnabled: input.animationsEnabled,
            recoveredSessionBannerText: input.isRecoveredSession
                ? DIRWatchLocalizer.string("snorkeling.recovery.banner")
                : nil,
            recoveryWarningText: input.recoveryWarning,
            recoveredSessionAccessibilityLabel: input.isRecoveredSession
                ? DIRWatchLocalizer.string("snorkeling.a11y.recovered_session")
                : nil,
            returnAdvisorAccessibilityLabel: advisorText == nil
                ? nil
                : DIRWatchLocalizer.string("snorkeling.a11y.return_advisor"),
            overlayAccessibilityLabel: overlayAccessibilityLabel(for: overlay),
            routeProgressText: routeProgressText(input.routeProgressPercent),
            offRouteText: offRouteText(input),
            gpsQualityBandText: input.gpsQualityBand.map { DIRWatchLocalizer.string($0.localizationKey) },
            plannedReturnAlertText: input.plannedReturnAlertActive
                ? DIRWatchLocalizer.string("snorkeling.watch.time_to_return")
                : nil,
            routeStatusText: SnorkelingWatchReadyPresentationPolicy.routeStatusText(for: route),
            routeNameText: route.routeName,
            routeRevisionText: route.revision.map { "r\($0)" },
            routePendingBannerText: SnorkelingWatchReadyPresentationPolicy.routePendingBannerText(for: route),
            routePlannedSummaryText: routePlannedSummary,
            routeCompactSummaryText: routeCompactSummary,
            returnPrimaryActionTitle: returnPrimaryTitle,
            returnPrimaryActionEnabled: returnAvailable,
            returnIsPrimaryAction: returnIsPrimary,
            precheckSummaryText: SnorkelingWatchReadyPresentationPolicy.precheckSummary(
                gpsStatusText: gps.text,
                gpsIsHealthy: SnorkelingWatchReadyPresentationPolicy.gpsIsHealthy(
                    gpsState: input.gpsPresentationState,
                    qualityBand: input.gpsQualityBand
                ),
                depthSensorHealthy: SnorkelingWatchReadyPresentationPolicy.depthSensorIsHealthy(
                    depthState: input.depthPresentationState,
                    sensorHealth: input.sensorHealth
                ),
                entryCaptured: input.entryPointCaptured,
                route: route,
                buddyEnabled: input.buddyReminderEnabled
            ),
            batteryText: battery.text,
            batteryColorToken: battery.colorToken
        )
    }

    private static func routePlannedSummaryText(for route: SnorkelingWatchImportedRoutePresentation) -> String? {
        guard route.status == .ready || route.status == .pending else { return nil }
        var parts: [String] = []
        if let distance = route.plannedDistanceMeters, distance.isFinite, distance > 0 {
            parts.append("\(Formatters.zero(distance)) m")
        }
        if let duration = route.plannedDurationSeconds, duration.isFinite, duration > 0 {
            parts.append(elapsedTimeText(duration))
        }
        guard !parts.isEmpty else { return nil }
        return parts.joined(separator: " · ")
    }

    private static func overlayAccessibilityLabel(for overlay: SnorkelingWatchOverlayPresentation?) -> String? {
        switch overlay {
        case .sensorDegraded:
            return DIRWatchLocalizer.string("snorkeling.overlay.sensor_degraded")
        case .gpsDegradedUnderwater:
            return DIRWatchLocalizer.string("snorkeling.overlay.gps_underwater")
        case .operational(let operational):
            return DIRWatchLocalizer.string(operational.titleKey)
        case nil:
            return nil
        }
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
            return (DIRWatchLocalizer.string("snorkeling.ready.title"), nil, DIRWatchLocalizer.string("snorkeling.ready.title"))
        case .surfaceDashboard:
            return (elapsedTimeText(input.sessionElapsedSeconds), DIRWatchLocalizer.string("snorkeling.metric.runtime"), DIRWatchLocalizer.string("snorkeling.a11y.runtime"))
        case .dipInProgress:
            let depth = input.currentDepthMeters ?? 0
            return ("\(Formatters.one(depth))", "m", DIRWatchLocalizer.formatted("snorkeling.a11y.depth", Formatters.one(depth)))
        case .navigation:
            return (distanceText(input.waypointNavigation.distanceToTargetMeters), "m", DIRWatchLocalizer.string("snorkeling.a11y.waypoint_distance"))
        case .returnToEntry:
            return (distanceText(input.returnNavigation.distanceToEntryMeters), "m", DIRWatchLocalizer.string("snorkeling.a11y.return_distance"))
        case .saveMarker:
            return (markerCategoryLabel(input.selectedMarkerCategory), nil, markerCategoryLabel(input.selectedMarkerCategory))
        case .sessionSummary:
            return (elapsedTimeText(input.sessionElapsedSeconds), nil, DIRWatchLocalizer.string("snorkeling.summary.title"))
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
            let text = DIRWatchLocalizer.string("snorkeling.nav.gps_unavailable")
            return (.unavailable, text, text)
        }
        let text: String
        let accessibility: String
        switch instruction {
        case .turnLeft:
            text = DIRWatchLocalizer.string("snorkeling.nav.turn_left")
            accessibility = DIRWatchLocalizer.string("snorkeling.a11y.turn_left")
        case .turnRight:
            text = DIRWatchLocalizer.string("snorkeling.nav.turn_right")
            accessibility = DIRWatchLocalizer.string("snorkeling.a11y.turn_right")
        case .onLine:
            text = DIRWatchLocalizer.string("snorkeling.nav.on_line")
            accessibility = DIRWatchLocalizer.string("snorkeling.a11y.on_line")
        case .unavailable:
            text = DIRWatchLocalizer.string("snorkeling.nav.gps_unavailable")
            accessibility = text
        }
        return (instruction, text, accessibility)
    }

    // MARK: - Labels

    private static func headerTitle(for stage: SnorkelingWatchStage) -> String {
        switch stage {
        case .ready: return DIRWatchLocalizer.string("snorkeling.ready.header")
        case .surfaceDashboard: return DIRWatchLocalizer.string("snorkeling.surface.header")
        case .dipInProgress: return DIRWatchLocalizer.string("snorkeling.dip.header")
        case .navigation: return DIRWatchLocalizer.string("snorkeling.nav.header")
        case .returnToEntry: return DIRWatchLocalizer.string("snorkeling.return.header")
        case .saveMarker: return DIRWatchLocalizer.string("snorkeling.marker.header")
        case .sessionSummary: return DIRWatchLocalizer.string("snorkeling.summary.header")
        }
    }

    private static func headerSubtitle(for input: SnorkelingWatchPresentationInput, stage: SnorkelingWatchStage) -> String {
        if input.isRecoveredSession {
            return DIRWatchLocalizer.string("snorkeling.recovery.subtitle")
        }
        if input.phase == .paused { return DIRWatchLocalizer.string("snorkeling.phase.paused") }
        if input.phase == .sensorDegraded || input.sensorHealth == .manualFallback {
            return DIRWatchLocalizer.string("snorkeling.sensor.degraded")
        }
        return input.phase.rawValue.uppercased()
    }

    private static func gpsPresentation(
        for state: SnorkelingGPSPresentationState,
        underwater: Bool,
        qualityBand: SnorkelingWatchGPSPresentationBand?
    ) -> (text: String, color: SnorkelingWatchColorToken) {
        if underwater {
            return (DIRWatchLocalizer.string("snorkeling.gps.underwater"), .secondary)
        }
        if let qualityBand {
            let color: SnorkelingWatchColorToken
            switch qualityBand {
            case .good: color = .green
            case .medium: color = .yellow
            case .poor: color = .orange
            case .lost: color = .red
            }
            return (DIRWatchLocalizer.string(qualityBand.localizationKey), color)
        }
        switch state {
        case .tracking:
            return (DIRWatchLocalizer.string("snorkeling.gps.tracking"), .green)
        case .degraded:
            return (DIRWatchLocalizer.string("snorkeling.gps.degraded"), .orange)
        case .stale:
            return (DIRWatchLocalizer.string("snorkeling.gps.stale"), .yellow)
        case .unavailable, .underwaterUnavailable:
            return (DIRWatchLocalizer.string("snorkeling.gps.unavailable"), .red)
        }
    }

    private static func routeProgressText(_ percent: Double?) -> String {
        guard let percent, percent.isFinite else {
            return "\(DIRWatchLocalizer.string("snorkeling.watch.route_progress")) —"
        }
        return "\(DIRWatchLocalizer.string("snorkeling.watch.route_progress")) \(Int(percent.rounded()))%"
    }

    private static func offRouteText(_ input: SnorkelingWatchPresentationInput) -> String? {
        if input.offRouteWarningPaused {
            return DIRWatchLocalizer.string("snorkeling.watch.off_route_paused")
        }
        guard input.isOffRoute else { return nil }
        let distance = input.offRouteDistanceMeters.map { Formatters.zero($0) } ?? "--"
        return "\(DIRWatchLocalizer.string("snorkeling.watch.off_route")) \(distance) m"
    }

    private static func depthSensorText(
        _ state: SnorkelingDepthPresentationState,
        health: SnorkelingSensorHealth
    ) -> String {
        if health == .manualFallback { return DIRWatchLocalizer.string("snorkeling.sensor.manual") }
        switch state {
        case .valid:
            return DIRWatchLocalizer.string("snorkeling.sensor.ok")
        case .degraded:
            return DIRWatchLocalizer.string("snorkeling.sensor.degraded")
        case .unavailable:
            return DIRWatchLocalizer.string("snorkeling.sensor.unavailable")
        }
    }

    private static func entryPointText(_ captured: Bool) -> String {
        captured
            ? DIRWatchLocalizer.string("snorkeling.entry.set")
            : DIRWatchLocalizer.string("snorkeling.entry.auto")
    }

    private static func durationLimitText(_ seconds: TimeInterval?) -> String {
        guard let seconds, seconds.isFinite, seconds > 0 else { return "--" }
        return elapsedTimeText(seconds)
    }

    private static func elapsedTimeText(_ interval: TimeInterval) -> String {
        let total = max(0, Int(interval))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0 { return String(format: "%02d:%02d:%02d", hours, minutes, seconds) }
        return String(format: "%02d:%02d", minutes, seconds)
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
        case .marineLife: return DIRWatchLocalizer.string("snorkeling.marker.marine_life")
        case .reef: return DIRWatchLocalizer.string("snorkeling.marker.reef")
        case .wreck: return DIRWatchLocalizer.string("snorkeling.marker.wreck")
        case .photoSpot: return DIRWatchLocalizer.string("snorkeling.marker.photo")
        case .buoy: return DIRWatchLocalizer.string("snorkeling.marker.buoy")
        case .custom: return DIRWatchLocalizer.string("snorkeling.marker.custom")
        }
    }

    private static func returnAdvisorText(_ input: SnorkelingWatchPresentationInput) -> String? {
        guard input.returnNavigation.advisorActive else { return nil }
        if let key = input.returnNavigation.informationalMessageKey {
            return DIRWatchLocalizer.string(key)
        }
        return DIRWatchLocalizer.string("snorkeling.return.advised")
    }

    private static func summaryFooter(_ state: SnorkelingWatchSessionSaveState) -> String {
        switch state {
        case .notSaved: return DIRWatchLocalizer.string("snorkeling.summary.not_saved")
        case .saved: return DIRWatchLocalizer.string("snorkeling.summary.saved")
        case .syncPending: return DIRWatchLocalizer.string("snorkeling.summary.sync_pending")
        case .failed: return DIRWatchLocalizer.string("snorkeling.summary.save_failed")
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
