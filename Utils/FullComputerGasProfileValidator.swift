import Foundation

enum FullComputerGasValidationIssue: Hashable, Codable {
    case invalidFractions(String)
    case missingBottomGas
    case duplicateName(String)
    case duplicateSwitchDepth(Double)
    case unorderedSwitchDepths
    case hypoxic(String)
    case modExceeded(String)
    case minPPO2Violated(String)
    case notBreathableAtDepth(String)
    case invalidGradientFactors
    case disabledBottomGas
    case invalidSelection(String)

    var localizationKey: String {
        switch self {
        case .invalidFractions: return "fc.gas.error.fractions"
        case .missingBottomGas: return "fc.gas.error.missing_bottom"
        case .duplicateName: return "fc.gas.error.duplicate_name"
        case .duplicateSwitchDepth: return "fc.gas.error.duplicate_switch"
        case .unorderedSwitchDepths: return "fc.gas.error.unordered_switches"
        case .hypoxic: return "fc.gas.error.hypoxic"
        case .modExceeded: return "fc.gas.error.mod"
        case .minPPO2Violated: return "fc.gas.error.min_ppo2"
        case .notBreathableAtDepth: return "fc.gas.error.not_breathable"
        case .invalidGradientFactors: return "fc.gas.error.gf"
        case .disabledBottomGas: return "fc.gas.error.bottom_disabled"
        case .invalidSelection: return "fc.gas.error.selection"
        }
    }

    var argument: String? {
        switch self {
        case .invalidFractions(let name),
             .duplicateName(let name),
             .hypoxic(let name),
             .modExceeded(let name),
             .minPPO2Violated(let name),
             .notBreathableAtDepth(let name),
             .invalidSelection(let name):
            return name
        case .duplicateSwitchDepth(let depth):
            return Formatters.one(depth)
        default:
            return nil
        }
    }
}

enum FullComputerGasProfileValidator {
    static func validate(
        _ profile: FullComputerGasProfile,
        environment: PlannerEnvironment = .seaLevelSaltWater,
        referenceDepthMeters: Double = 0
    ) -> [FullComputerGasValidationIssue] {
        var issues: [FullComputerGasValidationIssue] = []

        if !profile.bottomGas.isEnabled {
            issues.append(.disabledBottomGas)
        }
        issues.append(contentsOf: validateGas(profile.bottomGas, role: .bottom, environment: environment, referenceDepth: referenceDepthMeters))

        guard profile.bottomGas.oxygenFraction.isFinite,
              profile.bottomGas.heliumFraction.isFinite else {
            issues.append(.missingBottomGas)
            return unique(issues)
        }

        if !profile.gfLow.isFinite || !profile.gfHigh.isFinite
            || profile.gfLow < BuhlmannCoreConfiguration.minGradientFactor
            || profile.gfHigh > BuhlmannCoreConfiguration.maxGradientFactor
            || profile.gfLow >= profile.gfHigh {
            issues.append(.invalidGradientFactors)
        }

        var names: [String: FullComputerConfiguredGas] = [:]
        for gas in [profile.bottomGas] + profile.decoGases + profile.travelGases + profile.bailoutGases {
            let key = gas.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard !key.isEmpty else { continue }
            if let existing = names[key],
               abs(existing.oxygenFraction - gas.oxygenFraction) > 0.001
                || abs(existing.heliumFraction - gas.heliumFraction) > 0.001 {
                issues.append(.duplicateName(gas.name))
            } else {
                names[key] = gas
            }
        }

        let enabledDeco = profile.enabledDecoGases
        var seenDepths: Set<Int> = []
        var previousDepth = Double.infinity
        for gas in enabledDeco {
            issues.append(contentsOf: validateGas(gas, role: .deco, environment: environment, referenceDepth: gas.switchDepthMeters))
            let depthKey = Int((gas.switchDepthMeters * 10).rounded())
            if seenDepths.contains(depthKey) {
                issues.append(.duplicateSwitchDepth(gas.switchDepthMeters))
            }
            seenDepths.insert(depthKey)
            if gas.switchDepthMeters > previousDepth {
                issues.append(.unorderedSwitchDepths)
            }
            previousDepth = gas.switchDepthMeters
        }

        for gas in profile.travelGases where gas.isEnabled {
            issues.append(contentsOf: validateGas(gas, role: .travel, environment: environment, referenceDepth: gas.switchDepthMeters))
        }

        return unique(issues)
    }

    static func isValid(_ profile: FullComputerGasProfile) -> Bool {
        validate(profile).isEmpty
    }

    private static func validateGas(
        _ gas: FullComputerConfiguredGas,
        role: GasRole,
        environment: PlannerEnvironment,
        referenceDepth: Double
    ) -> [FullComputerGasValidationIssue] {
        var issues: [FullComputerGasValidationIssue] = []
        let buhlmann = gas.toBuhlmannGas()

        guard gas.oxygenFraction.isFinite,
              gas.heliumFraction.isFinite,
              gas.oxygenFraction > 0,
              gas.oxygenFraction <= 1,
              gas.heliumFraction >= 0,
              gas.heliumFraction <= 1,
              gas.oxygenFraction + gas.heliumFraction <= 1.0 + 0.000_1 else {
            issues.append(.invalidFractions(gas.name))
            return issues
        }

        if !buhlmann.isCompositionValid {
            issues.append(.invalidFractions(gas.name))
        }

        let checkDepth = max(0, referenceDepth)
        let ppo2 = buhlmann.ppO2(depthMeters: checkDepth, environment: environment)
        if ppo2 < BuhlmannConstants.minBreathablePPO2Bar {
            issues.append(.hypoxic(gas.name))
        }
        if ppo2 > gas.maxPPO2Bar + 0.000_1 {
            issues.append(.modExceeded(gas.name))
        }
        if let mod = buhlmann.modMeters(environment: environment),
           checkDepth > mod + 0.05 {
            issues.append(.modExceeded(gas.name))
        }

        if role != .bottom {
            let minDepth = buhlmann.minimumOperatingDepthMeters(environment: environment)
            if checkDepth < minDepth - 0.05 {
                issues.append(.minPPO2Violated(gas.name))
            }
        }

        if !buhlmann.isOperational(fromDepthMeters: checkDepth, toDepthMeters: checkDepth, environment: environment) {
            issues.append(.notBreathableAtDepth(gas.name))
        }

        if !gas.isEnabled && role == .bottom {
            issues.append(.disabledBottomGas)
        }

        return issues
    }

    private static func unique(_ issues: [FullComputerGasValidationIssue]) -> [FullComputerGasValidationIssue] {
        var seen = Set<FullComputerGasValidationIssue>()
        return issues.filter { seen.insert($0).inserted }
    }
}
