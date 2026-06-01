import XCTest

final class MissionModeTests: XCTestCase {
    func testStandardProfileEnablesDecorations() {
        XCTAssertTrue(MissionModeRuntimeProfile.standard.animationsEnabled)
        XCTAssertTrue(MissionModeRuntimeProfile.standard.decorativeEffectsEnabled)
    }

    func testMissionProfileReducesNonEssentialEffects() {
        XCTAssertFalse(MissionModeRuntimeProfile.mission.animationsEnabled)
        XCTAssertFalse(MissionModeRuntimeProfile.mission.decorativeEffectsEnabled)
    }

    func testAutoEnablePreferenceActivatesOnDiveStart() {
        XCTAssertTrue(
            MissionModeLifecycle.shouldActivateRuntime(autoEnablePreference: true, manualPendingForSession: false)
        )
        XCTAssertEqual(
            MissionModeLifecycle.activationSource(
                autoEnablePreference: true,
                manualPendingForSession: false,
                restored: false
            ),
            .automatic
        )
    }

    func testAutoEnableOffStaysInactiveUnlessManualPending() {
        XCTAssertFalse(
            MissionModeLifecycle.shouldActivateRuntime(autoEnablePreference: false, manualPendingForSession: false)
        )
        XCTAssertTrue(
            MissionModeLifecycle.shouldActivateRuntime(autoEnablePreference: false, manualPendingForSession: true)
        )
        XCTAssertEqual(
            MissionModeLifecycle.activationSource(
                autoEnablePreference: false,
                manualPendingForSession: true,
                restored: false
            ),
            .manual
        )
    }

    func testRestoreWithAutoEnableUsesRestoredSource() {
        XCTAssertTrue(
            MissionModeLifecycle.shouldActivateRuntime(autoEnablePreference: true, manualPendingForSession: false)
        )
        XCTAssertEqual(
            MissionModeLifecycle.activationSource(
                autoEnablePreference: true,
                manualPendingForSession: false,
                restored: true
            ),
            .restored
        )
    }

    func testRestoreWithAutoEnableOffStaysInactive() {
        XCTAssertFalse(
            MissionModeLifecycle.shouldActivateRuntime(autoEnablePreference: false, manualPendingForSession: false)
        )
        XCTAssertNil(
            MissionModeLifecycle.activationSource(
                autoEnablePreference: false,
                manualPendingForSession: false,
                restored: true
            )
        )
    }

    func testManualPendingDoesNotImplyAutoPreferenceChanged() {
        XCTAssertTrue(
            MissionModeLifecycle.shouldActivateRuntime(autoEnablePreference: false, manualPendingForSession: true)
        )
        XCTAssertFalse(
            MissionModeLifecycle.shouldActivateRuntime(autoEnablePreference: false, manualPendingForSession: false)
        )
    }
}
