import Foundation

enum CCRGasDensityPresentation {
    static func timelineSamples(from plan: CCRPlanResult) -> [(runtimeMinutes: Double, density: Double)] {
        plan.gasDensityTimeline.compactMap { sample -> (Double, Double)? in
            guard let density = sample.gasDensityGramsPerLiter else { return nil }
            return (sample.runtimeMinutes, density)
        }
    }

    static func hasAvailableTimeline(_ plan: CCRPlanResult) -> Bool {
        !timelineSamples(from: plan).isEmpty
    }

    static func unavailableReason(for plan: CCRPlanResult) -> CCRGasDensityUnavailableReason? {
        if hasAvailableTimeline(plan) { return nil }
        if let firstUnavailable = plan.gasDensityTimeline.compactMap(\.gasDensityResult).first {
            if case .unavailable(let reason) = firstUnavailable {
                return reason
            }
        }
        return .inspiredGasUnavailable
    }

    static func unavailableLabel(for reason: CCRGasDensityUnavailableReason?) -> String {
        guard let reason else {
            return DIRIOSLocalizer.string("ccr.gas_density.unavailable.label")
        }
        return DIRIOSLocalizer.string("ccr.gas_density.unavailable.\(reason.rawValue)")
    }

    static func accessibilitySummary(for plan: CCRPlanResult) -> String {
        if hasAvailableTimeline(plan) {
            let samples = timelineSamples(from: plan)
            return UIUXAccessibilitySummaries.ccrGasDensityTimeline(samples: samples)
        }
        let reason = unavailableReason(for: plan)
        return String(
            format: DIRIOSLocalizer.string("ccr.gas_density.unavailable.a11y"),
            unavailableLabel(for: reason)
        )
    }
}
