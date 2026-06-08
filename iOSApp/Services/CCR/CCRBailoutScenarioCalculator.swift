import Foundation

enum CCRBailoutScenarioCalculator {
    static func evaluateAll(input: CCRPlanInput, environment: PlannerEnvironment) -> [CCRBailoutScenarioResult] {
        CCRBailoutScenarioKind.allCases.map { evaluate(kind: $0, input: input, environment: environment) }
    }

    static func evaluate(kind: CCRBailoutScenarioKind, input: CCRPlanInput, environment: PlannerEnvironment) -> CCRBailoutScenarioResult {
        let startDepth: Double
        let stressMultiplier: Double
        switch kind {
        case .lostLoop, .floodedLoop:
            startDepth = input.maxDepthMeters
            stressMultiplier = input.bailoutStressMultiplier
        case .hypoxia:
            startDepth = max(0, input.setpointProfile.switchDepthMeters)
            stressMultiplier = input.bailoutStressMultiplier * 1.2
        case .hyperoxia:
            startDepth = input.maxDepthMeters
            stressMultiplier = input.bailoutStressMultiplier
        case .manualBailoutAtMaxDepth:
            startDepth = input.maxDepthMeters
            stressMultiplier = input.bailoutStressMultiplier
        }

        guard !input.bailoutGases.isEmpty else {
            return CCRBailoutScenarioResult(
                kind: kind,
                bailoutStartDepthMeters: startDepth,
                requiredGasLitersByCylinder: [:],
                availableGasLitersByCylinder: [:],
                status: .fail,
                warnings: [String(localized: "ccr.bailout.no_gases")],
                gasSwitchSequence: [],
                referenceNotes: String(localized: "ccr.reference_estimate_only")
            )
        }

        let sac = input.bailoutSACLitersPerMinute * stressMultiplier
        let ascentMinutes = max(0.1, startDepth / input.ascentRateMetersPerMinute)
        let bottomMinutes = kind == .manualBailoutAtMaxDepth ? input.bottomTimeMinutes * 0.25 : 0
        let requiredTotal = sac * (ascentMinutes + bottomMinutes + Double(input.decoStopsEstimateMinutes(startDepth: startDepth)))

        var requiredByCylinder: [UUID: Double] = [:]
        var availableByCylinder: [UUID: Double] = [:]
        var warnings: [String] = []
        var sequence: [String] = []
        var remaining = requiredTotal

        for bailout in input.bailoutGases.sorted(by: { $0.switchDepthMeters > $1.switchDepthMeters }) {
            availableByCylinder[bailout.id] = bailout.availableGasLiters
            let allocated = min(remaining, bailout.availableGasLiters)
            requiredByCylinder[bailout.id] = allocated
            remaining = max(0, remaining - allocated)
            sequence.append("\(bailout.label) @ \(Int(bailout.switchDepthMeters)) m")
            if bailout.switchDepthMeters > startDepth {
                warnings.append(String(format: String(localized: "ccr.bailout.switch_deeper_than_start"), bailout.label))
            }
            if let mod = bailout.gasMix.modMeters(environment: environment), startDepth > mod {
                warnings.append(String(format: String(localized: "ccr.bailout.mod_breach"), bailout.label))
            }
        }

        if remaining > 0.5 {
            warnings.append(String(localized: "ccr.bailout.shortfall"))
        }

        let status: CCRBailoutScenarioStatus
        if remaining > 0.5 {
            status = .fail
        } else if warnings.isEmpty {
            status = .pass
        } else {
            status = .warning
        }

        return CCRBailoutScenarioResult(
            kind: kind,
            bailoutStartDepthMeters: startDepth,
            requiredGasLitersByCylinder: requiredByCylinder,
            availableGasLitersByCylinder: availableByCylinder,
            status: status,
            warnings: warnings,
            gasSwitchSequence: sequence,
            referenceNotes: String(localized: "ccr.reference_estimate_only")
        )
    }
}

private extension CCRPlanInput {
    func decoStopsEstimateMinutes(startDepth: Double) -> Int {
        guard startDepth > 9 else { return 0 }
        return Int(ceil(startDepth / BuhlmannConstants.stopIntervalMeters)) * 3
    }
}

private extension GasMix {
    func modMeters(environment: PlannerEnvironment) -> Double? {
        GasMixValidator.modMeters(oxygenFraction: oxygen, maxPPO2: maxPPO2, environment: environment)
    }
}
