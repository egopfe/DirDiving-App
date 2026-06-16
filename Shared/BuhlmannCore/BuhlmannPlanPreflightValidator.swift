import Foundation

/// Explicit gas/profile validation before Bühlmann schedule generation.
enum BuhlmannPlanPreflightValidator {
    static func validate(_ request: BuhlmannPlanRequest) -> [BuhlmannPlanIssue] {
        var issues = BuhlmannEngine.validate(request)
        issues.append(contentsOf: validateAscentDecoGasEnvelope(request))
        return uniqueIssues(issues)
    }

    /// Validates deco/travel gas usability across expected post-switch depth bands before schedule propagation.
    private static func validateAscentDecoGasEnvelope(_ request: BuhlmannPlanRequest) -> [BuhlmannPlanIssue] {
        var issues: [BuhlmannPlanIssue] = []
        let environment = request.plannerEnvironment

        let switchGases = (request.decoGases + request.travelGases)
            .filter { $0.role != .bottom }
            .sorted { $0.switchDepthMeters > $1.switchDepthMeters }

        for (index, gas) in switchGases.enumerated() {
            let lowerBound = index + 1 < switchGases.count ? switchGases[index + 1].switchDepthMeters : 0
            issues.append(contentsOf: operationalIssues(
                for: gas,
                fromDepth: gas.switchDepthMeters,
                toDepth: lowerBound,
                environment: environment
            ))
            let switchPPO2 = gas.ppO2(depthMeters: gas.switchDepthMeters, environment: environment)
            if switchPPO2 > gas.maxPPO2Bar + BuhlmannConstants.decoGasSwitchPPO2ToleranceBar {
                issues.append(.gasSwitchTooDeep(gas.name))
            }
            if switchPPO2 < BuhlmannConstants.minBreathablePPO2Bar {
                issues.append(.hypoxicGasTooShallow(gas.name))
            }
        }

        var compositionByName: [String: BuhlmannGas] = [:]
        for gas in [request.bottomGas] + request.travelGases + request.decoGases where !gas.name.isEmpty {
            if let existing = compositionByName[gas.name],
               (abs(existing.oxygenFraction - gas.oxygenFraction) > 0.001
                || abs(existing.heliumFraction - gas.heliumFraction) > 0.001) {
                issues.append(.invalidGas(gas.name))
            } else {
                compositionByName[gas.name] = gas
            }
        }

        return issues
    }

    private static func operationalIssues(
        for gas: BuhlmannGas,
        fromDepth: Double,
        toDepth: Double,
        environment: PlannerEnvironment
    ) -> [BuhlmannPlanIssue] {
        guard gas.isCompositionValid, fromDepth.isFinite, toDepth.isFinite else {
            return [.invalidGas(gas.name)]
        }
        let shallow = max(0, min(fromDepth, toDepth))
        let deep = max(fromDepth, toDepth)
        var issues: [BuhlmannPlanIssue] = []
        if gas.ppO2(depthMeters: shallow, environment: environment) < BuhlmannConstants.minBreathablePPO2Bar {
            issues.append(.hypoxicGasTooShallow(gas.name))
        }
        let maxPPO2Tolerance = gas.role == .bottom
            ? 0.000_1
            : BuhlmannConstants.decoGasSwitchPPO2ToleranceBar
        if gas.ppO2(depthMeters: deep, environment: environment) > gas.maxPPO2Bar + maxPPO2Tolerance {
            issues.append(.ppo2Exceeded(gas.name))
        }
        return issues
    }

    private static func uniqueIssues(_ issues: [BuhlmannPlanIssue]) -> [BuhlmannPlanIssue] {
        var seen = Set<BuhlmannPlanIssue>()
        var result: [BuhlmannPlanIssue] = []
        for issue in issues where seen.insert(issue).inserted {
            result.append(issue)
        }
        return result
    }
}
