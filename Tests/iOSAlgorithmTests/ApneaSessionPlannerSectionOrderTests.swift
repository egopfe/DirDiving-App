import XCTest

final class ApneaSessionPlannerSectionOrderTests: XCTestCase {
    func testApneaPlannerProfileAndReadinessPrecedeWatchTransfer() throws {
        let root = repositoryRoot()
        let source = try String(contentsOf: root.appendingPathComponent("iOSApp/Views/Apnea/IOSApneaSessionPlannerView.swift"))
        let titleIndex = try XCTUnwrap(source.range(of: "apnea.ios.planner.title_field")?.lowerBound)
        let profileIndex = try XCTUnwrap(source.range(of: "apnea.ios.profiles.title", range: titleIndex..<source.endIndex)?.lowerBound)
        let seriesIndex = try XCTUnwrap(source.range(of: "apnea.ios.planner.series", range: profileIndex..<source.endIndex)?.lowerBound)
        let readinessIndex = try XCTUnwrap(source.range(of: "apnea.ios.planner.readiness", range: seriesIndex..<source.endIndex)?.lowerBound)
        let transferIndex = try XCTUnwrap(source.range(of: "apnea.ios.planner.watch_transfer", range: readinessIndex..<source.endIndex)?.lowerBound)
        let sendIndex = try XCTUnwrap(source.range(of: "apnea.ios.planner.send_watch", range: transferIndex..<source.endIndex)?.lowerBound)
        XCTAssertLessThan(profileIndex, seriesIndex)
        XCTAssertLessThan(seriesIndex, readinessIndex)
        XCTAssertLessThan(readinessIndex, transferIndex)
        XCTAssertLessThan(transferIndex, sendIndex)
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
