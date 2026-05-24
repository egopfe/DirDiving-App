import Foundation

enum BuhlmannPlanner {
    private static let halfTimesN2: [Double] = [5.0,8.0,12.5,18.5,27.0,38.3,54.3,77.0,109.0,146.0,187.0,239.0,305.0,390.0,498.0,635.0]
    private static let aN2: [Double] = [1.1696,1.0,0.8618,0.7562,0.62,0.5043,0.441,0.4,0.375,0.35,0.3295,0.3065,0.2835,0.261,0.248,0.2327]
    private static let bN2: [Double] = [0.5578,0.6514,0.7222,0.7825,0.8126,0.8434,0.8693,0.8910,0.9092,0.9222,0.9319,0.9403,0.9477,0.9544,0.9602,0.9653]

    /// Inert N₂ fraction for the simplified N₂-only ZHL-16C table (helium is not loaded into compartments).
    static func nitrogenFraction(oxygen: Double, helium: Double = 0) -> Double {
        max(0.01, min(0.79, 1.0 - oxygen - helium))
    }

    static func plan(depthMeters: Double, bottomGas: GasMix) -> BuhlmannPlanResult {
        plan(depthMeters: depthMeters, o2Fraction: bottomGas.oxygen, heliumFraction: bottomGas.helium)
    }

    static func plan(depthMeters: Double, o2Fraction: Double, heliumFraction: Double = 0) -> BuhlmannPlanResult {
        let fn2 = nitrogenFraction(oxygen: o2Fraction, helium: heliumFraction)
        var curve: [NDLPoint] = []
        let groups = ["1-4", "5-8", "9-12", "13-16"]
        for (offset, group) in groups.enumerated() {
            for depth in stride(from: 6.0, through: 60.0, by: 3.0) {
                let multiplier = 1.0 - Double(offset) * 0.09
                curve.append(NDLPoint(depthMeters: depth, ndlMinutes: ndl(depthMeters: depth, nitrogenFraction: fn2) * multiplier, compartmentGroup: group))
            }
        }
        let ndlValue = ndl(depthMeters: depthMeters, nitrogenFraction: fn2)
        return BuhlmannPlanResult(
            depthMeters: depthMeters,
            gasO2Fraction: o2Fraction,
            heliumFraction: heliumFraction,
            nitrogenFraction: fn2,
            ndlMinutes: ndlValue,
            curve: curve,
            warning: ndlValue <= 0 ? "Fuori curva secondo modello semplificato." : nil
        )
    }
    static func ndl(depthMeters: Double, nitrogenFraction: Double) -> Double {
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
        return controlling == Double.infinity ? 999 : max(0, controlling)
    }
}
