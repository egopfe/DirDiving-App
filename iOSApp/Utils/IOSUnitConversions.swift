import Foundation

enum IOSUnitConversions {
    static func feet(fromMeters meters: Double) -> Double {
        meters * IOSAlgorithmConfiguration.feetPerMeter
    }

    static func meters(fromFeet feet: Double) -> Double {
        feet * IOSAlgorithmConfiguration.metersPerFoot
    }

    static func psi(fromBar bar: Double) -> Double {
        bar * IOSAlgorithmConfiguration.psiPerBar
    }

    static func bar(fromPSI psi: Double) -> Double {
        psi / IOSAlgorithmConfiguration.psiPerBar
    }

    static func cubicFeet(fromLiters liters: Double) -> Double {
        liters * IOSAlgorithmConfiguration.cubicFeetPerLiter
    }

    static func liters(fromCubicFeet cubicFeet: Double) -> Double {
        cubicFeet / IOSAlgorithmConfiguration.cubicFeetPerLiter
    }

    static func fahrenheit(fromCelsius celsius: Double) -> Double {
        celsius * 9.0 / 5.0 + 32.0
    }

    static func celsius(fromFahrenheit fahrenheit: Double) -> Double {
        (fahrenheit - 32.0) * 5.0 / 9.0
    }

    static func feetPerMinute(fromMetersPerMinute metersPerMinute: Double) -> Double {
        metersPerMinute * IOSAlgorithmConfiguration.metersPerMinuteToFeetPerMinute
    }

    static func metersPerMinute(fromFeetPerMinute feetPerMinute: Double) -> Double {
        feetPerMinute / IOSAlgorithmConfiguration.metersPerMinuteToFeetPerMinute
    }

    /// Display-only fallback when no planner environment is available. Do not use for MOD/PPO₂ validation.
    static func displayOnlyAmbientPressureBar(depthMeters: Double) -> Double {
        AmbientPressureModel.ambientPressureBar(
            depthMeters: depthMeters,
            environment: .seaLevelSaltWater
        ) ?? (IOSAlgorithmConfiguration.surfacePressureBar
            + max(0, depthMeters) / IOSAlgorithmConfiguration.metersPerBarApproximation)
    }

    @available(*, deprecated, message: "Use ambientPressureBar(depthMeters:environment:) for safety paths.")
    static func ambientPressureBar(depthMeters: Double) -> Double {
        displayOnlyAmbientPressureBar(depthMeters: depthMeters)
    }

    static func depthMeters(forPressureBar pressureBar: Double) -> Double {
        AmbientPressureModel.depthMeters(ambientPressureBar: pressureBar, environment: .seaLevelSaltWater)
            ?? max(0, pressureBar - IOSAlgorithmConfiguration.surfacePressureBar)
                * IOSAlgorithmConfiguration.metersPerBarApproximation
    }

    static func ambientPressureBar(depthMeters: Double, environment: PlannerEnvironment) -> Double? {
        AmbientPressureModel.ambientPressureBar(depthMeters: depthMeters, environment: environment)
    }

    static func depthMeters(forPressureBar pressureBar: Double, environment: PlannerEnvironment) -> Double? {
        AmbientPressureModel.depthMeters(ambientPressureBar: pressureBar, environment: environment)
    }

}
