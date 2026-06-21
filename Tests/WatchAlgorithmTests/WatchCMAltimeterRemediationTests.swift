import XCTest

@MainActor
final class WatchFullComputerAltitudeSensorSettingsTests: XCTestCase {
    override func setUp() {
        super.setUp()
        WatchFullComputerAltitudeSensorProposalSettingsStore.shared.resetForTests()
    }

    override func tearDown() {
        WatchFullComputerAltitudeSensorProposalSettingsStore.shared.resetForTests()
        super.tearDown()
    }

    func testDefaultsToAutomaticAndPersists() {
        let store = WatchFullComputerAltitudeSensorProposalSettingsStore.shared
        XCTAssertEqual(store.mode, .automatic)
        store.setMode(.manualOnly)
        XCTAssertEqual(UserDefaults.standard.string(forKey: WatchFullComputerAltitudeSensorProposalSettingsStore.storageKey), "manualOnly")
        store.setMode(.automatic)
    }

    func testWatchSettingsSourceFileIsWatchOnly() throws {
        let root = FullComputerWatchArchitectureGuard.repositoryRoot(from: #filePath)
        let project = try String(contentsOf: root.appendingPathComponent("project.yml"), encoding: .utf8)
        XCTAssertTrue(project.contains("WatchFullComputerAltitudeSensorProposalSettingsStore.swift") || project.contains("path: Services"))
        XCTAssertFalse(project.contains("iOSApp/Services/WatchFullComputerAltitudeSensorProposalSettingsStore.swift"))
    }

    func testSettingsSectionExistsOnlyInWatchSettingsView() throws {
        let root = FullComputerWatchArchitectureGuard.repositoryRoot(from: #filePath)
        let watchSettings = try String(contentsOf: root.appendingPathComponent("Views/SettingsView.swift"), encoding: .utf8)
        XCTAssertTrue(watchSettings.contains("WatchFullComputerAltitudeSensorSettingsSection"))
        let iosSettingsDir = root.appendingPathComponent("iOSApp/Views")
        if FileManager.default.fileExists(atPath: iosSettingsDir.path) {
            let enumerator = FileManager.default.enumerator(at: iosSettingsDir, includingPropertiesForKeys: nil)
            while let url = enumerator?.nextObject() as? URL {
                guard url.pathExtension == "swift" else { continue }
                let source = try String(contentsOf: url, encoding: .utf8)
                XCTAssertFalse(source.contains("WatchFullComputerAltitudeSensorSettingsSection"))
                XCTAssertFalse(source.contains("FullComputerAltitudeSensorProposalMode"))
            }
        }
    }

    func testActivityScopeVisibilityKeys() throws {
        let root = FullComputerWatchArchitectureGuard.repositoryRoot(from: #filePath)
        let scope = try String(contentsOf: root.appendingPathComponent("Views/WatchActivitySettingsSections.swift"), encoding: .utf8)
        XCTAssertTrue(scope.contains("isDivingOnlySettingVisible"))
        XCTAssertTrue(scope.contains("isApneaOnlySettingVisible"))
        XCTAssertTrue(scope.contains("isSnorkelingOnlySettingVisible"))
    }
}

final class FullComputerAltitudeSamplingPolicyDocumentationTests: XCTestCase {
    func testDocumentedThresholdsMatchCode() throws {
        let root = FullComputerWatchArchitectureGuard.repositoryRoot(from: #filePath)
        let doc = try String(contentsOf: root.appendingPathComponent("Docs/WATCH_CMALTIMETER_SAMPLING_POLICY_CURRENT.md"), encoding: .utf8)
        XCTAssertTrue(doc.contains("\(FullComputerAltitudeSamplingPolicy.requiredSampleCount)"))
        XCTAssertTrue(doc.contains("\(Int(FullComputerAltitudeSamplingPolicy.maximumStableSpreadMeters))"))
        XCTAssertTrue(doc.contains("\(Int(FullComputerEnvironmentRecord.maximumSensorAccuracyMeters))"))
        XCTAssertTrue(doc.contains("\(Int(FullComputerAltitudeSamplingPolicy.timeoutSeconds))"))
        XCTAssertTrue(doc.contains("\(Int(FullComputerEnvironmentRecord.maximumSensorAgeSeconds))"))
    }

    func testInfoPlistMentionsAltitudeOrEnvironment() throws {
        let root = FullComputerWatchArchitectureGuard.repositoryRoot(from: #filePath)
        let plist = try String(contentsOf: root.appendingPathComponent("App/Info.plist"), encoding: .utf8)
        XCTAssertTrue(plist.localizedCaseInsensitiveContains("altitude") || plist.localizedCaseInsensitiveContains("environment"))
        XCTAssertTrue(plist.localizedCaseInsensitiveContains("accept"))
    }
}

@MainActor
final class WatchCMAltimeterLogbookProvenanceTests: XCTestCase {
    func testLogbookRecordPrefersSessionSnapshotSource() throws {
        let environment = try XCTUnwrap(
            FullComputerEnvironmentRecord.make(
                altitudeMeters: 1_200,
                salinity: .salt,
                source: .watchSettingsManual
            ).successValue
        )
        let runtime = try XCTUnwrap(environment.plannerEnvironment)
        let record = FullComputerEnvironmentRecord.logbookRecord(
            plannerEnvironment: runtime,
            preferred: nil,
            sessionSnapshot: environment
        )
        XCTAssertEqual(record.source, .watchSettingsManual)
        XCTAssertNotEqual(record.source, .legacyUnknown)
    }

    func testLogbookExportIncludesSensorReceivedAtForSensorProposal() throws {
        let sensorTime = Date(timeIntervalSince1970: 90_000)
        let receipt = sensorTime.addingTimeInterval(1)
        var environment = try XCTUnwrap(
            FullComputerEnvironmentRecord.make(
                altitudeMeters: 1_500,
                salinity: .salt,
                source: .watchSensorMeasuredProposal,
                capturedAt: sensorTime,
                sensorReceivedAt: receipt
            ).successValue
        )
        environment.sensorAccuracyMeters = 4
        environment.sensorPrecisionMeters = 1
        let plan = FullComputerRuntimePlan(
            profile: .defaultAirGF3070,
            plannerEnvironment: try XCTUnwrap(environment.plannerEnvironment)
        )
        let start = Date(timeIntervalSince1970: 91_000)
        var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: start)
        engine.tick(now: start.addingTimeInterval(30))
        var accumulator = FullComputerRuntimeLogbookAccumulator()
        accumulator.ingest(snapshot: engine.snapshot, gasSwitchTracker: engine.persistedGasSwitchTracker)
        let metadata = accumulator.export(
            watchDivingMode: DIRDivingMode.fullComputer.rawValue,
            gfLow: 30,
            gfHigh: 70,
            gasSwitchEvents: [],
            unavailableGasMixIds: [],
            algorithmVersion: FullComputerRuntimeConfiguration.algorithmVersion,
            environmentRecord: environment
        )
        XCTAssertEqual(metadata.environmentSourceRaw, FullComputerEnvironmentSource.watchSensorMeasuredProposal.rawValue)
        XCTAssertEqual(try XCTUnwrap(metadata.environmentSensorReceivedAt).timeIntervalSince1970, receipt.timeIntervalSince1970, accuracy: 0.01)
    }
}

@MainActor
final class WatchCMAltimeterBuhlmannAltitudeOracleTests: XCTestCase {
    private let altitudes: [Double] = [0, 500, 1_000, 1_500, 2_000, 4_500]

    override func setUp() {
        super.setUp()
        FullComputerPrediveConfigurationStore.shared.resetForTests()
        FullComputerPrediveConfigurationStore.shared.clearEnvironmentForTestsOnly()
        FullComputerEnvironmentSensorService.shared.resetForTests()
        WatchFullComputerAltitudeSensorProposalSettingsStore.shared.resetForTests()
    }

    func testAllSixteenCompartmentsMatchOracleAtAltitudeMatrix() throws {
        let start = Date(timeIntervalSince1970: 100_000)
        for altitude in altitudes {
            let surface = try XCTUnwrap(IndependentBuhlmannOracle.independentSurfacePressureBar(altitudeMeters: altitude))
            let environment = PlannerEnvironment(
                altitudeMeters: altitude,
                salinity: .salt,
                surfacePressureBar: surface,
                waterDensityKgPerM3: WaterDensityModel.saltwaterDensityKgPerM3
            )
            let plan = FullComputerRuntimePlan(profile: .defaultAirGF3070, plannerEnvironment: environment)
            var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: start)
            let oracle = IndependentOracleTissueState.airSaturated(surfacePressureBar: surface)
            for index in 0..<16 {
                XCTAssertEqual(
                    engine.snapshot.tissueState.compartments[index].nitrogenPressure,
                    oracle.compartments[index].pn2Bar,
                    accuracy: 0.0005,
                    "N2 compartment \(index) @ \(altitude)m"
                )
                XCTAssertEqual(
                    engine.snapshot.tissueState.compartments[index].heliumPressure,
                    oracle.compartments[index].pheBar,
                    accuracy: 0.0005,
                    "He compartment \(index) @ \(altitude)m"
                )
            }
            engine.tick(now: start.addingTimeInterval(600))
            let ambient = try XCTUnwrap(AmbientPressureModel.ambientPressureBar(depthMeters: 30, environment: environment))
            let seaAmbient = try XCTUnwrap(AmbientPressureModel.ambientPressureBar(depthMeters: 30, environment: .seaLevelSaltWater))
            if altitude > 0 {
                XCTAssertLessThan(ambient, seaAmbient, "altitude \(altitude)m ambient")
            }
            if let ndl = engine.snapshot.ndlMinutes {
                XCTAssertGreaterThan(ndl, 0, "altitude \(altitude)m NDL")
            }
        }
    }

    func testAcceptedSensorEnvironmentPropagatesToRuntimeOracle() throws {
        let config = FullComputerPrediveConfigurationStore.shared
        config.clearEnvironmentForTestsOnly()
        let provider = FakeAbsoluteAltitudeProvider()
        let service = FullComputerEnvironmentSensorService(provider: provider)
        let now = Date()

        service.requestProposal(into: config)
        for offset in 0..<5 {
            provider.emit(
                altitudeMeters: 1_500 + Double(offset) * 0.4,
                accuracyMeters: 5,
                precisionMeters: 1,
                sensorMeasuredAt: now.addingTimeInterval(Double(offset) * 0.1)
            )
        }
        XCTAssertEqual(service.state, .proposalReady)
        config.acceptPendingSensorProposal()
        XCTAssertTrue(config.isDraftValid)
        config.commitConfirmedProfile()
        let plan = try XCTUnwrap(config.runtimePlan())
        XCTAssertEqual(plan.plannerEnvironment.altitudeMeters, 1_500, accuracy: 1)
        var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: now)
        let oracle = IndependentOracleTissueState.airSaturated(
            surfacePressureBar: plan.plannerEnvironment.surfacePressureBar
        )
        for index in 0..<16 {
            XCTAssertEqual(
                engine.snapshot.tissueState.compartments[index].nitrogenPressure,
                oracle.compartments[index].pn2Bar,
                accuracy: 0.0005
            )
        }
        _ = engine
    }
}

@MainActor
final class WatchManualAltitudeStepperTests: XCTestCase {
    override func setUp() {
        super.setUp()
        FullComputerPrediveConfigurationStore.shared.resetForTests()
        FullComputerPrediveConfigurationStore.shared.clearEnvironmentForTestsOnly()
    }

    func testManualAltitudeRecordUpdatesSurfacePressure() throws {
        let config = FullComputerPrediveConfigurationStore.shared
        config.setDraftEnvironment(altitudeMeters: 1_010, salinity: .salt, source: .watchSettingsManual)
        let record = try XCTUnwrap(config.draftEnvironment)
        let sea = PlannerEnvironment.seaLevelSaltWater.surfacePressureBar
        XCTAssertLessThan(record.surfacePressureBar, sea)
        config.setDraftEnvironment(altitudeMeters: 1_020, salinity: .salt, source: .watchSettingsManual)
        let updated = try XCTUnwrap(config.draftEnvironment)
        XCTAssertLessThan(updated.surfacePressureBar, record.surfacePressureBar)
    }
}

private extension Result {
    var successValue: Success? {
        if case .success(let value) = self { return value }
        return nil
    }
}
