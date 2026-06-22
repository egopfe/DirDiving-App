import XCTest

final class IOSActivitySettingsRoutingTests: XCTestCase {
    func testMoreViewUsesModeSwitcherAndEmbeddedActivityContent() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/MoreView.swift"))
        XCTAssertTrue(source.contains("IOSCompanionSettingsModeSwitcher"))
        XCTAssertTrue(source.contains("IOSDivingSettingsEmbeddedContent"))
        XCTAssertTrue(source.contains("IOSApneaSettingsContent"))
        XCTAssertTrue(source.contains("IOSSnorkelingSettingsContent"))
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

    func testUnifiedSettingsRootUsesEmbeddableActivityContent() throws {
        let root = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/IOSCompanionSettingsRootView.swift"))
        XCTAssertTrue(root.contains("IOSApneaSettingsContent()"))
        XCTAssertTrue(root.contains("IOSSnorkelingSettingsContent()"))
        XCTAssertFalse(root.contains("IOSApneaSettingsForm()"))
        XCTAssertFalse(root.contains("IOSSnorkelingSettingsForm()"))
    }

    func testApneaContentDoesNotReferenceDivingOnlyKeys() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/Apnea/IOSApneaSettingsContent.swift"))
        XCTAssertFalse(source.contains("PlannerAscentSpeedSettings"))
        XCTAssertFalse(source.contains("dirdiving.settings.diving"))
        XCTAssertFalse(source.contains("snorkeling.ios.settings"))
    }

    func testSnorkelingContentDoesNotReferenceDivingOnlyKeys() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/Snorkeling/IOSSnorkelingSettingsContent.swift"))
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
