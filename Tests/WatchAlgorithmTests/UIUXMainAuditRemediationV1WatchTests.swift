import XCTest

final class UIUXMainAuditRemediationV1WatchTests: XCTestCase {
    func testBriefingFreshnessPolicyMarksOldCards() {
        let generatedAt = Date().addingTimeInterval(-(PlannerBriefingFreshnessPolicy.staleAfterSeconds + 60))
        let manifest = PlannerBriefingCardManifest(
            id: UUID(),
            plannerSessionId: UUID(),
            generatedAt: generatedAt,
            modeLabel: "CCR",
            title: "Briefing",
            subtitle: nil,
            referenceOnly: true,
            cards: []
        )
        let state = PlannerBriefingFreshnessPolicy.evaluate(
            manifest: manifest,
            isPackageIncomplete: false
        )
        XCTAssertEqual(state, .old)
        XCTAssertNotNil(PlannerBriefingFreshnessPolicy.localizedWarning(for: state))
    }

    func testBriefingFreshnessPolicyMarksSessionMismatch() {
        let manifest = PlannerBriefingCardManifest(
            id: UUID(),
            plannerSessionId: UUID(),
            generatedAt: Date(),
            modeLabel: "CCR",
            title: "Briefing",
            subtitle: nil,
            referenceOnly: true,
            cards: []
        )
        let state = PlannerBriefingFreshnessPolicy.evaluate(
            manifest: manifest,
            isPackageIncomplete: false,
            activePlannerSessionId: UUID()
        )
        XCTAssertEqual(state, .sessionMismatch)
    }

    func testBriefingFreshnessPolicyCurrentCardHasNoWarning() {
        let manifest = PlannerBriefingCardManifest(
            id: UUID(),
            plannerSessionId: UUID(),
            generatedAt: Date(),
            modeLabel: "CCR",
            title: "Briefing",
            subtitle: nil,
            referenceOnly: true,
            cards: []
        )
        let state = PlannerBriefingFreshnessPolicy.evaluate(
            manifest: manifest,
            isPackageIncomplete: false,
            activePlannerSessionId: manifest.plannerSessionId
        )
        XCTAssertEqual(state, .current)
        XCTAssertNil(PlannerBriefingFreshnessPolicy.localizedWarning(for: state))
    }

    func testDiveLiveViewUsesLocaleAwareTTVFormatting() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/DiveLiveView.swift"))
        XCTAssertTrue(source.contains("NumberFormatter()"))
        XCTAssertTrue(source.contains("formatter.locale = Locale.current"))
        XCTAssertFalse(source.contains("replacingOccurrences(of: \".\", with: \",\")"))
    }

    func testDiveLiveViewWiresCompactBannerPolicyOutputs() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/DiveLiveView.swift"))
        XCTAssertTrue(source.contains("isCompactWatchLayout"))
        XCTAssertTrue(source.contains("presentation.deferStopwatchPanel"))
        XCTAssertTrue(source.contains("presentation.deferControlsPanel"))
        XCTAssertTrue(source.contains("prioritizeDepthAndRuntime"))
    }

    func testUserImagesViewExplainsBundledVersusUploadedImages() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/UserImagesView.swift"))
        XCTAssertTrue(source.contains("user_images.info.bundled_readonly"))
        XCTAssertTrue(source.contains("user_images.info.uploaded_deletable"))
        XCTAssertTrue(source.contains("user_images.type.bundled"))
        XCTAssertTrue(source.contains("user_images.type.uploaded"))
    }

    func testReminderSuppressionDefersToCriticalAlarms() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Services/DiveManager.swift"))
        XCTAssertTrue(source.contains("shouldSuppressDiveReminders"))
        XCTAssertTrue(source.contains("alarmWarningMessage != nil"))
        XCTAssertTrue(source.contains("ascentStatus.isOverLimit"))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
