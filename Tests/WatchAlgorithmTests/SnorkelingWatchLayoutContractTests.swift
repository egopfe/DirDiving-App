import XCTest

final class SnorkelingWatchLayoutContractTests: XCTestCase {
    private let watchSizes = ["40mm", "44mm", "49mm"]
    private let stages: [SnorkelingWatchStage] = [
        .ready,
        .surfaceDashboard,
        .dipInProgress,
        .navigation,
        .returnToEntry,
        .saveMarker,
        .sessionSummary
    ]

    func testAllApprovedStagesProduceNonEmptyHeroAndGPSFields() {
        for stage in stages {
            let output = SnorkelingWatchPresentation.make(fixture(for: stage))
            XCTAssertFalse(output.heroValue.isEmpty, "Missing hero for \(stage)")
            XCTAssertFalse(output.gpsStatusText.isEmpty, "Missing GPS for \(stage)")
            XCTAssertFalse(output.headerTitle.isEmpty, "Missing header for \(stage)")
        }
    }

    func testCompactAndUltraLayoutsShareDeterministicFixtures() {
        for size in watchSizes {
            for stage in stages {
                let input = fixture(for: stage)
                let first = SnorkelingWatchPresentation.make(input)
                let second = SnorkelingWatchPresentation.make(input)
                XCTAssertEqual(first, second, "Non-deterministic presentation for \(size) \(stage)")
            }
        }
    }

    func testDynamicTypeLongStringsRemainNonEmpty() {
        var input = fixture(for: .navigation)
        input.waypointNavigation.waypointName = String(repeating: "Waypoint ", count: 12)
        let output = SnorkelingWatchPresentation.make(input)
        XCTAssertFalse(output.waypointNameText.isEmpty)
        XCTAssertFalse(output.turnInstructionAccessibility.isEmpty)
    }

    func testMissionModeProfileReducesAnimationFlag() {
        var input = fixture(for: .surfaceDashboard)
        input.missionModeEnabled = true
        input.animationsEnabled = false
        let output = SnorkelingWatchPresentation.make(input)
        XCTAssertFalse(output.animationsEnabled)
        XCTAssertEqual(output.missionModeText, DIRWatchLocalizer.string("mission_mode.a11y.active"))
    }

    func testAccessibilityStringsPresentForNavigation() {
        let output = SnorkelingWatchPresentation.make(fixture(for: .navigation))
        XCTAssertFalse(output.turnInstructionAccessibility.isEmpty)
        XCTAssertFalse(output.heroAccessibilityLabel.isEmpty)
    }

    private func fixture(for stage: SnorkelingWatchStage) -> SnorkelingWatchPresentationInput {
        var input = SnorkelingWatchPresentationInput(
            phase: .surfaceActive,
            isSessionArmed: true,
            isSessionStarted: true,
            showSessionSummary: stage == .sessionSummary,
            showSaveMarker: stage == .saveMarker,
            currentDepthMeters: stage == .dipInProgress ? 3.8 : 0.2,
            currentTemperatureCelsius: 21,
            verticalSpeedMetersPerSecond: stage == .dipInProgress ? -0.4 : 0.1,
            sessionElapsedSeconds: 1_825,
            surfaceElapsedSeconds: 900,
            underwaterTimeSeconds: 925,
            activeDipElapsedSeconds: 88,
            dipCount: 3,
            sessionMaxDepthMeters: 6.2,
            activeDipMaxDepthMeters: 4.1,
            accumulatedDistanceMeters: 760,
            averageSpeedMetersPerSecond: 0.55,
            gpsPresentationState: .tracking,
            depthPresentationState: .valid,
            sensorHealth: .available,
            entryPointCaptured: true,
            entryDistanceMeters: 210,
            targetDurationSeconds: 7_200,
            maxDistanceMeters: 1_500,
            missionModeEnabled: false,
            hapticsEnabled: true,
            buddyReminderEnabled: false,
            batteryFraction: 0.42,
            markerCount: 2,
            minimumWaterTemperatureCelsius: 18.5,
            waypointNavigation: SnorkelingWaypointNavigationSnapshot(
                waypointID: UUID(),
                waypointName: "Reef",
                waypointCategory: .reef,
                targetBearingDegrees: 120,
                currentHeadingDegrees: 100,
                signedAngularDeltaDegrees: -20,
                turnInstruction: .turnLeft,
                distanceToTargetMeters: 95,
                gpsPresentationState: .tracking,
                headingQuality: .valid,
                surfaceSpeedMetersPerSecond: 0.6,
                waypointReached: false,
                hasNextWaypoint: true,
                skippedWaypointIDs: []
            ),
            returnNavigation: SnorkelingReturnNavigationSnapshot(
                entryPoint: nil,
                alternateTarget: nil,
                entryPointAgeSeconds: 300,
                distanceToEntryMeters: 240,
                bearingToEntryDegrees: 300,
                currentHeadingDegrees: 280,
                signedAngularDeltaDegrees: -20,
                turnInstruction: .turnLeft,
                advisorReason: .distanceThreshold,
                advisorActive: true,
                gpsPresentationState: .degraded,
                headingQuality: .stale,
                informationalMessageKey: nil
            ),
            activeOverlays: [],
            isUnderwater: stage == .dipInProgress,
            animationsEnabled: true,
            selectedMarkerCategory: .reef,
            markerPositionQualityLabel: DIRWatchLocalizer.string("snorkeling.marker.quality.measured"),
            markerDistanceFromEntryText: "210 m",
            sessionSaveState: stage == .sessionSummary ? .saved : .notSaved,
            isRecoveredSession: false,
            recoveryWarning: nil
        )

        switch stage {
        case .ready:
            input.isSessionStarted = false
            input.isSessionArmed = false
            input.phase = .ready
        case .surfaceDashboard:
            input.phase = .surfaceActive
        case .dipInProgress:
            input.phase = .dipping
        case .navigation:
            input.phase = .navigation
        case .returnToEntry:
            input.phase = .returnMode
        case .saveMarker:
            input.phase = .surfaceActive
            input.showSaveMarker = true
        case .sessionSummary:
            input.phase = .ended
            input.showSessionSummary = true
        }
        return input
    }
}
