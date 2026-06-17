import XCTest

final class PlannerAscentSpeedSettingsTests: XCTestCase {
    func testPlannerAscentSpeedDefaults() {
        let defaults = PlannerAscentSpeedSettings.default
        XCTAssertEqual(defaults.deeperThan40Meters, 9, accuracy: 0.001)
        XCTAssertEqual(defaults.from40To30Meters, 9, accuracy: 0.001)
        XCTAssertEqual(defaults.from30To20Meters, 9, accuracy: 0.001)
        XCTAssertEqual(defaults.from20To6Meters, 6, accuracy: 0.001)
        XCTAssertEqual(defaults.from6To0Meters, 3, accuracy: 0.001)
    }

    func testPlannerAscentSpeedBandSelection() {
        let settings = PlannerAscentSpeedSettings.default
        XCTAssertEqual(settings.speed(forDepthMeters: 45), 9, accuracy: 0.001)
        XCTAssertEqual(settings.speed(forDepthMeters: 40), 9, accuracy: 0.001)
        XCTAssertEqual(settings.speed(forDepthMeters: 35), 9, accuracy: 0.001)
        XCTAssertEqual(settings.speed(forDepthMeters: 30), 9, accuracy: 0.001)
        XCTAssertEqual(settings.speed(forDepthMeters: 25), 9, accuracy: 0.001)
        XCTAssertEqual(settings.speed(forDepthMeters: 20), 6, accuracy: 0.001)
        XCTAssertEqual(settings.speed(forDepthMeters: 10), 6, accuracy: 0.001)
        XCTAssertEqual(settings.speed(forDepthMeters: 6), 3, accuracy: 0.001)
        XCTAssertEqual(settings.speed(forDepthMeters: 0), 3, accuracy: 0.001)
    }

    func testAscentMinutesSplitsAcrossBands() {
        let settings = PlannerAscentSpeedSettings.default
        let minutes = settings.ascentMinutes(from: 45, to: 6)
        let expected = (5.0 / 9.0) + (10.0 / 9.0) + (10.0 / 9.0) + (14.0 / 6.0)
        XCTAssertEqual(minutes, expected, accuracy: 0.01)
    }

    func testAscentMinutesReturnsZeroForInvalidOrNonAscent() {
        let settings = PlannerAscentSpeedSettings.default
        XCTAssertEqual(settings.ascentMinutes(from: 6, to: 20), 0, accuracy: 0.001)
        XCTAssertEqual(settings.ascentMinutes(from: -5, to: 0), 0, accuracy: 0.001)
        XCTAssertEqual(settings.ascentMinutes(from: 30, to: 30), 0, accuracy: 0.001)
    }

    func testRockBottomUsesPlannerAscentSpeeds() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 36)
        input.emergencyExtraMinutes = 3
        let environment = PlannerEnvironment.seaLevelSaltWater
        let defaultRock = ScheduleGasConsumptionService.rockBottomLiters(
            input: input,
            environment: environment,
            ascentSpeedSettings: .default
        )
        var slowShallow = PlannerAscentSpeedSettings.default
        slowShallow.from6To0Meters = 1.0
        let slowRock = ScheduleGasConsumptionService.rockBottomLiters(
            input: input,
            environment: environment,
            ascentSpeedSettings: slowShallow
        )
        XCTAssertGreaterThan(slowRock, defaultRock)
    }

    func testRockBottomStillUsesEmergencyExtraMinutes() {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 36)
        let settings = PlannerAscentSpeedSettings.default
        input.emergencyExtraMinutes = 3
        let ascent = ScheduleGasConsumptionService.automaticAscentMinutes(
            plannedDepthMeters: 36,
            ascentSpeedSettings: settings
        )
        XCTAssertEqual(
            ScheduleGasConsumptionService.emergencyMinutesUsed(input: input, ascentSpeedSettings: settings),
            ascent + 3,
            accuracy: 0.001
        )
    }

    func testGasConsumptionChangesWithAscentSpeed() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, switchDepthMeters: 40),
            PlannerCylinderEntry(
                role: .deco,
                gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6),
                switchDepthMeters: 21
            )
        ]
        let engine = BuhlmannPlanner.enginePlan(input: input)
        if engine.segments.filter({ $0.kind == .ascent }).isEmpty {
            throw XCTSkip("No ascent segments")
        }
        let environment = PlannerEnvironment.seaLevelSaltWater
        let fast = engine.withPlannerTransitMinutes(using: .default)
        var slowSettings = PlannerAscentSpeedSettings.default
        slowSettings.from40To30Meters = 3
        slowSettings.from30To20Meters = 3
        slowSettings.from20To6Meters = 2
        slowSettings.from6To0Meters = 1
        let slow = engine.withPlannerTransitMinutes(using: slowSettings)
        let fastLedger = try ScheduleGasConsumptionService.analyze(
            input: input,
            enginePlan: fast,
            environment: environment
        ).get()
        let slowLedger = try ScheduleGasConsumptionService.analyze(
            input: input,
            enginePlan: slow,
            environment: environment
        ).get()
        XCTAssertGreaterThan(slowLedger.totalConsumedLiters, fastLedger.totalConsumedLiters)
    }

    func testBuhlmannStopsUnchangedWhenAscentSpeedsChange() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, switchDepthMeters: 40),
            PlannerCylinderEntry(
                role: .deco,
                gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6),
                switchDepthMeters: 21
            )
        ]
        let engine = BuhlmannPlanner.enginePlan(input: input)
        if engine.stops.isEmpty {
            throw XCTSkip("No deco stops")
        }
        var slowSettings = PlannerAscentSpeedSettings.default
        slowSettings.from6To0Meters = 1
        let operational = engine.withPlannerTransitMinutes(using: slowSettings)
        XCTAssertEqual(engine.stops, operational.stops)
        XCTAssertEqual(
            BuhlmannPlanner.decoStops(from: engine).map(\.minutes),
            BuhlmannPlanner.decoStops(from: operational).map(\.minutes)
        )
        XCTAssertEqual(
            BuhlmannPlanner.decoStops(from: engine).map(\.depthMeters),
            BuhlmannPlanner.decoStops(from: operational).map(\.depthMeters)
        )
    }

    func testRuntimeTransitRowsUsePlannerAscentSpeeds() throws {
        var input = BuhlmannTestSupport.gasPlanInput(depth: 40, bottomMinutes: 20)
        input.bottomGas = GasMix(name: "TX 18/45", role: .bottom, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
        input.plannerCylinders = [
            PlannerCylinderEntry(role: .bottom, gas: input.bottomGas, switchDepthMeters: 40),
            PlannerCylinderEntry(
                role: .deco,
                gas: GasMix(name: "EAN50", role: .deco, oxygen: 0.5, helium: 0, maxPPO2: 1.6),
                switchDepthMeters: 21
            )
        ]
        let plan = PlannerService.makePlan(
            input: input,
            mode: .technical,
            ascentSpeedSettings: .default
        )
        if plan.decoStops.isEmpty {
            throw XCTSkip("No deco stops")
        }
        var slowSettings = PlannerAscentSpeedSettings.default
        slowSettings.from40To30Meters = 3
        let slowPlan = PlannerService.makePlan(
            input: input,
            mode: .technical,
            ascentSpeedSettings: slowSettings
        )
        let fastTravel = plan.ascentTableRows.filter { $0.kind == .travel }.map(\.minutes).reduce(0, +)
        let slowTravel = slowPlan.ascentTableRows.filter { $0.kind == .travel }.map(\.minutes).reduce(0, +)
        XCTAssertGreaterThan(slowTravel, fastTravel)
    }

    func testSettingsLocalizationKeysExist() throws {
        let en = try loadStrings(named: "en")
        let it = try loadStrings(named: "it")
        XCTAssertEqual(en["settings.planner_ascent_speeds.title"], "Planner Ascent Speeds")
        XCTAssertEqual(it["settings.planner_ascent_speeds.title"], "Velocità di risalita planner")
        XCTAssertNotNil(en["settings.planner_ascent_speeds.footnote"])
        XCTAssertNotNil(it["settings.planner_ascent_speeds.6_to_0"])
    }

    func testSettingsPersistAndReset() throws {
        let defaults = UserDefaults.standard
        let key = PlannerAscentSpeedSettings.storageKey
        let original = defaults.data(forKey: key)
        defer {
            if let original {
                defaults.set(original, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }

        var custom = PlannerAscentSpeedSettings.default
        custom.from6To0Meters = 2
        PlannerAscentSpeedSettings.save(custom)
        XCTAssertEqual(PlannerAscentSpeedSettings.load().from6To0Meters, 2, accuracy: 0.001)

        PlannerAscentSpeedSettings.save(.default)
        XCTAssertEqual(PlannerAscentSpeedSettings.load(), .default)
    }

    private func loadStrings(named language: String) throws -> [String: String] {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let url = root.appendingPathComponent("iOSApp/Resources/\(language).lproj/Localizable.strings")
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
