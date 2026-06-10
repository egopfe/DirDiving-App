import XCTest

final class WatchLocalizationStaticSweepTests: XCTestCase {
    private let watchSourceRoots = ["App", "Services", "Views", "Utils"]
    private let excludedRelativePaths: Set<String> = [
        "Views/ApneaView.swift",
        "Views/SnorkelingView.swift",
        "Views/BuddyAssistView.swift",
        "Views/ExperimentalConceptsView.swift"
    ]
    private let forbiddenHardcodedVisibleStrings = [
        "CONDIVIDI CSV",
        "ELIMINA LOG",
        "ESPORTA",
        "PROF. MASSIMA",
        "PROF. MEDIA",
        "ALLARME PROFONDITÀ",
        "Picker(\"Unità\"",
        "LIMITI PERSONALIZZATI",
        "\"SHORTCUT\""
    ]
    private let semanticKeysRequiringEnglish = [
        "watch.alarm.depth_exceeded_format",
        "watch.alarm.runtime_exceeded_format",
        "watch.alarm.battery_low_format",
        "watch.depth_validation.missing_sample",
        "watch.sync.photo.received",
        "log.share.csv.button"
    ]

    func testWatchMainSourcesAvoidHardcodedVisibleItalianStrings() throws {
        let root = repositoryRoot()
        for relativePath in try swiftFilesUnderWatchMain(root: root) {
            let source = try String(contentsOf: root.appendingPathComponent(relativePath), encoding: .utf8)
            for forbidden in forbiddenHardcodedVisibleStrings {
                XCTAssertFalse(
                    source.contains("\"\(forbidden)"),
                    "\(relativePath) contains hardcoded visible string \"\(forbidden)\""
                )
            }
        }
    }

    func testSemanticWatchKeysExistInEnglishAndItalian() throws {
        let en = try loadWatchStrings(named: "en")
        let it = try loadWatchStrings(named: "it")
        for key in semanticKeysRequiringEnglish {
            let english = en[key, default: ""]
            let italian = it[key, default: ""]
            XCTAssertFalse(english.isEmpty, "Missing EN key: \(key)")
            XCTAssertFalse(italian.isEmpty, "Missing IT key: \(key)")
            XCTAssertNotEqual(english, italian, "EN and IT should differ for \(key)")
        }
    }

    func testLocalizedKeysUsedInWatchMainSourcesHaveEnglishTranslations() throws {
        let root = repositoryRoot()
        let en = try loadWatchStrings(named: "en")
        var keys: Set<String> = []
        for relativePath in try swiftFilesUnderWatchMain(root: root) {
            let source = try String(contentsOf: root.appendingPathComponent(relativePath), encoding: .utf8)
            keys.formUnion(extractLocalizedKeys(from: source))
        }
        for key in keys.sorted() where key.hasPrefix("watch.") || key.hasPrefix("log.") || key.hasPrefix("alarms.") {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN translation for \(key)")
        }
    }

    func testDiveManagerUsesSemanticAlarmKeys() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("Services/DiveManager.swift"), encoding: .utf8)
        XCTAssertTrue(source.contains("watch.alarm.depth_exceeded_format"))
        XCTAssertFalse(source.contains("ALLARME PROFONDITÀ"))
    }

    func testWatchRuntimeSemanticKeysExistInBothCatalogs() throws {
        let en = try loadWatchStrings(named: "en")
        let it = try loadWatchStrings(named: "it")
        let keys = [
            "compass.status.calibration_required",
            "info.status.available",
            "image.error.invalid_filename",
            "image.error.invalid_size",
            "log.validation.invalid_sessions_excluded_local_format",
            "log.validation.invalid_sessions_excluded_format",
            "watchsync.import.error.log_store_unavailable",
            "dive.session.invalid.incoherent_data",
            "dive.session.unclassified_no_profile",
            "watchsync.diagnostic.failed_signed_ack",
            "sync.dive.received_from_iphone"
        ]
        for key in keys {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing watch EN \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing watch IT \(key)")
        }
    }

    func testWatchMainSourcesAvoidLegacyItalianSentenceKeys() throws {
        let root = repositoryRoot()
        let forbidden = [
            "Bussola da calibrare",
            "Nome file immagine non valido",
            "Errore import iPhone: log store non disponibile",
            "Failed: ack firmato non valido"
        ]
        for relativePath in try swiftFilesUnderWatchMain(root: root) {
            let source = try String(contentsOf: root.appendingPathComponent(relativePath), encoding: .utf8)
            for phrase in forbidden {
                XCTAssertFalse(source.contains("String(localized: \"\(phrase)"), "\(relativePath) uses legacy key \(phrase)")
            }
        }
    }

    func testWatchStringsNeverUseCompassoTerminology() throws {
        for locale in ["en", "it"] {
            let strings = try loadWatchStrings(named: locale)
            for (key, value) in strings {
                XCTAssertFalse(value.localizedCaseInsensitiveContains("compasso"), "Watch \(locale) \(key) contains Compasso")
                XCTAssertFalse(key.localizedCaseInsensitiveContains("compasso"), "Watch \(locale) key \(key) contains Compasso")
            }
        }
    }

    private func swiftFilesUnderWatchMain(root: URL) throws -> [String] {
        var results: [String] = []
        for sourceRoot in watchSourceRoots {
            let directory = root.appendingPathComponent(sourceRoot)
            guard FileManager.default.fileExists(atPath: directory.path) else { continue }
            let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: nil)
            while let url = enumerator?.nextObject() as? URL {
                guard url.pathExtension == "swift" else { continue }
                let relative = url.path.replacingOccurrences(of: root.path + "/", with: "")
                if excludedRelativePaths.contains(relative) { continue }
                results.append(relative)
            }
        }
        return results.sorted()
    }

    private func extractLocalizedKeys(from source: String) -> [String] {
        let pattern = #"String\(localized:\s*\"([^\"]+)\""#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(source.startIndex..<source.endIndex, in: source)
        var keys: [String] = []
        regex.enumerateMatches(in: source, range: range) { match, _, _ in
            guard let match, let keyRange = Range(match.range(at: 1), in: source) else { return }
            keys.append(String(source[keyRange]))
        }
        return keys
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
