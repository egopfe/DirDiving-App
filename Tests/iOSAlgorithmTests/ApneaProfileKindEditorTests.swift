import XCTest

final class ApneaProfileKindEditorTests: XCTestCase {
    func testNewCustomProfileDefaultsKindFromBridge() {
        let profile = ApneaCompanionProfile(displayName: "Custom", discipline: .custom)
        let resolved = profile.profileKind ?? ApneaSessionProfileBridge.profileKind(for: profile.discipline)
        XCTAssertEqual(resolved, .freeTraining)
    }

    func testApplyingProfileKindUpdatesStoredKind() {
        var profile = ApneaCompanionProfile(displayName: "Custom", discipline: .custom)
        profile.profileKind = .depthConstantWeight
        XCTAssertEqual(profile.profileKind, .depthConstantWeight)
    }

    func testNilKindResolvesFromDisciplineBridge() {
        let profile = ApneaCompanionProfile(displayName: "Depth", discipline: .constantWeight)
        let resolved = profile.profileKind ?? ApneaSessionProfileBridge.profileKind(for: profile.discipline)
        XCTAssertEqual(resolved, .depthConstantWeight)
    }

    func testPresetCannotBeEditedInPlace() {
        let preset = ApneaCompanionProfilePresets.bundledPresets().first!
        XCTAssertTrue(preset.isPreset)
        XCTAssertFalse(ApneaCompanionProfilePolicy.canEditInPlace(preset))
    }

    func testDuplicateMaintainsKindAndMaxRepetitions() {
        let original = ApneaCompanionProfile(
            displayName: "Intervals",
            discipline: .custom,
            profileKind: .trainingIntervals,
            maxRepetitions: 8
        )
        let copy = original.editableCopy()
        XCTAssertEqual(copy.profileKind, .trainingIntervals)
        XCTAssertEqual(copy.maxRepetitions, 8)
        XCTAssertFalse(copy.isPreset)
    }

    func testProfileEditorExposesKindRecoveryAndMaxRepetitions() throws {
        let root = repositoryRoot()
        let source = try String(contentsOf: root.appendingPathComponent("iOSApp/Views/Apnea/IOSApneaProfilesView.swift"))
        XCTAssertTrue(source.contains("apnea.profile.kind"))
        XCTAssertTrue(source.contains("apnea.profile.recovery_rule"))
        XCTAssertTrue(source.contains("apnea.profile.max_repetitions"))
        XCTAssertTrue(source.contains("applyProfileKind"))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
