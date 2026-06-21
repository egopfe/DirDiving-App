import Foundation

// MARK: - Independent Bühlmann ZH-L16C oracle (test-only)
//
// Provenance: ZH-L16C coefficients and half-times from the standard Bühlmann table used by
// DIR Diving Shared/BuhlmannCore. This module re-implements tissue loading and ceiling math
// without calling BuhlmannTissueModel, BuhlmannTissueState.ceiling, or BuhlmannEngine.
//
// Assumptions (sea-level salt water):
// - surface pressure 1.01325 bar
// - water density 1025 kg/m³
// - water vapour pressure 0.0627 bar
// - Schreiner equation for linear depth changes; Haldane exponential when inspired rate ≈ 0

struct IndependentOracleCompartment: Equatable {
    var pn2Bar: Double
    var pheBar: Double
}

struct IndependentOracleTissueState: Equatable {
    var compartments: [IndependentOracleCompartment]

    static func airSaturated(
        surfacePressureBar: Double = IndependentOracleConstants.seaLevelSurfacePressureBar
    ) -> IndependentOracleTissueState {
        let pn2 = (surfacePressureBar - IndependentOracleConstants.waterVaporPressureBar)
            * IndependentOracleConstants.nitrogenFractionAir
        let comps = Array(
            repeating: IndependentOracleCompartment(pn2Bar: max(0, pn2), pheBar: 0),
            count: IndependentOracleConstants.compartmentCount
        )
        return IndependentOracleTissueState(compartments: comps)
    }
}

struct IndependentOracleCeiling: Equatable {
    let depthMeters: Double
    let controllingCompartment: Int
    let compartmentDepthsMeters: [Double]
}

struct IndependentOracleGas: Equatable {
    let oxygenFraction: Double
    let heliumFraction: Double

    var nitrogenFraction: Double { max(0, 1 - oxygenFraction - heliumFraction) }

    static var air: IndependentOracleGas {
        IndependentOracleGas(oxygenFraction: 0.21, heliumFraction: 0)
    }
}

struct IndependentOracleProjection: Equatable {
    let rawCeiling: IndependentOracleCeiling
    let operationalCeiling: IndependentOracleCeiling
    let ndlMinutes: Double?
    let requiresDeco: Bool
    let gfOperational: Double
}

struct IndependentOracleSecondSnapshot: Equatable {
    let secondIndex: Int
    let depthMeters: Double
    let ambientBar: Double
    let inspiredPN2Bar: Double
    let inspiredPHeBar: Double
    let tissue: IndependentOracleTissueState
    let projection: IndependentOracleProjection
}

enum IndependentOracleConstants {
    static let compartmentCount = 16
    static let waterVaporPressureBar = 0.0627
    static let seaLevelSurfacePressureBar = 1.01325
    static let saltwaterDensityKgPerM3 = 1_025.0
    static let nitrogenFractionAir = 0.79
    static let gravity = 9.80665

    static let halfTimesN2: [Double] = [
        5, 8, 12.5, 18.5, 27, 38.3, 54.3, 77,
        109, 146, 187, 239, 305, 390, 498, 635
    ]

    static let halfTimesHe: [Double] = [
        1.88, 3.02, 4.72, 6.99, 10.21, 14.48, 20.53, 29.11,
        41.20, 55.19, 70.69, 90.34, 115.29, 147.42, 188.24, 240.03
    ]

    static let aN2: [Double] = [
        1.1696, 1.0, 0.8618, 0.7562, 0.62, 0.5043, 0.441, 0.4,
        0.375, 0.35, 0.3295, 0.3065, 0.2835, 0.261, 0.248, 0.2327
    ]

    static let bN2: [Double] = [
        0.5578, 0.6514, 0.7222, 0.7825, 0.8126, 0.8434, 0.8693, 0.891,
        0.9092, 0.9222, 0.9319, 0.9403, 0.9477, 0.9544, 0.9602, 0.9653
    ]

    static let aHe: [Double] = [
        1.6189, 1.383, 1.1919, 1.0458, 0.922, 0.8205, 0.7305, 0.6502,
        0.595, 0.5545, 0.5333, 0.5189, 0.5181, 0.5176, 0.5172, 0.5119
    ]

    static let bHe: [Double] = [
        0.477, 0.5747, 0.6527, 0.7223, 0.7582, 0.7957, 0.8279, 0.8553,
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

enum IndependentBuhlmannOracle {
    static let defaultEnvironment = PlannerEnvironment.seaLevelSaltWater
    static let productionSubStepSeconds: TimeInterval = 30

    /// Independent ISA barometric formula — must not call production `AmbientPressureModel`.
    static func independentSurfacePressureBar(altitudeMeters: Double) -> Double? {
        guard altitudeMeters.isFinite, altitudeMeters >= -500, altitudeMeters <= 4_500 else {
            return nil
        }
        let pressure = 1.01325 * pow(1.0 - 2.25577e-5 * altitudeMeters, 5.25588)
        guard pressure.isFinite, pressure > 0 else { return nil }
        return pressure
    }

    static func independentAmbientPressureBar(
        depthMeters: Double,
        environment: PlannerEnvironment
    ) -> Double? {
        guard depthMeters.isFinite, depthMeters >= 0 else { return nil }
        let rho = environment.waterDensityKgPerM3
        let pressure = environment.surfacePressureBar + (rho * IndependentOracleConstants.gravity * depthMeters) / 100_000.0
        guard pressure.isFinite, pressure > 0 else { return nil }
        return pressure
    }

    static func independentDepthMeters(
        ambientPressureBar: Double,
        environment: PlannerEnvironment
    ) -> Double? {
        guard ambientPressureBar.isFinite, ambientPressureBar >= environment.surfacePressureBar else { return nil }
        let rho = environment.waterDensityKgPerM3
        let meters = (ambientPressureBar - environment.surfacePressureBar) * 100_000.0 / (rho * IndependentOracleConstants.gravity)
        guard meters.isFinite, meters >= 0 else { return nil }
        return meters
    }

    static func ambientPressureBar(
        depthMeters: Double,
        environment: PlannerEnvironment = defaultEnvironment
    ) -> Double {
        independentAmbientPressureBar(depthMeters: depthMeters, environment: environment)
            ?? environment.surfacePressureBar
    }

    static func inspiredPressure(
        depthMeters: Double,
        gas: IndependentOracleGas,
        inert: Inert,
        environment: PlannerEnvironment = defaultEnvironment
    ) -> Double {
        let ambient = ambientPressureBar(depthMeters: depthMeters, environment: environment)
        let dry = max(0, ambient - IndependentOracleConstants.waterVaporPressureBar)
        switch inert {
        case .nitrogen: return dry * gas.nitrogenFraction
        case .helium: return dry * gas.heliumFraction
        }
    }

    enum Inert { case nitrogen, helium }

    static func schreiner(
        initial: Double,
        inspiredStart: Double,
        inspiredRatePerMinute: Double,
        k: Double,
        minutes: Double
    ) -> Double {
        guard k.isFinite, k > 0, minutes.isFinite, minutes >= 0 else { return initial }
        if abs(inspiredRatePerMinute) < 1e-7 {
            return inspiredStart + (initial - inspiredStart) * exp(-k * minutes)
        }
        return inspiredStart
            + inspiredRatePerMinute * (minutes - 1 / k)
            - (inspiredStart - initial - inspiredRatePerMinute / k) * exp(-k * minutes)
    }

    static func advanceLinear(
        state: IndependentOracleTissueState,
        fromDepthMeters: Double,
        toDepthMeters: Double,
        durationSeconds: Double,
        gas: IndependentOracleGas,
        environment: PlannerEnvironment = defaultEnvironment
    ) -> IndependentOracleTissueState {
        guard durationSeconds.isFinite, durationSeconds > 0 else { return state }
        var result = state
        var elapsed: TimeInterval = 0
        while elapsed < durationSeconds {
            let stepDuration = min(productionSubStepSeconds, durationSeconds - elapsed)
            let stepEnd = elapsed + stepDuration
            let startFraction = elapsed / durationSeconds
            let endFraction = stepEnd / durationSeconds
            let stepStartDepth = fromDepthMeters + (toDepthMeters - fromDepthMeters) * startFraction
            let stepEndDepth = fromDepthMeters + (toDepthMeters - fromDepthMeters) * endFraction
            result = advanceLinearSingleStep(
                state: result,
                fromDepthMeters: stepStartDepth,
                toDepthMeters: stepEndDepth,
                durationSeconds: stepDuration,
                gas: gas,
                environment: environment
            )
            elapsed = stepEnd
        }
        return result
    }

    private static func advanceLinearSingleStep(
        state: IndependentOracleTissueState,
        fromDepthMeters: Double,
        toDepthMeters: Double,
        durationSeconds: Double,
        gas: IndependentOracleGas,
        environment: PlannerEnvironment
    ) -> IndependentOracleTissueState {
        guard durationSeconds.isFinite, durationSeconds > 0 else { return state }
        let minutes = durationSeconds / 60
        let startN2 = inspiredPressure(depthMeters: fromDepthMeters, gas: gas, inert: .nitrogen, environment: environment)
        let endN2 = inspiredPressure(depthMeters: toDepthMeters, gas: gas, inert: .nitrogen, environment: environment)
        let startHe = inspiredPressure(depthMeters: fromDepthMeters, gas: gas, inert: .helium, environment: environment)
        let endHe = inspiredPressure(depthMeters: toDepthMeters, gas: gas, inert: .helium, environment: environment)
        let rateN2 = (endN2 - startN2) / minutes
        let rateHe = (endHe - startHe) / minutes

        let loaded = state.compartments.enumerated().map { index, compartment -> IndependentOracleCompartment in
            let kN2 = log(2) / IndependentOracleConstants.halfTimesN2[index]
            let kHe = log(2) / IndependentOracleConstants.halfTimesHe[index]
            return IndependentOracleCompartment(
                pn2Bar: schreiner(
                    initial: compartment.pn2Bar,
                    inspiredStart: startN2,
                    inspiredRatePerMinute: rateN2,
                    k: kN2,
                    minutes: minutes
                ),
                pheBar: schreiner(
                    initial: compartment.pheBar,
                    inspiredStart: startHe,
                    inspiredRatePerMinute: rateHe,
                    k: kHe,
                    minutes: minutes
                )
            )
        }
        return IndependentOracleTissueState(compartments: loaded)
    }

    static func ceiling(
        state: IndependentOracleTissueState,
        gfFraction: Double,
        environment: PlannerEnvironment = defaultEnvironment
    ) -> IndependentOracleCeiling {
        let fraction = max(0, min(1, gfFraction))
        var maxDepth = 0.0
        var controlling = 0
        var perCompartment = Array(repeating: 0.0, count: IndependentOracleConstants.compartmentCount)

        for (index, compartment) in state.compartments.enumerated() {
            let total = compartment.pn2Bar + compartment.pheBar
            guard total.isFinite, total > 0 else { continue }
            let a = IndependentOracleConstants.coefficientA(index: index, pn2: compartment.pn2Bar, phe: compartment.pheBar)
            let b = IndependentOracleConstants.coefficientB(index: index, pn2: compartment.pn2Bar, phe: compartment.pheBar)
            let denominator = 1 + fraction * ((1 / b) - 1)
            guard denominator.isFinite, denominator > 0 else { continue }
            let toleratedAmbient = (total - fraction * a) / denominator
            guard toleratedAmbient.isFinite, toleratedAmbient >= environment.surfacePressureBar else { continue }
            let depth = independentDepthMeters(ambientPressureBar: toleratedAmbient, environment: environment) ?? 0
            perCompartment[index] = depth
            if depth > maxDepth {
                maxDepth = depth
                controlling = index
            }
        }
        return IndependentOracleCeiling(depthMeters: max(0, maxDepth), controllingCompartment: controlling, compartmentDepthsMeters: perCompartment)
    }

    static func gfAtDepth(depthMeters: Double, firstStopDepthMeters: Double, gfLow: Double, gfHigh: Double) -> Double {
        guard firstStopDepthMeters > 0 else { return max(0, min(1, gfHigh / 100)) }
        let low = max(0, min(1, gfLow / 100))
        let high = max(0, min(1, gfHigh / 100))
        let ratio = max(0, min(1, depthMeters / firstStopDepthMeters))
        return high - (high - low) * ratio
    }

    static func ceilToStop(_ depth: Double, interval: Double) -> Double {
        guard interval > 0 else { return depth }
        return ceil(depth / interval) * interval
    }

    static func project(
        state: IndependentOracleTissueState,
        depthMeters: Double,
        gas: IndependentOracleGas,
        gfLow: Double,
        gfHigh: Double,
        stopIntervalMeters: Double = 3,
        environment: PlannerEnvironment = defaultEnvironment,
        ascentRateMetersPerMinute: Double = 9
    ) -> IndependentOracleProjection {
        let safeDepth = max(0, depthMeters.isFinite ? depthMeters : 0)
        let gfLowFraction = max(0, min(1, gfLow / 100))
        let raw = ceiling(state: state, gfFraction: gfLowFraction, environment: environment)
        let firstStop = raw.depthMeters > 0.01
            ? min(safeDepth, ceilToStop(raw.depthMeters, interval: stopIntervalMeters))
            : 0
        let opGF = gfAtDepth(depthMeters: safeDepth, firstStopDepthMeters: firstStop, gfLow: gfLow, gfHigh: gfHigh)
        let operational = ceiling(state: state, gfFraction: opGF, environment: environment)
        let ndlDepth = safeDepth >= BuhlmannCoreConfiguration.minPlannerDepthMeters
            ? safeDepth
            : BuhlmannCoreConfiguration.minPlannerDepthMeters
        let ndl = noDecompressionLimit(
            depthMeters: ndlDepth,
            gas: gas,
            gfHigh: gfHigh,
            initial: state,
            environment: environment,
            ascentRateMetersPerMinute: ascentRateMetersPerMinute
        )
        let requiresDeco = (ndl ?? 999) <= 0.01 || raw.depthMeters > 0.05 || operational.depthMeters > 0.05
        return IndependentOracleProjection(
            rawCeiling: raw,
            operationalCeiling: operational,
            ndlMinutes: ndl,
            requiresDeco: requiresDeco,
            gfOperational: opGF
        )
    }

    static func noDecompressionLimit(
        depthMeters: Double,
        gas: IndependentOracleGas,
        gfHigh: Double,
        initial: IndependentOracleTissueState,
        environment: PlannerEnvironment = defaultEnvironment,
        ascentRateMetersPerMinute: Double = 9,
        maxBottomMinutes: Double = Double(BuhlmannCoreConfiguration.maxBottomTimeMinutes)
    ) -> Double? {
        guard depthMeters.isFinite,
              depthMeters >= BuhlmannCoreConfiguration.minPlannerDepthMeters,
              depthMeters <= BuhlmannCoreConfiguration.maxPlannerDepthMeters else {
            return nil
        }

        func canSurface(afterBottomMinutes minutes: Double) -> Bool {
            let loaded = advanceLinear(
                state: initial,
                fromDepthMeters: depthMeters,
                toDepthMeters: depthMeters,
                durationSeconds: minutes * 60,
                gas: gas,
                environment: environment
            )
            let ascentMinutes = max(0.1, depthMeters / ascentRateMetersPerMinute)
            let surfaced = advanceLinear(
                state: loaded,
                fromDepthMeters: depthMeters,
                toDepthMeters: 0,
                durationSeconds: ascentMinutes * 60,
                gas: gas,
                environment: environment
            )
            return surfaced.projection(gfHigh: gfHigh, depthMeters: 0, environment: environment).operationalCeiling.depthMeters <= 0.01
        }

        if !canSurface(afterBottomMinutes: 0) { return 0 }
        if canSurface(afterBottomMinutes: maxBottomMinutes) { return maxBottomMinutes }

        var low = 0.0
        var high = maxBottomMinutes
        for _ in 0..<32 {
            let mid = (low + high) / 2
            if canSurface(afterBottomMinutes: mid) { low = mid } else { high = mid }
        }
        return floor(low * 10) / 10
    }

    /// Replay a depth timeline with one-second steps and linear Schreiner integration.
    static func replaySecondBySecond(
        depthAtSecond: (Int) -> Double,
        totalSeconds: Int,
        gas: IndependentOracleGas = .air,
        gfLow: Double = 30,
        gfHigh: Double = 70,
        initial: IndependentOracleTissueState = .airSaturated()
    ) -> [IndependentOracleSecondSnapshot] {
        var state = initial
        var previousDepth = depthAtSecond(0)
        var snapshots: [IndependentOracleSecondSnapshot] = []

        for second in 0..<totalSeconds {
            let depth = depthAtSecond(second)
            if second > 0 {
                state = advanceLinear(
                    state: state,
                    fromDepthMeters: previousDepth,
                    toDepthMeters: depth,
                    durationSeconds: 1,
                    gas: gas
                )
            }
            let ambient = ambientPressureBar(depthMeters: depth)
            let projection = project(state: state, depthMeters: depth, gas: gas, gfLow: gfLow, gfHigh: gfHigh)
            snapshots.append(
                IndependentOracleSecondSnapshot(
                    secondIndex: second,
                    depthMeters: depth,
                    ambientBar: ambient,
                    inspiredPN2Bar: inspiredPressure(depthMeters: depth, gas: gas, inert: .nitrogen),
                    inspiredPHeBar: inspiredPressure(depthMeters: depth, gas: gas, inert: .helium),
                    tissue: state,
                    projection: projection
                )
            )
            previousDepth = depth
        }
        return snapshots
    }

    /// Mirrors production `changeGas` 0.5-minute constant-depth load after switch.
    static func simulateGasSwitchLoad(
        state: IndependentOracleTissueState,
        depthMeters: Double,
        gas: IndependentOracleGas,
        environment: PlannerEnvironment = defaultEnvironment
    ) -> IndependentOracleTissueState {
        advanceLinear(
            state: state,
            fromDepthMeters: depthMeters,
            toDepthMeters: depthMeters,
            durationSeconds: BuhlmannConstants.gasSwitchMinutes * 60,
            gas: gas,
            environment: environment
        )
    }

    static func oracleGas(from gas: BuhlmannGas) -> IndependentOracleGas {
        IndependentOracleGas(oxygenFraction: gas.oxygenFraction, heliumFraction: gas.heliumFraction)
    }

    /// Schedule/TTS reference on independently loaded oracle tissues (shared schedule engine, independent tissues).
    static func productionProjectionOnOracleTissues(
        state: IndependentOracleTissueState,
        depthMeters: Double,
        plan: FullComputerRuntimePlan,
        environment: PlannerEnvironment = defaultEnvironment
    ) -> BuhlmannRuntimeProjection {
        BuhlmannEngine.runtimeProjection(
            tissueState: state.buhlmannTissueState(),
            depthMeters: depthMeters,
            gas: plan.activeGas,
            gfLow: plan.gfLow,
            gfHigh: plan.gfHigh,
            plannerEnvironment: environment,
            travelGases: plan.travelGases,
            decoGases: plan.decoGases,
            ascentRateMetersPerMinute: plan.ascentRateMetersPerMinute,
            stopIntervalMeters: plan.stopIntervalMeters
        )
    }

    static func compareTissueToProduction(
        oracle: IndependentOracleTissueState,
        production: BuhlmannTissueState,
        second: Int,
        failures: inout [String],
        maxFailures: Int = 5
    ) {
        for index in 0..<IndependentOracleConstants.compartmentCount {
            let oN2 = oracle.compartments[index].pn2Bar
            let pN2 = production.compartments[index].nitrogenPressure
            if abs(oN2 - pN2) > IndependentBuhlmannOracleTolerances.tissuePressureBar {
                failures.append("s\(second) c\(index) pn2 oracle=\(oN2) prod=\(pN2)")
                break
            }
            let oHe = oracle.compartments[index].pheBar
            let pHe = production.compartments[index].heliumPressure
            if abs(oHe - pHe) > IndependentBuhlmannOracleTolerances.tissuePressureBar {
                failures.append("s\(second) c\(index) phe oracle=\(oHe) prod=\(pHe)")
                break
            }
        }
        if failures.count >= maxFailures {
            return
        }
    }
}

extension IndependentOracleTissueState {
    func buhlmannTissueState() -> BuhlmannTissueState {
        BuhlmannTissueState(
            compartments: compartments.map {
                BuhlmannTissueCompartment(nitrogenPressure: $0.pn2Bar, heliumPressure: $0.pheBar)
            }
        )
    }
}

private extension IndependentOracleTissueState {
    func projection(gfHigh: Double, depthMeters: Double, environment: PlannerEnvironment) -> IndependentOracleProjection {
        IndependentBuhlmannOracle.project(
            state: self,
            depthMeters: depthMeters,
            gas: .air,
            gfLow: min(gfHigh, 30),
            gfHigh: gfHigh,
            environment: environment
        )
    }
}

// MARK: - Production recorder + comparison helpers

enum Audit15ProductionRecorder {
    struct SecondSnapshot: Equatable {
        let secondIndex: Int
        let depthMeters: Double
        let tissue: BuhlmannTissueState
        let rawCeilingMeters: Double
        let operationalCeilingMeters: Double
        let controllingRaw: Int
        let controllingOperational: Int
        let ndlMinutes: Double?
        let ttsMinutes: Int
        let requiresDeco: Bool
        let stopCount: Int
        let engineState: FullComputerRuntimeEngineState
    }

    static func record(
        engine: inout FullComputerRuntimeEngine,
        depthAtSecond: (Int) -> Double,
        totalSeconds: Int,
        sessionStart: Date,
        snapshotEverySeconds: Int = 60,
        snapshotAtSeconds: Set<Int> = []
    ) -> [SecondSnapshot] {
        FullComputerDecoSolver.resetCacheForTests()
        var previousDepth = depthAtSecond(0)
        var rows: [SecondSnapshot] = []
        var lastFullSnapshot = engine.snapshot
        engine.testHook_setDeferSnapshotRefresh(true)
        defer { engine.testHook_setDeferSnapshotRefresh(false) }

        for second in 0..<totalSeconds {
            autoreleasepool {
                let depth = depthAtSecond(second)
                let timestamp = sessionStart.addingTimeInterval(TimeInterval(second))
                if second == 0 {
                    _ = engine.ingestSample(depthMeters: depth, timestamp: timestamp)
                } else if abs(depth - previousDepth) > 0.000_1 {
                    _ = engine.ingestSample(depthMeters: depth, timestamp: timestamp)
                } else {
                    engine.tick(now: timestamp)
                }
                previousDepth = depth

                let needsFullSnapshot = second == 0
                    || second == totalSeconds - 1
                    || second % max(1, snapshotEverySeconds) == 0
                    || snapshotAtSeconds.contains(second)
                if needsFullSnapshot {
                    engine.testHook_refreshSnapshotForTests()
                    lastFullSnapshot = engine.snapshot
                }

                let tissue = engine.testHook_tissueState
                let snap = lastFullSnapshot
                let requiresDeco = (snap.ndlMinutes ?? 999) <= 0.01
                    || snap.rawCeilingMeters > 0.05
                    || snap.operationalCeilingMeters > 0.05
                    || !snap.stops.isEmpty
                rows.append(
                    SecondSnapshot(
                        secondIndex: second,
                        depthMeters: depth,
                        tissue: tissue,
                        rawCeilingMeters: snap.rawCeilingMeters,
                        operationalCeilingMeters: snap.operationalCeilingMeters,
                        controllingRaw: snap.controllingCompartmentRaw,
                        controllingOperational: snap.controllingCompartmentOperational,
                        ndlMinutes: snap.ndlMinutes,
                        ttsMinutes: snap.ttsMinutes,
                        requiresDeco: requiresDeco,
                        stopCount: snap.stops.count,
                        engineState: snap.engineState
                    )
                )
            }
        }
        return rows
    }
}

enum Audit15ProfileTimeline {
    static let targetBottomMeters = 39.0
    static let multilevelMeters = 10.0
    static let descentRateMetersPerMinute = 18.0
    static let ascentRateMetersPerMinute = 9.0

    static func descentSeconds(to depth: Double) -> Int {
        Int(ceil((depth / descentRateMetersPerMinute) * 60))
    }

    static func ascentSeconds(from: Double, to: Double) -> Int {
        guard from > to else { return 0 }
        return Int(ceil(((from - to) / ascentRateMetersPerMinute) * 60))
    }

    /// Builds second index → depth for Air 39 m multilevel Audit-15 profile.
    static func depthAtSecond(
        second: Int,
        descentEnd: Int,
        bottomEnd: Int,
        ascentEnd: Int,
        levelEnd: Int
    ) -> Double {
        if second <= descentEnd {
            let progress = Double(second) / Double(max(1, descentEnd))
            return targetBottomMeters * progress
        }
        if second <= bottomEnd {
            return targetBottomMeters
        }
        if second <= ascentEnd {
            let span = ascentEnd - bottomEnd
            let progress = Double(second - bottomEnd) / Double(max(1, span))
            return targetBottomMeters - (targetBottomMeters - multilevelMeters) * progress
        }
        if second <= levelEnd {
            return multilevelMeters
        }
        return multilevelMeters
    }

    static func compareOracleToProduction(
        oracle: [IndependentOracleSecondSnapshot],
        production: [Audit15ProductionRecorder.SecondSnapshot],
        gfLow: Double = 30,
        gfHigh: Double = 70,
        environment: PlannerEnvironment = IndependentBuhlmannOracle.defaultEnvironment
    ) -> [String] {
        guard oracle.count == production.count else {
            return ["count_mismatch oracle=\(oracle.count) production=\(production.count)"]
        }
        var failures: [String] = []
        let gfLowFraction = max(0, min(1, gfLow / 100))
        for (o, p) in zip(oracle, production) {
            for index in 0..<IndependentOracleConstants.compartmentCount {
                let oN2 = o.tissue.compartments[index].pn2Bar
                let pN2 = p.tissue.compartments[index].nitrogenPressure
                if abs(oN2 - pN2) > IndependentBuhlmannOracleTolerances.tissuePressureBar {
                    failures.append("s\(o.secondIndex) c\(index) pn2 oracle=\(oN2) prod=\(pN2)")
                    break
                }
                let oHe = o.tissue.compartments[index].pheBar
                let pHe = p.tissue.compartments[index].heliumPressure
                if abs(oHe - pHe) > IndependentBuhlmannOracleTolerances.tissuePressureBar {
                    failures.append("s\(o.secondIndex) c\(index) phe oracle=\(oHe) prod=\(pHe)")
                    break
                }
            }

            let shouldCheckProjection = o.secondIndex == 0
                || o.secondIndex % 60 == 0
                || o.secondIndex == production.count - 1
            guard shouldCheckProjection else { continue }

            let bridged = o.tissue.buhlmannTissueState()
            let rawFromOracleTissues = bridged.ceiling(gf: gfLowFraction, environment: environment).depthMeters
            if abs(rawFromOracleTissues - p.rawCeilingMeters) > IndependentBuhlmannOracleTolerances.ceilingMeters {
                failures.append("s\(o.secondIndex) rawCeiling bridged=\(rawFromOracleTissues) prod=\(p.rawCeilingMeters)")
            }
            if o.projection.requiresDeco != p.requiresDeco {
                failures.append("s\(o.secondIndex) requiresDeco oracle=\(o.projection.requiresDeco) prod=\(p.requiresDeco)")
            }
        }
        return failures
    }

    struct ReplayComparisonResult {
        let oracleFailures: [String]
        let keySnapshots: [Audit15ProductionRecorder.SecondSnapshot]
        let decimatedSnapshots: [Audit15ProductionRecorder.SecondSnapshot]
    }

    static func replayWithOracleComparison(
        engine: inout FullComputerRuntimeEngine,
        depthAtSecond: (Int) -> Double,
        totalSeconds: Int,
        sessionStart: Date,
        keySeconds: Set<Int>,
        decimateEverySeconds: Int = 60
    ) -> ReplayComparisonResult {
        FullComputerDecoSolver.resetCacheForTests()
        var previousDepth = depthAtSecond(0)
        var oracleState = IndependentOracleTissueState.airSaturated()
        var oracleFailures: [String] = []
        var keySnapshots: [Audit15ProductionRecorder.SecondSnapshot] = []
        var decimatedSnapshots: [Audit15ProductionRecorder.SecondSnapshot] = []
        var lastFullSnapshot = engine.snapshot
        let gfLowFraction = 0.30

        engine.testHook_setDeferSnapshotRefresh(true)
        defer { engine.testHook_setDeferSnapshotRefresh(false) }

        for second in 0..<totalSeconds {
            autoreleasepool {
                let depth = depthAtSecond(second)
                let timestamp = sessionStart.addingTimeInterval(TimeInterval(second))
                if second == 0 {
                    _ = engine.ingestSample(depthMeters: depth, timestamp: timestamp)
                } else if abs(depth - previousDepth) > 0.000_1 {
                    _ = engine.ingestSample(depthMeters: depth, timestamp: timestamp)
                } else {
                    engine.tick(now: timestamp)
                }
                previousDepth = depth

                if second > 0 {
                    oracleState = IndependentBuhlmannOracle.advanceLinear(
                        state: oracleState,
                        fromDepthMeters: depthAtSecond(second - 1),
                        toDepthMeters: depth,
                        durationSeconds: 1,
                        gas: .air
                    )
                }

                for index in 0..<IndependentOracleConstants.compartmentCount {
                    let oN2 = oracleState.compartments[index].pn2Bar
                    let pN2 = engine.testHook_tissueState.compartments[index].nitrogenPressure
                    if abs(oN2 - pN2) > IndependentBuhlmannOracleTolerances.tissuePressureBar {
                        oracleFailures.append("s\(second) c\(index) pn2 oracle=\(oN2) prod=\(pN2)")
                        break
                    }
                }

                let needsFullSnapshot = second == 0
                    || second == totalSeconds - 1
                    || second % max(1, decimateEverySeconds) == 0
                    || keySeconds.contains(second)
                if needsFullSnapshot {
                    engine.testHook_refreshSnapshotForTests()
                    lastFullSnapshot = engine.snapshot
                    let row = makeSecondSnapshot(
                        secondIndex: second,
                        depthMeters: depth,
                        tissue: engine.testHook_tissueState,
                        snap: lastFullSnapshot
                    )
                    decimatedSnapshots.append(row)
                    if keySeconds.contains(second) {
                        keySnapshots.append(row)
                    }

                    let rawFromOracleTissues = oracleState.buhlmannTissueState()
                        .ceiling(gf: gfLowFraction, environment: IndependentBuhlmannOracle.defaultEnvironment).depthMeters
                    if abs(rawFromOracleTissues - lastFullSnapshot.rawCeilingMeters) > IndependentBuhlmannOracleTolerances.ceilingMeters {
                        oracleFailures.append("s\(second) rawCeiling bridged=\(rawFromOracleTissues) prod=\(lastFullSnapshot.rawCeilingMeters)")
                    }
                }
            }
            if oracleFailures.count >= 5 { break }
        }

        return ReplayComparisonResult(
            oracleFailures: oracleFailures,
            keySnapshots: keySnapshots,
            decimatedSnapshots: decimatedSnapshots
        )
    }

    private static func makeSecondSnapshot(
        secondIndex: Int,
        depthMeters: Double,
        tissue: BuhlmannTissueState,
        snap: FullComputerRuntimeSnapshot
    ) -> Audit15ProductionRecorder.SecondSnapshot {
        let requiresDeco = (snap.ndlMinutes ?? 999) <= 0.01
            || snap.rawCeilingMeters > 0.05
            || snap.operationalCeilingMeters > 0.05
            || !snap.stops.isEmpty
        return Audit15ProductionRecorder.SecondSnapshot(
            secondIndex: secondIndex,
            depthMeters: depthMeters,
            tissue: tissue,
            rawCeilingMeters: snap.rawCeilingMeters,
            operationalCeilingMeters: snap.operationalCeilingMeters,
            controllingRaw: snap.controllingCompartmentRaw,
            controllingOperational: snap.controllingCompartmentOperational,
            ndlMinutes: snap.ndlMinutes,
            ttsMinutes: snap.ttsMinutes,
            requiresDeco: requiresDeco,
            stopCount: snap.stops.count,
            engineState: snap.engineState
        )
    }

    static func compareOracleStream(
        depthAtSecond: (Int) -> Double,
        totalSeconds: Int,
        production: [Audit15ProductionRecorder.SecondSnapshot],
        gas: IndependentOracleGas = .air,
        gfLow: Double = 30,
        gfHigh: Double = 70,
        environment: PlannerEnvironment = IndependentBuhlmannOracle.defaultEnvironment
    ) -> [String] {
        guard production.count == totalSeconds else {
            return ["count_mismatch production=\(production.count) expected=\(totalSeconds)"]
        }
        var oracleState = IndependentOracleTissueState.airSaturated(
            surfacePressureBar: environment.surfacePressureBar
        )
        var previousDepth = depthAtSecond(0)
        var failures: [String] = []
        let gfLowFraction = max(0, min(1, gfLow / 100))

        for second in 0..<totalSeconds {
            let depth = depthAtSecond(second)
            if second > 0 {
                oracleState = IndependentBuhlmannOracle.advanceLinear(
                    state: oracleState,
                    fromDepthMeters: previousDepth,
                    toDepthMeters: depth,
                    durationSeconds: 1,
                    gas: gas,
                    environment: environment
                )
            }
            previousDepth = depth
            let p = production[second]

            for index in 0..<IndependentOracleConstants.compartmentCount {
                let oN2 = oracleState.compartments[index].pn2Bar
                let pN2 = p.tissue.compartments[index].nitrogenPressure
                if abs(oN2 - pN2) > IndependentBuhlmannOracleTolerances.tissuePressureBar {
                    failures.append("s\(second) c\(index) pn2 oracle=\(oN2) prod=\(pN2)")
                    break
                }
                let oHe = oracleState.compartments[index].pheBar
                let pHe = p.tissue.compartments[index].heliumPressure
                if abs(oHe - pHe) > IndependentBuhlmannOracleTolerances.tissuePressureBar {
                    failures.append("s\(second) c\(index) phe oracle=\(oHe) prod=\(pHe)")
                    break
                }
            }
            if failures.count >= 5 { return failures }

            let shouldCheckProjection = second == 0
                || second % 60 == 0
                || second == totalSeconds - 1
            guard shouldCheckProjection else { continue }

            let rawFromOracleTissues = oracleState.buhlmannTissueState()
                .ceiling(gf: gfLowFraction, environment: environment).depthMeters
            if abs(rawFromOracleTissues - p.rawCeilingMeters) > IndependentBuhlmannOracleTolerances.ceilingMeters {
                failures.append("s\(second) rawCeiling bridged=\(rawFromOracleTissues) prod=\(p.rawCeilingMeters)")
            }
            let oracleRequiresDeco = IndependentBuhlmannOracle.project(
                state: oracleState,
                depthMeters: depth,
                gas: gas,
                gfLow: gfLow,
                gfHigh: gfHigh,
                environment: environment
            ).requiresDeco
            if oracleRequiresDeco != p.requiresDeco {
                failures.append("s\(second) requiresDeco oracle=\(oracleRequiresDeco) prod=\(p.requiresDeco)")
            }
            if failures.count >= 5 { return failures }
        }
        return failures
    }
}

// MARK: - Mutated oracle helpers (mutation-resistance tests only)

enum IndependentOracleMutationFixtures {
    static func schreinerReversedRate(
        initial: Double,
        inspiredStart: Double,
        inspiredRatePerMinute: Double,
        k: Double,
        minutes: Double
    ) -> Double {
        IndependentBuhlmannOracle.schreiner(
            initial: initial,
            inspiredStart: inspiredStart,
            inspiredRatePerMinute: -inspiredRatePerMinute,
            k: k,
            minutes: minutes
        )
    }

    static func advanceWithSecondsAsMinutes(
        state: IndependentOracleTissueState,
        fromDepthMeters: Double,
        toDepthMeters: Double,
        durationSeconds: Double,
        gas: IndependentOracleGas = .air
    ) -> IndependentOracleTissueState {
        IndependentBuhlmannOracle.advanceLinear(
            state: state,
            fromDepthMeters: fromDepthMeters,
            toDepthMeters: toDepthMeters,
            durationSeconds: durationSeconds * 60,
            gas: gas
        )
    }
}
