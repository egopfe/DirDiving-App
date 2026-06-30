import XCTest

final class ApneaReleaseHardValidationTests: XCTestCase {
    private var startDate = Date(timeIntervalSince1970: 1_700_000_000)

    override func setUp() {
        super.setUp()
        startDate = Date(timeIntervalSince1970: 1_700_000_000)
    }

    // MARK: - Mockup / bundle safety

    func testNoRasterMockupEmbeddedInWatchBundle() {
        let bundle = Bundle.main
        let resourcePaths = bundle.paths(forResourcesOfType: "png", inDirectory: nil)
        let embeddedMockups = resourcePaths.filter { $0.contains("APNEA_") }
        XCTAssertTrue(embeddedMockups.isEmpty, "APNEA mockups must not ship in the app bundle: \(embeddedMockups)")
    }

    func testApneaViewExcludedFromWatchMainTargetByPolicy() throws {
        let project = try String(
            contentsOf: repositoryRoot().appendingPathComponent("project.yml"),
            encoding: .utf8
        )
        XCTAssertFalse(
            project.contains("- ApneaView.swift"),
            "ApneaView must be included in MAIN Watch target after promotion"
        )
    }

    // MARK: - Safety / self-check

    func testReleaseSelfCheckPassesOnApneaSources() throws {
        let apneaSources = try loadApneaSourceCorpus()
        let issues = ApneaReleaseSelfCheck.runAll(apneaSourceText: apneaSources)
        XCTAssertTrue(issues.isEmpty, "Self-check issues: \(issues)")
    }

    func testSensorDegradedBlocksReadyStart() {
        let output = ApneaWatchPresentation.make(baseInput(isSessionStarted: false, sensorDegraded: true))
        XCTAssertFalse(output.startEnabled)
        XCTAssertNotNil(output.startDisabledReason)
    }

    func testMinimumRecoverySecondsDocumented() {
        XCTAssertGreaterThanOrEqual(ApneaReleaseHardTolerances.minimumRecoverySeconds, 30)
    }

    // MARK: - Persistence / performance

    func testCheckpointRoundTripWithinBudget() throws {
        var engine = makeEngine()
        engine.armSession(at: startDate)
        _ = engine.ingest(
            raw: .init(depthMeters: 5, sensorTimestamp: startDate.addingTimeInterval(1), receivedAt: startDate.addingTimeInterval(1)),
            wallClock: startDate.addingTimeInterval(1)
        )

        let start = CFAbsoluteTimeGetCurrent()
        let envelope = try engine.exportCheckpoint(now: startDate.addingTimeInterval(10))
        _ = try ApneaSessionEngine(checkpoint: envelope)
        let elapsed = CFAbsoluteTimeGetCurrent() - start
        XCTAssertLessThanOrEqual(elapsed, ApneaReleaseHardTolerances.checkpointRoundTripBudgetSeconds)
    }

    func testBuddyDisclaimerLocalizationKeysExist() throws {
        let keys = [
            "apnea.buddy.on",
            "apnea.buddy.off",
            "apnea.ready.buddy",
            "apnea.ready.sensor_unavailable",
        ]
        let en = try loadWatchStrings(named: "en")
        let it = try loadWatchStrings(named: "it")
        for key in keys {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN key: \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT key: \(key)")
        }
    }

    // MARK: - Helpers

    private func loadApneaSourceCorpus() throws -> String {
        let root = repositoryRoot()
        let paths = [
            "Shared/Utils/ApneaSessionEngine.swift",
            "Shared/Utils/ApneaLifecycleStateMachine.swift",
            "Shared/Utils/ApneaOperationalEventEngine.swift",
            "Utils/ApneaWatchPresentation.swift",
            "Views/ApneaView.swift",
            "Services/ApneaSessionSyncCodec.swift",
            "Shared/Utils/ApneaSyncTransferSupport.swift",
        ]
        return try paths.map { try String(contentsOf: root.appendingPathComponent($0), encoding: .utf8) }.joined(separator: "\n")
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

    private func baseInput(
        isSessionStarted: Bool,
        sensorDegraded: Bool = false
    ) -> ApneaWatchPresentationInput {
        ApneaWatchPresentationInput(
            isSessionStarted: isSessionStarted,
            showSessionSummary: false,
            currentDepthMeters: 0,
            maxDepthMeters: 0,
            temperatureCelsius: nil,
            diveElapsedSeconds: 0,
            diveCount: 0,
            verticalSpeedMetersPerSecond: 0,
            targetDepthMeters: 25,
            recoveryPolicyLabel: "1:1",
            activeAlarmCount: 0,
            configuredAlarmLabels: [],
            buddyReminderEnabled: true,
            sensorDegraded: sensorDegraded,
            hapticsEnabled: true,
            missionModeEnabled: false,
            surfaceElapsedSeconds: 0,
            lastDiveDurationSeconds: 0,
            lastDiveMaxDepthMeters: 0,
            requiredRecoverySeconds: 0,
            recoveryElapsedSeconds: 0,
            recoveryRemainingSeconds: 0,
            recoveryInsufficient: false,
            recoveryInProgress: false,
            allowEarlyDiveWhenIncomplete: false,
            sessionTotalSeconds: 0,
            totalUnderwaterSeconds: 0,
            sessionMaxDepthMeters: 0,
            bestDiveDurationSeconds: 0,
            averageDiveDurationSeconds: 0,
            sessionWarnings: [],
            dataQualityDegraded: sensorDegraded,
            activeOverlay: nil,
            runtimeLayout: .freeTrainingCompact,
            sensorQualityLabels: [],
            maxRepetitions: nil,
            averageRecoverySeconds: 0,
            dataQualityLevel: .good
        )
    }

    private func makeEngine() -> ApneaSessionEngine {
        ApneaSessionEngine(configuration: .default, sessionStart: startDate)
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
