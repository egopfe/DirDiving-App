import XCTest

final class PlannerLocalizationTests: XCTestCase {
    private let requiredKeys = [
        "planner.buhlmann.tissue_curve_title",
        "planner.buhlmann.tissue_curve_disclaimer",
        "planner.buhlmann.group_1_4",
        "planner.buhlmann.group_5_8",
        "planner.buhlmann.group_9_12",
        "planner.buhlmann.group_13_16",
        "planner.buhlmann.ndl_reference_title",
        "planner.charts.depth_profile",
        "planner.ascent.row.bottom",
        "planner.ascent.row.travel",
        "planner.metric.tts",
        "planner.metric.runtime",
        "planner.table.depth"
    ]

    func testLocalizationKeysExistInEnglishAndItalian() throws {
        let en = try loadStrings(named: "en")
        let it = try loadStrings(named: "it")
        for key in requiredKeys {
            XCTAssertNotNil(en[key], "Missing EN key \(key)")
            XCTAssertNotNil(it[key], "Missing IT key \(key)")
            XCTAssertFalse(en[key]?.isEmpty ?? true)
            XCTAssertFalse(it[key]?.isEmpty ?? true)
        }
        XCTAssertEqual(it["planner.table.depth"], "Profondità")
    }

    private func loadStrings(named locale: String) throws -> [String: String] {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("iOSApp/Resources/\(locale).lproj/Localizable.strings")
        let raw = try String(contentsOf: url, encoding: .utf8)
        var result: [String: String] = [:]
        let pattern = #"\"([^\"]+)\"\s*=\s*\"([^\"]*)\";"#
        let regex = try NSRegularExpression(pattern: pattern)
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
