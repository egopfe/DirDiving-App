import XCTest
@testable import DIRDivingiOSApp

final class DivingUDDFExportTests: XCTestCase {
    func testSingleSessionUDDFStructure() throws {
        let session = makeExportSession()
        let uddf = try XCTUnwrap(DivingUDDFExportService.makeUDDF(for: session))
        XCTAssertTrue(uddf.contains("<uddf"))
        XCTAssertTrue(uddf.contains("<profiledata>"))
        XCTAssertTrue(uddf.contains("<repetitiongroup>"))
        XCTAssertTrue(uddf.contains("<dive"))
        XCTAssertTrue(uddf.contains("<samples>"))
        XCTAssertTrue(uddf.contains("<waypoint>"))
        XCTAssertTrue(uddf.contains("<divetime>"))
        XCTAssertTrue(uddf.contains("<depth>"))
    }

    func testUDDFIsParseable() throws {
        let session = makeExportSession()
        let uddf = try XCTUnwrap(DivingUDDFExportService.makeUDDF(for: session))
        let data = try XCTUnwrap(uddf.data(using: .utf8))
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".xml")
        try data.write(to: url)
        let parser = UDDFImportParser()
        let source = DivingImportSource(url: url, fileName: "test.uddf", format: .uddf, fileSizeBytes: data.count)
        switch parser.previewImport(from: url, source: source) {
        case .success(let preview):
            XCTAssertEqual(preview.candidates.count, 1)
        case .failure(let error):
            XCTFail("Expected parse success: \(error)")
        }
    }

    func testMultiSessionUDDFContainsMultipleDives() throws {
        let sessions = [makeExportSession(), makeExportSession(startOffset: 7200)]
        let uddf = try XCTUnwrap(DivingUDDFExportService.makeUDDF(for: sessions))
        let diveCount = uddf.components(separatedBy: "<dive ").count - 1
        XCTAssertEqual(diveCount, 2)
    }

    func testEmptySamplesNotExportable() {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let session = DiveSession(
            id: UUID(),
            startDate: start,
            endDate: start,
            durationSeconds: 0,
            maxDepthMeters: 0,
            avgDepthMeters: 0,
            avgWaterTemperatureCelsius: nil,
            ttv: 0,
            entryGPS: nil,
            exitGPS: nil,
            samples: [],
            hasDepthProfile: false
        )
        XCTAssertNil(DivingUDDFExportService.makeUDDF(for: session))
    }

    private func makeExportSession(startOffset: TimeInterval = 0) -> DiveSession {
        let start = Date(timeIntervalSince1970: 1_700_000_000 + startOffset)
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
            siteName: "UDDF Site"
        )
    }
}
