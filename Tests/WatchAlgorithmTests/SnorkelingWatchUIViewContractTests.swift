import XCTest

final class SnorkelingWatchUIViewContractTests: XCTestCase {
    func testSnorkelingViewIncludesDynamicTypeAndAccessibilityHooks() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/SnorkelingView.swift"))
        XCTAssertTrue(source.contains("dynamicTypeSize"))
        XCTAssertTrue(source.contains("accessibilityLabel"))
        XCTAssertTrue(source.contains("accessibilityIdentifier"))
        XCTAssertTrue(source.contains("readyPanel"))
        XCTAssertTrue(source.contains("surfaceDashboardPanel"))
        XCTAssertTrue(source.contains("saveMarkerPanel"))
        XCTAssertTrue(source.contains("sessionSummaryPanel"))
        XCTAssertFalse(source.contains("SNORKELING_WATCH_"), "Raster mockup filenames must not appear in production view source")
        XCTAssertFalse(source.contains("Image(\"SNORKELING"), "Raster mockups must not ship in Watch UI")
    }

    func testSnorkelingLocalizationKeysExistInEnAndIt() throws {
        let keys = [
            "snorkeling.ready.duration",
            "snorkeling.gps.tracking",
            "snorkeling.gps.unavailable",
            "snorkeling.nav.turn_left",
            "snorkeling.return.advised",
            "snorkeling.summary.header",
            "snorkeling.a11y.gps_status",
            "snorkeling.a11y.turn_left",
        ]
        let en = try loadWatchStrings(named: "en")
        let it = try loadWatchStrings(named: "it")
        for key in keys {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN key: \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT key: \(key)")
        }
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func loadWatchStrings(named locale: String) throws -> [String: String] {
        let url = repositoryRoot().appendingPathComponent("Resources/\(locale).lproj/Localizable.strings")
        return parseStringsFile(try String(contentsOf: url, encoding: .utf8))
    }

    private func parseStringsFile(_ raw: String) -> [String: String] {
        var result: [String: String] = [:]
        let pattern = #"\"([^\"]+)\"\s*=\s*\"([^\"]*)\";"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return result }
        let range = NSRange(raw.startIndex..<raw.endIndex, in: raw)
        regex.enumerateMatches(in: raw, range: range) { match, _, _ in
            guard let match,
                  let keyRange = Range(match.range(at: 1), in: raw),
                  let valueRange = Range(match.range(at: 2), in: raw) else { return }
            result[String(raw[keyRange])] = String(raw[valueRange])
        }
        return result
    }
}
