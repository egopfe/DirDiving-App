import XCTest
@testable import DIRDivingiOSApp

final class DivingExportCoordinatorTests: XCTestCase {
    func testEmptySelectionFails() {
        let result = DivingExportCoordinator.export(sessions: [], format: .csv)
        guard case .failure(.emptySelection) = result else {
            return XCTFail("Expected emptySelection")
        }
    }

    func testSingleCSVExportSucceeds() {
        let session = makeExportSession()
        switch DivingExportCoordinator.export(sessions: [session], format: .csv) {
        case .success(let report):
            XCTAssertEqual(report.exportedCount, 1)
            XCTAssertNotNil(report.url)
        case .failure(let error):
            XCTFail("Expected success: \(error)")
        }
    }

    func testMultiCSVExportFails() {
        let sessions = [makeExportSession(), makeExportSession(startOffset: 3600)]
        guard case .failure(.unsupportedMultiCSV) = DivingExportCoordinator.export(sessions: sessions, format: .csv) else {
            return XCTFail("Expected unsupportedMultiCSV")
        }
    }

    func testMultiXMLExportSucceeds() {
        let sessions = [makeExportSession(), makeExportSession(startOffset: 3600)]
        switch DivingExportCoordinator.export(sessions: sessions, format: .subsurfaceXML) {
        case .success(let report):
            XCTAssertEqual(report.exportedCount, 2)
            XCTAssertNotNil(report.url)
        case .failure(let error):
            XCTFail("Expected success: \(error)")
        }
    }

    func testMultiUDDFExportSucceeds() {
        let sessions = [makeExportSession(), makeExportSession(startOffset: 3600)]
        switch DivingExportCoordinator.export(sessions: sessions, format: .uddf) {
        case .success(let report):
            XCTAssertEqual(report.exportedCount, 2)
            XCTAssertNotNil(report.url)
        case .failure(let error):
            XCTFail("Expected success: \(error)")
        }
    }

    func testDemoDiveSkipped() {
        let demo = makeExportSession(isDemo: true)
        switch DivingExportCoordinator.export(sessions: [demo], format: .subsurfaceXML) {
        case .success:
            XCTFail("Expected failure for demo-only export")
        case .failure(.emptySamples):
            XCTAssertTrue(true)
        case .failure(let error):
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testBuildCandidateFlagsDemo() {
        let demo = makeExportSession(isDemo: true)
        let candidate = DivingExportCoordinator.buildCandidate(for: demo)
        XCTAssertFalse(candidate.isExportable)
        XCTAssertTrue(candidate.warnings.contains(.demoDive))
    }

    private func makeExportSession(startOffset: TimeInterval = 0, isDemo: Bool = false) -> DiveSession {
        let start = Date(timeIntervalSince1970: 1_700_000_000 + startOffset)
        let end = start.addingTimeInterval(600)
        return DiveSession(
            id: UUID(),
            startDate: start,
            endDate: end,
            durationSeconds: 600,
            maxDepthMeters: 20,
            avgDepthMeters: 10,
            avgWaterTemperatureCelsius: 22,
            ttv: 8,
            entryGPS: nil,
            exitGPS: nil,
            samples: [
                DiveSample(timestamp: start, depthMeters: 0, temperatureCelsius: 22),
                DiveSample(timestamp: end, depthMeters: 20, temperatureCelsius: 21)
            ],
            isDemo: isDemo
        )
    }
}
