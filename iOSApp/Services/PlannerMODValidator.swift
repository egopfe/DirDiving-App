import Foundation

struct MODValidationIssue: Identifiable, Hashable {
    let id = UUID()
    let gasLabel: String
    let switchDepthMeters: Double
    let modMeters: Double
    let ppO2Max: Double
    let oxygenFraction: Double
    let cylinderRole: GasRole?
}

enum PlannerMODValidator {
    static func modMeters(
        oxygenFraction: Double,
        maxPPO2: Double,
        environment: PlannerEnvironment = .seaLevelSaltWater
    ) -> Double {
        GasMixValidator.modMeters(oxygenFraction: oxygenFraction, maxPPO2: maxPPO2, environment: environment) ?? 0
    }

    static func modMeters(for gas: GasMix, environment: PlannerEnvironment = .seaLevelSaltWater) -> Double {
        modMeters(oxygenFraction: gas.oxygen, maxPPO2: gas.maxPPO2, environment: environment)
    }

    static func validateGasSwitch(
        depthMeters: Double,
        gas: GasMix,
        role: GasRole? = nil,
        environment: PlannerEnvironment = .seaLevelSaltWater
    ) -> MODValidationIssue? {
        let mod = modMeters(for: gas, environment: environment)
        guard depthMeters > mod + 0.05 else { return nil }
        return MODValidationIssue(
            gasLabel: gas.label,
            switchDepthMeters: depthMeters,
            modMeters: mod,
            ppO2Max: gas.maxPPO2,
            oxygenFraction: gas.oxygen,
            cylinderRole: role
        )
    }

    /// Validates every planner cylinder and the planned bottom depth against each gas MOD.
    static func validatePlannerCylinders(
        input: GasPlanInput,
        environment: PlannerEnvironment = .seaLevelSaltWater
    ) -> [MODValidationIssue] {
        var working = input
        working.ensurePlannerCylindersFromLegacy()
        var issues: [MODValidationIssue] = []

        for entry in working.plannerCylinders {
            switch entry.role {
            case .bottom, .ccrDiluent:
                if let issue = validateGasSwitch(
                    depthMeters: working.plannedDepthMeters,
                    gas: entry.gas,
                    role: entry.role,
                    environment: environment
                ) {
                    issues.append(issue)
                }
            case .travel, .deco, .bailout, .ccrBailout:
                if let issue = validateGasSwitch(
                    depthMeters: entry.switchDepthMeters,
                    gas: entry.gas,
                    role: entry.role,
                    environment: environment
                ) {
                    issues.append(issue)
                }
            }
        }
        return issues
    }

    static func validateDecoStops(
        stops: [DecoStop],
        gases: [GasMix],
        environment: PlannerEnvironment = .seaLevelSaltWater
    ) -> [MODValidationIssue] {
        guard !stops.isEmpty, !gases.isEmpty else { return [] }
        var issues: [MODValidationIssue] = []
        for stop in stops {
            let gas = gases.first { $0.label == stop.gas }
                ?? gases.first { stop.gas.localizedCaseInsensitiveContains($0.label) }
                ?? gases.first
            guard let gas else { continue }
            if let issue = validateGasSwitch(
                depthMeters: stop.depthMeters,
                gas: gas,
                role: .deco,
                environment: environment
            ) {
                issues.append(issue)
            }
        }
        return issues
    }

    static func liveInputIssues(
        input: GasPlanInput,
        environment: PlannerEnvironment = .seaLevelSaltWater
    ) -> [MODValidationIssue] {
        var working = input
        working.syncLegacyGasesFromPlannerCylinders()
        return validatePlannerCylinders(input: working, environment: environment)
    }

    static func validateAll(
        input: GasPlanInput,
        requestedStops: [DecoStop],
        environment: PlannerEnvironment = .seaLevelSaltWater
    ) -> [MODValidationIssue] {
        var combined = validatePlannerCylinders(input: input, environment: environment)
        let decoGases = input.plannerCylinders
            .filter { $0.role == .deco }
            .map(\.gas)
        let stopGases = decoGases.isEmpty ? [input.decoGas1, input.decoGas2] : decoGases
        combined.append(contentsOf: validateDecoStops(stops: requestedStops, gases: stopGases, environment: environment))
        return deduplicated(combined)
    }

    private static func deduplicated(_ issues: [MODValidationIssue]) -> [MODValidationIssue] {
        var seen = Set<String>()
        return issues.filter { issue in
            let key = "\(issue.gasLabel)-\(issue.switchDepthMeters)-\(issue.modMeters)"
            return seen.insert(key).inserted
        }
    }
}
