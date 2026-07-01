import XCTest
@testable import DIRDivingiOSApp

final class DivingSubsurfaceXMLExportTests: XCTestCase {
    func testSingleSessionXMLStructure() throws {
        let session = makeExportSession()
        let xml = try XCTUnwrap(DivingSubsurfaceXMLExportService.makeXML(for: session))
        XCTAssertTrue(xml.contains("<divelog"))
        XCTAssertTrue(xml.contains("<dives>"))
        XCTAssertTrue(xml.contains("<dive"))
        XCTAssertTrue(xml.contains("<divecomputer"))
        XCTAssertTrue(xml.contains("<sample"))
        XCTAssertTrue(xml.contains("Test Site"))
    }

    func testXMLIsParseable() throws {
        let session = makeExportSession()
        let xml = try XCTUnwrap(DivingSubsurfaceXMLExportService.makeXML(for: session))
        let data = try XCTUnwrap(xml.data(using: .utf8))
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".xml")
        try data.write(to: url)
        let parser = SubsurfaceXMLImportParser()
        let source = DivingImportSource(url: url, fileName: "test.xml", format: .subsurfaceXML, fileSizeBytes: data.count)
        switch parser.previewImport(from: url, source: source) {
        case .success(let preview):
            XCTAssertEqual(preview.candidates.count, 1)
            XCTAssertTrue(preview.candidates[0].isImportable)
        case .failure(let error):
            XCTFail("Expected parse success: \(error)")
        }
    }

    func testMultiSessionXMLContainsMultipleDives() throws {
        let sessions = [makeExportSession(), makeExportSession(startOffset: 3600)]
        let xml = try XCTUnwrap(DivingSubsurfaceXMLExportService.makeXML(for: sessions))
        let diveCount = xml.components(separatedBy: "<dive ").count - 1
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
        XCTAssertNil(DivingSubsurfaceXMLExportService.makeXML(for: session))
    }

    func testNotesAreXMLEscaped() throws {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let end = start.addingTimeInterval(60)
        let session = DiveSession(
            id: UUID(),
            startDate: start,
            endDate: end,
            durationSeconds: 60,
            maxDepthMeters: 10,
            avgDepthMeters: 5,
            avgWaterTemperatureCelsius: 22,
            ttv: 1,
            entryGPS: nil,
            exitGPS: nil,
            samples: [
                DiveSample(timestamp: start, depthMeters: 0, temperatureCelsius: 22),
                DiveSample(timestamp: end, depthMeters: 10, temperatureCelsius: 21)
            ],
            notes: "A & B <test>"
        )
        let xml = try XCTUnwrap(DivingSubsurfaceXMLExportService.makeXML(for: session))
        XCTAssertTrue(xml.contains("A &amp; B &lt;test&gt;"))
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
            siteName: "Test Site",
            buddy: "Buddy",
            notes: "Notes"
        )
    }
}
