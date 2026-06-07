import XCTest

final class WatchMainUILocalizationTests: XCTestCase {
    private let requiredKeys = [
        "live.metric.ttv",
        "live.metric.runtime",
        "live.metric.max_depth",
        "live.metric.avg_depth",
        "log.export.subsurface.button",
        "log.delete.button",
        "log.share.csv.button",
        "depth.safety.caution.title",
        "depth.safety.critical.title",
        "depth.safety.a11y.caution",
        "depth.safety.a11y.critical",
        "depth.safety.a11y.exceeded",
        "live.banner.collapsed.a11y",
        "watch.nav.back.a11y",
        "watch.depth_validation.missing_sample",
        "watch.depth_validation.stale_sample",
        "watch.depth_validation.stuck_sensor",
        "watch.depth_validation.implausible_change",
        "watch.depth_validation.non_finite",
        "watch.depth_validation.out_of_range",
        "watch.sync.photo.received",
        "watch.sync.photo.error",
        "settings.row.units.picker.a11y",
        "alarms.depth.default_off_hint",
        "alarms.depth.preset_30m"
    ]

    private let forbiddenVisibleStrings = [
        "ESPORTA",
        "ELIMINA LOG",
        "PROF. MASSIMA",
        "PROF. MEDIA",
        "CONDIVIDI CSV",
        "COMPASSO"
    ]

    private let compiledViewFiles = [
        "Views/DiveLiveView.swift",
        "Views/DiveDetailView.swift",
        "Views/ExportView.swift",
        "Views/DepthSafetyLiveViews.swift",
        "Views/CompassView.swift"
    ]

    func testWatchDepthValidationMessagesUseSemanticKeys() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Services/DiveManager.swift"))
        XCTAssertFalse(source.contains("Campione profondita"))
        XCTAssertTrue(source.contains("watch.depth_validation.missing_sample"))
    }

    func testWatchSettingsUnitsPickerUsesLocalizedLabel() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/SettingsView.swift"))
        XCTAssertFalse(source.contains("Picker(\"Unità\""))
        XCTAssertTrue(source.contains("settings.row.units.picker.a11y"))
    }

    func testWatchAlarmDefaultsDocumented() throws {
        let en = try loadWatchStrings(named: "en")
        XCTAssertTrue(en["alarms.depth.default_off_hint", default: ""].contains("off by default"))
        XCTAssertFalse(en["alarms.depth.preset_30m", default: ""].isEmpty)
    }

    func testWatchMainLocalizationKeysExistInEnglishAndItalian() throws {
        let en = try loadWatchStrings(named: "en")
        let it = try loadWatchStrings(named: "it")
        for key in requiredKeys {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN key: \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT key: \(key)")
        }
    }

    func testWatchMainCompiledViewsAvoidHardcodedItalianExportDeleteDepthLabels() throws {
        let root = repositoryRoot()
        for relativePath in compiledViewFiles {
            let url = root.appendingPathComponent(relativePath)
            let source = try String(contentsOf: url, encoding: .utf8)
            for forbidden in forbiddenVisibleStrings where forbidden != "COMPASSO" {
                XCTAssertFalse(
                    source.contains("\"\(forbidden)\""),
                    "\(relativePath) still contains hardcoded \"\(forbidden)\""
                )
            }
        }
    }

    func testWatchMainStringsAndViewsAvoidCompassoTerminology() throws {
        let root = repositoryRoot()
        for locale in ["en", "it"] {
            let strings = try loadWatchStrings(named: locale)
            for (key, value) in strings {
                XCTAssertFalse(
                    value.localizedCaseInsensitiveContains("COMPASSO"),
                    "Watch \(locale) string \(key) uses COMPASSO instead of BUSSOLA terminology"
                )
            }
        }
        for relativePath in compiledViewFiles {
            let source = try String(contentsOf: root.appendingPathComponent(relativePath), encoding: .utf8)
            XCTAssertFalse(
                source.localizedCaseInsensitiveContains("COMPASSO"),
                "\(relativePath) uses COMPASSO instead of BUSSOLA terminology"
            )
        }
    }

    func testDepthSafetyCopyDiffersBetweenCautionAndCritical() throws {
        let en = try loadWatchStrings(named: "en")
        let it = try loadWatchStrings(named: "it")
        XCTAssertNotEqual(en["depth.safety.caution.title"], en["depth.safety.critical.title"])
        XCTAssertNotEqual(it["depth.safety.caution.title"], it["depth.safety.critical.title"])
        XCTAssertEqual(en["depth.safety.caution.title"], "Approaching supported depth range")
        XCTAssertEqual(en["depth.safety.critical.title"], "Near maximum supported depth")
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func loadWatchStrings(named locale: String) throws -> [String: String] {
        let url = repositoryRoot().appendingPathComponent("Resources/\(locale).lproj/Localizable.strings")
        let raw = try String(contentsOf: url, encoding: .utf8)
        return parseStringsFile(raw)
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
