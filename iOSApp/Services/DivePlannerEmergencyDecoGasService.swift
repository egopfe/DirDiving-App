import Foundation

enum DivePlannerEmergencyDecoGasService {
    // Buddy deco gas first implementation:
    // use 2x multiplier on required decompression gas for each deco gas.
    // Future extension may introduce buddy-specific RMV.

    static func analyze(
        input: GasPlanInput,
        enginePlan: BuhlmannEngineResult,
        environment: PlannerEnvironment,
        includeBuddyDecoGas: Bool
    ) -> EmergencyDecoGasAdequacyReport? {
        let requiredByLabel = requiredDecoLitersByGasLabel(
            input: input,
            enginePlan: enginePlan,
            environment: environment
        )
        guard !requiredByLabel.isEmpty else { return nil }

        let availability = decoAvailabilityByGasLabel(from: input)
        let gasNames = Set(requiredByLabel.keys).union(availability.availableLitersByLabel.keys).sorted()

        let results = gasNames.compactMap { gasName -> DecoGasAdequacyResult? in
            let requiredPrimary = requiredByLabel[gasName] ?? 0
            guard requiredPrimary > 0 else { return nil }
            let available = availability.availableLitersByLabel[gasName] ?? 0
            let capacity = availability.cylinderWaterCapacityLitersByLabel[gasName]
            return buildResult(
                gasName: gasName,
                requiredPrimary: requiredPrimary,
                availableLiters: available,
                cylinderWaterCapacityLiters: capacity,
                includeBuddyDecoGas: includeBuddyDecoGas
            )
        }

        guard !results.isEmpty else { return nil }

        return EmergencyDecoGasAdequacyReport(
            buddyIncluded: includeBuddyDecoGas,
            perGasResults: results,
            isOverallAdequate: results.allSatisfy(\.isAdequate)
        )
    }

    static func requiredDecoLitersByGasLabel(
        input: GasPlanInput,
        enginePlan: BuhlmannEngineResult,
        environment: PlannerEnvironment
    ) -> [String: Double] {
        var requiredByLabel: [String: Double] = [:]
        for segment in enginePlan.segments where segment.kind == .stop {
            guard segment.minutes.isFinite, segment.minutes > 0, segment.depthMeters.isFinite else { continue }
            guard let ambient = AmbientPressureModel.ambientPressureBar(
                depthMeters: segment.depthMeters,
                environment: environment
            ), ambient.isFinite, ambient > 0 else { continue }
            let consumed = input.sacLitersPerMinute * ambient * segment.minutes
            guard consumed.isFinite, consumed >= 0 else { continue }
            requiredByLabel[segment.gas.label, default: 0] += consumed
        }
        return requiredByLabel
    }

    static func buildResult(
        gasName: String,
        requiredPrimary: Double,
        availableLiters: Double,
        cylinderWaterCapacityLiters: Double?,
        includeBuddyDecoGas: Bool
    ) -> DecoGasAdequacyResult {
        let requiredBuddy = includeBuddyDecoGas ? requiredPrimary : 0
        let requiredTotal = requiredPrimary + requiredBuddy
        let isAdequate = availableLiters >= requiredTotal
        let reserveLiters = max(0, availableLiters - requiredTotal)
        let shortfallLiters = max(0, requiredTotal - availableLiters)
        let capacity = normalizedCapacity(cylinderWaterCapacityLiters)
        return DecoGasAdequacyResult(
            gasName: gasName,
            requiredLitersPrimaryDiver: requiredPrimary,
            requiredLitersBuddy: requiredBuddy,
            requiredLitersTotal: requiredTotal,
            availableLiters: availableLiters,
            isAdequate: isAdequate,
            reserveLiters: reserveLiters,
            shortfallLiters: shortfallLiters,
            reserveBar: isAdequate ? barEquivalent(liters: reserveLiters, cylinderWaterCapacityLiters: capacity) : nil,
            shortfallBar: isAdequate ? nil : barEquivalent(liters: shortfallLiters, cylinderWaterCapacityLiters: capacity),
            buddyIncluded: includeBuddyDecoGas,
            cylinderWaterCapacityLiters: capacity
        )
    }

    static func barEquivalent(liters: Double, cylinderWaterCapacityLiters: Double?) -> Double? {
        guard let capacity = normalizedCapacity(cylinderWaterCapacityLiters) else { return nil }
        let bar = liters / capacity
        guard bar.isFinite, !bar.isNaN, !bar.isInfinite else { return nil }
        return bar
    }

    static func briefingLines(for report: EmergencyDecoGasAdequacyReport) -> [String] {
        guard report.hasDecoGasChecks else { return [] }
        var lines: [String] = [
            DIRIOSLocalizer.string(
                report.isOverallAdequate
                    ? "planner.emergency.deco_gas.summary_adequate"
                    : "planner.emergency.deco_gas.summary_not_adequate"
            ),
            String(
                format: DIRIOSLocalizer.string("planner.emergency.deco_gas.buddy_included.value"),
                DIRIOSLocalizer.string(
                    report.buddyIncluded
                        ? "planner.emergency.deco_gas.buddy_included.yes"
                        : "planner.emergency.deco_gas.buddy_included.no"
                )
            )
        ]
        for result in report.perGasResults {
            lines.append(
                String(
                    format: DIRIOSLocalizer.string("planner.emergency.deco_gas.briefing.line"),
                    result.gasName,
                    Formatters.zero(result.requiredLitersTotal),
                    Formatters.zero(result.availableLiters),
                    DIRIOSLocalizer.string(
                        result.isAdequate
                            ? "planner.emergency.deco_gas.adequate"
                            : "planner.emergency.deco_gas.not_adequate"
                    )
                )
            )
        }
        return lines
    }

    private struct DecoAvailabilityByGasLabel {
        let availableLitersByLabel: [String: Double]
        let cylinderWaterCapacityLitersByLabel: [String: Double]
    }

    private static func decoAvailabilityByGasLabel(from input: GasPlanInput) -> DecoAvailabilityByGasLabel {
        var availableLitersByLabel: [String: Double] = [:]
        var cylinderWaterCapacityLitersByLabel: [String: Double] = [:]
        for entry in input.plannerCylinders where entry.role == .deco {
            let label = entry.gas.label
            let cylinder = entry.cylinder
            guard cylinder.volumeLiters.isFinite, cylinder.volumeLiters > 0 else { continue }
            let startLiters = cylinder.volumeLiters * cylinder.startPressureBar
            guard startLiters.isFinite, startLiters >= 0 else { continue }
            availableLitersByLabel[label, default: 0] += startLiters
            cylinderWaterCapacityLitersByLabel[label, default: 0] += cylinder.volumeLiters
        }
        return DecoAvailabilityByGasLabel(
            availableLitersByLabel: availableLitersByLabel,
            cylinderWaterCapacityLitersByLabel: cylinderWaterCapacityLitersByLabel
        )
    }

    private static func normalizedCapacity(_ capacity: Double?) -> Double? {
        guard let capacity, capacity.isFinite, capacity > 0 else { return nil }
        return capacity
    }
}
