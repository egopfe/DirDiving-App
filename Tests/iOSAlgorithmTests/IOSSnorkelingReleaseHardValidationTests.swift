import XCTest

final class IOSSnorkelingReleaseHardValidationTests: XCTestCase {
    func testReleaseSelfCheckPassesOnSnorkelingSources() throws {
        let root = repositoryRoot()
        let sources = try productionSourceCorpus(at: root)
        let english = try loadIOSStrings(named: "en")
        let italian = try loadIOSStrings(named: "it")
        let project = try String(contentsOf: root.appendingPathComponent("project.yml"), encoding: .utf8)
        let issues = SnorkelingReleaseSelfCheck.runAll(
            snorkelingSourceText: sources,
            english: english,
            italian: italian,
            repositoryRoot: root,
            projectText: project,
            verifyWatchLocalization: false
        )
        XCTAssertTrue(issues.isEmpty, "Self-check issues: \(issues)")

        let enKeys = Set(english.keys.filter { $0.hasPrefix("snorkeling.ios.") })
        let itKeys = Set(italian.keys.filter { $0.hasPrefix("snorkeling.ios.") })
        XCTAssertEqual(enKeys, itKeys, "iOS snorkeling EN/IT key sets differ")
    }

    func testSessionNamespaceDoesNotCollideWithRouteOrCheckpoint() {
        XCTAssertNotEqual(SnorkelingReleaseSelfCheck.sessionSyncPayloadKey, SnorkelingReleaseSelfCheck.checkpointNamespace)
        XCTAssertNotEqual(SnorkelingReleaseSelfCheck.sessionSyncPayloadKey, SnorkelingReleaseSelfCheck.routeSyncTransferType)
    }

    func testProductionShellExcludesExplorationCenter() throws {
        let root = repositoryRoot()
        let rootView = try String(
            contentsOf: root.appendingPathComponent("iOSApp/Views/Snorkeling/IOSSnorkelingRootView.swift"),
            encoding: .utf8
        )
        XCTAssertFalse(rootView.contains("ExplorationCenterView"))
    }

    private func productionSourceCorpus(at root: URL) throws -> String {
        let paths = SnorkelingReleaseSelfCheck.watchCommand04to07Files
            + SnorkelingReleaseSelfCheck.iosCommand08Files
            + SnorkelingReleaseSelfCheck.iosCommand09Files
            + SnorkelingReleaseSelfCheck.iosCommand10Files
            + SnorkelingReleaseSelfCheck.iosCommand11Files
        return try paths.map { try String(contentsOf: root.appendingPathComponent($0), encoding: .utf8) }.joined(separator: "\n")
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
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
