import XCTest
@testable import DIRDivingiOSApp

final class SubsurfaceXMLImportParserTests: XCTestCase {
    private let fixture = """
    <divelog>
      <dives>
        <dive date="2026-06-01" time="10:00:00" duration="45:00 min" maxdepth="30.0 m">
          <location>Test Site</location>
          <divecomputer model="Example DC">
            <sample time="0:00 min" depth="0.0 m" temp="22.0 C" />
            <sample time="20:00 min" depth="30.0 m" temp="20.0 C" />
            <sample time="45:00 min" depth="0.0 m" temp="21.0 C" />
          </divecomputer>
        </dive>
      </dives>
    </divelog>
    """

    func testPreviewImportProducesOneCandidate() throws {
        let url = try writeTemp(named: "subsurface.xml", contents: fixture)
        let source = DivingImportSource(url: url, fileName: "subsurface.xml", format: .subsurfaceXML, fileSizeBytes: fixture.utf8.count)
        let parser = SubsurfaceXMLImportParser()
        let result = try parser.previewImport(from: url, source: source).get()
        XCTAssertEqual(result.candidates.count, 1)
        let candidate = try XCTUnwrap(result.candidates.first)
        XCTAssertEqual(candidate.sourceComputerModel, "Example DC")
        XCTAssertEqual(candidate.session.samples.count, 3)
        XCTAssertGreaterThan(candidate.session.maxDepthMeters, 29)
        XCTAssertTrue(candidate.isImportable)
    }

    private func writeTemp(named: String, contents: String) throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + named)
        try contents.write(to: url, atomically: true, encoding: .utf8)
        return url
    }
}
