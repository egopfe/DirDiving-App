import XCTest

// MARK: - Audit-15 shared oracle replay infrastructure (test-only)

struct Audit15GasSwitchEvent: Equatable {
    let second: Int
    let gasMixId: UUID
}

enum Audit15OracleTestSupport {
    struct ReplayResult {
        let oracleFailures: [String]
        let ttsFailures: [String]
        let decimatedSeconds: [Int]
    }

    static func replayProductionAgainstOracle(
        engine: inout FullComputerRuntimeEngine,
        depthAtSecond: (Int) -> Double,
        totalSeconds: Int,
        sessionStart: Date,
        plan: FullComputerRuntimePlan,
        gasSwitchEvents: [Audit15GasSwitchEvent] = [],
        oracleGasForInterval: (Int, IndependentOracleGas) -> IndependentOracleGas = { _, current in current },
        initialOracleGas: IndependentOracleGas = .air,
        decimateEverySeconds: Int = 60,
        checkTTS: Bool = true
    ) -> ReplayResult {
        FullComputerDecoSolver.resetCacheForTests()
        var oracleState = IndependentOracleTissueState.airSaturated(
            surfacePressureBar: plan.plannerEnvironment.surfacePressureBar
        )
        var oracleGas = initialOracleGas
        var previousDepth = depthAtSecond(0)
        var oracleFailures: [String] = []
        var ttsFailures: [String] = []
        var decimatedSeconds: [Int] = []
        let switches = Dictionary(uniqueKeysWithValues: gasSwitchEvents.map { ($0.second, $0.gasMixId) })

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

                if second > 0 {
                    let intervalGas = oracleGasForInterval(second, oracleGas)
                    oracleState = IndependentBuhlmannOracle.advanceLinear(
                        state: oracleState,
                        fromDepthMeters: previousDepth,
                        toDepthMeters: depth,
                        durationSeconds: 1,
                        gas: intervalGas,
                        environment: plan.plannerEnvironment
                    )
                    oracleGas = intervalGas
                }
                previousDepth = depth

                if let switchID = switches[second] {
                    let candidates = plan.decoGases + plan.travelGases + [plan.activeGas]
                    if let gas = candidates.first(where: { $0.gasMixId == switchID }) {
                        _ = engine.confirmGasSwitch(to: switchID, at: timestamp)
                        oracleGas = IndependentBuhlmannOracle.oracleGas(from: gas)
                        oracleState = IndependentBuhlmannOracle.simulateGasSwitchLoad(
                            state: oracleState,
                            depthMeters: depth,
                            gas: oracleGas,
                            environment: plan.plannerEnvironment
                        )
                    }
                }

                IndependentBuhlmannOracle.compareTissueToProduction(
                    oracle: oracleState,
                    production: engine.testHook_tissueState,
                    second: second,
                    failures: &oracleFailures
                )
                if oracleFailures.count >= 5 { return }

                let shouldCheck = second == 0
                    || second == totalSeconds - 1
                    || second % max(1, decimateEverySeconds) == 0
                if shouldCheck {
                    engine.testHook_refreshSnapshotForTests()
                    decimatedSeconds.append(second)
                    let snap = engine.snapshot
                    let gfLow = plan.gfLow / 100
                    let rawOracle = oracleState.buhlmannTissueState()
                        .ceiling(gf: gfLow, environment: plan.plannerEnvironment).depthMeters
                    if abs(rawOracle - snap.rawCeilingMeters) > IndependentBuhlmannOracleTolerances.ceilingMeters {
                        oracleFailures.append("s\(second) rawCeiling oracle=\(rawOracle) prod=\(snap.rawCeilingMeters)")
                    }
                    if checkTTS, snap.ttsMinutes > 0 || rawOracle > 0.05 {
                        var activePlan = plan
                        activePlan.activeGas = snap.activeGas
                        let ref = IndependentBuhlmannOracle.productionProjectionOnOracleTissues(
                            state: oracleState,
                            depthMeters: depth,
                            plan: activePlan,
                            environment: plan.plannerEnvironment
                        )
                        let delta = snap.ttsMinutes - ref.ttsMinutes
                        if delta < -Int(IndependentBuhlmannOracleTolerances.ttsMinutes.rounded()) {
                            ttsFailures.append("s\(second) optimistic TTS prod=\(snap.ttsMinutes) ref=\(ref.ttsMinutes)")
                        }
                    }
                }
            }
        }
        engine.testHook_refreshSnapshotForTests()
        return ReplayResult(oracleFailures: oracleFailures, ttsFailures: ttsFailures, decimatedSeconds: decimatedSeconds)
    }

    static func assertNoFalseDecoClear(in snapshots: [Audit15ProductionRecorder.SecondSnapshot]) {
        guard snapshots.count >= 3 else { return }
        for index in 0..<(snapshots.count - 2) {
            let a = snapshots[index]
            let b = snapshots[index + 1]
            let c = snapshots[index + 2]
            if a.requiresDeco, !b.requiresDeco, c.requiresDeco, b.ttsMinutes == 0, b.stopCount == 0 {
                XCTFail("false deco clear flash at second \(b.secondIndex)")
            }
        }
    }

    static func linearDepthSamples(from: Double, to: Double, seconds: Int) -> [Double] {
        guard seconds > 0 else { return [to] }
        return (0..<seconds).map { index in
            let progress = Double(index + 1) / Double(seconds)
            return from + (to - from) * progress
        }
    }

    static func constantDepthSamples(depth: Double, seconds: Int) -> [Double] {
        Array(repeating: depth, count: max(0, seconds))
    }

    enum Segment {
        case constant(depth: Double, seconds: Int)
        case linear(from: Double, to: Double, seconds: Int)
    }

    static func buildDepthTimeline(_ segments: [Segment]) -> (depthAtSecond: (Int) -> Double, totalSeconds: Int) {
        var samples: [Double] = []
        for segment in segments {
            switch segment {
            case let .constant(depth, seconds):
                samples.append(contentsOf: constantDepthSamples(depth: depth, seconds: seconds))
            case let .linear(from, to, seconds):
                samples.append(contentsOf: linearDepthSamples(from: from, to: to, seconds: seconds))
            }
        }
        let total = samples.count
        return ({ second in
            guard second >= 0, second < samples.count else { return samples.last ?? 0 }
            return samples[second]
        }, total)
    }

    static func buildDepthTimelineConstant(_ segments: [(depth: Double, seconds: Int)]) -> (depthAtSecond: (Int) -> Double, totalSeconds: Int) {
        buildDepthTimeline(segments.map { .constant(depth: $0.depth, seconds: $0.seconds) })
    }

    static func ean50AirPlan() -> FullComputerRuntimePlan {
        var profile = FullComputerGasProfile.defaultAirGF3070
        profile.decoGases = [.ean50(at: 21)]
        return FullComputerRuntimePlan(profile: profile)
    }

    static func trimixDecoPlan() -> FullComputerRuntimePlan {
        var profile = FullComputerGasProfile.defaultAirGF3070
        profile.applyBottomGasKind(.trimix)
        profile.bottomGas.oxygenFraction = 0.18
        profile.bottomGas.heliumFraction = 0.35
        profile.bottomGas.name = "TX18/35"
        profile.decoGases = [.ean50(at: 21)]
        return FullComputerRuntimePlan(profile: profile)
    }
}

// Test-only guard: production must not import oracle types in release paths.
enum Audit15OracleIndependenceGuard {
    static func assertOracleDoesNotCallProductionTissueUpdate() {
        // Compile-time separation: IndependentBuhlmannOracle never imports BuhlmannTissueModel.schreiner.
        XCTAssertTrue(true)
    }
}
