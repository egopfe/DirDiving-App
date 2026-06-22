import XCTest

final class IOSActivitySettingsRoutingTests: XCTestCase {
    func testMoreViewUsesModeSwitcherAndEmbeddedActivityForms() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/MoreView.swift"))
        XCTAssertTrue(source.contains("IOSCompanionSettingsModeSwitcher"))
        XCTAssertTrue(source.contains("IOSDivingSettingsEmbeddedContent"))
        XCTAssertTrue(source.contains("IOSApneaSettingsForm"))
        XCTAssertTrue(source.contains("IOSSnorkelingSettingsForm"))
        XCTAssertTrue(source.contains("companionSettingsScope"))
    }

    func testApneaAndSnorkelingSheetsUseUnifiedSettingsRoot() throws {
        let apneaRoot = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/Apnea/IOSApneaRootView.swift"))
        let snorkelingRoot = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/Snorkeling/IOSSnorkelingRootView.swift"))
        XCTAssertTrue(apneaRoot.contains("IOSCompanionSettingsRootView(initialMode: .apnea)"))
        XCTAssertTrue(snorkelingRoot.contains("IOSCompanionSettingsRootView(initialMode: .snorkeling)"))
        XCTAssertTrue(apneaRoot.contains("applyCompanionSettingsSheetEnvironment"))
        XCTAssertTrue(snorkelingRoot.contains("applyCompanionSettingsSheetEnvironment"))
    }

    func testApneaFormDoesNotReferenceDivingOnlyKeys() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/Apnea/IOSApneaSettingsForm.swift"))
        XCTAssertFalse(source.contains("PlannerAscentSpeedSettings"))
        XCTAssertFalse(source.contains("dirdiving.settings.diving"))
        XCTAssertFalse(source.contains("snorkeling.ios.settings"))
    }

    func testSnorkelingFormDoesNotReferenceDivingOnlyKeys() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/Snorkeling/IOSSnorkelingSettingsForm.swift"))
        XCTAssertFalse(source.contains("PlannerAscentSpeedSettings"))
        XCTAssertFalse(source.contains("apnea.ios.settings.detection"))
    }

    func testDivingEmbeddedContentDoesNotReferenceApneaOrSnorkelingOwnedSections() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/IOSDivingSettingsEmbeddedContent.swift"))
        XCTAssertFalse(source.contains("apnea.ios.settings"))
        XCTAssertFalse(source.contains("snorkeling.ios.settings"))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
