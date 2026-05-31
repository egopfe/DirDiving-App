import Foundation

enum PlannerInputValidator {
    static func validate(_ input: GasPlanInput) -> PlannerValidationResult {
        var result = PlannerValidationResult()
        if !input.plannedDepthMeters.isFinite || input.plannedDepthMeters < IOSAlgorithmConfiguration.minPlannerDepthMeters {
            result.add(.invalidInput, message: "Profondita massima non valida.")
        } else if input.plannedDepthMeters > IOSAlgorithmConfiguration.maxPlannerDepthMeters {
            result.add(.unsupportedDepth)
        }
        if !input.plannedAverageDepthMeters.isFinite
            || input.plannedAverageDepthMeters < 0
            || input.plannedAverageDepthMeters > input.plannedDepthMeters {
            result.add(.invalidInput, message: "Profondita media non valida.")
        }
        let depth = input.effectivePlanningDepthMeters
        let bottomTime = input.plannedBottomMinutes

        if !depth.isFinite || depth < IOSAlgorithmConfiguration.minPlannerDepthMeters {
            result.add(.invalidInput, message: "Profondita non valida.")
        } else if depth > IOSAlgorithmConfiguration.maxPlannerDepthMeters {
            result.add(.unsupportedDepth)
        }

        if !bottomTime.isFinite || bottomTime <= 0 || bottomTime > IOSAlgorithmConfiguration.maxBottomTimeMinutes {
            result.add(.invalidInput, message: "Tempo al fondo non valido.")
        }

        if !input.sacLitersPerMinute.isFinite || input.sacLitersPerMinute <= 0 {
            result.add(.invalidInput, message: "SAC/RMV non valido.")
        }
        if !input.emergencySacLitersPerMinute.isFinite || input.emergencySacLitersPerMinute <= 0 {
            result.add(.invalidInput, message: "SAC di emergenza non valido.")
        }
        if input.teamSize < 1 {
            result.add(.invalidInput, message: "Team size non valido.")
        }
        if !input.waterTemperatureCelsius.isFinite
            || input.waterTemperatureCelsius < IOSAlgorithmConfiguration.minWaterTemperatureCelsius
            || input.waterTemperatureCelsius > IOSAlgorithmConfiguration.maxWaterTemperatureCelsius {
            result.add(.invalidInput, message: "Temperatura non valida.")
        }
        if !input.gfLow.isFinite
            || !input.gfHigh.isFinite
            || input.gfLow < IOSAlgorithmConfiguration.minGradientFactor
            || input.gfHigh > IOSAlgorithmConfiguration.maxGradientFactor
            || input.gfLow >= input.gfHigh {
            result.add(.invalidInput, message: "Gradient factor non validi.")
        }
        if case .failure(let error) = PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) {
            switch error {
            case .invalidAltitude:
                result.add(.invalidEnvironment, message: String(localized: "planner.environment.invalid_altitude.message"))
            case .invalidSalinity:
                result.add(.invalidEnvironment, message: String(localized: "planner.environment.invalid_salinity.message"))
            }
        }

        if !input.densityWarningLimit.isFinite
            || !input.densityDangerLimit.isFinite
            || input.densityWarningLimit <= 0
            || input.densityDangerLimit <= input.densityWarningLimit {
            result.add(.invalidInput, message: "Limiti densita gas non validi.")
        }

        for entry in input.plannerCylinders {
            result.merge(validate(cylinder: entry.cylinder))
        }
        result.merge(validate(cylinder: input.primaryCylinder))
        for member in input.teamMembers {
            if !member.sacLitersPerMinute.isFinite || member.sacLitersPerMinute <= 0 {
                result.add(.invalidInput, message: "SAC team non valido.")
            }
            result.merge(validate(cylinder: member.cylinder))
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
            result.add(.invalidInput, message: "Volume bombola non valido.")
        }
        if !cylinder.startPressure.isFinite
            || !cylinder.reservePressure.isFinite
            || cylinder.startPressure < 0
            || cylinder.reservePressure < 0 {
            result.add(.invalidInput, message: "Pressioni bombola non valide.")
        }
        if cylinder.startPressureBar <= cylinder.reservePressureBar {
            result.add(.invalidInput, message: "Pressione iniziale minore o uguale alla riserva.")
        }
        return result
    }
}
