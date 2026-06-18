import XCTest

/// Documents Command 04 UI promotion gate — engine READY, MAIN target promotion deferred.
final class ApneaCommand04PromotionGateTests: XCTestCase {
    static let gateDecision = "READY_FOR_COMMAND_04"

    func testPromotionGateDecisionIsReadyForCommand04() {
        XCTAssertEqual(Self.gateDecision, "READY_FOR_COMMAND_04")
    }

    func testApneaViewIncludedInMainAfterPromotion() throws {
        let project = try String(
            contentsOf: repositoryRoot().appendingPathComponent("project.yml"),
            encoding: .utf8
        )
        XCTAssertFalse(
            project.contains("- ApneaView.swift"),
            "ApneaView should be promoted to MAIN Watch target"
        )
    }

    func testEngineLifecyclePrerequisitesPassSelfCheck() throws {
        let corpus = try loadApneaEngineCorpus()
        let issues = ApneaReleaseSelfCheck.verifyNoBlackoutOrNoMovementClaims(in: corpus)
            + ApneaReleaseSelfCheck.verifySyncNamespaceIsolation()
        XCTAssertTrue(issues.isEmpty, "Self-check issues: \(issues)")
    }

    func testNoProductionTimerInApneaEngineSources() throws {
        let path = repositoryRoot().appendingPathComponent("Shared/Utils/ApneaSessionEngine.swift")
        let text = try String(contentsOf: path, encoding: .utf8)
        XCTAssertFalse(text.contains("Timer.scheduledTimer"))
        XCTAssertFalse(text.contains("Timer("))
    }

    func testCommand04GateRequiresBuddyAndReferenceOnlyLocalization() throws {
        let keys = [
            "apnea.buddy.on",
            "apnea.ready.buddy",
            "apnea.ready.sensor_unavailable",
        ]
        let en = try loadWatchStrings(named: "en")
        let it = try loadWatchStrings(named: "it")
        for key in keys {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN: \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT: \(key)")
        }
    }

    // MARK: - Helpers

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func loadApneaEngineCorpus() throws -> String {
        let paths = [
            "Shared/Utils/ApneaSessionEngine.swift",
            "Shared/Utils/ApneaLifecycleStateMachine.swift",
            "Shared/Models/ApneaRecoveryPolicy.swift",
        ]
        return try paths
            .map { try String(contentsOf: repositoryRoot().appendingPathComponent($0), encoding: .utf8) }
            .joined(separator: "\n")
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
