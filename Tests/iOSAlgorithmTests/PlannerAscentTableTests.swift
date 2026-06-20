import XCTest

final class PlannerAscentTableTests: XCTestCase {
    private func environment() -> PlannerEnvironment {
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: 0, salinity: .salt) else {
            fatalError("Expected environment")
        }
        return environment
    }

    func testAscentTableIncludesBottomRow() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, switchDepthMeters: 40),
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6), switchDepthMeters: 21)
        ]
        let plan = PlannerService.makePlan(input: input)
        XCTAssertTrue(plan.ascentTableRows.contains(where: { $0.kind == .bottom }))
    }

    func testAscentTableIncludesDecompressionStopRows() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, switchDepthMeters: 40),
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6), switchDepthMeters: 21)
        ]
        let plan = PlannerService.makePlan(input: input)
        if plan.decoStops.isEmpty {
            XCTFail("No deco stops for profile")
            return
        }
        let stopRows = plan.ascentTableRows.filter { $0.kind == .decoStop }
        XCTAssertEqual(stopRows.count, plan.decoStops.count)
    }

    func testSurfaceRowRemains() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 18, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "EAN32", role: .bottom, oxygen: 0.32, helium: 0, maxPPO2: 1.4)
        let plan = PlannerService.makePlan(input: input)
        XCTAssertTrue(plan.ascentTableRows.contains(where: { $0.kind == .surface }))
    }

    func testTTSLabelMapsToEngineTTS() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, switchDepthMeters: 40),
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6), switchDepthMeters: 21)
        ]
        let engine = BuhlmannPlanner.enginePlan(input: input)
        let plan = PlannerService.makePlan(input: input)
        XCTAssertEqual(plan.ttsMinutes, engine.ttsMinutes)
        XCTAssertGreaterThanOrEqual(plan.totalRuntimeMinutes, plan.ttsMinutes)
    }

    func testTrimixDisplayLabelUsesReadableName() {
        let gas = BuhlmannTestSupport.trimix1845()
        XCTAssertEqual(gas.displayLabel, "TRIMIX 18/45")
        let engine = BuhlmannEngine.plan(
            BuhlmannPlanRequest(
                maxDepthMeters: 40,
                bottomMinutes: 20,
                bottomGas: gas,
                travelGases: [],
                decoGases: [BuhlmannTestSupport.ean50()],
                gfLow: 30,
                gfHigh: 85
            )
        )
        let rows = PlannerAscentTableBuilder.rows(from: engine, decoStops: BuhlmannPlanner.decoStops(from: engine), environment: environment())
        XCTAssertTrue(rows.contains(where: { $0.gas.contains("TRIMIX") }))
    }

    func testAscentTableSurfaceRowIsLast() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, switchDepthMeters: 40),
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6), switchDepthMeters: 21)
        ]
        let plan = PlannerService.makePlan(input: input)
        if plan.decoStops.isEmpty {
            XCTFail("No deco stops for profile")
            return
        }
        XCTAssertEqual(plan.ascentTableRows.last?.kind, .surface)
    }

    func testRuntimeTableIncludesDescentBeforeBottom() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, switchDepthMeters: 40),
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6), switchDepthMeters: 21)
        ]
        let engine = BuhlmannPlanner.enginePlan(input: input)
        let stops = BuhlmannPlanner.decoStops(from: engine)
        if stops.isEmpty {
            XCTFail("No deco stops for profile")
            return
        }
        let rows = PlannerAscentTableBuilder.rows(from: engine, decoStops: stops, environment: environment())

        let descentSegmentCount = engine.segments.filter { $0.kind == .descent }.count
        XCTAssertGreaterThan(descentSegmentCount, 0, "Expected descent segments in engine plan")
        XCTAssertEqual(rows.first?.kind, .descent)
        if let bottomIndex = rows.firstIndex(where: { $0.kind == .bottom }),
           let descentIndex = rows.firstIndex(where: { $0.kind == .descent }) {
            XCTAssertLessThan(descentIndex, bottomIndex)
        }
        XCTAssertEqual(rows.last?.kind, .surface)

        if let firstTravel = rows.firstIndex(where: { $0.kind == .travel }),
           let firstDeco = rows.firstIndex(where: { $0.kind == .decoStop }) {
            XCTAssertLessThan(firstTravel, firstDeco)
        }

        let decoDepths = rows.filter { $0.kind == .decoStop }.map(\.depthMeters)
        XCTAssertEqual(decoDepths, stops.map(\.depthMeters))

        let lastBottomIndex = engine.segments.lastIndex(where: { $0.kind == .bottom }) ?? -1
        let expectedTravelCount = engine.segments[(lastBottomIndex + 1)...]
            .filter { $0.kind == .ascent || $0.kind == .gasSwitch }
            .count
        XCTAssertEqual(rows.filter { $0.kind == .travel }.count, expectedTravelCount)
    }

    func testAscentTablePPO2ValuesAreFiniteForRealRows() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, switchDepthMeters: 40),
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6), switchDepthMeters: 21)
        ]
        let plan = PlannerService.makePlan(input: input)
        if plan.decoStops.isEmpty {
            XCTFail("No deco stops for profile")
            return
        }
        for row in plan.ascentTableRows where row.kind != .surface {
            XCTAssertTrue(row.ppO2.isFinite)
            XCTAssertFalse(row.ppO2.isNaN)
            XCTAssertGreaterThanOrEqual(row.ppO2, 0)
        }
    }

    func testIncompletePlanSuppressesDecompressionTableRows() {
        let gas = BuhlmannTestSupport.air(switchDepth: 30)
        let stop = BuhlmannDecompressionStop(
            depthMeters: 21,
            minutes: 5,
            gas: gas,
            ppO2: 1.2,
            maxPPO2: 1.4,
            gradientFactor: 0.7
        )
        let engine = BuhlmannEngineResult(
            ndlMinutes: 0,
            ttsMinutes: 45,
            totalRuntimeMinutes: 60,
            descentMinutes: 2,
            bottomMinutes: 30,
            gasSwitchMinutes: 0,
            finalTissueState: nil,
            stops: [stop],
            segments: [],
            tissueHistory: .empty,
            issues: [.calculationLimitReached],
            modelState: .modelIncomplete
        )
        let resolution = PlanCalculationCompletenessResolver.resolve(
            enginePlan: engine,
            stops: engine.stops.map(BuhlmannPlanner.makeDecoStop)
        )
        XCTAssertEqual(resolution.completeness, .incompletePartialStops)
        XCTAssertTrue(resolution.presentationStops.isEmpty)
        let rows = PlannerAscentTableBuilder.rows(
            from: engine,
            decoStops: resolution.presentationStops,
            environment: .seaLevelSaltWater
        )
        XCTAssertFalse(rows.contains { $0.kind == .decoStop })
    }

    func testRuntimeTableDecoStopsAreMarkedAsDecoStop() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, switchDepthMeters: 40),
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6), switchDepthMeters: 21)
        ]
        let plan = PlannerService.makePlan(input: input)
        if plan.decoStops.isEmpty {
            XCTFail("No deco stops for profile")
            return
        }
        let stopRows = plan.ascentTableRows.filter { $0.kind == .decoStop }
        XCTAssertEqual(stopRows.count, plan.decoStops.count)
        XCTAssertTrue(stopRows.allSatisfy { $0.kind == .decoStop })
    }

    func testAddingDescentDoesNotChangeDecoStops() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, switchDepthMeters: 40),
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6), switchDepthMeters: 21)
        ]
        let engine = BuhlmannPlanner.enginePlan(input: input)
        let stops = BuhlmannPlanner.decoStops(from: engine)
        if stops.isEmpty {
            XCTFail("No deco stops for profile")
            return
        }
        let rows = PlannerAscentTableBuilder.rows(from: engine, decoStops: stops, environment: environment())
        let decoDepths = rows.filter { $0.kind == .decoStop }.map(\.depthMeters)
        let decoMinutes = rows.filter { $0.kind == .decoStop }.map(\.minutes)
        XCTAssertEqual(decoDepths, stops.map(\.depthMeters))
        XCTAssertEqual(decoMinutes, stops.map { Double($0.minutes) })
    }

    func testTechnicalRuntimePreservesGasSwitchRows() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, switchDepthMeters: 40),
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6), switchDepthMeters: 21)
        ]
        let plan = PlannerService.makePlan(input: input, mode: .technical)
        if plan.decoStops.isEmpty {
            XCTFail("No deco stops for profile")
            return
        }
        XCTAssertGreaterThan(plan.ascentTableRows.filter { $0.kind == .travel }.count, 0)
    }

    func testBaseDoesNotShowDecoStopWithoutDeco() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 18, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "EAN32", role: .bottom, oxygen: 0.32, helium: 0, maxPPO2: 1.4)
        let plan = PlannerService.makePlan(input: input, mode: .base)
        XCTAssertTrue(plan.decoStops.isEmpty)
        XCTAssertFalse(plan.ascentTableRows.contains(where: { $0.kind == .decoStop }))
    }

    func testDecoStopUsesUserFacingLabel() throws {
        let en = try loadStrings(named: "en")
        let it = try loadStrings(named: "it")
        XCTAssertEqual(en["planner.runtime.row.deco_stop"], "Deco Stop")
        XCTAssertEqual(it["planner.runtime.row.deco_stop"], "Sosta Deco")
        XCTAssertFalse(PlannerAscentRowKind.decoStop.localizedTitle.localizedCaseInsensitiveContains("decoStop"))
    }

    func testRuntimeTravelRowItalianLabelIsRisalita() throws {
        let en = try loadStrings(named: "en")
        let it = try loadStrings(named: "it")
        XCTAssertEqual(en["planner.runtime.row.travel"], "Travel")
        XCTAssertEqual(it["planner.runtime.row.travel"], "Risalita")
        XCTAssertEqual(PlannerAscentRowKind.travel.localizedTitle, DIRIOSLocalizer.string("planner.runtime.row.travel"))
    }

    func testRuntimeTitleLocalization() throws {
        let en = try loadStrings(named: "en")
        let it = try loadStrings(named: "it")
        XCTAssertEqual(en["planner.runtime.title"], "Dive Runtime")
        XCTAssertEqual(it["planner.runtime.title"], "Runtime immersione")
    }

    func testDecoStopsAreInterleavedWithTravelRows() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, switchDepthMeters: 40),
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6), switchDepthMeters: 21)
        ]
        let plan = PlannerService.makePlan(input: input)
        if plan.decoStops.count < 2 {
            XCTFail("Need at least two deco stops for interleaving")
            return
        }
        let kinds = plan.ascentTableRows.map(\.kind)
        guard let firstDeco = kinds.firstIndex(of: .decoStop),
              let lastDeco = kinds.lastIndex(of: .decoStop),
              firstDeco != lastDeco else {
            XCTFail("Need distinct deco stop rows")
            return
        }
        XCTAssertTrue(kinds[firstDeco..<lastDeco].contains(.travel))
        if let lastTravel = kinds.lastIndex(of: .travel) {
            XCTAssertLessThan(firstDeco, lastTravel)
        }
    }

    func testRuntimeRowsFollowDescendingOperationalDepthsAfterBottom() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, switchDepthMeters: 40),
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6), switchDepthMeters: 21)
        ]
        let plan = PlannerService.makePlan(input: input)
        if plan.decoStops.isEmpty {
            XCTFail("No deco stops for profile")
            return
        }
        guard let bottomIndex = plan.ascentTableRows.firstIndex(where: { $0.kind == .bottom }) else {
            XCTFail("Missing bottom row")
            return
        }
        let postBottom = Array(plan.ascentTableRows.dropFirst(bottomIndex + 1).dropLast())
        let decoDepths = postBottom.filter { $0.kind == .decoStop }.map(\.depthMeters)
        XCTAssertEqual(decoDepths, decoDepths.sorted(by: >))
    }

    func testEachDecoStopAppearsExactlyOnce() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, switchDepthMeters: 40),
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6), switchDepthMeters: 21)
        ]
        let plan = PlannerService.makePlan(input: input)
        if plan.decoStops.isEmpty {
            XCTFail("No deco stops for profile")
            return
        }
        XCTAssertEqual(plan.ascentTableRows.filter { $0.kind == .decoStop }.count, plan.decoStops.count)
    }

    func testDecoStopDepthsAndTimesArePreserved() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, switchDepthMeters: 40),
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6), switchDepthMeters: 21)
        ]
        let plan = PlannerService.makePlan(input: input)
        if plan.decoStops.isEmpty {
            XCTFail("No deco stops for profile")
            return
        }
        let stopRows = plan.ascentTableRows.filter { $0.kind == .decoStop }
        XCTAssertEqual(stopRows.map(\.depthMeters), plan.decoStops.map(\.depthMeters))
        XCTAssertEqual(stopRows.map(\.minutes), plan.decoStops.map { Double($0.minutes) })
    }

    func testNoDecoPlanHasNoDecoStopRows() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 18, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "EAN32", role: .bottom, oxygen: 0.32, helium: 0, maxPPO2: 1.4)
        let plan = PlannerService.makePlan(input: input)
        XCTAssertTrue(plan.decoStops.isEmpty)
        XCTAssertFalse(plan.ascentTableRows.contains(where: { $0.kind == .decoStop }))
    }

    func testTechnicalMultigasRuntimeKeepsGasSwitchOrder() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, switchDepthMeters: 40),
            PlannerCylinderEntry(role: .deco, gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6), switchDepthMeters: 21)
        ]
        let plan = PlannerService.makePlan(input: input, mode: .technical)
        if plan.decoStops.isEmpty {
            XCTFail("No deco stops for profile")
            return
        }
        let engine = BuhlmannPlanner.enginePlan(input: input)
        let lastBottom = engine.segments.lastIndex(where: { $0.kind == .bottom }) ?? -1
        let engineTravelKinds = engine.segments[(lastBottom + 1)...]
            .filter { $0.kind == .ascent || $0.kind == .gasSwitch }
            .map(\.kind)
        let rowTravelCount = plan.ascentTableRows.filter { $0.kind == .travel }.count
        XCTAssertEqual(rowTravelCount, engineTravelKinds.count)
        if let firstDeco = plan.ascentTableRows.firstIndex(where: { $0.kind == .decoStop }),
           let firstTravel = plan.ascentTableRows.firstIndex(where: { $0.kind == .travel }) {
            XCTAssertLessThan(firstTravel, firstDeco)
        }
    }

    func testRuntimeSurfaceIsLast() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        let plan = PlannerService.makePlan(input: input)
        XCTAssertEqual(plan.ascentTableRows.last?.kind, .surface)
    }

    func testRawDecoStopEnumNameIsNotPresented() throws {
        let en = try loadStrings(named: "en")
        let it = try loadStrings(named: "it")
        XCTAssertEqual(en["planner.runtime.row.deco_stop"], "Deco Stop")
        XCTAssertEqual(it["planner.runtime.row.deco_stop"], "Sosta Deco")
        XCTAssertFalse(PlannerAscentRowKind.decoStop.localizedTitle.localizedCaseInsensitiveContains("decoStop"))
    }

    func testBriefingOrderFootnoteLocalizationExists() throws {
        let en = try loadStrings(named: "en")
        let it = try loadStrings(named: "it")
        XCTAssertTrue(en["planner.table.briefing_order.footnote"]?.contains("interleaved") == true)
        XCTAssertFalse(it["planner.table.briefing_order.footnote", default: ""].isEmpty)
    }

    private func loadStrings(named language: String) throws -> [String: String] {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let url = root
            .appendingPathComponent("iOSApp/Resources/\(language).lproj/Localizable.strings")
        let contents = try String(contentsOf: url, encoding: .utf8)
        var map: [String: String] = [:]
        let pattern = #""([^"]+)"\s*=\s*"((?:\\.|[^"\\])*)";"#
        let regex = try NSRegularExpression(pattern: pattern)
        let range = NSRange(contents.startIndex..<contents.endIndex, in: contents)
        regex.enumerateMatches(in: contents, range: range) { match, _, _ in
            guard let match, match.numberOfRanges == 3,
                  let keyRange = Range(match.range(at: 1), in: contents),
                  let valueRange = Range(match.range(at: 2), in: contents) else { return }
            map[String(contents[keyRange])] = String(contents[valueRange])
        }
        return map
    }
}
