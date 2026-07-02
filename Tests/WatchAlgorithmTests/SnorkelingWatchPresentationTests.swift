import XCTest

final class SnorkelingWatchPresentationTests: XCTestCase {
    func testReadyStageWhenSessionNotStarted() {
        let output = SnorkelingWatchPresentation.make(baseInput(isSessionStarted: false))
        XCTAssertEqual(output.stage, .ready)
        XCTAssertTrue(output.startEnabled)
    }

    func testSurfaceDashboardWhenSessionActiveOnSurface() {
        let output = SnorkelingWatchPresentation.make(
            baseInput(isSessionStarted: true, phase: .surfaceActive, currentDepthMeters: 0.1)
        )
        XCTAssertEqual(output.stage, .surfaceDashboard)
        XCTAssertEqual(output.heroValue, output.runtimeText)
    }

    func testDipStageWhenSubmerged() {
        let output = SnorkelingWatchPresentation.make(
            baseInput(isSessionStarted: true, phase: .dipping, currentDepthMeters: 3.4)
        )
        XCTAssertEqual(output.stage, .dipInProgress)
        XCTAssertEqual(output.heroValue, "3.4")
        XCTAssertFalse(output.showsLiveGPSCoordinates)
    }

    func testNavigationStageUsesTurnInstruction() {
        var input = baseInput(isSessionStarted: true, phase: .navigation)
        input.waypointNavigation = SnorkelingWaypointNavigationSnapshot(
            waypointID: UUID(),
            waypointName: "Reef",
            waypointCategory: .reef,
            targetBearingDegrees: 90,
            currentHeadingDegrees: 70,
            signedAngularDeltaDegrees: -20,
            turnInstruction: .turnLeft,
            distanceToTargetMeters: 120,
            gpsPresentationState: .tracking,
            headingQuality: .valid,
            surfaceSpeedMetersPerSecond: 0.8,
            waypointReached: false,
            hasNextWaypoint: true,
            skippedWaypointIDs: []
        )
        let output = SnorkelingWatchPresentation.make(input)
        XCTAssertEqual(output.stage, .navigation)
        XCTAssertEqual(output.turnInstructionText, DIRWatchLocalizer.string("snorkeling.nav.turn_left"))
        XCTAssertEqual(output.turnInstructionAccessibility, DIRWatchLocalizer.string("snorkeling.a11y.turn_left"))
    }

    func testReturnStageShowsAdvisorLine() {
        var input = baseInput(isSessionStarted: true, phase: .returnMode)
        input.returnNavigation = SnorkelingReturnNavigationSnapshot(
            entryPoint: nil,
            alternateTarget: nil,
            entryPointAgeSeconds: 120,
            distanceToEntryMeters: 240,
            bearingToEntryDegrees: 270,
            currentHeadingDegrees: 250,
            signedAngularDeltaDegrees: -20,
            turnInstruction: .turnLeft,
            advisorReason: .distanceThreshold,
            advisorActive: true,
            gpsPresentationState: .tracking,
            headingQuality: .valid,
            informationalMessageKey: nil
        )
        let output = SnorkelingWatchPresentation.make(input)
        XCTAssertEqual(output.stage, .returnToEntry)
        XCTAssertTrue(output.showReturnAdvisor)
        XCTAssertEqual(output.returnAdvisorText, DIRWatchLocalizer.string("snorkeling.return.advised"))
    }

    func testSaveMarkerStageWhenRequested() {
        let output = SnorkelingWatchPresentation.make(
            baseInput(isSessionStarted: true, phase: .surfaceActive, showSaveMarker: true)
        )
        XCTAssertEqual(output.stage, .saveMarker)
        XCTAssertTrue(output.saveMarkerEnabled)
    }

    func testSessionSummaryStage() {
        let output = SnorkelingWatchPresentation.make(
            baseInput(isSessionStarted: true, phase: .ended, showSessionSummary: true, sessionElapsedSeconds: 3_615)
        )
        XCTAssertEqual(output.stage, .sessionSummary)
        XCTAssertEqual(output.summaryTotalTimeText, "01:00:15")
    }

    func testStartDisabledWhenDepthUnavailable() {
        var input = baseInput(isSessionStarted: false)
        input.depthPresentationState = .unavailable
        let output = SnorkelingWatchPresentation.make(input)
        XCTAssertFalse(output.startEnabled)
        XCTAssertNotNil(output.startDisabledReason)
    }

    func testHapticsOffStillProvidesOverlayPath() {
        var input = baseInput(isSessionStarted: true, phase: .surfaceActive)
        input.activeOverlays = [
            SnorkelingOperationalOverlay(
                kind: .alarm,
                titleKey: "snorkeling.alarm.title",
                subtitle: "Depth",
                severity: .warning,
                eventID: UUID()
            )
        ]
        let output = SnorkelingWatchPresentation.make(input)
        if case .operational(let overlay) = output.overlay {
            XCTAssertEqual(overlay.subtitle, "Depth")
        } else {
            XCTFail("Expected operational overlay")
        }
    }

    func testMissionModeReducesAnimationsFlagPassesThrough() {
        var input = baseInput(isSessionStarted: true, phase: .surfaceActive)
        input.missionModeEnabled = true
        input.animationsEnabled = false
        let output = SnorkelingWatchPresentation.make(input)
        XCTAssertFalse(output.animationsEnabled)
    }

    func testUnderwaterGPSLabelIsInformational() {
        var input = baseInput(isSessionStarted: true, phase: .dipping, currentDepthMeters: 2.0)
        input.isUnderwater = true
        input.gpsPresentationState = .underwaterUnavailable
        let output = SnorkelingWatchPresentation.make(input)
        XCTAssertEqual(output.gpsStatusText, DIRWatchLocalizer.string("snorkeling.gps.underwater"))
        XCTAssertEqual(output.overlay, .gpsDegradedUnderwater)
    }

    func testLongItalianStringsDoNotEmptyCriticalFields() {
        var input = baseInput(isSessionStarted: true, phase: .navigation)
        input.waypointNavigation.waypointName = "Punto di interesse marino molto lungo per il test layout"
        let output = SnorkelingWatchPresentation.make(input)
        XCTAssertFalse(output.waypointNameText.isEmpty)
        XCTAssertFalse(output.turnInstructionText.isEmpty)
    }

    func testDeterministicReplay() {
        let input = baseInput(isSessionStarted: true, phase: .dipping, currentDepthMeters: 4.2, verticalSpeed: -0.3)
        XCTAssertEqual(SnorkelingWatchPresentation.make(input), SnorkelingWatchPresentation.make(input))
    }

    func testNoFixMarkerQualityOnSurface() {
        var input = baseInput(isSessionStarted: true, phase: .surfaceActive, showSaveMarker: true)
        input.gpsPresentationState = .unavailable
        input.markerPositionQualityLabel = DIRWatchLocalizer.string("snorkeling.marker.quality.no_fix")
        let output = SnorkelingWatchPresentation.make(input)
        XCTAssertEqual(output.stage, .saveMarker)
        XCTAssertFalse(output.showsLiveGPSCoordinates)
    }

    func testBatteryWarningOverlaySeverity() {
        var input = baseInput(isSessionStarted: true, phase: .surfaceActive)
        input.activeOverlays = [
            SnorkelingOperationalOverlay(
                kind: .alarm,
                titleKey: "snorkeling.alarm.title",
                subtitle: "Battery",
                severity: .critical,
                eventID: UUID()
            )
        ]
        let output = SnorkelingWatchPresentation.make(input)
        if case .operational(let overlay) = output.overlay {
            XCTAssertEqual(overlay.severity, .critical)
        } else {
            XCTFail("Expected alarm overlay")
        }
    }

    func testRecoveredSessionBannerIsPresentedAfterCheckpointRestore() {
        var input = baseInput(isSessionStarted: true, phase: .surfaceActive)
        input.isRecoveredSession = true
        input.recoveryWarning = DIRWatchLocalizer.string("snorkeling.recovery.gps_degraded")
        let output = SnorkelingWatchPresentation.make(input)
        XCTAssertEqual(output.recoveredSessionBannerText, DIRWatchLocalizer.string("snorkeling.recovery.banner"))
        XCTAssertNotNil(output.recoveredSessionAccessibilityLabel)
        XCTAssertFalse(output.heroValue.isEmpty)
    }

    func testRecoveredBannerDoesNotAppearForFreshSession() {
        let output = SnorkelingWatchPresentation.make(baseInput(isSessionStarted: true, phase: .surfaceActive))
        XCTAssertNil(output.recoveredSessionBannerText)
    }

    func testRecoveredBannerDoesNotHideCriticalAlarm() {
        var input = baseInput(isSessionStarted: true, phase: .surfaceActive)
        input.isRecoveredSession = true
        input.activeOverlays = [
            SnorkelingOperationalOverlay(
                kind: .alarm,
                titleKey: "snorkeling.alarm.title",
                subtitle: "Depth",
                severity: .critical,
                eventID: UUID()
            )
        ]
        let output = SnorkelingWatchPresentation.make(input)
        XCTAssertNotNil(output.recoveredSessionBannerText)
        if case .operational(let overlay) = output.overlay {
            XCTAssertEqual(overlay.severity, .critical)
        } else {
            XCTFail("Expected alarm overlay above recovered banner")
        }
    }

    func testRecoveredBannerAccessibilityTextExists() {
        var input = baseInput(isSessionStarted: true, phase: .surfaceActive)
        input.isRecoveredSession = true
        let output = SnorkelingWatchPresentation.make(input)
        XCTAssertEqual(output.recoveredSessionAccessibilityLabel, DIRWatchLocalizer.string("snorkeling.a11y.recovered_session"))
    }

    func testNavigationPresentationHasAccessibilityText() {
        var input = baseInput(isSessionStarted: true, phase: .navigation)
        input.waypointNavigation.turnInstruction = .turnLeft
        let output = SnorkelingWatchPresentation.make(input)
        XCTAssertFalse(output.turnInstructionAccessibility.isEmpty)
        XCTAssertFalse(output.heroAccessibilityLabel.isEmpty)
    }

    func testReturnAdvisorHasAccessibilityText() {
        var input = baseInput(isSessionStarted: true, phase: .returnMode)
        input.returnNavigation.advisorActive = true
        input.returnNavigation.informationalMessageKey = "snorkeling.return.advisor.distance"
        let output = SnorkelingWatchPresentation.make(input)
        XCTAssertNotNil(output.returnAdvisorAccessibilityLabel)
        XCTAssertNotEqual(output.returnAdvisorText, "snorkeling.return.advisor.distance")
    }

    func testAlarmOverlayHasAccessibilityText() {
        var input = baseInput(isSessionStarted: true, phase: .surfaceActive)
        input.activeOverlays = [
            SnorkelingOperationalOverlay(
                kind: .alarm,
                titleKey: "snorkeling.alarm.title",
                subtitle: "Depth",
                severity: .warning,
                eventID: UUID()
            )
        ]
        let output = SnorkelingWatchPresentation.make(input)
        XCTAssertEqual(output.overlayAccessibilityLabel, DIRWatchLocalizer.string("snorkeling.alarm.title"))
    }

    func testSummaryPresentationHasAccessibilityText() {
        let output = SnorkelingWatchPresentation.make(
            baseInput(isSessionStarted: true, phase: .ended, showSessionSummary: true)
        )
        XCTAssertFalse(output.summaryTotalTimeText.isEmpty)
        XCTAssertFalse(output.summaryFooterText.isEmpty)
    }

    func testDeterministicReplayPreservesRecoveredBanner() {
        var input = baseInput(isSessionStarted: true, phase: .surfaceActive)
        input.isRecoveredSession = true
        XCTAssertEqual(SnorkelingWatchPresentation.make(input), SnorkelingWatchPresentation.make(input))
    }

    // MARK: - Fixtures

    private func baseInput(
        isSessionStarted: Bool,
        phase: SnorkelingLifecyclePhase = .ready,
        showSaveMarker: Bool = false,
        showSessionSummary: Bool = false,
        currentDepthMeters: Double? = nil,
        verticalSpeed: Double = 0,
        sessionElapsedSeconds: TimeInterval = 0
    ) -> SnorkelingWatchPresentationInput {
        SnorkelingWatchPresentationInput(
            phase: phase,
            isSessionArmed: isSessionStarted,
            isSessionStarted: isSessionStarted,
            showSessionSummary: showSessionSummary,
            showSaveMarker: showSaveMarker,
            currentDepthMeters: currentDepthMeters,
            currentTemperatureCelsius: 22,
            verticalSpeedMetersPerSecond: verticalSpeed,
            sessionElapsedSeconds: sessionElapsedSeconds,
            surfaceElapsedSeconds: sessionElapsedSeconds,
            underwaterTimeSeconds: 0,
            activeDipElapsedSeconds: 45,
            dipCount: 2,
            sessionMaxDepthMeters: 5.5,
            activeDipMaxDepthMeters: 4.2,
            accumulatedDistanceMeters: 420,
            averageSpeedMetersPerSecond: 0.7,
            gpsPresentationState: .tracking,
            depthPresentationState: .valid,
            sensorHealth: .available,
            entryPointCaptured: true,
            entryDistanceMeters: 180,
            targetDurationSeconds: 7_200,
            maxDistanceMeters: 1_500,
            missionModeEnabled: false,
            hapticsEnabled: true,
            buddyReminderEnabled: true,
            batteryFraction: 0.55,
            markerCount: 1,
            minimumWaterTemperatureCelsius: 19.5,
            waypointNavigation: .unavailable,
            returnNavigation: .unavailable,
            activeOverlays: [],
            isUnderwater: (currentDepthMeters ?? 0) >= 0.5,
            animationsEnabled: true,
            selectedMarkerCategory: .reef,
            markerPositionQualityLabel: DIRWatchLocalizer.string("snorkeling.marker.quality.measured"),
            markerDistanceFromEntryText: "180 m",
            sessionSaveState: .notSaved,
            isRecoveredSession: false,
            recoveryWarning: nil,
            gpsQualityBand: .good,
            routeProgressPercent: 42,
            offRouteDistanceMeters: nil,
            isOffRoute: false,
            offRouteWarningPaused: false,
            plannedReturnAlertActive: false,
            importedRoutePresentation: .missing,
            microMapPresentation: .unavailable
        )
    }
}
