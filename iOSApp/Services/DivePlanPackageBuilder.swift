import Foundation

enum DivePlanPackageBuilder {
    static func build(
        input: GasPlanInput,
        plan: DivePlanResult?,
        modeLabel: String,
        planID: UUID,
        revision: Int,
        createdAt: Date = Date(),
        expiresAt: Date? = nil
    ) throws -> DivePlanPackage {
        var workingInput = input
        workingInput.ensurePlannerCylindersFromLegacy()
        workingInput.syncLegacyGasesFromPlannerCylinders()

        let gases = workingInput.plannerCylinders.enumerated().map { index, entry in
            DivePlanGasPayload(
                id: entry.gas.id,
                name: entry.gas.name,
                role: entry.role,
                oxygenFraction: entry.gas.oxygen,
                heliumFraction: entry.gas.helium,
                maxPPO2Bar: entry.gas.maxPPO2,
                switchDepthMeters: entry.role == .bottom ? nil : entry.switchDepthMeters,
                sortOrder: index
            )
        }

        let bottomSegments = makeBottomSegments(input: workingInput, plan: plan)
        let switches = workingInput.plannerCylinders
            .filter { $0.role == .deco }
            .sorted { $0.switchDepthMeters > $1.switchDepthMeters }
            .enumerated()
            .map { index, entry in
                DivePlanGasSwitchPayload(
                    gasID: entry.gas.id,
                    switchDepthMeters: entry.switchDepthMeters,
                    order: index
                )
            }

        let maxDepth = plan?.segments.filter { $0.kind == .bottom }.map(\.depthMeters).max()
            ?? workingInput.plannedDepthMeters
        let bottomMinutes = plan?.segments.filter { $0.kind == .bottom }.map(\.minutes).reduce(0, +)
            ?? workingInput.plannedBottomMinutes
        let decoStopCount = plan?.decoStops.count ?? 0
        let requiresDeco = decoStopCount > 0 || (plan?.ttsMinutes ?? 0) > 0
        let planKind = bottomSegments.count > 1 ? "multilevel" : "single"

        let body = DivePlanPackageBody(
            schemaVersion: DivePlanPackageCodec.currentSchemaVersion,
            algorithmVersion: DivePlanPackageCodec.algorithmVersion,
            planID: planID,
            revision: revision,
            createdAt: createdAt,
            expiresAt: expiresAt ?? createdAt.addingTimeInterval(DivePlanPackageCodec.defaultTTL),
            environment: DivePlanEnvironmentPayload(
                altitudeMeters: workingInput.altitudeMeters,
                salinityRaw: workingInput.salinity.rawValue
            ),
            gfLow: workingInput.gfLow,
            gfHigh: workingInput.gfHigh,
            gases: gases,
            bottomSegments: bottomSegments,
            plannedSwitches: switches,
            plannerSummary: DivePlanSummaryPayload(
                modeLabel: modeLabel,
                planKind: planKind,
                maxDepthMeters: maxDepth,
                bottomMinutes: bottomMinutes,
                totalRuntimeMinutes: plan?.totalRuntimeMinutes ?? Int(bottomMinutes.rounded()),
                requiresDeco: requiresDeco,
                decoStopCount: decoStopCount
            ),
            capabilities: .current
        )
        return try DivePlanPackageCodec.seal(body)
    }

    private static func makeBottomSegments(input: GasPlanInput, plan: DivePlanResult?) -> [DivePlanBottomSegmentPayload] {
        let bottomFromPlan = plan?.segments
            .filter { $0.kind == .bottom }
            .enumerated()
            .map { index, segment in
                DivePlanBottomSegmentPayload(
                    depthMeters: segment.depthMeters,
                    durationMinutes: segment.minutes,
                    order: index
                )
            } ?? []
        if !bottomFromPlan.isEmpty { return bottomFromPlan }
        return [
            DivePlanBottomSegmentPayload(
                depthMeters: input.plannedDepthMeters,
                durationMinutes: input.plannedBottomMinutes,
                order: 0
            )
        ]
    }
}
