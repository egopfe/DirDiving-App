import XCTest
@testable import DIRDivingiOSApp

final class DivingImportExportRoundTripTests: XCTestCase {
    func testXMLExportImportRoundTrip() throws {
        let original = makeSession(siteName: "Round Trip Cave", buddy: "Alex")
        let xml = try XCTUnwrap(DivingSubsurfaceXMLExportService.makeXML(for: original))
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".xml")
        try xml.write(to: url, atomically: true, encoding: .utf8)
        let parser = SubsurfaceXMLImportParser()
        let source = DivingImportSource(url: url, fileName: "roundtrip.xml", format: .subsurfaceXML, fileSizeBytes: xml.count)
        let preview = try XCTUnwrap(parser.previewImport(from: url, source: source).get())
        XCTAssertEqual(preview.candidates.count, 1)
        let imported = preview.candidates[0].session
        XCTAssertEqual(imported.siteName, "Round Trip Cave")
        XCTAssertEqual(imported.buddy, "Alex")
        XCTAssertFalse(imported.samples.isEmpty)
    }

    func testCSVExportImportRoundTripPreservesMetadata() throws {
        let sessionID = UUID()
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let end = start.addingTimeInterval(600)
        let session = DiveSession(
            id: sessionID,
            startDate: start,
            endDate: end,
            durationSeconds: 600,
            maxDepthMeters: 32,
            avgDepthMeters: 18,
            avgWaterTemperatureCelsius: 22,
            ttv: 48,
            entryGPS: nil,
            exitGPS: nil,
            samples: [
                DiveSample(timestamp: start, depthMeters: 0, temperatureCelsius: 22),
                DiveSample(timestamp: end, depthMeters: 32, temperatureCelsius: 21)
            ],
            siteName: "Grotta",
            buddy: "Marco"
        )
        let csv = try XCTUnwrap(SubsurfaceExportService.makeCSV(for: session))
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".csv")
        try csv.write(to: url, atomically: true, encoding: .utf8)
        guard case .success(let summary) = DiveImportService.importCSV(from: url) else {
            return XCTFail("CSV round trip failed")
        }
        XCTAssertEqual(summary.session.id, sessionID)
        XCTAssertEqual(summary.session.siteName, "Grotta")
    }

    private func makeSession(siteName: String, buddy: String) -> DiveSession {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let end = start.addingTimeInterval(600)
        return DiveSession(
            id: UUID(),
            startDate: start,
            endDate: end,
            durationSeconds: 600,
            maxDepthMeters: 30,
            avgDepthMeters: 15,
            avgWaterTemperatureCelsius: 22,
            ttv: 12,
            entryGPS: nil,
            exitGPS: nil,
            samples: [
                DiveSample(timestamp: start, depthMeters: 0, temperatureCelsius: 22),
                DiveSample(timestamp: start.addingTimeInterval(300), depthMeters: 30, temperatureCelsius: 20),
                DiveSample(timestamp: end, depthMeters: 0, temperatureCelsius: 21)
            ],
            siteName: siteName,
            buddy: buddy
        )
    }
}

private extension Result {
    func get() throws -> Success {
        switch self {
        case .success(let value): return value
        case .failure(let error): throw error
        }
    }
}
