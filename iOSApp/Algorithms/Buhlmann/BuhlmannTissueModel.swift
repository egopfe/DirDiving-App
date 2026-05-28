import Foundation

struct BuhlmannTissueCompartment: Hashable {
    var nitrogenPressure: Double
    var heliumPressure: Double
}

struct BuhlmannCeiling: Hashable {
    let depthMeters: Double
    let controllingCompartment: Int
}

struct BuhlmannTissueState: Hashable {
    var compartments: [BuhlmannTissueCompartment]

    static func airSaturated() -> BuhlmannTissueState {
        let pn2 = (IOSAlgorithmConfiguration.surfacePressureBar - BuhlmannConstants.waterVaporPressureBar)
            * BuhlmannConstants.nitrogenFractionAir
        let compartments = Array(
            repeating: BuhlmannTissueCompartment(nitrogenPressure: pn2, heliumPressure: 0),
            count: BuhlmannConstants.compartmentCount
        )
        return BuhlmannTissueState(compartments: compartments)
    }

    func loadedConstantDepth(depthMeters: Double, minutes: Double, gas: BuhlmannGas) -> BuhlmannTissueState {
        loadedLinearDepth(fromDepthMeters: depthMeters, toDepthMeters: depthMeters, minutes: minutes, gas: gas)
    }

    func loadedLinearDepth(fromDepthMeters: Double, toDepthMeters: Double, minutes: Double, gas: BuhlmannGas) -> BuhlmannTissueState {
        guard minutes.isFinite, minutes > 0 else { return self }
        let startN2 = gas.inspiredPressure(depthMeters: fromDepthMeters, inert: .nitrogen)
        let endN2 = gas.inspiredPressure(depthMeters: toDepthMeters, inert: .nitrogen)
        let startHe = gas.inspiredPressure(depthMeters: fromDepthMeters, inert: .helium)
        let endHe = gas.inspiredPressure(depthMeters: toDepthMeters, inert: .helium)
        let rateN2 = (endN2 - startN2) / minutes
        let rateHe = (endHe - startHe) / minutes

        let loaded = compartments.enumerated().map { index, compartment in
            let kN2 = log(2.0) / BuhlmannConstants.halfTimesN2[index]
            let kHe = log(2.0) / BuhlmannConstants.halfTimesHe[index]
            return BuhlmannTissueCompartment(
                nitrogenPressure: Self.schreiner(
                    initialTissuePressure: compartment.nitrogenPressure,
                    inspiredPressureAtStart: startN2,
                    inspiredPressureRate: rateN2,
                    k: kN2,
                    minutes: minutes
                ),
                heliumPressure: Self.schreiner(
                    initialTissuePressure: compartment.heliumPressure,
                    inspiredPressureAtStart: startHe,
                    inspiredPressureRate: rateHe,
                    k: kHe,
                    minutes: minutes
                )
            )
        }
        return BuhlmannTissueState(compartments: loaded)
    }

    func ceiling(gf: Double) -> BuhlmannCeiling {
        let fraction = max(0, min(1, gf))
        var maxDepth = 0.0
        var controlling = 0

        for (index, compartment) in compartments.enumerated() {
            let total = compartment.nitrogenPressure + compartment.heliumPressure
            guard total.isFinite, total > 0 else { continue }
            let a = BuhlmannConstants.coefficientA(index: index, pn2: compartment.nitrogenPressure, phe: compartment.heliumPressure)
            let b = BuhlmannConstants.coefficientB(index: index, pn2: compartment.nitrogenPressure, phe: compartment.heliumPressure)
            let denominator = 1.0 + fraction * ((1.0 / b) - 1.0)
            guard denominator.isFinite, denominator > 0 else { continue }
            let toleratedAmbient = (total - fraction * a) / denominator
            let depth = IOSUnitConversions.depthMeters(forPressureBar: toleratedAmbient)
            if depth > maxDepth {
                maxDepth = depth
                controlling = index
            }
        }

        return BuhlmannCeiling(depthMeters: max(0, maxDepth), controllingCompartment: controlling)
    }

    private static func schreiner(
        initialTissuePressure: Double,
        inspiredPressureAtStart: Double,
        inspiredPressureRate: Double,
        k: Double,
        minutes: Double
    ) -> Double {
        guard k.isFinite, k > 0, minutes.isFinite, minutes >= 0 else {
            return initialTissuePressure
        }
        if abs(inspiredPressureRate) < 0.000_000_1 {
            return inspiredPressureAtStart
                + (initialTissuePressure - inspiredPressureAtStart) * exp(-k * minutes)
        }
        return inspiredPressureAtStart
            + inspiredPressureRate * (minutes - (1.0 / k))
            - (inspiredPressureAtStart - initialTissuePressure - inspiredPressureRate / k) * exp(-k * minutes)
    }
}
