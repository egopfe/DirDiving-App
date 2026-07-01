import XCTest
@testable import DIRDivingiOSApp

final class DivingImportFormatDetectorTests: XCTestCase {
    func testDetectsSubsurfaceCSVHeader() throws {
        let url = try writeTempFile(named: "dive.csv", contents: "time_seconds,depth_m,temperature_c\n0,0,22\n")
        XCTAssertEqual(DivingImportFormatDetector.detect(url: url), .subsurfaceCSV)
    }

    func testDetectsSubsurfaceXML() throws {
        let url = try writeTempFile(named: "log.xml", contents: "<divelog><dives><dive date=\"2026-06-01\"></dive></dives></divelog>")
        XCTAssertEqual(DivingImportFormatDetector.detect(url: url), .subsurfaceXML)
    }

    func testDetectsUDDF() throws {
        let url = try writeTempFile(named: "log.uddf", contents: "<uddf version=\"3.2.0\"><profiledata></profiledata></uddf>")
        XCTAssertEqual(DivingImportFormatDetector.detect(url: url), .uddf)
    }

    private func writeTempFile(named: String, contents: String) throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + named)
        try contents.write(to: url, atomically: true, encoding: .utf8)
        return url
    }
}
