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
            throw XCTSkip("No deco stops for profile")
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
            throw XCTSkip("No deco stops for profile")
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
            throw XCTSkip("No deco stops for profile")
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
            throw XCTSkip("No deco stops for profile")
        }
        for row in plan.ascentTableRows where row.kind != .surface {
            XCTAssertTrue(row.ppO2.isFinite)
            XCTAssertFalse(row.ppO2.isNaN)
            XCTAssertGreaterThanOrEqual(row.ppO2, 0)
        }
    }

    func testIncompletePlanSuppressesDecompressionTableRows() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 120, bottomMinutes: 120)
        input.bottomGas = GasMix(name: "Air", role: .bottom, oxygen: 0.21, helium: 0, maxPPO2: 1.4)
        let plan = PlannerService.makePlan(input: input)
        if plan.calculationCompleteness != .incompletePartialStops {
            throw XCTSkip("Profile did not hit calculation limit")
        }
        XCTAssertTrue(plan.decoStops.isEmpty)
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
            throw XCTSkip("No deco stops for profile")
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
            throw XCTSkip("No deco stops for profile")
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
            throw XCTSkip("No deco stops for profile")
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

    func testRuntimeTitleLocalization() throws {
        let en = try loadStrings(named: "en")
        let it = try loadStrings(named: "it")
        XCTAssertEqual(en["planner.runtime.title"], "Dive Runtime")
        XCTAssertEqual(it["planner.runtime.title"], "Runtime immersione")
    }

    func testBriefingOrderFootnoteLocalizationExists() throws {
        let en = try loadStrings(named: "en")
        let it = try loadStrings(named: "it")
        XCTAssertTrue(en["planner.table.briefing_order.footnote"]?.contains("Dive runtime") == true)
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
