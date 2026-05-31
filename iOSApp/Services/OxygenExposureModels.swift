import Foundation

enum OxygenExposureWarningState: Hashable, Error {
    case elevatedCNS(Double)
    case elevatedDailyCNS(Double)
    case elevatedOTU(Double)
    case elevatedDailyOTU(Double)
    case elevatedWeeklyOTU(Double)
    case invalidExposureInput
}

/// Carry-over state for repetitive / multi-dive oxygen exposure planning.
struct OxygenExposureCarryover: Codable, Hashable {
    let cnsSinglePercent: Double
    let cnsDailyPercent: Double
    let otuDaily24h: Double
    let otuWeekly: Double

    static let zero = OxygenExposureCarryover(
        cnsSinglePercent: 0,
        cnsDailyPercent: 0,
        otuDaily24h: 0,
        otuWeekly: 0
    )
}

/// NOAA 1991 single-exposure CNS limits (piecewise-linear, Baker / NOAA Diving Manual).
enum NOAACNSLimitTable {
    struct PiecewiseRange: Sendable {
        let lowerExclusive: Double
        let upperInclusive: Double
        let slope: Double
        let intercept: Double
    }

    static let piecewiseRanges: [PiecewiseRange] = [
        .init(lowerExclusive: 0.5, upperInclusive: 0.6, slope: -1_800, intercept: 1_800),
        .init(lowerExclusive: 0.6, upperInclusive: 0.7, slope: -1_500, intercept: 1_620),
        .init(lowerExclusive: 0.7, upperInclusive: 0.8, slope: -1_200, intercept: 1_410),
        .init(lowerExclusive: 0.8, upperInclusive: 0.9, slope: -900, intercept: 1_170),
        .init(lowerExclusive: 0.9, upperInclusive: 1.1, slope: -600, intercept: 900),
        .init(lowerExclusive: 1.1, upperInclusive: 1.5, slope: -300, intercept: 570),
        .init(lowerExclusive: 1.5, upperInclusive: 1.6, slope: -750, intercept: 1_245)
    ]

    static func singleExposureLimitMinutes(for ppO2: Double) -> Double? {
        limitMinutes(for: ppO2, ranges: piecewiseRanges)
    }

    fileprivate static func limitMinutes(for ppO2: Double, ranges: [PiecewiseRange]) -> Double? {
        guard ppO2.isFinite else { return nil }
        guard ppO2 > 0.5 else { return .infinity }
        if ppO2 > 1.6 {
            let extrapolated = -750 * ppO2 + 1_245
            guard extrapolated.isFinite else { return nil }
            return max(1, extrapolated)
        }
        for range in ranges where ppO2 > range.lowerExclusive && ppO2 <= range.upperInclusive {
            let limit = range.slope * ppO2 + range.intercept
            return limit.isFinite && limit > 0 ? limit : nil
        }
        return nil
    }
}

/// NOAA 24-hour / daily CNS limits (Table 1 daily column, linear interpolation between knots).
enum NOAACNSDailyLimitTable {
    private static let knots: [(ppO2: Double, limitMinutes: Double)] = [
        (1.0, 570),
        (1.1, 270),
        (1.2, 240),
        (1.3, 210),
        (1.4, 166),
        (1.5, 83),
        (1.6, 45)
    ]

    static func dailyLimitMinutes(for ppO2: Double) -> Double? {
        guard ppO2.isFinite else { return nil }
        guard ppO2 > 0.5 else { return .infinity }
        if ppO2 <= 1.0 {
            return NOAACNSLimitTable.singleExposureLimitMinutes(for: ppO2)
        }
        if ppO2 >= 1.6 {
            return NOAACNSLimitTable.singleExposureLimitMinutes(for: ppO2)
        }
        for index in 0..<(knots.count - 1) {
            let left = knots[index]
            let right = knots[index + 1]
            if ppO2 >= left.ppO2 && ppO2 <= right.ppO2 {
                let span = right.ppO2 - left.ppO2
                guard span > 0 else { return left.limitMinutes }
                let fraction = (ppO2 - left.ppO2) / span
                let limit = left.limitMinutes + fraction * (right.limitMinutes - left.limitMinutes)
                return limit.isFinite && limit > 0 ? limit : nil
            }
        }
        return nil
    }
}

/// CNS recovery during surface intervals and in-water air breaks (PPO2 ≤ 0.5 bar).
enum CNSRecoveryModel {
    /// Standard technical-diving CNS clock half-time (Baker / NOAA practice).
    static let surfaceHalfTimeMinutes = 90.0

    static func decayedPercent(_ percent: Double, minutes: Double, halfTimeMinutes: Double = surfaceHalfTimeMinutes) -> Double {
        guard percent.isFinite, percent > 0, minutes.isFinite, minutes > 0 else { return max(0, percent) }
        guard halfTimeMinutes.isFinite, halfTimeMinutes > 0 else { return percent }
        let factor = pow(0.5, minutes / halfTimeMinutes)
        return max(0, percent * factor)
    }
}

/// NOAA REPEX / Hamilton pulmonary OTU daily and weekly planning limits.
enum OTUREPEXLimits {
    static let singleDiveElevatedOTU = 300.0
    static let dailyOTU = 850.0
    static let weeklyOTU = 1_800.0
    static let dailyResetSurfaceIntervalMinutes = 1_440.0
    static let weeklyResetSurfaceIntervalMinutes = 10_080.0
}

/// Pulmonary oxygen toxicity (OTU / UPTD) per Lambertsen with ramp integration (Baker Eq. 1–2).
enum OTUModel {
    private static let otuExponent = 5.0 / 6.0
    private static let rampExponent = 11.0 / 6.0

    static func otuIncrement(ppO2: Double, minutes: Double) -> Double? {
        otuIncrementConstant(ppO2: ppO2, minutes: minutes)
    }

    static func otuIncrementConstant(ppO2: Double, minutes: Double) -> Double? {
        guard ppO2.isFinite, minutes.isFinite, minutes >= 0 else { return nil }
        guard ppO2 > 0.5 else { return 0 }
        let value = minutes * pow((0.5 / (ppO2 - 0.5)), otuExponent)
        return value.isFinite ? value : nil
    }

    static func otuIncrementLinearRamp(ppO2Initial: Double, ppO2Final: Double, minutes: Double) -> Double? {
        guard ppO2Initial.isFinite, ppO2Final.isFinite, minutes.isFinite, minutes >= 0 else { return nil }
        let minP = min(ppO2Initial, ppO2Final)
        let maxP = max(ppO2Initial, ppO2Final)
        guard maxP > 0.5 else { return 0 }
        if minutes == 0 { return 0 }

        let lowP = minP < 0.5 ? 0.5 : minP
        let effectiveMinutes = minP < 0.5 ? minutes * (maxP - lowP) / max(maxP - minP, 1e-9) : minutes
        let po2I = ppO2Initial < 0.5 ? 0.5 : ppO2Initial
        let po2F = ppO2Final < 0.5 ? 0.5 : ppO2Final

        if abs(po2F - po2I) < 1e-9 {
            return otuIncrementConstant(ppO2: po2I, minutes: effectiveMinutes)
        }

        let high = pow((po2F - 0.5) / 0.5, rampExponent)
        let low = pow((po2I - 0.5) / 0.5, rampExponent)
        let value = (3.0 / 11.0) * effectiveMinutes / (po2F - po2I) * (high - low)
        return value.isFinite && value >= 0 ? value : nil
    }
}

@available(*, deprecated, message: "Use NOAACNSLimitTable for NOAA piecewise CNS limits.")
enum CNSClockModel {
    static func cnsIncrement(ppO2: Double, minutes: Double) -> Double? {
        NOAACNSLimitTable.singleExposureLimitMinutes(for: ppO2).flatMap { limit in
            guard limit.isFinite, limit > 0 else { return 0.0 }
            return (minutes / limit) * 100
        }
    }
}

struct OxygenExposureResult: Hashable {
    let cnsSinglePercent: Double
    let cnsDailyPercent: Double
    let otuDive: Double
    let otuDaily24h: Double
    let otuWeekly: Double
    let airBreakRecoveryApplied: Bool
    let warningStates: [OxygenExposureWarningState]

    var carryoverEnd: OxygenExposureCarryover {
        OxygenExposureCarryover(
            cnsSinglePercent: cnsSinglePercent,
            cnsDailyPercent: cnsDailyPercent,
            otuDaily24h: otuDaily24h,
            otuWeekly: otuWeekly
        )
    }
}

struct OxygenExposureModel: Hashable {
    let cnsPercent: Double
    let otu: Double
    let cnsDailyPercent: Double
    let otuDaily24h: Double
    let otuWeekly: Double
    let otuDiveOnly: Double
    let airBreakRecoveryApplied: Bool
    let warningStates: [OxygenExposureWarningState]

    static let cnsElevatedThresholdPercent = 80.0
    static let integrationStepMinutes = 0.05

    static func from(segments: [BuhlmannRuntimeSegment], environment: PlannerEnvironment) -> Result<OxygenExposureModel, OxygenExposureWarningState> {
        from(segments: segments, environment: environment, carryover: .zero).map(asLegacyModel)
    }

    static func from(
        segments: [BuhlmannRuntimeSegment],
        environment: PlannerEnvironment,
        carryover: OxygenExposureCarryover
    ) -> Result<OxygenExposureResult, OxygenExposureWarningState> {
        var cnsSingle = max(0, carryover.cnsSinglePercent)
        var cnsDaily = max(0, carryover.cnsDailyPercent)
        var otuDive = 0.0
        var otuDaily = max(0, carryover.otuDaily24h)
        var otuWeekly = max(0, carryover.otuWeekly)
        var currentDepthMeters = 0.0
        var airBreakRecoveryApplied = false

        for segment in segments {
            guard segment.minutes.isFinite, segment.minutes >= 0 else {
                return .failure(.invalidExposureInput)
            }

            let startDepth: Double
            let endDepth: Double
            switch segment.kind {
            case .descent, .ascent:
                startDepth = currentDepthMeters
                endDepth = segment.depthMeters
            default:
                startDepth = segment.depthMeters
                endDepth = segment.depthMeters
            }

            guard startDepth.isFinite, endDepth.isFinite else {
                return .failure(.invalidExposureInput)
            }

            switch integrateSegment(
                startDepthMeters: startDepth,
                endDepthMeters: endDepth,
                minutes: segment.minutes,
                gas: segment.gas,
                environment: environment,
                cnsSingle: &cnsSingle,
                cnsDaily: &cnsDaily,
                otuDive: &otuDive,
                airBreakRecoveryApplied: &airBreakRecoveryApplied
            ) {
            case .success:
                break
            case .failure(let error):
                return .failure(error)
            }

            currentDepthMeters = endDepth
        }

        otuDaily += otuDive
        otuWeekly += otuDive

        guard cnsSingle.isFinite, cnsDaily.isFinite, otuDive.isFinite, otuDaily.isFinite, otuWeekly.isFinite else {
            return .failure(.invalidExposureInput)
        }

        let warnings = makeWarnings(
            cnsSingle: cnsSingle,
            cnsDaily: cnsDaily,
            otuDive: otuDive,
            otuDaily: otuDaily,
            otuWeekly: otuWeekly
        )

        return .success(
            OxygenExposureResult(
                cnsSinglePercent: min(300, cnsSingle),
                cnsDailyPercent: min(300, cnsDaily),
                otuDive: otuDive,
                otuDaily24h: otuDaily,
                otuWeekly: otuWeekly,
                airBreakRecoveryApplied: airBreakRecoveryApplied,
                warningStates: warnings
            )
        )
    }

    static func applySurfaceInterval(to carryover: OxygenExposureCarryover, minutes: Double) -> OxygenExposureCarryover {
        guard minutes.isFinite, minutes >= 0 else { return carryover }
        let cnsSingle = CNSRecoveryModel.decayedPercent(carryover.cnsSinglePercent, minutes: minutes)
        let cnsDaily = CNSRecoveryModel.decayedPercent(carryover.cnsDailyPercent, minutes: minutes)
        let otuDaily = decayedOTUBudget(
            carryover.otuDaily24h,
            minutes: minutes,
            resetWindowMinutes: OTUREPEXLimits.dailyResetSurfaceIntervalMinutes
        )
        let otuWeekly = decayedOTUBudget(
            carryover.otuWeekly,
            minutes: minutes,
            resetWindowMinutes: OTUREPEXLimits.weeklyResetSurfaceIntervalMinutes
        )
        return OxygenExposureCarryover(
            cnsSinglePercent: cnsSingle,
            cnsDailyPercent: cnsDaily,
            otuDaily24h: otuDaily,
            otuWeekly: otuWeekly
        )
    }

    private static func decayedOTUBudget(_ value: Double, minutes: Double, resetWindowMinutes: Double) -> Double {
        guard value.isFinite, value > 0, minutes.isFinite, minutes > 0 else { return max(0, value) }
        guard resetWindowMinutes.isFinite, resetWindowMinutes > 0 else { return value }
        if minutes >= resetWindowMinutes { return 0 }
        let factor = max(0, 1 - minutes / resetWindowMinutes)
        return max(0, value * factor)
    }

    private static func integrateSegment(
        startDepthMeters: Double,
        endDepthMeters: Double,
        minutes: Double,
        gas: BuhlmannGas,
        environment: PlannerEnvironment,
        cnsSingle: inout Double,
        cnsDaily: inout Double,
        otuDive: inout Double,
        airBreakRecoveryApplied: inout Bool
    ) -> Result<Void, OxygenExposureWarningState> {
        guard minutes.isFinite, minutes >= 0 else { return .failure(.invalidExposureInput) }
        if minutes == 0 { return .success(()) }

        let steps = max(1, Int(ceil(minutes / integrationStepMinutes)))
        let dt = minutes / Double(steps)

        for step in 0..<steps {
            let alphaStart = Double(step) / Double(steps)
            let alphaEnd = Double(step + 1) / Double(steps)
            let depthStart = startDepthMeters + (endDepthMeters - startDepthMeters) * alphaStart
            let depthEnd = startDepthMeters + (endDepthMeters - startDepthMeters) * alphaEnd
            let depthMid = startDepthMeters + (endDepthMeters - startDepthMeters) * ((Double(step) + 0.5) / Double(steps))
            guard let ppO2Start = inspiredPPO2(depthMeters: depthStart, gas: gas, environment: environment),
                  let ppO2End = inspiredPPO2(depthMeters: depthEnd, gas: gas, environment: environment),
                  let ppO2 = inspiredPPO2(depthMeters: depthMid, gas: gas, environment: environment) else {
                return .failure(.invalidExposureInput)
            }

            if ppO2 > 0.5 {
                guard let singleLimit = NOAACNSLimitTable.singleExposureLimitMinutes(for: ppO2),
                      let dailyLimit = NOAACNSDailyLimitTable.dailyLimitMinutes(for: ppO2),
                      singleLimit.isFinite, dailyLimit.isFinite,
                      singleLimit > 0, dailyLimit > 0 else {
                    return .failure(.invalidExposureInput)
                }
                cnsSingle += (dt / singleLimit) * 100
                cnsDaily += (dt / dailyLimit) * 100
                let otuIncrement: Double?
                if abs(ppO2End - ppO2Start) > 1e-9 {
                    otuIncrement = OTUModel.otuIncrementLinearRamp(
                        ppO2Initial: ppO2Start,
                        ppO2Final: ppO2End,
                        minutes: dt
                    )
                } else {
                    otuIncrement = OTUModel.otuIncrementConstant(ppO2: ppO2, minutes: dt)
                }
                guard let increment = otuIncrement else {
                    return .failure(.invalidExposureInput)
                }
                otuDive += increment
            } else {
                let before = cnsSingle
                cnsSingle = CNSRecoveryModel.decayedPercent(cnsSingle, minutes: dt)
                cnsDaily = CNSRecoveryModel.decayedPercent(cnsDaily, minutes: dt)
                if cnsSingle < before - 0.000_1 {
                    airBreakRecoveryApplied = true
                }
            }
        }

        return .success(())
    }

    private static func makeWarnings(
        cnsSingle: Double,
        cnsDaily: Double,
        otuDive: Double,
        otuDaily: Double,
        otuWeekly: Double
    ) -> [OxygenExposureWarningState] {
        var warnings: [OxygenExposureWarningState] = []
        if cnsSingle >= cnsElevatedThresholdPercent { warnings.append(.elevatedCNS(cnsSingle)) }
        if cnsDaily >= cnsElevatedThresholdPercent { warnings.append(.elevatedDailyCNS(cnsDaily)) }
        if otuDive >= OTUREPEXLimits.singleDiveElevatedOTU { warnings.append(.elevatedOTU(otuDive)) }
        if otuDaily >= OTUREPEXLimits.dailyOTU { warnings.append(.elevatedDailyOTU(otuDaily)) }
        if otuWeekly >= OTUREPEXLimits.weeklyOTU { warnings.append(.elevatedWeeklyOTU(otuWeekly)) }
        return warnings
    }

    private static func asLegacyModel(_ result: OxygenExposureResult) -> OxygenExposureModel {
        OxygenExposureModel(
            cnsPercent: result.cnsSinglePercent,
            otu: result.otuDive,
            cnsDailyPercent: result.cnsDailyPercent,
            otuDaily24h: result.otuDaily24h,
            otuWeekly: result.otuWeekly,
            otuDiveOnly: result.otuDive,
            airBreakRecoveryApplied: result.airBreakRecoveryApplied,
            warningStates: result.warningStates
        )
    }

    private static func inspiredPPO2(depthMeters: Double, gas: BuhlmannGas, environment: PlannerEnvironment) -> Double? {
        guard depthMeters.isFinite, depthMeters >= 0 else { return nil }
        guard let ambient = AmbientPressureModel.ambientPressureBar(depthMeters: depthMeters, environment: environment) else {
            return nil
        }
        let ppO2 = max(0, gas.oxygenFraction) * ambient
        return ppO2.isFinite ? ppO2 : nil
    }
}
