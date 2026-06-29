import XCTest

final class DivePlanPackageBuilderTests: XCTestCase {
    func testBuilderProducesValidPackage() throws {
        var input = GasPlanInput()
        input.ensurePlannerCylindersFromLegacy()
        input.gfLow = 30
        input.gfHigh = 70
        input.plannedDepthMeters = 40
        input.plannedBottomMinutes = 25

        let package = try DivePlanPackageBuilder.build(
            input: input,
            plan: nil,
            modeLabel: "Deco",
            planID: UUID(),
            revision: 1
        )
        try DivePlanPackageCodec.validate(package)
        XCTAssertFalse(package.body.gases.isEmpty)
        XCTAssertEqual(package.body.plannerSummary.planKind, "single")
        XCTAssertEqual(package.body.gradientFactorPreset, FullComputerGradientFactorPreset.standard3070.rawValue)
    }

    func testBuilderEmitsGradientFactorPresetForAllPlannerPresets() throws {
        for preset in PlannerGFPreset.allCases {
            var input = GasPlanInput()
            input.ensurePlannerCylindersFromLegacy()
            PlannerModePolicy.applyGFPreset(preset, to: &input)
            let package = try DivePlanPackageBuilder.build(
                input: input,
                plan: nil,
                modeLabel: "Deco",
                planID: UUID(),
                revision: 1
            )
            XCTAssertEqual(
                package.body.gradientFactorPreset,
                preset.fullComputerGradientFactorPresetRawValue
            )
            XCTAssertNotNil(FullComputerGradientFactorPreset.matching(package: package))
        }
    }

    func testBuilderExcludesTravelAndBailoutRoles() throws {
        var input = GasPlanInput()
        input.ensurePlannerCylindersFromLegacy()
        input.gfLow = 30
        input.gfHigh = 70
        input.plannedDepthMeters = 40
        input.plannedBottomMinutes = 20
        let package = try DivePlanPackageBuilder.build(
            input: input,
            plan: nil,
            modeLabel: "Deco",
            planID: UUID(),
            revision: 1
        )
        XCTAssertFalse(package.body.gases.contains(where: { $0.role == .travel }))
        XCTAssertFalse(package.body.gases.contains(where: { $0.role == .bailout }))
    }

    func testTransferSupportRoundTripPayload() throws {
        let body = DivePlanPackageBody(
            schemaVersion: 1,
            algorithmVersion: DivePlanPackageCodec.algorithmVersion,
            planID: UUID(),
            revision: 1,
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(3600),
            environment: DivePlanEnvironmentPayload(altitudeMeters: 0, salinityRaw: SalinityMode.salt.rawValue),
            gfLow: 30,
            gfHigh: 70,
            gases: [
                DivePlanGasPayload(
                    name: "Air",
                    role: .bottom,
                    oxygenFraction: 0.21,
                    heliumFraction: 0,
                    maxPPO2Bar: 1.4
                )
            ],
            bottomSegments: [DivePlanBottomSegmentPayload(depthMeters: 30, durationMinutes: 20, order: 0)],
            plannedSwitches: [],
            plannerSummary: DivePlanSummaryPayload(
                modeLabel: "Deco",
                planKind: "single",
                maxDepthMeters: 30,
                bottomMinutes: 20,
                totalRuntimeMinutes: 35,
                requiresDeco: false,
                decoStopCount: 0
            ),
            capabilities: .current
        )
        let package = try DivePlanPackageCodec.seal(body)
        let data = try DivePlanPackageCodec.encode(package)
        let userInfo = DivePlanPackageTransferSupport.makeTransferUserInfo(packageData: data, package: package)
        let decoded = try DivePlanPackageTransferSupport.decodePackage(from: userInfo)
        XCTAssertEqual(decoded.payloadChecksumSHA256, package.payloadChecksumSHA256)
    }
}
