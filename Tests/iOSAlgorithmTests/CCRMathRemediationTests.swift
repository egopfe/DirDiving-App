import XCTest
import PDFKit

final class CCRMathRemediationTests: XCTestCase {
    // MARK: - P1-005 Imperial CCR switch depth

    func testImperialCCRSetpointSwitchDepthStoresMeters() {
        let meters = ManualDiveEditorDefaults.depthMeters(fromInput: 66, units: .imperial)
        XCTAssertEqual(meters, 20.1168, accuracy: 0.05)
    }

    func testMetricCCRSetpointSwitchDepthStoresMeters() {
        let meters = ManualDiveEditorDefaults.depthMeters(fromInput: 20, units: .metric)
        XCTAssertEqual(meters, 20, accuracy: 0.001)
    }

    func testCCRMetadataValidationRejectsLowGreaterThanHigh() {
        let metadata = CCRLogbookMetadata(
            rebreatherModel: "rEvo",
            lowSetpoint: 1.3,
            highSetpoint: 0.7,
            setpointSwitchDepthMeters: 20,
            diluentLabel: "AIR",
            bailoutLabels: ["EAN32"]
        )
        XCTAssertNotNil(ManualDiveEditorValidation.ccrMetadataError(metadata: metadata, maxDepthMeters: 40))
    }

    // MARK: - P1-006 Ratio Deco rejects CCR

    func testRatioDecoPlannerRejectsCCRMode() {
        var input = BuhlmannTestSupport.gasPlanInput()
        input.plannedDepthMeters = 40
        input.plannedBottomMinutes = 20
        let schedule = RatioDecoPlanner.makeSchedule(
            input: input,
            mode: .ccr,
            preset: .preset1to1,
            environment: .seaLevelSaltWater,
            descentMinutes: 4
        )
        XCTAssertNotNil(schedule)
        XCTAssertTrue(schedule?.warnings.contains(.unavailableInCCRMode) ?? false)
        XCTAssertTrue(schedule?.stops.isEmpty ?? false)
    }

    func testRatioDecoValidatorRejectsCCRMode() {
        var input = BuhlmannTestSupport.gasPlanInput()
        input.plannedDepthMeters = 40
        let request = BuhlmannPlanner.makeRequest(input: input, environment: .seaLevelSaltWater)
        let enginePlan = BuhlmannEngine.plan(request)
        let schedule = RatioDecoSchedule(
            stops: [],
            totalDecoMinutes: 0,
            totalRuntimeMinutes: 24,
            firstStopDepthMeters: 9,
            presetName: "1:1",
            warnings: [.unavailableInCCRMode],
            depthProfilePoints: [],
            ascentTableRows: []
        )
        let validation = RatioDecoValidator.validate(
            schedule: schedule,
            input: input,
            mode: .ccr,
            enginePlan: enginePlan,
            request: request,
            environment: .seaLevelSaltWater
        )
        XCTAssertFalse(validation.isBuhlmannCompatible)
        XCTAssertTrue(validation.warnings.contains(.unavailableInCCRMode))
    }

    // MARK: - P1-001 CCR tissue trace

    func testCCRTissueTraceMatchesEngineFinalState() {
        var input = CCRPlanInput.default
        input.maxDepthMeters = 40
        input.bottomTimeMinutes = 25
        input.bailoutGases = [CCRBailoutGas(mixKind: .ean, oxygenPercent: 32, switchDepthMeters: 0)]
        let environment = PlannerEnvironment.seaLevelSaltWater
        let engine = CCRPlannerEngine.plan(input: input, environment: environment)
        let replayed = CCRTissueHistorySampler.replayFinalState(
            input: input,
            environment: environment,
            segments: engine.exposureSegments
        )
        for index in 0..<BuhlmannConstants.compartmentCount {
            XCTAssertEqual(
                replayed.compartments[index].nitrogenPressure,
                engine.finalTissueState.compartments[index].nitrogenPressure,
                accuracy: 0.02,
                "N2 compartment \(index)"
            )
            XCTAssertEqual(
                replayed.compartments[index].heliumPressure,
                engine.finalTissueState.compartments[index].heliumPressure,
                accuracy: 0.02,
                "He compartment \(index)"
            )
        }
        XCTAssertFalse(engine.tissueHistory.samples.isEmpty)
    }

    // MARK: - P1-002 runtime segments quarantined

    func testRuntimeSegmentsDoNotAlterCCRPlan() {
        var baseline = CCRPlanInput.default
        baseline.bailoutGases = [CCRBailoutGas()]
        var withSegments = baseline
        withSegments.setpointProfile.runtimeSegments = [
            CCRSetpointSegment(runtimeMinutes: 10, depthMeters: 30, setpointBar: 1.5, note: "unused")
        ]
        let basePlan = CCRPlannerService.makePlan(input: baseline)
        let segmentPlan = CCRPlannerService.makePlan(input: withSegments)
        XCTAssertEqual(basePlan.ttsMinutes, segmentPlan.ttsMinutes)
        XCTAssertEqual(basePlan.cnsFullPlanPercent, segmentPlan.cnsFullPlanPercent, accuracy: 0.01)
    }

    // MARK: - P1-003 Bailout heuristic

    func testBailoutScenarioUsesHeuristicDisclaimer() {
        var input = CCRPlanInput.default
        input.bailoutGases = [CCRBailoutGas(mixKind: .ean, oxygenPercent: 32, switchDepthMeters: 0)]
        let scenario = CCRBailoutScenarioCalculator.evaluate(
            kind: .lostLoop,
            input: input,
            environment: .seaLevelSaltWater
        )
        XCTAssertTrue(scenario.referenceNotes.contains(String(localized: "ccr.bailout.heuristic_disclaimer")))
    }

    // MARK: - P1-004 Water vapor

    func testCCRInspiredGasAppliesWaterVaporCorrection() {
        let diluent = CCRDiluent.air
        let env = PlannerEnvironment.seaLevelSaltWater
        let ambient = CCRInspiredGasModel.ambientPressureBar(depthMeters: 30, environment: env)
        let dry = max(0, ambient - BuhlmannConstants.waterVaporPressureBar)
        let expectedN2 = max(0, dry - 1.3) * diluent.nitrogenFraction
        let inspired = CCRInspiredGasModel.inspiredPressures(
            depthMeters: 30,
            setpointBar: 1.3,
            diluent: diluent,
            environment: env
        )
        XCTAssertEqual(inspired?.ppN2 ?? 0, expectedN2, accuracy: 0.01)
    }

    // MARK: - P2 export / PDF

    func testUnavailableCCRPlanBlocksExport() {
        var input = CCRPlanInput.default
        input.bailoutGases = []
        let plan = CCRPlannerService.makePlan(input: input)
        let context = PDFExportCCRPlannerContext(
            input: input,
            plan: plan,
            safetyAcknowledged: true,
            unitPreference: .metric
        )
        XCTAssertFalse(PDFExportService.canExportCCRPlan(context))
    }

    func testCCRPlanPDFUsesLocalizedBailoutStatus() throws {
        var input = CCRPlanInput.default
        input.bailoutGases = [CCRBailoutGas(mixKind: .ean, oxygenPercent: 32, switchDepthMeters: 0)]
        let plan = CCRPlannerService.makePlan(input: input)
        let context = PDFExportCCRPlannerContext(
            input: input,
            plan: plan,
            safetyAcknowledged: true,
            unitPreference: .metric
        )
        let data = CCRPlannerPDFBuilder.build(context: context)
        XCTAssertFalse(data.isEmpty)
        XCTAssertEqual(String(data: data.prefix(4), encoding: .ascii), "%PDF")
        let status = try XCTUnwrap(plan.bailoutScenarios.first?.status)
        XCTAssertNotEqual(status.localizedTitle, status.rawValue)
        XCTAssertFalse(status.localizedTitle.isEmpty)
    }

    // MARK: - P2 checklist roles

    func testCCRChecklistSyncMapsDiluentAndBailoutRoles() {
        var input = CCRPlanInput.default
        input.bailoutGases = [CCRBailoutGas(mixKind: .ean, oxygenPercent: 32, switchDepthMeters: 0)]
        let items = ChecklistPlannerSyncMapper.ccrChecklistItems(from: input)
        XCTAssertTrue(items.contains { $0.gasRole == .ccrDiluent })
        XCTAssertTrue(items.contains { $0.gasRole == .ccrBailout })
    }

    func testCCRChecklistExportUpdatesExistingRoleRows() {
        var input = CCRPlanInput.default
        input.diluent = CCRDiluent(mixKind: .ean, oxygenPercent: 32, heliumPercent: 0)
        input.bailoutGases = [CCRBailoutGas(mixKind: .ean, oxygenPercent: 32, switchDepthMeters: 0)]
        var checklist = [
            EquipmentChecklistItem(
                title: String(localized: "equipment.ccr.diluent_cylinder"),
                usesGas: true,
                gasText: "AIR",
                gasRole: .ccrDiluent
            )
        ]
        ChecklistPlannerSyncMapper.applyCCRExport(input: input, to: &checklist)
        XCTAssertEqual(checklist.filter { $0.gasRole == .ccrDiluent }.count, 1)
        XCTAssertEqual(checklist.first?.gasText, "EAN32")
    }

    // MARK: - P2 persistence

    func testCCRPlannerStateRoundTripsThroughJSON() throws {
        var input = CCRPlanInput.default
        input.rebreatherModel = "rEvo"
        input.setpointProfile.lowSetpoint = 0.6
        input.setpointProfile.highSetpoint = 1.2
        input.setpointProfile.switchDepthMeters = 18
        input.bailoutGases = [CCRBailoutGas(mixKind: .ean, oxygenPercent: 32, switchDepthMeters: 6)]
        let data = try JSONEncoder().encode(input)
        let decoded = try JSONDecoder().decode(CCRPlanInput.self, from: data)
        XCTAssertEqual(decoded.rebreatherModel, "rEvo")
        XCTAssertEqual(decoded.setpointProfile.lowSetpoint, 0.6, accuracy: 0.001)
        XCTAssertEqual(decoded.setpointProfile.switchDepthMeters, 18, accuracy: 0.001)
        XCTAssertEqual(decoded.bailoutGases.count, 1)
    }

    // MARK: - P2-012 service limits

    func testPlannerServiceEnforcesBaseNoDecoDepthLimit() {
        var input = GasPlanInput()
        input.ensurePlannerCylindersFromLegacy()
        input.plannedDepthMeters = 55
        input.plannedBottomMinutes = 20
        let validation = PlannerModePolicy.validate(draft: input, mode: .base)
        XCTAssertFalse(validation.isValid)
        let plan = PlannerService.makePlan(input: input, mode: .base)
        XCTAssertNotEqual(plan.buhlmannState, .validReference)
    }

    // MARK: - P3 GF validation label

    func testInvalidGFUsesGradientFactorIssue() {
        var input = CCRPlanInput.default
        input.gfLow = 80
        input.gfHigh = 70
        input.bailoutGases = [CCRBailoutGas()]
        let validation = CCRPlanValidator.validate(input, environment: .seaLevelSaltWater)
        XCTAssertTrue(validation.issues.contains(where: {
            if case .invalidGradientFactor = $0 { return true }
            return false
        }))
    }

    private func pdfText(_ data: Data) -> String {
        guard let document = PDFDocument(data: data) else { return "" }
        return (0..<document.pageCount)
            .compactMap { document.page(at: $0)?.string }
            .joined(separator: "\n")
    }
}
