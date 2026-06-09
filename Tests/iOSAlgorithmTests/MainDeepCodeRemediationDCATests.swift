import XCTest

@MainActor
final class MainDeepCodeRemediationDCATests: XCTestCase {
    override func setUp() async throws {
        try await super.setUp()
        WatchDiveSyncCodec.replayCache.reset()
        WatchSyncAuth.resetPeerTrust()
    }

    // MARK: - MAIN-DCA-004 mode-projected MOD gating

    func testBaseModeIgnoresHiddenTechnicalTravelMODViolation() {
        var input = GasPlanInput()
        input.ensurePlannerCylindersFromLegacy()
        input.plannerCylinders.append(
            PlannerCylinderEntry(
                role: .travel,
                gas: GasMix(name: "Travel", oxygen: 0.32, helium: 0, maxPPO2: 1.4),
                switchDepthMeters: 40
            )
        )
        let active = PlannerModePolicy.activePlanInput(from: input, mode: .base)
        let draftIssues = PlannerMODValidator.liveInputIssues(input: input, environment: input.plannerEnvironment)
        let projectedIssues = PlannerMODValidator.liveInputIssues(input: active, environment: active.plannerEnvironment)
        XCTAssertFalse(draftIssues.isEmpty)
        XCTAssertTrue(projectedIssues.isEmpty)
    }

    func testTechnicalModeStillReportsMODIssues() {
        var input = GasPlanInput()
        input.ensurePlannerCylindersFromLegacy()
        if let index = input.plannerCylinders.firstIndex(where: { $0.role == .bottom }) {
            input.plannerCylinders[index].gas.oxygen = 1.0
            input.plannerCylinders[index].gas.maxPPO2 = 1.6
            input.plannerCylinders[index].switchDepthMeters = 20
        }
        let active = PlannerModePolicy.activePlanInput(from: input, mode: .technical)
        let issues = PlannerMODValidator.liveInputIssues(input: active, environment: active.plannerEnvironment)
        XCTAssertFalse(issues.isEmpty)
    }

    // MARK: - MAIN-DCA-005 analysis cache key

    func testSACChangeInvalidatesAnalysisCache() async {
        let store = PlannerStore()
        var initial = store.input
        initial.sacLitersPerMinute = 18
        store.input = initial
        store.calculate()
        let firstConsumption = store.analysis.consumptionLiters
        var updated = store.input
        updated.sacLitersPerMinute = 24
        store.input = updated
        await store.testHook_flushDebouncedWork()
        XCTAssertNotEqual(firstConsumption, store.analysis.consumptionLiters)
    }

    func testPlanningReferenceChangeInvalidatesAnalysisCache() async {
        let store = PlannerStore()
        var initial = store.input
        initial.planningDepthReference = .maximumDepth
        initial.plannedDepthMeters = 40
        initial.plannedAverageDepthMeters = 20
        store.input = initial
        store.calculate()
        let firstConsumption = store.analysis.consumptionLiters
        var updated = store.input
        updated.planningDepthReference = .averageDepth
        store.input = updated
        await store.testHook_flushDebouncedWork()
        XCTAssertNotEqual(firstConsumption, store.analysis.consumptionLiters)
    }

    // MARK: - MAIN-DCA-010 MOD vs END semantics

    func testBottomGasMODDiffersFromENDAtDepth() {
        var input = GasPlanInput()
        input.ensurePlannerCylindersFromLegacy()
        input.plannedDepthMeters = 40
        let analysis = GasPlanningService.analyze(input: input, mode: .base)
        let mod = input.bottomGas.modMeters(environment: input.plannerEnvironment)
        XCTAssertNotEqual(mod, analysis.endMeters, accuracy: 0.5)
    }

    // MARK: - MAIN-DCA-015 CCR bailout switch depth

    func testCCRImportClampsBailoutSwitchDepthAboveMOD() {
        var input = CCRPlanInput()
        let item = EquipmentChecklistItem(
            title: "Bailout",
            usesGas: true,
            gasMixKind: .ean,
            gasText: "32",
            switchDepthMeters: 50,
            gasRole: .ccrBailout
        )
        let candidate = CCRChecklistImportCandidate(
            id: item.id,
            checklistItem: item,
            assignedRole: .ccrBailout,
            isSelected: true,
            duplicateAction: .replace,
            matchesExistingDiluent: false,
            matchesExistingBailoutIndex: nil
        )
        CCRChecklistImportCoordinator.importSelected(candidates: [candidate], to: &input)
        XCTAssertFalse(input.bailoutGases.isEmpty)
        let mod = GasMixValidator.modMeters(
            oxygenFraction: input.bailoutGases[0].oxygenFraction,
            maxPPO2: input.bailoutGases[0].gasMix.maxPPO2,
            environment: .seaLevelSaltWater
        ) ?? 0
        XCTAssertLessThanOrEqual(input.bailoutGases[0].switchDepthMeters, mod + 0.5)
    }

    // MARK: - MAIN-DCA-014 replay persistence

    func testReplayCacheSurvivesPersistAndLoad() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("replay-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let cache = SyncNonceReplayCache()
        XCTAssertTrue(cache.register("nonce-a"))
        cache.persistProtected(to: url)
        let restored = SyncNonceReplayCache()
        restored.loadProtected(from: url)
        XCTAssertTrue(restored.isReplay("nonce-a"))
    }
}
