import XCTest
@testable import DIRDivingiOSApp

final class DivingCSVImportParserTests: XCTestCase {
    func testPreviewImportFromRoundTripCSV() throws {
        let session = sampleSession()
        let csv = try XCTUnwrap(SubsurfaceExportService.makeCSV(for: session))
        let url = try writeTemp(named: "roundtrip.csv", contents: csv)
        let source = DivingImportFormatDetector.makeSource(from: url)
        let parser = DivingCSVImportParser()
        let result = try parser.previewImport(from: url, source: source).get()
        XCTAssertEqual(result.candidates.count, 1)
        XCTAssertEqual(result.candidates.first?.session.id, session.id)
        XCTAssertTrue(result.candidates.first?.isImportable ?? false)
    }

    private func sampleSession() -> DiveSession {
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
            ],
            siteName: "Test Site"
        )
    }

    private func writeTemp(named: String, contents: String) throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + named)
        try contents.write(to: url, atomically: true, encoding: .utf8)
        return url
    }
}
