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
        "Picker(\"Unità\""
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
