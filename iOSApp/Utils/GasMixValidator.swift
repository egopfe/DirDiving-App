import Foundation

enum GasMixValidator {
    static func validate(oxygen: Double, helium: Double, maxPPO2: Double? = nil) -> PlannerValidationResult {
        var result = PlannerValidationResult()
        guard oxygen.isFinite, helium.isFinite, maxPPO2?.isFinite ?? true else {
            result.add(.invalidInput)
            result.add(.unsupportedGas)
            return result
        }
        if oxygen <= 0 || oxygen > IOSAlgorithmConfiguration.maxGasFraction {
            result.add(.invalidInput)
            result.add(.unsupportedGas)
        }
        if helium < 0 || helium > IOSAlgorithmConfiguration.maxGasFraction {
            result.add(.invalidInput)
            result.add(.unsupportedGas)
        }
        if oxygen + helium > IOSAlgorithmConfiguration.maxGasFraction {
            result.add(.invalidInput)
            result.add(.unsupportedGas)
        }
        if let maxPPO2,
           maxPPO2 < IOSAlgorithmConfiguration.minPPO2Bar || maxPPO2 > IOSAlgorithmConfiguration.maxPPO2Bar {
            result.add(.invalidInput)
            result.add(.PPO2Exceeded)
        }
        return result
    }

    static func validate(_ gas: GasMix) -> PlannerValidationResult {
        validate(oxygen: gas.oxygen, helium: gas.helium, maxPPO2: gas.maxPPO2)
    }

    static func nitrogenFraction(oxygen: Double, helium: Double) -> Double? {
        let validation = validate(oxygen: oxygen, helium: helium)
        guard !validation.states.contains(.invalidInput), !validation.states.contains(.unsupportedGas) else {
            return nil
        }
        return 1.0 - oxygen - helium
    }

    static func actualPPO2(oxygenFraction: Double, depthMeters: Double) -> Double? {
        guard oxygenFraction.isFinite, depthMeters.isFinite, oxygenFraction > 0, depthMeters >= 0 else {
            return nil
        }
        return oxygenFraction * IOSUnitConversions.ambientPressureBar(depthMeters: depthMeters)
    }

    static func modMeters(oxygenFraction: Double, maxPPO2: Double) -> Double? {
        guard oxygenFraction.isFinite,
              maxPPO2.isFinite,
              oxygenFraction > 0,
              maxPPO2 > 0 else {
            return nil
        }
        return IOSUnitConversions.depthMeters(forPressureBar: maxPPO2 / oxygenFraction)
    }
}
