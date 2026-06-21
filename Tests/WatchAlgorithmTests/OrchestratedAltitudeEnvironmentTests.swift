import XCTest

@MainActor
final class OrchestratedAltitudeEnvironmentTests: XCTestCase {
    private let planID = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!

    override func setUp() {
        super.setUp()
        FullComputerImportedPlanStore.shared.resetForTests()
        FullComputerPrediveConfigurationStore.shared.resetForTests()
        FullComputerPrediveConfigurationStore.shared.clearEnvironmentForTestsOnly()
        FullComputerEnvironmentSensorService.shared.resetForTests()
        WatchFullComputerAltitudeSensorProposalSettingsStore.shared.resetForTests()
    }

    override func tearDown() {
        FullComputerEnvironmentSensorService.shared.resetForTests()
        WatchFullComputerAltitudeSensorProposalSettingsStore.shared.resetForTests()
        FullComputerImportedPlanStore.shared.resetForTests()
        FullComputerPrediveConfigurationStore.shared.resetForTests()
        super.tearDown()
    }

    func testRuntimePlanWithoutEnvironmentIsNil() {
        FullComputerPrediveConfigurationStore.shared.clearEnvironmentForTestsOnly()
        XCTAssertNil(FullComputerPrediveConfigurationStore.shared.runtimePlan())
    }

    func testImported1500mSaltPlanPropagatesToRuntimeEnvironment() throws {
        let package = try makePackage(altitudeMeters: 1_500, salinity: .salt, revision: 1)
        let store = FullComputerImportedPlanStore.shared
        let config = FullComputerPrediveConfigurationStore.shared
        XCTAssertTrue(store.importPayload(package, source: "test"))
        try store.activatePendingPlan(configuration: config)
        let plan = try XCTUnwrap(config.runtimePlan())
        XCTAssertEqual(plan.plannerEnvironment.altitudeMeters, 1_500, accuracy: 0.01)
        XCTAssertEqual(plan.plannerEnvironment.salinity, .salt)
        XCTAssertNotEqual(plan.plannerEnvironment.surfacePressureBar, PlannerEnvironment.seaLevelSaltWater.surfacePressureBar, accuracy: 0.001)
        XCTAssertEqual(config.confirmedEnvironment?.source, .iPhonePlanImported)
    }

    func testImported500mAirAnd2000mFreshProfiles() throws {
        let airPackage = try makePackage(altitudeMeters: 500, salinity: .salt, revision: 2)
        try activateAndAssert(airPackage, expectedAltitude: 500, expectedSalinity: .salt)

        FullComputerImportedPlanStore.shared.resetForTests()
        FullComputerPrediveConfigurationStore.shared.resetForTests()
        FullComputerPrediveConfigurationStore.shared.clearEnvironmentForTestsOnly()

        let freshPackage = try makePackage(altitudeMeters: 2_000, salinity: .fresh, revision: 3)
        try activateAndAssert(freshPackage, expectedAltitude: 2_000, expectedSalinity: .fresh)
    }

    func testInvalidAltitudePackageRejected() throws {
        let package = try makeInvalidAltitudePackage(altitudeMeters: 5_000, revision: 4)
        XCTAssertFalse(FullComputerImportedPlanStore.shared.importPayload(package, source: "test"))
        XCTAssertEqual(FullComputerImportedPlanStore.shared.lastImportError, .invalidEnvironment)
    }

    func testLogbookMetadataCapturesEnvironment() throws {
        let start = Date(timeIntervalSince1970: 40_000)
        let environment = try XCTUnwrap(
            FullComputerEnvironmentRecord.make(altitudeMeters: 1_500, salinity: .salt, source: .iPhonePlanImported).successValue
        )
        let plan = FullComputerRuntimePlan(
            profile: .defaultAirGF3070,
            plannerEnvironment: try XCTUnwrap(environment.plannerEnvironment)
        )
        var engine = try FullComputerRuntimeEngine(plan: plan, sessionStart: start)
        engine.tick(now: start.addingTimeInterval(60))
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
        XCTAssertEqual(try XCTUnwrap(metadata.altitudeMeters), 1_500, accuracy: 0.01)
        XCTAssertEqual(metadata.salinityRaw, SalinityMode.salt.rawValue)
        XCTAssertEqual(metadata.environmentSourceRaw, FullComputerEnvironmentSource.iPhonePlanImported.rawValue)
        XCTAssertTrue(metadata.hasKnownEnvironment)
    }

    func testIndependentOraclePressureDiffersFromSeaLevelAtAltitude() {
        guard let surface = IndependentBuhlmannOracle.independentSurfacePressureBar(altitudeMeters: 1_500) else {
            return XCTFail("expected independent surface pressure")
        }
        XCTAssertLessThan(surface, PlannerEnvironment.seaLevelSaltWater.surfacePressureBar)
        let environment = PlannerEnvironment(
            altitudeMeters: 1_500,
            salinity: .salt,
            surfacePressureBar: surface,
            waterDensityKgPerM3: WaterDensityModel.saltwaterDensityKgPerM3
        )
        let ambient = IndependentBuhlmannOracle.ambientPressureBar(depthMeters: 30, environment: environment)
        let seaAmbient = IndependentBuhlmannOracle.ambientPressureBar(depthMeters: 30, environment: .seaLevelSaltWater)
        XCTAssertLessThan(ambient, seaAmbient)
    }

    func testWatchManualEnvironmentPropagatesToConfirmedRuntime() throws {
        let config = FullComputerPrediveConfigurationStore.shared
        config.setDraftEnvironment(
            altitudeMeters: 1_200,
            salinity: .fresh,
            source: .watchSettingsManual
        )
        config.commitConfirmedProfile()

        let plan = try XCTUnwrap(config.runtimePlan())
        XCTAssertEqual(plan.plannerEnvironment.altitudeMeters, 1_200, accuracy: 0.01)
        XCTAssertEqual(plan.plannerEnvironment.salinity, .fresh)
        XCTAssertEqual(config.confirmedEnvironment?.source, .watchSettingsManual)
    }

    func testSensorMeasurementRemainsPendingUntilExplicitAcceptance() throws {
        let config = FullComputerPrediveConfigurationStore.shared
        config.setDraftEnvironment(
            altitudeMeters: 900,
            salinity: .salt,
            source: .watchSettingsManual
        )
        let provider = FakeAbsoluteAltitudeProvider()
        let service = FullComputerEnvironmentSensorService(provider: provider)

        service.requestProposal(into: config)
        for offset in [0.0, 1.0, -1.0, 2.0, 0.5] {
            provider.emit(
                altitudeMeters: 1_250 + offset,
                accuracyMeters: 8,
                precisionMeters: 1
            )
        }

        XCTAssertEqual(service.state, .proposalReady)
        XCTAssertEqual(try XCTUnwrap(config.draftEnvironment?.altitudeMeters), 900, accuracy: 0.01)
        XCTAssertEqual(config.draftEnvironment?.source, .watchSettingsManual)
        XCTAssertEqual(config.pendingSensorProposal?.source, .watchSensorMeasuredProposal)
        XCTAssertEqual(try XCTUnwrap(config.pendingSensorProposal?.altitudeMeters), 1_250.5, accuracy: 0.01)

        config.acceptPendingSensorProposal()
        XCTAssertNil(config.pendingSensorProposal)
        XCTAssertEqual(config.draftEnvironment?.source, .watchSensorMeasuredProposal)
        XCTAssertEqual(try XCTUnwrap(config.draftEnvironment?.sensorAccuracyMeters), 8, accuracy: 0.01)
        service.cancel()
    }

    func testSensorProposalDoesNotCreateEnvironmentWithoutAcceptance() {
        let config = FullComputerPrediveConfigurationStore.shared
        let provider = FakeAbsoluteAltitudeProvider()
        let service = FullComputerEnvironmentSensorService(provider: provider)

        service.requestProposal(into: config)
        for altitude in [1_498.0, 1_500.0, 1_501.0, 1_499.0, 1_500.5] {
            provider.emit(
                altitudeMeters: altitude,
                accuracyMeters: 6,
                precisionMeters: 1
            )
        }

        XCTAssertNil(config.draftEnvironment)
        XCTAssertNotNil(config.pendingSensorProposal)
        XCTAssertNil(config.runtimePlan())
        service.cancel()
    }

    func testSensorSamplingRejectsInaccurateOrUnstableWindows() {
        let now = Date(timeIntervalSince1970: 50_000)
        let inaccurate = (0..<5).map { index in
            FullComputerAbsoluteAltitudeSample(
                altitudeMeters: 1_000 + Double(index),
                accuracyMeters: FullComputerEnvironmentRecord.maximumSensorAccuracyMeters + 1,
                precisionMeters: 1,
                sensorMeasuredAt: now.addingTimeInterval(Double(index)),
                receivedAt: now.addingTimeInterval(Double(index))
            )
        }
        XCTAssertNil(FullComputerAltitudeSamplingPolicy.stableProposal(from: inaccurate))

        let unstableAltitudes = [1_000.0, 1_030.0, 990.0, 1_025.0, 980.0]
        let unstable = unstableAltitudes.enumerated().map { index, altitude in
            FullComputerAbsoluteAltitudeSample(
                altitudeMeters: altitude,
                accuracyMeters: 5,
                precisionMeters: 1,
                sensorMeasuredAt: now.addingTimeInterval(Double(index)),
                receivedAt: now.addingTimeInterval(Double(index))
            )
        }
        XCTAssertNil(FullComputerAltitudeSamplingPolicy.stableProposal(from: unstable))
    }

    func testLiveEnvironmentRejectsFutureSchemaDensityMismatchAndMissingSensorMetadata() throws {
        var future = try XCTUnwrap(
            FullComputerEnvironmentRecord.make(
                altitudeMeters: 1_000,
                salinity: .salt,
                source: .watchSettingsManual
            ).successValue
        )
        future.schemaVersion += 1
        XCTAssertEqual(future.validateForLiveStart(), .unsupportedSchema)

        var wrongDensity = try XCTUnwrap(
            FullComputerEnvironmentRecord.make(
                altitudeMeters: 1_000,
                salinity: .fresh,
                source: .watchSettingsManual
            ).successValue
        )
        wrongDensity.waterDensityKgPerM3 += 10
        XCTAssertEqual(wrongDensity.validateForLiveStart(), .waterDensityMismatch)

        let sensorWithoutAccuracy = try XCTUnwrap(
            FullComputerEnvironmentRecord.make(
                altitudeMeters: 1_000,
                salinity: .salt,
                source: .watchSensorMeasuredProposal
            ).successValue
        )
        XCTAssertEqual(sensorWithoutAccuracy.validateForLiveStart(), .invalidSensorMetadata)

        let now = Date(timeIntervalSince1970: 60_000)
        var staleSensor = try XCTUnwrap(
            FullComputerEnvironmentRecord.make(
                altitudeMeters: 1_000,
                salinity: .salt,
                source: .watchSensorMeasuredProposal,
                capturedAt: now.addingTimeInterval(-(FullComputerEnvironmentRecord.maximumSensorAgeSeconds + 1))
            ).successValue
        )
        staleSensor.sensorAccuracyMeters = 5
        staleSensor.sensorPrecisionMeters = 1
        XCTAssertEqual(staleSensor.validateForLiveStart(now: now), .staleSensorMeasurement)
    }

    private func activateAndAssert(
        _ package: DivePlanPackage,
        expectedAltitude: Double,
        expectedSalinity: SalinityMode,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let config = FullComputerPrediveConfigurationStore.shared
        XCTAssertTrue(FullComputerImportedPlanStore.shared.importPayload(package, source: "test"), file: file, line: line)
        try FullComputerImportedPlanStore.shared.activatePendingPlan(configuration: config)
        let plan = try XCTUnwrap(config.runtimePlan(), file: file, line: line)
        XCTAssertEqual(plan.plannerEnvironment.altitudeMeters, expectedAltitude, accuracy: 0.01, file: file, line: line)
        XCTAssertEqual(plan.plannerEnvironment.salinity, expectedSalinity, file: file, line: line)
    }

    private func makePackage(
        altitudeMeters: Double,
        salinity: SalinityMode,
        revision: Int,
        bottomName: String = "Air",
        fo2: Double = 0.21,
        fhe: Double = 0
    ) throws -> DivePlanPackage {
        let bottomID = UUID()
        let decoID = UUID()
        let surface = try XCTUnwrap(AmbientPressureModel.surfacePressureBar(altitudeMeters: altitudeMeters))
        let body = DivePlanPackageBody(
            schemaVersion: DivePlanPackageCodec.currentSchemaVersion,
            algorithmVersion: DivePlanPackageCodec.algorithmVersion,
            planID: planID,
            revision: revision,
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(3600),
            environment: DivePlanEnvironmentPayload(
                altitudeMeters: altitudeMeters,
                salinityRaw: salinity.rawValue,
                surfacePressureBar: surface
            ),
            gfLow: 30,
            gfHigh: 70,
            gases: [
                DivePlanGasPayload(
                    id: bottomID,
                    name: bottomName,
                    role: .bottom,
                    oxygenFraction: fo2,
                    heliumFraction: fhe,
                    maxPPO2Bar: 1.4,
                    switchDepthMeters: nil,
                    sortOrder: 0
                ),
                DivePlanGasPayload(
                    id: decoID,
                    name: "EAN50",
                    role: .deco,
                    oxygenFraction: 0.50,
                    heliumFraction: 0,
                    maxPPO2Bar: 1.6,
                    switchDepthMeters: 21,
                    sortOrder: 1
                ),
            ],
            bottomSegments: [DivePlanBottomSegmentPayload(depthMeters: 30, durationMinutes: 20, order: 0)],
            plannedSwitches: [DivePlanGasSwitchPayload(gasID: decoID, switchDepthMeters: 21, order: 0)],
            plannerSummary: DivePlanSummaryPayload(
                modeLabel: "Deco",
                planKind: "single",
                maxDepthMeters: 45,
                bottomMinutes: 20,
                totalRuntimeMinutes: 55,
                requiresDeco: true,
                decoStopCount: 2
            ),
            capabilities: .current
        )
        return try DivePlanPackageCodec.seal(body)
    }

    private func makeInvalidAltitudePackage(altitudeMeters: Double, revision: Int) throws -> DivePlanPackage {
        let body = DivePlanPackageBody(
            schemaVersion: DivePlanPackageCodec.currentSchemaVersion,
            algorithmVersion: DivePlanPackageCodec.algorithmVersion,
            planID: planID,
            revision: revision,
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(3600),
            environment: DivePlanEnvironmentPayload(
                altitudeMeters: altitudeMeters,
                salinityRaw: SalinityMode.salt.rawValue,
                surfacePressureBar: 1.0
            ),
            gfLow: 30,
            gfHigh: 70,
            gases: [
                DivePlanGasPayload(
                    id: UUID(),
                    name: "Air",
                    role: .bottom,
                    oxygenFraction: 0.21,
                    heliumFraction: 0,
                    maxPPO2Bar: 1.4,
                    switchDepthMeters: nil,
                    sortOrder: 0
                ),
            ],
            bottomSegments: [DivePlanBottomSegmentPayload(depthMeters: 20, durationMinutes: 10, order: 0)],
            plannedSwitches: [],
            plannerSummary: DivePlanSummaryPayload(
                modeLabel: "Base",
                planKind: "single",
                maxDepthMeters: 20,
                bottomMinutes: 10,
                totalRuntimeMinutes: 20,
                requiresDeco: false,
                decoStopCount: 0
            ),
            capabilities: .current
        )
        return try DivePlanPackageCodec.seal(body)
    }
}

private extension Result {
    var successValue: Success? {
        if case .success(let value) = self { return value }
        return nil
    }
}
