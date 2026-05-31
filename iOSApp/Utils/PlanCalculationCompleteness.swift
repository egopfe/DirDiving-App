import Foundation

/// Whether the Bühlmann engine produced a complete, trustworthy decompression schedule.
enum PlanCalculationCompleteness: String, Codable, Hashable {
    case complete
    case incompletePartialStops
    case noDecompressionSolution
}

enum PlanCalculationCompletenessResolver {
    static func resolve(
        enginePlan: BuhlmannEngineResult,
        stops: [DecoStop]
    ) -> (completeness: PlanCalculationCompleteness, presentationStops: [DecoStop], extraStates: [PlannerResultState]) {
        let limitReached = enginePlan.issues.contains(.calculationLimitReached)

        if limitReached {
            return (
                .incompletePartialStops,
                [],
                [.calculationIncomplete, .noValidDecompressionSolution, .modelIncomplete]
            )
        }

        if stops.isEmpty,
           let ndl = enginePlan.ndlMinutes,
           enginePlan.bottomMinutes > ndl + 0.01 {
            return (.noDecompressionSolution, [], [.noValidDecompressionSolution])
        }

        return (.complete, stops, [])
    }
}
