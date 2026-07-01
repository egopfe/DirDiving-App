import XCTest
@testable import DIRDivingiOSApp

final class DivingImportNoRegressionTests: XCTestCase {
    func testLegacyImportCSVStillWorks() throws {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let end = start.addingTimeInterval(600)
        let session = DiveSession(
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
        let csv = try XCTUnwrap(SubsurfaceExportService.makeCSV(for: session))
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".csv")
        try csv.write(to: url, atomically: true, encoding: .utf8)
        guard case .success(let summary) = DiveImportService.importCSV(from: url) else {
            return XCTFail("Legacy CSV import failed")
        }
        XCTAssertEqual(summary.session.samples.count, 2)
    }

    func testImportRegistryDoesNotReferenceSnorkelingOrApneaTypes() {
        XCTAssertNotNil(DivingImportParserRegistry.parser(for: .subsurfaceCSV))
        XCTAssertNotNil(DivingImportParserRegistry.parser(for: .subsurfaceXML))
        XCTAssertNotNil(DivingImportParserRegistry.parser(for: .uddf))
    }
}
