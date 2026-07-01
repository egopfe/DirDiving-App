import XCTest

final class ApneaSessionPlannerSectionOrderTests: XCTestCase {
    func testApneaPlannerSectionsOrderedBeforeWatchTransfer() throws {
        let root = repositoryRoot()
        let source = try String(contentsOf: root.appendingPathComponent("iOSApp/Views/Apnea/IOSApneaSessionPlannerView.swift"))
        let titleIndex = try XCTUnwrap(source.range(of: "apnea.ios.planner.title_field")?.lowerBound)
        let profileIndex = try XCTUnwrap(source.range(of: "apnea.ios.profiles.title", range: titleIndex..<source.endIndex)?.lowerBound)
        let seriesIndex = try XCTUnwrap(source.range(of: "apnea.ios.planner.series", range: profileIndex..<source.endIndex)?.lowerBound)
        let recoveryIndex = try XCTUnwrap(source.range(of: "apnea.ios.planner.recovery", range: seriesIndex..<source.endIndex)?.lowerBound)
        let checklistIndex = try XCTUnwrap(source.range(of: "apnea.checklist.title", range: recoveryIndex..<source.endIndex)?.lowerBound)
        let sessionCheckIndex = try XCTUnwrap(source.range(of: "apnea.session_check.title", range: checklistIndex..<source.endIndex)?.lowerBound)
        let notesIndex = try XCTUnwrap(source.range(of: "apnea.ios.planner.notes", range: sessionCheckIndex..<source.endIndex)?.lowerBound)
        let transferIndex = try XCTUnwrap(source.range(of: "apnea.ios.planner.watch_transfer", range: notesIndex..<source.endIndex)?.lowerBound)
        let sendIndex = try XCTUnwrap(source.range(of: "apnea.ios.planner.send_watch", range: transferIndex..<source.endIndex)?.lowerBound)
        XCTAssertLessThan(profileIndex, seriesIndex)
        XCTAssertLessThan(seriesIndex, recoveryIndex)
        XCTAssertLessThan(recoveryIndex, checklistIndex)
        XCTAssertLessThan(checklistIndex, sessionCheckIndex)
        XCTAssertLessThan(sessionCheckIndex, notesIndex)
        XCTAssertLessThan(notesIndex, transferIndex)
        XCTAssertLessThan(transferIndex, sendIndex)
    }

    func testPlannerUsesSessionCheckEvaluator() throws {
        let root = repositoryRoot()
        let source = try String(contentsOf: root.appendingPathComponent("iOSApp/Views/Apnea/IOSApneaSessionPlannerView.swift"))
        XCTAssertTrue(source.contains("ApneaReadinessPresentation.plannerSessionCheck"))
        XCTAssertTrue(source.contains("ApneaReadinessPresentation.canSendToWatch"))
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
