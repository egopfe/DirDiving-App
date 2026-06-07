import Foundation

/// Planner mode depth/time constraints using the existing Bühlmann engine (no static NDL tables).
enum PlannerModeLimits {
    static let decoMaximumDepthMeters = 40.0
    /// Display/reference equivalent for imperial UX copy (~40 m).
    static let decoMaximumDepthFeet = 131.0

    static func enforceInputLimits(_ input: inout GasPlanInput, mode: PlannerMode) {
        switch mode {
        case .base:
            enforceBasicInputLimits(&input)
        case .deco:
            enforceDecoInputLimits(&input)
        case .technical:
            break
        }
    }

    static func noDecompressionLimitMinutes(
        depthMeters: Double,
        input: GasPlanInput,
        mode: PlannerMode = .base
    ) -> Double? {
        let active = PlannerModePolicy.activePlanInput(from: input, mode: mode)
        guard case .success(let environment) = PlannerEnvironment.make(
            altitudeMeters: active.altitudeMeters,
            salinity: active.salinity
        ) else {
            return nil
        }
        let bottomEntry = active.plannerCylinders.first(where: { $0.role == .bottom })
        let bottomGas = BuhlmannGas(
            gas: bottomEntry?.gas ?? active.bottomGas,
            role: .bottom,
            switchDepthMeters: depthMeters
        )
        guard bottomGas.isCompositionValid else { return nil }
        return BuhlmannEngine.noDecompressionLimit(
            depthMeters: depthMeters,
            gas: bottomGas,
            gfHigh: active.gfHigh,
            initialTissueState: BuhlmannTissueState.airSaturated(surfacePressureBar: environment.surfacePressureBar),
            plannerEnvironment: environment
        )
    }

    static func maximumNoDecompressionDepthMeters(for input: GasPlanInput) -> Double? {
        let active = PlannerModePolicy.activePlanInput(from: input, mode: .base)
        let targetMinutes = active.plannedBottomMinutes
        guard targetMinutes.isFinite, targetMinutes > 0 else {
            return IOSAlgorithmConfiguration.minPlannerDepthMeters
        }

        let minDepth = IOSAlgorithmConfiguration.minPlannerDepthMeters
        let maxDepth = IOSAlgorithmConfiguration.maxPlannerDepthMeters

        func isCompatible(_ depth: Double) -> Bool {
            guard let ndl = noDecompressionLimitMinutes(depthMeters: depth, input: active) else {
                return false
            }
            return targetMinutes <= ndl + 0.05
        }

        guard isCompatible(minDepth) else { return minDepth }
        if isCompatible(maxDepth) { return maxDepth }

        var low = minDepth
        var high = maxDepth
        for _ in 0..<32 {
            let mid = (low + high) / 2.0
            if isCompatible(mid) {
                low = mid
            } else {
                high = mid
            }
        }
        return floor(low)
    }

    static func requiresMandatoryDecompression(for input: GasPlanInput, mode: PlannerMode = .base) -> Bool {
        guard mode == .base else { return false }
        let active = PlannerModePolicy.activePlanInput(from: input, mode: .base)
        guard let ndl = noDecompressionLimitMinutes(
            depthMeters: active.plannedDepthMeters,
            input: active,
            mode: .base
        ) else {
            return active.plannedBottomMinutes > 0.05
        }
        if active.plannedBottomMinutes > ndl + 0.05 {
            return true
        }
        guard case .success(let environment) = PlannerEnvironment.make(
            altitudeMeters: active.altitudeMeters,
            salinity: active.salinity
        ) else {
            return false
        }
        let request = BuhlmannPlanner.makeRequest(input: active, environment: environment)
        guard BuhlmannEngine.validate(request).isEmpty else { return true }
        let enginePlan = BuhlmannEngine.plan(request)
        return !enginePlan.stops.isEmpty
    }

    static func validateBasicLimits(for draft: GasPlanInput) -> PlannerValidationResult {
        var result = PlannerValidationResult()
        if requiresMandatoryDecompression(for: draft, mode: .base) {
            result.add(.basicNoDecoLimitExceeded)
        }
        return result
    }

    static func validateDecoDepthLimits(for draft: GasPlanInput) -> PlannerValidationResult {
        var result = PlannerValidationResult()
        if draft.plannedDepthMeters > decoMaximumDepthMeters + 0.05 {
            result.add(.decoDepthLimitExceeded)
        }
        if draft.plannedAverageDepthMeters > decoMaximumDepthMeters + 0.05 {
            result.add(.decoDepthLimitExceeded)
        }
        return result
    }

    static func basicMaximumBottomMinutes(for input: GasPlanInput) -> Double? {
        noDecompressionLimitMinutes(depthMeters: input.plannedDepthMeters, input: input, mode: .base)
    }

    static func basicMaximumDepthMeters(for input: GasPlanInput) -> Double? {
        maximumNoDecompressionDepthMeters(for: input)
    }

    static func decoMaximumDepthMeters(for input: GasPlanInput) -> Double {
        decoMaximumDepthMeters
    }

    private static func enforceBasicInputLimits(_ input: inout GasPlanInput) {
        if let maxBottom = noDecompressionLimitMinutes(
            depthMeters: input.plannedDepthMeters,
            input: input,
            mode: .base
        ) {
            input.plannedBottomMinutes = min(input.plannedBottomMinutes, floor(maxBottom))
        }
        if let maxDepth = maximumNoDecompressionDepthMeters(for: input) {
            input.plannedDepthMeters = min(input.plannedDepthMeters, maxDepth)
        }
        input.plannedDepthMeters = max(
            IOSAlgorithmConfiguration.minPlannerDepthMeters,
            input.plannedDepthMeters
        )
        input.plannedBottomMinutes = max(1, input.plannedBottomMinutes)
    }

    private static func enforceDecoInputLimits(_ input: inout GasPlanInput) {
        input.plannedDepthMeters = min(input.plannedDepthMeters, decoMaximumDepthMeters)
        input.plannedAverageDepthMeters = min(input.plannedAverageDepthMeters, decoMaximumDepthMeters)
        if input.plannedAverageDepthMeters > input.plannedDepthMeters {
            input.plannedAverageDepthMeters = input.plannedDepthMeters
        }
    }
}

/// Alias for planner calculation mode naming in specs/docs.
typealias PlannerCalculationMode = PlannerMode
