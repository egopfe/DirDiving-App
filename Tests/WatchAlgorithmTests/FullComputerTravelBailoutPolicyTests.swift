import XCTest

final class FullComputerTravelBailoutPolicyTests: XCTestCase {
    /// Policy A: iOS plan packages carry bottom + deco only; travel/bailout are Watch-native.

    func testImportedPlanHasNoTravelGases() throws {
        let package = try DivePlanPackageCodec.seal(samplePackageBody())
        let profile = try FullComputerGasProfile(importing: package)
        XCTAssertTrue(profile.travelGases.isEmpty)
    }

    func testImportedPlanHasNoBailoutGases() throws {
        let package = try DivePlanPackageCodec.seal(samplePackageBody())
        let profile = try FullComputerGasProfile(importing: package)
        XCTAssertTrue(profile.bailoutGases.isEmpty)
    }

    func testPackageGasesContainOnlyBottomAndDecoRoles() throws {
        let package = try DivePlanPackageCodec.seal(samplePackageBody())
        XCTAssertTrue(package.body.gases.allSatisfy { $0.role == .bottom || $0.role == .deco })
    }

    func testWatchNativeTravelGasCanBeAddedLocally() {
        var profile = FullComputerGasProfile.defaultAirGF3070
        profile.travelGases = [
            FullComputerConfiguredGas(
                name: "EAN32",
                role: .travel,
                oxygenFraction: 0.32,
                heliumFraction: 0,
                maxPPO2Bar: 1.4,
                switchDepthMeters: 21
            )
        ]
        XCTAssertEqual(profile.enabledTravelGases.count, 1)
        XCTAssertTrue(FullComputerGasProfileValidator.isValid(profile, environment: .seaLevelSaltWater))
    }

    func testLocalTravelGasDoesNotAutoActivateInRuntime() throws {
        var profile = FullComputerGasProfile.defaultAirGF3070
        profile.travelGases = [
            FullComputerConfiguredGas(
                name: "EAN36",
                role: .travel,
                oxygenFraction: 0.36,
                heliumFraction: 0,
                maxPPO2Bar: 1.4,
                switchDepthMeters: 30
            )
        ]
        let plan = FullComputerRuntimePlan(profile: profile, plannerEnvironment: .seaLevelSaltWater)
        let tracker = FullComputerGasSwitchTracker.initial
        var bootstrapped = tracker
        bootstrapped.bootstrap(bottomGasMixId: plan.activeGas.gasMixId)
        let projection = FullComputerGasSwitchPolicy.projectionGases(from: plan, tracker: bootstrapped)
        XCTAssertTrue(projection.travel.isEmpty)
    }

    func testBailoutExcludedFromNormalTTSProjection() {
        var profile = FullComputerGasProfile.defaultAirGF3070
        profile.bailoutGases = [
            FullComputerConfiguredGas(
                name: "Bailout",
                role: .bailout,
                oxygenFraction: 0.21,
                heliumFraction: 0,
                maxPPO2Bar: 1.4,
                switchDepthMeters: 0
            )
        ]
        let plan = FullComputerRuntimePlan(profile: profile, plannerEnvironment: .seaLevelSaltWater)
        XCTAssertTrue(plan.decoGases.allSatisfy { $0.role != .bailout })
        XCTAssertTrue(plan.travelGases.allSatisfy { $0.role != .bailout })
    }

    func testBailoutNotInEnabledDecoGases() {
        var profile = FullComputerGasProfile.defaultAirGF3070
        profile.bailoutGases = [
            FullComputerConfiguredGas(
                name: "Bailout",
                role: .bailout,
                oxygenFraction: 0.21,
                heliumFraction: 0,
                maxPPO2Bar: 1.4,
                switchDepthMeters: 0
            )
        ]
        XCTAssertTrue(profile.enabledDecoGases.isEmpty)
    }

    func testBailoutNotSuggestedAsNormalSwitch() {
        let bailout = BuhlmannGas(
            name: "Bailout",
            role: .bailout,
            oxygenFraction: 0.21,
            heliumFraction: 0,
            maxPPO2Bar: 1.4,
            switchDepthMeters: 0,
            gasMixId: UUID()
        )
        let bottom = FullComputerRuntimePlan.defaultAirGF3070.activeGas
        var tracker = FullComputerGasSwitchTracker.initial
        tracker.bootstrap(bottomGasMixId: bottom.gasMixId)
        let suggested = FullComputerGasSwitchPolicy.suggestedSwitchGas(
            activeGas: bottom,
            depthMeters: 10,
            plannedGases: [bailout],
            tracker: tracker,
            environment: .seaLevelSaltWater
        )
        XCTAssertNil(suggested)
    }

    func testOffPlanConfirmationRequiredForBailoutSwitch() throws {
        let bailout = BuhlmannGas(
            name: "Bailout Air",
            role: .bailout,
            oxygenFraction: 0.21,
            heliumFraction: 0,
            maxPPO2Bar: 1.4,
            switchDepthMeters: 0,
            gasMixId: UUID()
        )
        let start = Date(timeIntervalSince1970: 1_720_000_000)
        var engine = try FullComputerRuntimeEngine(sessionStart: start)
        _ = engine.ingestSample(depthMeters: 15, timestamp: start.addingTimeInterval(60))
        XCTAssertFalse(engine.confirmGasSwitch(to: bailout.gasMixId, at: start.addingTimeInterval(61)))
        XCTAssertTrue(engine.confirmOffPlanGasSwitch(bailout, at: start.addingTimeInterval(62)))
        XCTAssertEqual(engine.snapshot.activeGas.gasMixId, bailout.gasMixId)
    }

    private func samplePackageBody() -> DivePlanPackageBody {
        let bottomID = UUID()
        let decoID = UUID()
        return DivePlanPackageBody(
            schemaVersion: DivePlanPackageCodec.currentSchemaVersion,
            algorithmVersion: DivePlanPackageCodec.algorithmVersion,
            planID: UUID(),
            revision: 1,
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(3600),
            environment: DivePlanEnvironmentPayload(altitudeMeters: 0, salinityRaw: SalinityMode.salt.rawValue),
            gfLow: 30,
            gfHigh: 70,
            gases: [
                DivePlanGasPayload(id: bottomID, name: "Air", role: .bottom, oxygenFraction: 0.21, heliumFraction: 0, maxPPO2Bar: 1.4, sortOrder: 0),
                DivePlanGasPayload(id: decoID, name: "EAN50", role: .deco, oxygenFraction: 0.50, heliumFraction: 0, maxPPO2Bar: 1.6, switchDepthMeters: 21, sortOrder: 1),
            ],
            bottomSegments: [DivePlanBottomSegmentPayload(depthMeters: 30, durationMinutes: 20, order: 0)],
            plannedSwitches: [DivePlanGasSwitchPayload(gasID: decoID, switchDepthMeters: 21, order: 0)],
            plannerSummary: DivePlanSummaryPayload(
                modeLabel: "Deco",
                planKind: "single",
                maxDepthMeters: 30,
                bottomMinutes: 20,
                totalRuntimeMinutes: 40,
                requiresDeco: true,
                decoStopCount: 1
            ),
            capabilities: .current
        )
    }
}
