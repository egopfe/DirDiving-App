import XCTest

final class ApneaReadinessPresentationTests: XCTestCase {
    func testSessionCheckStatusKeysMapAllStatuses() {
        XCTAssertEqual(ApneaReadinessPresentation.sessionCheckStatusKey(for: .ready), "apnea.session_check.ready")
        XCTAssertEqual(ApneaReadinessPresentation.sessionCheckStatusKey(for: .warning), "apnea.session_check.warning")
        XCTAssertEqual(ApneaReadinessPresentation.sessionCheckStatusKey(for: .incomplete), "apnea.session_check.incomplete")
        XCTAssertEqual(ApneaReadinessPresentation.sessionCheckStatusKey(for: .blocked), "apnea.session_check.incomplete")
    }

    func testCanSendToWatchAllowsReadyAndWarningOnly() {
        let ready = ApneaSessionCheckResult(
            status: .ready,
            profileKind: .freeTraining,
            recoveryAlertsEnabled: true,
            buddyReminderShown: true,
            issues: []
        )
        let warning = ApneaSessionCheckResult(
            status: .warning,
            profileKind: .freeTraining,
            recoveryAlertsEnabled: true,
            buddyReminderShown: true,
            issues: []
        )
        let incomplete = ApneaSessionCheckResult(
            status: .incomplete,
            profileKind: .freeTraining,
            recoveryAlertsEnabled: true,
            buddyReminderShown: true,
            issues: []
        )
        XCTAssertTrue(ApneaReadinessPresentation.canSendToWatch(plannerValid: true, sessionCheck: ready))
        XCTAssertTrue(ApneaReadinessPresentation.canSendToWatch(plannerValid: true, sessionCheck: warning))
        XCTAssertFalse(ApneaReadinessPresentation.canSendToWatch(plannerValid: true, sessionCheck: incomplete))
    }

    func testDashboardReadinessSourceContainsChecklistAndSessionCheck() throws {
        let root = repositoryRoot()
        let source = try String(contentsOf: root.appendingPathComponent("iOSApp/Views/Apnea/IOSApneaDashboardView.swift"))
        XCTAssertTrue(source.contains("apnea.readiness.title"))
        XCTAssertTrue(source.contains("apnea.checklist.completed_format"))
        XCTAssertTrue(source.contains("ApneaReadinessPresentation.sessionCheckStatusKey"))
        XCTAssertTrue(source.contains("readinessCard"))
        XCTAssertTrue(source.contains("showChecklist"))
        XCTAssertTrue(source.contains("showSessionCheck"))
    }

    func testReadinessDoesNotDependOnLogbookPresence() throws {
        let root = repositoryRoot()
        let source = try String(contentsOf: root.appendingPathComponent("iOSApp/Views/Apnea/IOSApneaDashboardView.swift"))
        let readinessRange = try XCTUnwrap(source.range(of: "readinessCard"))
        let lastSessionRange = source.range(of: "lastSessionCard")
        if let lastSessionRange {
            XCTAssertLessThan(readinessRange.lowerBound, lastSessionRange.lowerBound)
        }
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
