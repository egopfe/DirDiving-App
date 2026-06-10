import Foundation

enum PlannerInputValidator {
    static func validate(_ input: GasPlanInput) -> PlannerValidationResult {
        validate(input, mode: .technical)
    }

    static func validate(_ input: GasPlanInput, mode: PlannerMode) -> PlannerValidationResult {
        let presentation = PlannerResultPresentation.presentation(for: mode)
        var result = PlannerValidationResult()
        if !input.plannedDepthMeters.isFinite || input.plannedDepthMeters < IOSAlgorithmConfiguration.minPlannerDepthMeters {
            result.add(.invalidInput, message: DIRIOSLocalizer.string("planner.validation.max_depth_invalid"))
        } else if input.plannedDepthMeters > IOSAlgorithmConfiguration.maxPlannerDepthMeters {
            result.add(.unsupportedDepth)
        }
        if mode != .base {
            if !input.plannedAverageDepthMeters.isFinite
                || input.plannedAverageDepthMeters < 0
                || input.plannedAverageDepthMeters > input.plannedDepthMeters {
                result.add(.invalidInput, message: DIRIOSLocalizer.string("planner.validation.average_depth_invalid"))
            }
        }
        let depth = input.effectivePlanningDepthMeters
        let bottomTime = input.plannedBottomMinutes

        if !depth.isFinite || depth < IOSAlgorithmConfiguration.minPlannerDepthMeters {
            result.add(.invalidInput, message: DIRIOSLocalizer.string("planner.validation.depth_invalid"))
        } else if depth > IOSAlgorithmConfiguration.maxPlannerDepthMeters {
            result.add(.unsupportedDepth)
        }

        if !bottomTime.isFinite || bottomTime <= 0 || bottomTime > IOSAlgorithmConfiguration.maxBottomTimeMinutes {
            result.add(.invalidInput, message: DIRIOSLocalizer.string("planner.validation.bottom_time_invalid"))
        }

        if !input.sacLitersPerMinute.isFinite || input.sacLitersPerMinute <= 0 {
            result.add(.invalidInput, message: DIRIOSLocalizer.string("planner.validation.sac_invalid"))
        }
        if presentation.showsExtendedAnalysisTiles {
            if !input.emergencySacLitersPerMinute.isFinite || input.emergencySacLitersPerMinute <= 0 {
                result.add(.invalidInput, message: DIRIOSLocalizer.string("planner.validation.sac_buddy_invalid"))
            }
            if input.teamSize < 1 {
                result.add(.invalidInput, message: DIRIOSLocalizer.string("planner.validation.team_size_invalid"))
            }
        }
        if !input.waterTemperatureCelsius.isFinite
            || input.waterTemperatureCelsius < IOSAlgorithmConfiguration.minWaterTemperatureCelsius
            || input.waterTemperatureCelsius > IOSAlgorithmConfiguration.maxWaterTemperatureCelsius {
            result.add(.invalidInput, message: DIRIOSLocalizer.string("planner.validation.temperature_invalid"))
        }
        if presentation.showsManualGFControls {
            if !input.gfLow.isFinite
                || !input.gfHigh.isFinite
                || input.gfLow < IOSAlgorithmConfiguration.minGradientFactor
                || input.gfHigh > IOSAlgorithmConfiguration.maxGradientFactor
                || input.gfLow >= input.gfHigh {
                result.add(.invalidInput, message: DIRIOSLocalizer.string("planner.validation.gradient_factors_invalid"))
            }
        }
        if mode == .technical {
            if !input.densityWarningLimit.isFinite
                || !input.densityDangerLimit.isFinite
                || input.densityWarningLimit <= 0
                || input.densityDangerLimit <= input.densityWarningLimit {
                result.add(.invalidInput, message: DIRIOSLocalizer.string("planner.validation.density_limits_invalid"))
            }
        }

        if case .failure(let error) = PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) {
            switch error {
            case .invalidAltitude:
                result.add(.invalidEnvironment, message: DIRIOSLocalizer.string("planner.environment.invalid_altitude.message"))
            case .invalidSalinity:
                result.add(.invalidEnvironment, message: DIRIOSLocalizer.string("planner.environment.invalid_salinity.message"))
            }
        }

        let environment = input.plannerEnvironment
        for issue in PlannerMODValidator.validatePlannerCylinders(input: input, environment: environment) {
            guard issue.cylinderRole != .bottom else { continue }
            result.add(.MODExceeded, message: DIRIOSLocalizer.string("planner.mod.exceeds_allowed"))
        }

        for entry in input.plannerCylinders {
            result.merge(validate(cylinder: entry.cylinder))
        }
        result.merge(validate(cylinder: input.primaryCylinder))
        if presentation.showsTeamPreview {
            for member in input.teamMembers {
                if !member.sacLitersPerMinute.isFinite || member.sacLitersPerMinute <= 0 {
                    result.add(.invalidInput, message: DIRIOSLocalizer.string("planner.validation.team_sac_invalid"))
                }
                result.merge(validate(cylinder: member.cylinder))
            }
        }

        for gas in input.allGases {
            result.merge(GasMixValidator.validate(gas))
        }

        if result.states.isEmpty {
            result.add(.validReference)
        }
        return result
    }

    static func validate(cylinder: Cylinder) -> PlannerValidationResult {
        var result = PlannerValidationResult()
        if !cylinder.volumeLiters.isFinite || cylinder.volumeLiters <= 0 {
            result.add(.invalidInput, message: DIRIOSLocalizer.string("planner.validation.cylinder_volume_invalid"))
        }
        if !cylinder.startPressure.isFinite
            || !cylinder.reservePressure.isFinite
            || cylinder.startPressure < 0
            || cylinder.reservePressure < 0 {
            result.add(.invalidInput, message: DIRIOSLocalizer.string("planner.validation.cylinder_pressure_invalid"))
        }
        if cylinder.startPressureBar <= cylinder.reservePressureBar {
            result.add(.invalidInput, message: DIRIOSLocalizer.string("planner.validation.cylinder_reserve_invalid"))
        }
        return result
    }
}
