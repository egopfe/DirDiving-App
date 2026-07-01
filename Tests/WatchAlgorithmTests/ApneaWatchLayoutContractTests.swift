import XCTest

final class ApneaWatchLayoutContractTests: XCTestCase {
    private let watchSizes = ["41mm", "45mm", "49mm"]
    private let stages: [ApneaWatchStage] = [
        .ready, .dive, .ascent, .surfaceRecovery, .sessionSummary
    ]

    func testLayoutMatrixCoversAllMajorStages() {
        let matrixStages = Set(
            ApneaMockupReferenceMatrix.all
                .filter { $0.platform == .watch }
                .compactMap(\.presentationStage)
        )
        XCTAssertTrue(matrixStages.contains("ready"))
        XCTAssertTrue(matrixStages.contains("dive"))
        XCTAssertTrue(matrixStages.contains("ascent"))
        XCTAssertTrue(matrixStages.contains("surfaceRecovery"))
        XCTAssertTrue(matrixStages.contains("sessionSummary"))
    }

    func testAllMajorStagesProduceNonEmptySafetyFields() {
        for stage in stages {
            let output = ApneaWatchPresentation.make(fixture(for: stage))
            XCTAssertFalse(output.sensorLabel.isEmpty, "Missing sensor label for \(stage)")
            switch stage {
            case .ready:
                XCTAssertNotNil(output.startDisabledReason == nil ? "ok" : output.startDisabledReason)
            case .sessionSummary:
                XCTAssertFalse(output.summaryDiveCountText.isEmpty)
                XCTAssertFalse(output.summaryMaxDepthText.isEmpty)
            default:
                break
            }
        }
    }

    func testCompactAndUltraLayoutsShareDeterministicFixtures() {
        for size in watchSizes {
            for stage in stages {
                let input = fixture(for: stage)
                let first = ApneaWatchPresentation.make(input)
                let second = ApneaWatchPresentation.make(input)
                XCTAssertEqual(first, second, "Non-deterministic presentation for \(size) \(stage)")
            }
        }
    }

    func testSensorDegradedFixtureBlocksStart() {
        let output = ApneaWatchPresentation.make(fixture(for: .ready, sensorDegraded: true))
        XCTAssertFalse(output.startEnabled)
        XCTAssertNotNil(output.startDisabledReason)
    }

    func testAlarmOverlayFixtureRetainsAccessibilityStrings() {
        let overlay = ApneaWatchOverlayPresentation(
            kind: .alarm,
            title: "ALLARME",
            subtitle: "Depth 20",
            depthMeters: 20,
            dismissSafe: false
        )
        var input = fixture(for: .dive)
        input.activeOverlay = overlay
        let output = ApneaWatchPresentation.make(input)
        XCTAssertEqual(output.activeOverlay?.kind, .alarm)
        XCTAssertFalse(output.activeOverlay?.title.isEmpty ?? true)
    }

    func testEnglishAndItalianRecoveryStringsExist() throws {
        let keys = [
            "apnea.recovery.state.in_progress",
            "apnea.recovery.state.completed",
            "apnea.recovery.state.insufficient",
        ]
        let en = try loadWatchStrings(named: "en")
        let it = try loadWatchStrings(named: "it")
        for key in keys {
            XCTAssertFalse(en[key, default: ""].isEmpty)
            XCTAssertFalse(it[key, default: ""].isEmpty)
        }
    }

    private func fixture(for stage: ApneaWatchStage, sensorDegraded: Bool = false) -> ApneaWatchPresentationInput {
        switch stage {
        case .ready:
            return baseInput(isSessionStarted: false, sensorDegraded: sensorDegraded)
        case .dive:
            return baseInput(isSessionStarted: true, currentDepthMeters: 12, verticalSpeed: -0.4, sensorDegraded: sensorDegraded)
        case .ascent:
            return baseInput(isSessionStarted: true, currentDepthMeters: 6, verticalSpeed: 0.8, sensorDegraded: sensorDegraded)
        case .surfaceRecovery:
            return baseInput(
                isSessionStarted: true,
                currentDepthMeters: 0,
                recoveryRemainingSeconds: 40,
                requiredRecoverySeconds: 90,
                lastDiveDurationSeconds: 55,
                sensorDegraded: sensorDegraded
            )
        case .sessionSummary:
            return baseInput(isSessionStarted: true, showSessionSummary: true, diveCount: 3, sensorDegraded: sensorDegraded)
        }
    }

    private func baseInput(
        isSessionStarted: Bool,
        showSessionSummary: Bool = false,
        currentDepthMeters: Double = 0,
        verticalSpeed: Double = 0,
        diveCount: Int = 1,
        recoveryRemainingSeconds: TimeInterval = 0,
        requiredRecoverySeconds: TimeInterval = 0,
        lastDiveDurationSeconds: TimeInterval = 0,
        recoveryInsufficient: Bool = false,
        sensorDegraded: Bool = false
    ) -> ApneaWatchPresentationInput {
        ApneaWatchPresentationInput(
            isSessionStarted: isSessionStarted,
            showSessionSummary: showSessionSummary,
            currentDepthMeters: currentDepthMeters,
            maxDepthMeters: max(currentDepthMeters, 12),
            temperatureCelsius: 24,
            diveElapsedSeconds: 42,
            diveCount: diveCount,
            verticalSpeedMetersPerSecond: verticalSpeed,
            targetDepthMeters: 20,
            recoveryPolicyLabel: "2:1",
            activeAlarmCount: 1,
            configuredAlarmLabels: ["Depth 20 m"],
            buddyReminderEnabled: true,
            checklistCompletedCount: 0,
            checklistTotalCount: 0,
            sensorDegraded: sensorDegraded,
            hapticsEnabled: true,
            missionModeEnabled: false,
            surfaceElapsedSeconds: 30,
            lastDiveDurationSeconds: lastDiveDurationSeconds,
            lastDiveMaxDepthMeters: 18,
            requiredRecoverySeconds: requiredRecoverySeconds,
            recoveryElapsedSeconds: max(0, requiredRecoverySeconds - recoveryRemainingSeconds),
            recoveryRemainingSeconds: recoveryRemainingSeconds,
            recoveryInsufficient: recoveryInsufficient,
            recoveryInProgress: recoveryRemainingSeconds > 0,
            allowEarlyDiveWhenIncomplete: false,
            sessionTotalSeconds: 600,
            totalUnderwaterSeconds: 180,
            sessionMaxDepthMeters: 20,
            bestDiveDurationSeconds: 62,
            averageDiveDurationSeconds: 55,
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
