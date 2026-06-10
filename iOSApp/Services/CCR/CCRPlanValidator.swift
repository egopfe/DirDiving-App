import Foundation

enum CCRPlanValidator {
    private static let minimumSetpointBar = 0.5
    private static let maximumSetpointBar = IOSAlgorithmConfiguration.maxPPO2Bar

    static func validate(_ input: CCRPlanInput, environment: PlannerEnvironment) -> CCRPlanValidationResult {
        var issues: [CCRPlanIssue] = []
        let profile = input.setpointProfile

        if !input.maxDepthMeters.isFinite
            || input.maxDepthMeters < IOSAlgorithmConfiguration.minPlannerDepthMeters
            || input.maxDepthMeters > IOSAlgorithmConfiguration.maxPlannerDepthMeters {
            issues.append(.invalidDepth(DIRIOSLocalizer.string("ccr.validation.invalid_depth")))
        }

        if !input.bottomTimeMinutes.isFinite
            || input.bottomTimeMinutes <= 0
            || input.bottomTimeMinutes > IOSAlgorithmConfiguration.maxBottomTimeMinutes {
            issues.append(.invalidDepth(DIRIOSLocalizer.string("ccr.validation.invalid_bottom_time")))
        }

        if !input.gfLow.isFinite || !input.gfHigh.isFinite || input.gfLow >= input.gfHigh {
            issues.append(.invalidGradientFactor(DIRIOSLocalizer.string("ccr.validation.invalid_gf")))
        }

        for (label, value) in [("low", profile.lowSetpoint), ("high", profile.highSetpoint)] {
            if !value.isFinite || value <= 0 {
                issues.append(.invalidSetpoint(DIRIOSLocalizer.formatted("ccr.validation.invalid_setpoint", label)))
                continue
            }
            if value < minimumSetpointBar || value > maximumSetpointBar {
                issues.append(.hyperoxicSetpoint(DIRIOSLocalizer.formatted("ccr.validation.setpoint_out_of_bounds", label)))
            }
        }

        if profile.lowSetpoint >= profile.highSetpoint {
            issues.append(.invalidSetpoint(DIRIOSLocalizer.string("ccr.validation.low_ge_high")))
        }

        if input.diluent.mixKind == .oxygen {
            issues.append(.invalidDiluent(DIRIOSLocalizer.string("ccr.validation.pure_o2_diluent")))
        }

        if input.diluent.oxygenFraction + input.diluent.heliumFraction > 1.0 {
            issues.append(.invalidDiluent(DIRIOSLocalizer.string("ccr.validation.invalid_diluent_mix")))
        }

        if let lowAtSurface = CCRInspiredGasModel.inspiredPressures(
            depthMeters: 0,
            setpointBar: profile.lowSetpoint,
            diluent: input.diluent,
            environment: environment
        ), lowAtSurface.availableInert <= 0, profile.lowSetpoint > environment.surfacePressureBar {
            issues.append(.ambientBelowSetpoint(DIRIOSLocalizer.string("ccr.validation.ambient_below_low_setpoint")))
        }

        let diluentPPO2AtMax = input.diluent.oxygenFraction
            * CCRInspiredGasModel.ambientPressureBar(depthMeters: input.maxDepthMeters, environment: environment)
        if diluentPPO2AtMax < BuhlmannConstants.minBreathablePPO2Bar {
            issues.append(.hypoxicDiluent(DIRIOSLocalizer.string("ccr.validation.hypoxic_diluent_at_depth")))
        }

        for bailout in input.bailoutGases {
            if bailout.mixKind == .oxygen && bailout.switchDepthMeters > 6 {
                issues.append(.bailoutMODExceeded(DIRIOSLocalizer.formatted("ccr.validation.bailout_o2_shallow", bailout.label)))
                continue
            }
            let mod = bailout.gasMix.modMeters(environment: environment) ?? 0
            if bailout.switchDepthMeters > mod + 0.5 {
                issues.append(.bailoutMODExceeded(DIRIOSLocalizer.formatted("ccr.validation.bailout_mod", bailout.label)))
            }
        }

        if input.bailoutGases.isEmpty {
            issues.append(.missingBailout(DIRIOSLocalizer.string("ccr.validation.missing_bailout")))
        }

        return CCRPlanValidationResult(issues: issues)
    }
}

private extension GasMix {
    func modMeters(environment: PlannerEnvironment) -> Double? {
        GasMixValidator.modMeters(oxygenFraction: oxygen, maxPPO2: maxPPO2, environment: environment)
    }
}
