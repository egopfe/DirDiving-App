import XCTest
@testable import DIRDivingiOSApp

final class UDDFImportParserTests: XCTestCase {
    private let fixture = """
    <uddf version="3.2.0">
      <profiledata>
        <repetitiongroup>
          <dive id="d1">
            <informationbeforedive>
              <datetime>2026-06-01T10:00:00</datetime>
            </informationbeforedive>
            <samples>
              <sample depth="0.0" divetime="0" temperature="22 C" />
              <sample depth="18.0" divetime="600" temperature="20 C" />
              <sample depth="0.0" divetime="1200" />
            </samples>
          </dive>
          <dive id="d2">
            <informationbeforedive>
              <datetime>2026-06-02T11:00:00</datetime>
            </informationbeforedive>
            <samples>
              <sample depth="0.0" divetime="0" />
              <sample depth="12.0" divetime="300" />
            </samples>
          </dive>
        </repetitiongroup>
      </profiledata>
    </uddf>
    """

    func testPreviewImportProducesMultipleCandidates() throws {
        let url = try writeTemp(named: "dives.uddf", contents: fixture)
        let source = DivingImportSource(url: url, fileName: "dives.uddf", format: .uddf, fileSizeBytes: fixture.utf8.count)
        let parser = UDDFImportParser()
        let result = try parser.previewImport(from: url, source: source).get()
        XCTAssertEqual(result.candidates.count, 2)
        XCTAssertTrue(result.candidates.allSatisfy(\.isImportable))
    }

    private func writeTemp(named: String, contents: String) throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + named)
        try contents.write(to: url, atomically: true, encoding: .utf8)
        return url
    }
}
