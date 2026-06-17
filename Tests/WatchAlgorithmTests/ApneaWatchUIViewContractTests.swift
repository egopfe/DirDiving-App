import XCTest

final class ApneaWatchUIViewContractTests: XCTestCase {
    func testApneaViewIncludesDynamicTypeAndAccessibilityHooks() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/ApneaView.swift"))
        XCTAssertTrue(source.contains("dynamicTypeSize"))
        XCTAssertTrue(source.contains("accessibilityLabel"))
        XCTAssertTrue(source.contains("a11y.watch.haptics_off_badge.label"))
        XCTAssertTrue(source.contains("ui.missionLabel"))
        XCTAssertTrue(source.contains("surfaceRecoveryPanel"))
        XCTAssertTrue(source.contains("sessionSummaryPanel"))
        XCTAssertTrue(source.contains("eventOverlay"))
    }

    func testApneaLocalizationKeysExistInEnAndIt() throws {
        let keys = [
            "apnea.ready.title",
            "apnea.ready.start",
            "apnea.stage.dive",
            "apnea.stage.ascent",
            "apnea.a11y.vertical_speed",
            "apnea.surface.title",
            "apnea.surface.last_dive",
            "apnea.recovery.state.completed",
            "apnea.summary.title",
            "apnea.summary.dives",
            "apnea.summary.save_end",
            "apnea.overlay.dismiss",
            "apnea.overlay.a11y.marker",
            "apnea.overlay.a11y.target",
            "apnea.alarms.sample.depth"
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
