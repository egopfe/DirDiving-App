import Foundation

enum BuhlmannPlanner {
    private static let halfTimesN2: [Double] = [5.0,8.0,12.5,18.5,27.0,38.3,54.3,77.0,109.0,146.0,187.0,239.0,305.0,390.0,498.0,635.0]
    private static let aN2: [Double] = [1.1696,1.0,0.8618,0.7562,0.62,0.5043,0.441,0.4,0.375,0.35,0.3295,0.3065,0.2835,0.261,0.248,0.2327]
    private static let bN2: [Double] = [0.5578,0.6514,0.7222,0.7825,0.8126,0.8434,0.8693,0.8910,0.9092,0.9222,0.9319,0.9403,0.9477,0.9544,0.9602,0.9653]
    static func plan(depthMeters: Double, gas: GasMix) -> BuhlmannPlanResult {
        guard depthMeters.isFinite, depthMeters >= IOSAlgorithmConfiguration.minimumPlannerDepthMeters else {
            return unavailable(depthMeters: depthMeters, gas: gas, state: .invalidInput, warning: "Input Buhlmann non valido.")
        }
        guard depthMeters <= IOSAlgorithmConfiguration.maximumPlannerDepthMeters else {
            return unavailable(depthMeters: depthMeters, gas: gas, state: .unsupportedDepth, warning: "Profondita non supportata dal riferimento Buhlmann semplificato.")
        }
        guard let fractions = GasMixValidator.fractions(for: gas) else {
            return unavailable(depthMeters: depthMeters, gas: gas, state: .invalidInput, warning: "Miscela non valida per il riferimento Buhlmann.")
        }
        guard fractions.helium == 0 else {
            return unavailable(depthMeters: depthMeters, gas: gas, state: .unsupportedTrimix, warning: "Trimix non elaborato dal riferimento N2-only semplificato.")
        }
        return plan(depthMeters: depthMeters, o2Fraction: fractions.oxygen)
    }

    static func plan(depthMeters: Double, o2Fraction: Double) -> BuhlmannPlanResult {
        guard depthMeters.isFinite,
              depthMeters >= IOSAlgorithmConfiguration.minimumPlannerDepthMeters,
              depthMeters <= IOSAlgorithmConfiguration.maximumPlannerDepthMeters,
              o2Fraction.isFinite,
              o2Fraction > 0,
              o2Fraction <= 1 else {
            return BuhlmannPlanResult(
                depthMeters: depthMeters.isFinite ? max(0, depthMeters) : 0,
                gasO2Fraction: o2Fraction.isFinite ? max(0, o2Fraction) : 0,
                nitrogenFraction: 0,
                ndlMinutes: 0,
                curve: [],
                warning: "Riferimento Buhlmann non disponibile per input non valido.",
                modelState: .invalidInput
            )
        }
        let fn2 = max(0, min(0.79, 1.0 - o2Fraction))
        var curve: [NDLPoint] = []
        let groups = ["1-4", "5-8", "9-12", "13-16"]
        for (offset, group) in groups.enumerated() {
            for depth in stride(from: 6.0, through: 60.0, by: 3.0) {
                let multiplier = 1.0 - Double(offset) * 0.09
                if let ndl = ndl(depthMeters: depth, nitrogenFraction: fn2) {
                    curve.append(NDLPoint(depthMeters: depth, ndlMinutes: ndl * multiplier, compartmentGroup: group))
                }
            }
        }
        guard let ndlValue = ndl(depthMeters: depthMeters, nitrogenFraction: fn2) else {
            return BuhlmannPlanResult(
                depthMeters: depthMeters,
                gasO2Fraction: o2Fraction,
                nitrogenFraction: fn2,
                ndlMinutes: 0,
                curve: curve,
                warning: "Riferimento NDL non disponibile: non usare come piano azionabile.",
                modelState: .unavailable
            )
        }
        return BuhlmannPlanResult(
            depthMeters: depthMeters,
            gasO2Fraction: o2Fraction,
            nitrogenFraction: fn2,
            ndlMinutes: ndlValue,
            curve: curve,
            warning: ndlValue <= 0 ? "Fuori curva secondo modello semplificato." : "Modello Buhlmann N2-only semplificato: riferimento non certificato.",
            modelState: .simplifiedReferenceOnly
        )
    }

    static func ndl(depthMeters: Double, nitrogenFraction: Double) -> Double? {
        guard depthMeters.isFinite,
              depthMeters >= IOSAlgorithmConfiguration.minimumPlannerDepthMeters,
              depthMeters <= IOSAlgorithmConfiguration.maximumPlannerDepthMeters,
              nitrogenFraction.isFinite,
              nitrogenFraction > 0,
              nitrogenFraction <= 0.79 else { return nil }
        let surfacePressure = 1.0
        let waterVaporPressure = 0.0627
        let surfacePN2 = (surfacePressure - waterVaporPressure) * nitrogenFraction
        let ambient = 1.0 + depthMeters / 10.0
        let inspiredPN2 = (ambient - waterVaporPressure) * nitrogenFraction
        var controlling = Double.infinity
        for i in 0..<halfTimesN2.count {
            let k = log(2.0) / halfTimesN2[i]
            let m0 = (surfacePressure / bN2[i]) + aN2[i]
            if inspiredPN2 <= m0 { continue }
            let ratio = (m0 - inspiredPN2) / (surfacePN2 - inspiredPN2)
            if ratio > 0 && ratio < 1 { controlling = min(controlling, -log(ratio) / k) }
        }
        guard controlling.isFinite else { return nil }
        return max(0, controlling)
    }

    private static func unavailable(depthMeters: Double, gas: GasMix, state: BuhlmannModelState, warning: String) -> BuhlmannPlanResult {
        BuhlmannPlanResult(
            depthMeters: depthMeters.isFinite ? max(0, depthMeters) : 0,
            gasO2Fraction: gas.oxygen.isFinite ? max(0, gas.oxygen) : 0,
            nitrogenFraction: GasMixValidator.fractions(for: gas)?.nitrogen ?? 0,
            ndlMinutes: 0,
            curve: [],
            warning: warning,
            modelState: state
        )
    }
}
