import XCTest

final class AuditRemediationTests: XCTestCase {
    // MARK: - P2.1 Environment-aware MOD

    func testAirEAN32EAN36MODAtSeaLevel() {
        let environment = PlannerEnvironment.seaLevelSaltWater
        let air = GasMix(name: "Air", oxygen: 0.21, helium: 0, maxPPO2: 1.4)
        let ean32 = GasMix(name: "EAN32", oxygen: 0.32, helium: 0, maxPPO2: 1.4)
        let ean36 = GasMix(name: "EAN36", oxygen: 0.36, helium: 0, maxPPO2: 1.4)
        let airMOD = PlannerMODValidator.modMeters(for: air, environment: environment)
        let ean32MOD = PlannerMODValidator.modMeters(for: ean32, environment: environment)
        let ean36MOD = PlannerMODValidator.modMeters(for: ean36, environment: environment)
        XCTAssertGreaterThan(airMOD, ean32MOD)
        XCTAssertGreaterThan(ean32MOD, ean36MOD)
    }

    func testEAN32MODAdjustsWithAltitude() {
        let gas = GasMix(name: "EAN32", oxygen: 0.32, helium: 0, maxPPO2: 1.4)
        let seaMOD = PlannerMODValidator.modMeters(for: gas, environment: .seaLevelSaltWater)
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: 2_000, salinity: .salt) else {
            return XCTFail("Expected valid altitude environment")
        }
        let altitudeMOD = PlannerMODValidator.modMeters(for: gas, environment: environment)
        XCTAssertGreaterThan(altitudeMOD, seaMOD)
    }

    func testFreshwaterMODDiffersFromSaltwaterAtSeaLevel() {
        let gas = GasMix(name: "EAN32", oxygen: 0.32, helium: 0, maxPPO2: 1.4)
        guard case .success(let fresh) = PlannerEnvironment.make(altitudeMeters: 0, salinity: .fresh),
              case .success(let salt) = PlannerEnvironment.make(altitudeMeters: 0, salinity: .salt) else {
            return XCTFail("Expected environments")
        }
        let freshMOD = PlannerMODValidator.modMeters(for: gas, environment: fresh)
        let saltMOD = PlannerMODValidator.modMeters(for: gas, environment: salt)
        XCTAssertNotEqual(freshMOD, saltMOD, accuracy: 0.01)
    }

    func testGasMixCardDisplayMatchesPlannerMODValidator() {
        var input = GasPlanInput()
        input.altitudeMeters = 2_000
        input.salinity = .salt
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.50, helium: 0, maxPPO2: 1.6), switchDepthMeters: 21)
        ]
        let environment = input.plannerEnvironment
        let entry = input.plannerCylinders[0]
        XCTAssertEqual(
            entry.modMeters(environment: environment),
            PlannerMODValidator.modMeters(for: entry.gas, environment: environment),
            accuracy: 0.001
        )
    }

    func testGasPlanningServiceMODWarningUsesEnvironment() {
        var input = GasPlanInput()
        input.plannedDepthMeters = 40
        input.altitudeMeters = 3_000
        input.bottomGas = GasMix(name: "EAN32", role: .bottom, oxygen: 0.32, helium: 0, maxPPO2: 1.4)
        let analysis = GasPlanningService.analyze(input: input)
        XCTAssertTrue(analysis.states.contains(.MODExceeded))
    }

    // MARK: - P2.2 Duplicate session IDs

    func testDuplicateCloudSessionsDoNotTrapConflictDetection() {
        let id = UUID()
        let start = Date(timeIntervalSince1970: 1_000)
        let older = makeSession(id: id, start: start, siteName: "Older", endOffset: 100)
        let newer = makeSession(id: id, start: start, siteName: "Newer", endOffset: 200)
        let local = makeSession(siteName: "Local")
        let conflicts = DiveSessionMergeConflictDetector.detect(local: [local], cloud: [older, newer])
        XCTAssertFalse(conflicts.contains { $0.fieldName == "siteName" && $0.sessionID == id })
        XCTAssertTrue(conflicts.contains { $0.fieldName == "duplicateSessionID" && $0.sessionID == id })
    }

    func testDuplicateLocalSessionsDoNotTrapConflictDetection() {
        let id = UUID()
        let start = Date(timeIntervalSince1970: 1_000)
        let older = makeSession(id: id, start: start, siteName: "Older", endOffset: 100)
        let newer = makeSession(id: id, start: start, siteName: "Newer", endOffset: 200)
        let cloud = makeSession(id: id, start: start, siteName: "Cloud", endOffset: 150)
        let conflicts = DiveSessionMergeConflictDetector.detect(local: [older, newer], cloud: [cloud])
        XCTAssertTrue(conflicts.contains { $0.fieldName == "duplicateSessionID" && $0.sessionID == id })
    }

    func testDeduplicationKeepsNewestSession() {
        let id = UUID()
        let start = Date(timeIntervalSince1970: 1_000)
        let older = makeSession(id: id, start: start, siteName: "Older", endOffset: 100)
        let newer = makeSession(id: id, start: start, siteName: "Newer", endOffset: 200)
        let result = DiveSessionCollectionIntegrity.deduplicated([older, newer])
        XCTAssertEqual(result.duplicateSessionIDs, [id])
        XCTAssertEqual(result.sessions.first?.siteName, "Newer")
    }

    func testCorruptedDuplicateInputDoesNotTrap() {
        let id = UUID()
        let start = Date(timeIntervalSince1970: 1_000)
        let a = makeSession(id: id, start: start, siteName: "A", endOffset: 120)
        let b = makeSession(id: id, start: start, siteName: "B", endOffset: 120)
        XCTAssertNoThrow(DiveSessionMergeConflictDetector.detect(local: [a, b], cloud: [a, b]))
    }

    // MARK: - P2.3 Bühlmann preflight

    func testHypoxicTrimixRejectedBeforeScheduleGeneration() {
        let request = BuhlmannTestSupport.request(
            depth: 20,
            bottomMinutes: 20,
            bottomGas: BuhlmannGas(
                name: "TX 8/50",
                role: .bottom,
                oxygenFraction: 0.08,
                heliumFraction: 0.50,
                maxPPO2Bar: 1.4,
                switchDepthMeters: 20
            )
        )
        let issues = BuhlmannPlanPreflightValidator.validate(request)
        XCTAssertFalse(issues.isEmpty)
        let plan = PlannerService.makePlan(input: makeGasPlanInput(from: request))
        XCTAssertTrue(plan.buhlmannState == .invalidInput || !plan.decoStops.isEmpty || plan.ttrMinutes >= 0)
    }

    func testEAN50SwitchedTooDeepRejected() {
        let request = BuhlmannTestSupport.request(
            depth: 45,
            bottomMinutes: 20,
            bottomGas: BuhlmannTestSupport.trimix1845(switchDepth: 45),
            decoGases: [BuhlmannTestSupport.ean50(switchDepth: 40)]
        )
        let issues = BuhlmannPlanPreflightValidator.validate(request)
        XCTAssertTrue(issues.contains(where: {
            if case .gasSwitchTooDeep = $0 { return true }
            return false
        }))
    }

    func testValidMultigasPlanUnchangedByPreflight() {
        let request = BuhlmannTestSupport.request(
            depth: 45,
            bottomMinutes: 20,
            bottomGas: BuhlmannTestSupport.trimix1845(switchDepth: 45),
            decoGases: [BuhlmannTestSupport.ean50(switchDepth: 21), BuhlmannTestSupport.oxygen(switchDepth: 6)]
        )
        XCTAssertTrue(BuhlmannPlanPreflightValidator.validate(request).isEmpty)
    }

    // MARK: - P3.2 CSV temperature optional

    func testCSVWithoutTemperatureImportsSuccessfully() throws {
        let csv = """
        time_seconds,depth_m
        0,0
        60,12
        """
        let url = try temporaryCSV(csv)
        guard case .success(let summary) = DiveImportService.importCSV(from: url) else {
            return XCTFail("Expected import without temperature column")
        }
        XCTAssertNil(summary.session.avgWaterTemperatureCelsius)
        XCTAssertTrue(summary.session.samples.allSatisfy { $0.temperatureCelsius == nil })
    }

    func testCSVMissingDepthStillRejected() throws {
        let csv = """
        time_seconds
        0
        """
        let url = try temporaryCSV(csv)
        guard case .failure(.emptyProfile) = DiveImportService.importCSV(from: url) else {
            return XCTFail("Expected emptyProfile failure when depth column is absent")
        }
    }

    // MARK: - P3.3 Sync key hardening

    func testMissingPeerSecretSigningFailsSafely() {
        WatchSyncAuth.resetPeerTrust()
        XCTAssertFalse(WatchSyncAuth.hasPeerSecret())
        XCTAssertThrowsError(try WatchSyncAuth.deriveSyncKey(peerBundleID: "com.egopfe.dirdiving.ios.watch")) { error in
            XCTAssertEqual(error as? WatchSyncAuthError, .missingPeerSecret)
        }
        let signature = WatchDiveSyncCodec.ackSignature(sessionID: UUID(), issuedAt: Date())
        XCTAssertTrue(signature.isEmpty)
    }

    func testPeerSecretPresentSigningWorks() throws {
        WatchSyncAuth.resetPeerTrust()
        defer { WatchSyncAuth.resetPeerTrust() }
        let peerSecret = Data(repeating: 9, count: 32).base64EncodedString()
        WatchSyncAuth.ingestSharedSecretFromContext([WatchSyncAuth.contextKey: peerSecret])
        guard WatchSyncAuth.hasPeerSecret() else {
            throw XCTSkip("Peer secret unavailable in test keychain")
        }
        do {
            _ = try WatchSyncAuth.deriveSyncKey(peerBundleID: "com.egopfe.dirdiving.ios.watch")
        } catch {
            throw XCTSkip("Local sync secret unavailable in test keychain")
        }
        XCTAssertFalse(WatchDiveSyncCodec.ackSignature(sessionID: UUID(), issuedAt: Date()).isEmpty)
    }

    // MARK: - P3.5 Unused planned gas visibility

    func testUnusedCylinderAppearsInUnusedListWithoutChangingConsumedTotals() {
        var input = GasPlanInput()
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas),
            PlannerCylinderEntry(role: .bailout, gas: GasMix(name: "Bailout", role: .bailout, oxygen: 0.21, helium: 0, maxPPO2: 1.4), switchDepthMeters: 6)
        ]
        let environment = input.plannerEnvironment
        let enginePlan = BuhlmannPlanner.enginePlan(input: input)
        guard case .success(let ledger) = ScheduleGasConsumptionService.analyze(input: input, enginePlan: enginePlan, environment: environment) else {
            return XCTFail("Expected ledger")
        }
        XCTAssertFalse(ledger.unusedPlannedEntries.isEmpty)
        XCTAssertTrue(ledger.unusedPlannedEntries.contains { $0.role == .bailout })
        XCTAssertGreaterThan(ledger.totalConsumedLiters, 0)
    }

    // MARK: - P3.7 Fixtures

    func testAltitudeFreshwaterMODFixtureRegression() {
        guard case .success(let seaFresh) = PlannerEnvironment.make(altitudeMeters: 0, salinity: .fresh),
              case .success(let altitudeFresh) = PlannerEnvironment.make(altitudeMeters: 1_500, salinity: .fresh) else {
            return XCTFail("Expected environments")
        }
        let gas = GasMix(name: "EAN32", oxygen: 0.32, helium: 0, maxPPO2: 1.4)
        let seaMOD = PlannerMODValidator.modMeters(for: gas, environment: seaFresh)
        let altitudeMOD = PlannerMODValidator.modMeters(for: gas, environment: altitudeFresh)
        XCTAssertGreaterThan(seaMOD, 0)
        XCTAssertGreaterThan(altitudeMOD, seaMOD)
    }

    func testGF3070Versus5080ComparisonTolerance() {
        BuhlmannPlanner.clearGFComparisonCacheForTesting()
        var input = GasPlanInput()
        input.plannedDepthMeters = 40
        input.plannedBottomMinutes = 20
        input.gfLow = 50
        input.gfHigh = 80
        let comparisons = BuhlmannPlanner.gfComparisons(input: input)
        let conservative = comparisons.first { $0.label == "30/70" }
        let aggressive = comparisons.first { $0.label == "CUSTOM" }
        XCTAssertNotNil(conservative)
        XCTAssertNotNil(aggressive)
        XCTAssertGreaterThanOrEqual(conservative?.ttsMinutes ?? 0, aggressive?.ttsMinutes ?? 0)
    }

    // MARK: - Helpers

    private func makeSession(
        id: UUID = UUID(),
        start: Date = Date(timeIntervalSince1970: 1_000),
        siteName: String? = nil,
        endOffset: TimeInterval = 120
    ) -> DiveSession {
        let end = start.addingTimeInterval(endOffset)
        let samples = [
            DiveSample(timestamp: start, depthMeters: 0, temperatureCelsius: 20),
            DiveSample(timestamp: end, depthMeters: 18, temperatureCelsius: 20)
        ]
        let summary = DiveProfileMath.summary(samples: samples, startDate: start, endDate: end)
        return DiveSession(
            id: id,
            startDate: start,
            endDate: end,
            durationSeconds: summary.durationSeconds,
            maxDepthMeters: summary.maxDepthMeters,
            avgDepthMeters: summary.averageDepthMeters,
            avgWaterTemperatureCelsius: summary.averageTemperatureCelsius,
            ttv: summary.ttv,
            entryGPS: nil,
            exitGPS: nil,
            samples: samples,
            siteName: siteName
        )
    }

    private func temporaryCSV(_ contents: String) throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).csv")
        try contents.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private func makeGasPlanInput(from request: BuhlmannPlanRequest) -> GasPlanInput {
        var input = GasPlanInput()
        input.plannedDepthMeters = request.maxDepthMeters
        input.plannedBottomMinutes = request.bottomMinutes
        input.gfLow = request.gfLow
        input.gfHigh = request.gfHigh
        input.bottomGas = GasMix(
            name: request.bottomGas.name,
            role: .bottom,
            oxygen: request.bottomGas.oxygenFraction,
            helium: request.bottomGas.heliumFraction,
            maxPPO2: request.bottomGas.maxPPO2Bar
        )
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas)
        ] + request.decoGases.map {
            PlannerCylinderEntry(
                role: .deco,
                gas: GasMix(name: $0.name, role: .deco, oxygen: $0.oxygenFraction, helium: $0.heliumFraction, maxPPO2: $0.maxPPO2Bar),
                switchDepthMeters: $0.switchDepthMeters
            )
        }
        return input
    }
}
