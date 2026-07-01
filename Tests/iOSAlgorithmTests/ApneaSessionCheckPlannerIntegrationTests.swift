import XCTest

@MainActor
final class ApneaSessionCheckPlannerIntegrationTests: XCTestCase {
    private func validPlan() -> ApneaSessionPlan {
        ApneaSessionPlan(
            kind: .pyramid,
            title: "Morning",
            entries: IOSApneaPlannerStore.defaultPyramidEntries(),
            recoveryPolicy: .default
        )
    }

    private func sessionProfile() -> ApneaSessionProfile {
        ApneaSessionProfileBridge.fromCompanion(
            ApneaCompanionProfile(displayName: "Custom", discipline: .custom, profileKind: .freeTraining)
        )
    }

    func testValidPlannerWithBuddyConfirmedIsReady() {
        let result = ApneaReadinessPresentation.plannerSessionCheck(
            profile: sessionProfile(),
            recoveryPolicy: validPlan().recoveryPolicy,
            recoveryAlertsEnabled: true,
            buddyChecklistConfirmed: true
        )
        XCTAssertEqual(result.status, .ready)
        XCTAssertTrue(ApneaReadinessPresentation.canSendToWatch(plannerValid: true, sessionCheck: result))
    }

    func testValidPlannerWithIncompleteBuddyChecklistIsWarning() {
        let result = ApneaReadinessPresentation.plannerSessionCheck(
            profile: sessionProfile(),
            recoveryPolicy: validPlan().recoveryPolicy,
            recoveryAlertsEnabled: true,
            buddyChecklistConfirmed: false
        )
        XCTAssertEqual(result.status, .warning)
        XCTAssertTrue(ApneaReadinessPresentation.canSendToWatch(plannerValid: true, sessionCheck: result))
    }

    func testPlannerWithoutProfileIsIncompleteAndBlocksSend() {
        let result = ApneaReadinessPresentation.plannerSessionCheck(
            profile: nil,
            recoveryPolicy: .default,
            recoveryAlertsEnabled: true,
            buddyChecklistConfirmed: true
        )
        XCTAssertEqual(result.status, .incomplete)
        XCTAssertFalse(ApneaReadinessPresentation.canSendToWatch(plannerValid: true, sessionCheck: result))
    }

    func testShortRecoveryPolicyProducesWarning() {
        let shortPolicy = ApneaRecoveryPolicy(
            mode: .ratio1to1,
            minimumSurfaceSeconds: 10,
            recommendedSurfaceSeconds: 20,
            phases: [.surfaceRest],
            allowEarlyDiveWhenIncomplete: false
        )
        let result = ApneaReadinessPresentation.plannerSessionCheck(
            profile: sessionProfile(),
            recoveryPolicy: shortPolicy,
            recoveryAlertsEnabled: true,
            buddyChecklistConfirmed: true
        )
        XCTAssertEqual(result.status, .warning)
        XCTAssertTrue(result.issues.contains(where: { $0.localizationKey == "apnea.session_check.recovery_short" }))
        XCTAssertTrue(ApneaReadinessPresentation.canSendToWatch(plannerValid: true, sessionCheck: result))
    }

    func testInvalidPlannerBlocksSendEvenWhenSessionCheckReady() {
        var plan = validPlan()
        plan.title = ""
        let plannerValid = ApneaSessionPlanValidator.isValid(plan)
        let result = ApneaReadinessPresentation.plannerSessionCheck(
            profile: sessionProfile(),
            recoveryPolicy: plan.recoveryPolicy,
            recoveryAlertsEnabled: true,
            buddyChecklistConfirmed: true
        )
        XCTAssertFalse(ApneaReadinessPresentation.canSendToWatch(plannerValid: plannerValid, sessionCheck: result))
    }
}
