import Foundation

/// Deterministic iOS deco plan transfer fixture for FC_UI_07 (Command 14).
enum IOSDivePlanTransferMockupFixtures {
    static let fixtureKey = "ios_deco_plan_transfer"
    static let fixedPlanID = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
    static let fixedBottomGasID = UUID(uuidString: "33333333-3333-3333-3333-333333333333")!
    static let fixedDecoGasID = UUID(uuidString: "44444444-4444-4444-4444-444444444444")!
    static let fixedCreatedAt = Date(timeIntervalSince1970: 1_735_689_600)
    static let fixedExpiresAt = Date(timeIntervalSince1970: 2_000_000_000)

    static func validDecoPlanPackage(revision: Int = 1) throws -> DivePlanPackage {
        let body = DivePlanPackageBody(
            schemaVersion: DivePlanPackageCodec.currentSchemaVersion,
            algorithmVersion: DivePlanPackageCodec.algorithmVersion,
            planID: fixedPlanID,
            revision: revision,
            createdAt: fixedCreatedAt,
            expiresAt: fixedExpiresAt,
            environment: DivePlanEnvironmentPayload(altitudeMeters: 0, salinityRaw: SalinityMode.salt.rawValue),
            gfLow: 30,
            gfHigh: 70,
            gases: [
                DivePlanGasPayload(
                    id: fixedBottomGasID,
                    name: "Trimix 18/45",
                    role: .bottom,
                    oxygenFraction: 0.18,
                    heliumFraction: 0.45,
                    maxPPO2Bar: 1.4,
                    switchDepthMeters: nil,
                    sortOrder: 0
                ),
                DivePlanGasPayload(
                    id: fixedDecoGasID,
                    name: "EAN50",
                    role: .deco,
                    oxygenFraction: 0.50,
                    heliumFraction: 0,
                    maxPPO2Bar: 1.6,
                    switchDepthMeters: 21,
                    sortOrder: 1
                ),
            ],
            bottomSegments: [DivePlanBottomSegmentPayload(depthMeters: 45, durationMinutes: 20, order: 0)],
            plannedSwitches: [DivePlanGasSwitchPayload(gasID: fixedDecoGasID, switchDepthMeters: 21, order: 0)],
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

    static func presentationLabels(for package: DivePlanPackage) -> (bottomGas: String, decoGases: String, gf: String, planKind: String) {
        let bottom = package.body.gases.first(where: { $0.role == .bottom })?.name ?? "—"
        let deco = package.body.gases.filter { $0.role == .deco }.map(\.name).joined(separator: ", ")
        let gf = "\(Int(package.body.gfLow))/\(Int(package.body.gfHigh))"
        let plan = package.body.plannerSummary.modeLabel
        return (bottom, deco.isEmpty ? "—" : deco, gf, plan)
    }
}
