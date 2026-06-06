import Foundation

enum BuhlmannConstants {
    static let compartmentCount = 16
    static let waterVaporPressureBar = 0.0627
    /// Matches `PlannerEnvironment.seaLevelSaltWater.surfacePressureBar` (ISA sea-level barometric).
    static let seaLevelSurfacePressureBar = 1.01325
    /// Matches `WaterDensityModel.saltwaterDensityKgPerM3` for Bühlmann fallback pressure paths.
    static let saltwaterDensityKgPerM3 = 1_025.0
    static let defaultDescentRateMetersPerMinute = 18.0
    static let defaultAscentRateMetersPerMinute = 9.0
    static let stopIntervalMeters = 3.0
    static let gasSwitchMinutes = 0.5
    static let maxStopMinutesPerDepth = 180
    static let maxScheduleMinutes = 720
    static let minBreathablePPO2Bar = 0.16
    /// Allows standard recreational deco switch depths (e.g. 6 m O2 @ 1.6 bar) under ISA ambient pressure.
    static var decoGasSwitchPPO2ToleranceBar: Double { IOSAlgorithmConfiguration.ppo2DecoGasSwitchDepthToleranceBar }
    static let oxygenFractionAir = 0.21
    static let nitrogenFractionAir = 0.79

    static let halfTimesN2: [Double] = [
        5.0, 8.0, 12.5, 18.5, 27.0, 38.3, 54.3, 77.0,
        109.0, 146.0, 187.0, 239.0, 305.0, 390.0, 498.0, 635.0
    ]

    static let halfTimesHe: [Double] = [
        1.88, 3.02, 4.72, 6.99, 10.21, 14.48, 20.53, 29.11,
        41.20, 55.19, 70.69, 90.34, 115.29, 147.42, 188.24, 240.03
    ]

    static let aN2: [Double] = [
        1.1696, 1.0000, 0.8618, 0.7562, 0.6200, 0.5043, 0.4410, 0.4000,
        0.3750, 0.3500, 0.3295, 0.3065, 0.2835, 0.2610, 0.2480, 0.2327
    ]

    static let bN2: [Double] = [
        0.5578, 0.6514, 0.7222, 0.7825, 0.8126, 0.8434, 0.8693, 0.8910,
        0.9092, 0.9222, 0.9319, 0.9403, 0.9477, 0.9544, 0.9602, 0.9653
    ]

    static let aHe: [Double] = [
        1.6189, 1.3830, 1.1919, 1.0458, 0.9220, 0.8205, 0.7305, 0.6502,
        0.5950, 0.5545, 0.5333, 0.5189, 0.5181, 0.5176, 0.5172, 0.5119
    ]

    static let bHe: [Double] = [
        0.4770, 0.5747, 0.6527, 0.7223, 0.7582, 0.7957, 0.8279, 0.8553,
        0.8757, 0.8903, 0.8997, 0.9073, 0.9122, 0.9171, 0.9217, 0.9267
    ]

    static func coefficientA(index: Int, pn2: Double, phe: Double) -> Double {
        let total = max(pn2 + phe, 0.000_001)
        return (aN2[index] * pn2 + aHe[index] * phe) / total
    }

    static func coefficientB(index: Int, pn2: Double, phe: Double) -> Double {
        let total = max(pn2 + phe, 0.000_001)
        return (bN2[index] * pn2 + bHe[index] * phe) / total
    }
}
