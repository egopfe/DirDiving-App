import XCTest

final class IOSSnorkelingUIViewContractTests: XCTestCase {
    func testIOSDashboardIncludesAccessibilityAndNoRasterMockups() throws {
        let root = repositoryRoot()
        let dashboard = try String(contentsOf: root.appendingPathComponent("iOSApp/Views/Snorkeling/IOSSnorkelingDashboardView.swift"))
        XCTAssertTrue(dashboard.contains("accessibilityLabel"))
        XCTAssertTrue(dashboard.contains("mapPreviewAccessibilityLabel"))
        XCTAssertFalse(dashboard.contains("SNORKELING_IOS_"))
        XCTAssertFalse(dashboard.contains("Image(\"SNORKELING"))
    }

    func testIOSRoutePlannerAndSessionDetailHaveAccessibilityHooks() throws {
        let root = repositoryRoot()
        let planner = try String(contentsOf: root.appendingPathComponent("iOSApp/Views/Snorkeling/IOSSnorkelingRoutePlannerView.swift"))
        let detail = try String(contentsOf: root.appendingPathComponent("iOSApp/Views/Snorkeling/IOSSnorkelingSessionDetailView.swift"))
        XCTAssertTrue(planner.contains("DIRIOSLocalizer"))
        XCTAssertTrue(detail.contains("accessibilityLabel"))
        XCTAssertFalse(planner.contains("offlineCacheReady: true"))
    }

    func testIOSLocalizationKeysExistInEnAndIt() throws {
        let keys = IOSSnorkelingLocalizationCatalog.productionKeys
        let en = try loadIOSStrings(named: "en")
        let it = try loadIOSStrings(named: "it")
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

    private func loadIOSStrings(named locale: String) throws -> [String: String] {
        let url = repositoryRoot().appendingPathComponent("iOSApp/Resources/\(locale).lproj/Localizable.strings")
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
