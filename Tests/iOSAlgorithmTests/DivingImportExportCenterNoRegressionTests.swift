import XCTest
@testable import DIRDivingiOSApp

final class DivingImportExportCenterNoRegressionTests: XCTestCase {
    func testLegacyCSVImportStillWorks() throws {
        let session = makeSession()
        let csv = try XCTUnwrap(SubsurfaceExportService.makeCSV(for: session))
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".csv")
        try csv.write(to: url, atomically: true, encoding: .utf8)
        guard case .success = DiveImportService.importCSV(from: url) else {
            return XCTFail("Legacy CSV import failed")
        }
    }

    func testImportRegistryStillAvailable() {
        XCTAssertNotNil(DivingImportParserRegistry.parser(for: .subsurfaceCSV))
        XCTAssertNotNil(DivingImportParserRegistry.parser(for: .subsurfaceXML))
        XCTAssertNotNil(DivingImportParserRegistry.parser(for: .uddf))
    }

    func testExportFormatsAvailable() {
        XCTAssertEqual(DivingExportFormat.allCases.count, 3)
    }

    private func makeSession() -> DiveSession {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let end = start.addingTimeInterval(600)
        return DiveSession(
            id: UUID(),
            startDate: start,
            endDate: end,
            durationSeconds: 600,
            maxDepthMeters: 24,
            avgDepthMeters: 12,
            avgWaterTemperatureCelsius: 22,
            ttv: 10,
            entryGPS: nil,
            exitGPS: nil,
            samples: [
                DiveSample(timestamp: start, depthMeters: 0, temperatureCelsius: 22),
                DiveSample(timestamp: end, depthMeters: 24, temperatureCelsius: 21)
            ]
        )
    }
}
