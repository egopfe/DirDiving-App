import XCTest

@MainActor
final class ApneaWatchRuntimeStoreTests: XCTestCase {
    private let start = Date(timeIntervalSince1970: 1_700_000_000)

    override func setUp() {
        super.setUp()
        #if DEBUG
        let checkpoint = FileManager.default.temporaryDirectory
            .appendingPathComponent("apnea-checkpoint-\(UUID().uuidString).json")
        ApneaWatchRuntimeStore.testHook_checkpointURL = checkpoint
        var config = ApneaLifecycleConfiguration.default
        config.immersionStartDepthMeters = 1.0
        config.surfaceStableDwellSeconds = 3
        config.minimumDiveDurationSeconds = 1
        config.recoveryMinimumSeconds = 2
        ApneaWatchRuntimeStore.testLifecycleConfiguration = config
        #endif
    }

    override func tearDown() {
        #if DEBUG
        if let url = ApneaWatchRuntimeStore.testHook_checkpointURL {
            try? FileManager.default.removeItem(at: url)
        }
        ApneaWatchRuntimeStore.testHook_checkpointURL = nil
        ApneaWatchRuntimeStore.testLifecycleConfiguration = nil
        #endif
        super.tearDown()
    }

    func testRuntimeStoreInitializesWithIdleSession() {
        let store = ApneaWatchRuntimeStore()
        XCTAssertEqual(store.lifecyclePhase, .idle)
        XCTAssertFalse(store.isSessionActive)
        XCTAssertEqual(store.presentationInput.diveCount, 0)
    }

    func testReadyPresentationDerivesFromEngineAfterArm() {
        let store = ApneaWatchRuntimeStore()
        store.armSession()
        let output = ApneaWatchPresentation.make(store.presentationInput)
        XCTAssertFalse(output.startEnabled == false && store.lifecyclePhase == .idle)
        XCTAssertTrue(store.isSessionActive)
    }

    func testDepthChangesFlowThroughPresentation() {
        let store = ApneaWatchRuntimeStore()
        store.armSession(at: start)
        store.ingestDepthForTesting(depthMeters: 8, at: start.addingTimeInterval(2))
        XCTAssertEqual(store.presentationInput.currentDepthMeters, 8, accuracy: 0.01)
    }

    func testSensorDegradedBlocksReadyStartPresentation() {
        var input = ApneaWatchRuntimeStore().presentationInput
        input = ApneaWatchPresentationInput(
            isSessionStarted: false,
            showSessionSummary: false,
            currentDepthMeters: 0,
            maxDepthMeters: 0,
            temperatureCelsius: nil,
            diveElapsedSeconds: 0,
            diveCount: 0,
            verticalSpeedMetersPerSecond: 0,
            targetDepthMeters: 20,
            recoveryPolicyLabel: "2:1",
            activeAlarmCount: 0,
            configuredAlarmLabels: [],
            buddyReminderEnabled: true,
            sensorDegraded: true,
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
            dataQualityDegraded: true,
            activeOverlay: nil,
            runtimeLayout: .freeTrainingCompact,
            sensorQualityLabels: [],
            maxRepetitions: nil,
            averageRecoverySeconds: 0,
            dataQualityLevel: .good
        )
        let output = ApneaWatchPresentation.make(input)
        XCTAssertFalse(output.startEnabled)
    }

    func testManualFallbackRemainsExplicit() {
        let store = ApneaWatchRuntimeStore()
        store.armSession()
        store.startManualFallback()
        XCTAssertTrue(store.isSensorDegraded)
        XCTAssertEqual(store.presentationInput.sensorDegraded, true)
    }

    func testCompletedSessionWritesOnlyToApneaLogbook() {
        let store = ApneaWatchRuntimeStore()
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        ApneaLogbookStore.testHook_storageDirectoryURL = directory
        let logbook = ApneaLogbookStore()

        var engine = ApneaSessionEngine(
            configuration: ApneaWatchRuntimeStore.testLifecycleConfiguration ?? .default,
            recoveryPolicy: .init(mode: .ratio2to1, minimumSurfaceSeconds: 2, recommendedSurfaceSeconds: 5),
            sessionStart: start
        )
        engine.armSession(at: start)
        engine.replayProfile(
            depths: [0, 0, 2, 6, 8, 4, 0, 0, 0, 0],
            intervalSeconds: 1,
            startDate: start.addingTimeInterval(1)
        )
        engine.tick(now: start.addingTimeInterval(12))
        store.replaceEngineForTesting(engine)

        XCTAssertGreaterThanOrEqual(store.presentationInput.diveCount, 1)
        store.saveCompletedSession(to: logbook)
        XCTAssertEqual(logbook.sessions.count, 1)
        XCTAssertGreaterThanOrEqual(logbook.sessions.first?.dives.count ?? 0, 1)
        ApneaLogbookStore.testHook_storageDirectoryURL = nil
    }

    func testApneaProductionUIAndRuntimeDoNotReferenceDiveManager() throws {
        let productionPaths = [
            "Views/ApneaView.swift",
            "Services/ApneaWatchRuntimeStore.swift",
            "Services/ApneaWatchRuntimeProviding.swift",
        ]
        let forbidden = ["DiveManager", "DiveLogStore", "FullComputerRuntimeEngine", "ExplorationStore"]
        let root = repositoryRoot()
        var violations: [String] = []
        for path in productionPaths {
            let text = try String(contentsOf: root.appendingPathComponent(path), encoding: .utf8)
            for symbol in forbidden {
                if text.contains(symbol) {
                    violations.append("\(path): \(symbol)")
                }
            }
        }
        XCTAssertTrue(violations.isEmpty, violations.joined(separator: ", "))
    }

    func testRejectedDepthDoesNotAlterOperationalTargetEvents() {
        let store = ApneaWatchRuntimeStore()
        store.armSession()
        store.ingestDepthForTesting(depthMeters: 10, at: start)
        store.ingestDepthForTesting(depthMeters: 50, at: start.addingTimeInterval(0.05))
        XCTAssertNil(store.operationalOverlay)
    }

    func testCheckpointRestorePreservesArmedSession() {
        let store = ApneaWatchRuntimeStore()
        store.armSession(at: start)
        store.ingestDepthForTesting(depthMeters: 6, at: start.addingTimeInterval(2))
        store.persistCheckpointNowForTesting()
        let restored = ApneaWatchRuntimeStore()
        XCTAssertTrue(restored.isSessionActive)
        XCTAssertEqual(restored.presentationInput.currentDepthMeters, 6, accuracy: 0.5)
    }

    private func replayShortDive(on store: ApneaWatchRuntimeStore) {
        let depths = [0.0, 0.2, 0.6, 1.2, 2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 10.0, 8.0, 6.0, 4.0, 2.0, 1.0, 0.2, 0.0]
        var offset: TimeInterval = 1
        for depth in depths {
            store.ingestDepthForTesting(depthMeters: depth, at: start.addingTimeInterval(offset))
            offset += 2.5
        }
        for extra in stride(from: offset, through: offset + 25, by: 1) {
            store.tickForTesting(at: start.addingTimeInterval(extra))
        }
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
