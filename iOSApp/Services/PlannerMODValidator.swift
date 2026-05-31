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
    /// MOD (m) = ((PPO₂ max / FO₂) - 1) × 10 — Dalton / best mix (FO₂ from mix, including trimix helium fraction).
    static func modMeters(oxygenFraction: Double, maxPPO2: Double) -> Double {
        GasMixValidator.modMeters(oxygenFraction: oxygenFraction, maxPPO2: maxPPO2) ?? 0
    }

    static func modMeters(for gas: GasMix) -> Double {
        modMeters(oxygenFraction: gas.oxygen, maxPPO2: gas.maxPPO2)
    }

    static func validateGasSwitch(depthMeters: Double, gas: GasMix, role: GasRole? = nil) -> MODValidationIssue? {
        let mod = modMeters(for: gas)
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
    static func validatePlannerCylinders(input: GasPlanInput) -> [MODValidationIssue] {
        var working = input
        working.ensurePlannerCylindersFromLegacy()
        var issues: [MODValidationIssue] = []

        for entry in working.plannerCylinders {
            switch entry.role {
            case .bottom:
                if let issue = validateGasSwitch(
                    depthMeters: working.plannedDepthMeters,
                    gas: entry.gas,
                    role: .bottom
                ) {
                    issues.append(issue)
                }
            case .travel, .deco, .bailout:
                if let issue = validateGasSwitch(
                    depthMeters: entry.switchDepthMeters,
                    gas: entry.gas,
                    role: entry.role
                ) {
                    issues.append(issue)
                }
            }
        }
        return issues
    }

    static func validateDecoStops(stops: [DecoStop], gases: [GasMix]) -> [MODValidationIssue] {
        guard !stops.isEmpty, !gases.isEmpty else { return [] }
        var issues: [MODValidationIssue] = []
        for (index, stop) in stops.enumerated() {
            let gas = gases[min(index, gases.count - 1)]
            if let issue = validateGasSwitch(depthMeters: stop.depthMeters, gas: gas, role: .deco) {
                issues.append(issue)
            }
        }
        return issues
    }

    static func liveInputIssues(input: GasPlanInput) -> [MODValidationIssue] {
        var working = input
        working.syncLegacyGasesFromPlannerCylinders()
        return validatePlannerCylinders(input: working)
    }

    static func validateAll(input: GasPlanInput, requestedStops: [DecoStop]) -> [MODValidationIssue] {
        var combined = validatePlannerCylinders(input: input)
        let decoGases = input.plannerCylinders
            .filter { $0.role == .deco }
            .map(\.gas)
        let stopGases = decoGases.isEmpty ? [input.decoGas1, input.decoGas2] : decoGases
        combined.append(contentsOf: validateDecoStops(stops: requestedStops, gases: stopGases))
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
