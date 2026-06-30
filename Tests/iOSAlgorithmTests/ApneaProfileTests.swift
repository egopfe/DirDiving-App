import XCTest

final class ApneaProfileTests: XCTestCase {
    func testDefaultProfileKindIsFreeTraining() {
        XCTAssertEqual(ApneaSessionProfile.freeTrainingDefault.kind, .freeTraining)
    }

    func testStaticProfileHasRecoveryPolicy() {
        let profile = ApneaSessionProfileBridge.bundledPresets().first { $0.kind == .staticApnea }
        XCTAssertNotNil(profile)
        XCTAssertEqual(profile?.minimumRecoveryPolicy.mode, .ratio2to1)
    }

    func testDepthProfileUsesDepthLayout() {
        let profile = ApneaSessionProfile(
            kind: .depthConstantWeight,
            displayName: "Depth",
            targetDepthMeters: 20
        )
        XCTAssertEqual(profile.watchRuntimeLayout, .depthMetrics)
    }
}
