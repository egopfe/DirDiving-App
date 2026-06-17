import Foundation

enum CCRInspiredGasModel {
    static func ambientPressureBar(depthMeters: Double, environment: PlannerEnvironment) -> Double {
        AmbientPressureModel.ambientPressureBar(depthMeters: depthMeters, environment: environment)
            ?? BuhlmannConstants.seaLevelSurfacePressureBar
    }

    static func inspiredPressures(
        depthMeters: Double,
        setpointBar: Double,
        diluent: CCRDiluent,
        environment: PlannerEnvironment
    ) -> (ppO2: Double, ppN2: Double, ppHe: Double, availableInert: Double)? {
        guard depthMeters.isFinite, setpointBar.isFinite, setpointBar > 0 else { return nil }
        let ambient = ambientPressureBar(depthMeters: depthMeters, environment: environment)
        guard ambient.isFinite else { return nil }
        let dryAmbient = max(0, ambient - BuhlmannConstants.waterVaporPressureBar)
        if dryAmbient <= setpointBar + 0.000_1 {
            return (setpointBar, 0, 0, 0)
        }
        let availableInert = max(0, dryAmbient - setpointBar)
        let ppN2 = availableInert * diluent.nitrogenFraction
        let ppHe = availableInert * diluent.heliumFraction
        return (setpointBar, ppN2, ppHe, availableInert)
    }

    static func ppN2Bar(depthMeters: Double, setpointBar: Double, diluent: CCRDiluent, environment: PlannerEnvironment) -> Double {
        inspiredPressures(depthMeters: depthMeters, setpointBar: setpointBar, diluent: diluent, environment: environment)?.ppN2 ?? 0
    }

    static func endMeters(depthMeters: Double, setpointBar: Double, diluent: CCRDiluent, environment: PlannerEnvironment) -> Double {
        let ppN2 = ppN2Bar(depthMeters: depthMeters, setpointBar: setpointBar, diluent: diluent, environment: environment)
        return NarcosisAnalyticsSupport.endMeters(fromPPN2Bar: ppN2, environment: environment)
    }

    /// Synthetic OC-style gas for segment labeling only — not used for CCR tissue loading.
    static func labelGas(diluent: CCRDiluent, setpointBar: Double, depthMeters: Double, environment: PlannerEnvironment) -> BuhlmannGas {
        let ambient = max(0.001, ambientPressureBar(depthMeters: depthMeters, environment: environment))
        let oxygenFraction = min(1, setpointBar / ambient)
        return BuhlmannGas(
            name: "CCR \(diluent.label) SP \(String(format: "%.1f", setpointBar))",
            role: .bottom,
            oxygenFraction: oxygenFraction,
            heliumFraction: diluent.heliumFraction,
            maxPPO2Bar: setpointBar + 0.1,
            switchDepthMeters: depthMeters
        )
    }
}

extension BuhlmannTissueState {
    func ccrLoadedConstantDepth(
        depthMeters: Double,
        minutes: Double,
        diluent: CCRDiluent,
        setpointBar: Double,
        environment: PlannerEnvironment
    ) -> BuhlmannTissueState {
        ccrLoadedLinearDepth(
            fromDepthMeters: depthMeters,
            toDepthMeters: depthMeters,
            minutes: minutes,
            diluent: diluent,
            setpointBar: setpointBar,
            environment: environment
        )
    }

    func ccrLoadedLinearDepth(
        fromDepthMeters: Double,
        toDepthMeters: Double,
        minutes: Double,
        diluent: CCRDiluent,
        setpointBar: Double,
        environment: PlannerEnvironment
    ) -> BuhlmannTissueState {
        guard minutes.isFinite, minutes > 0 else { return self }
        guard let start = CCRInspiredGasModel.inspiredPressures(
            depthMeters: fromDepthMeters,
            setpointBar: setpointBar,
            diluent: diluent,
            environment: environment
        ), let end = CCRInspiredGasModel.inspiredPressures(
            depthMeters: toDepthMeters,
            setpointBar: setpointBar,
            diluent: diluent,
            environment: environment
        ) else {
            return self
        }

        let rateN2 = (end.ppN2 - start.ppN2) / minutes
        let rateHe = (end.ppHe - start.ppHe) / minutes

        let loaded = compartments.enumerated().map { index, compartment in
            let kN2 = log(2.0) / BuhlmannConstants.halfTimesN2[index]
            let kHe = log(2.0) / BuhlmannConstants.halfTimesHe[index]
            return BuhlmannTissueCompartment(
                nitrogenPressure: Self.ccrSchreiner(
                    initial: compartment.nitrogenPressure,
                    inspiredStart: start.ppN2,
                    inspiredRate: rateN2,
                    k: kN2,
                    minutes: minutes
                ),
                heliumPressure: Self.ccrSchreiner(
                    initial: compartment.heliumPressure,
                    inspiredStart: start.ppHe,
                    inspiredRate: rateHe,
                    k: kHe,
                    minutes: minutes
                )
            )
        }
        return BuhlmannTissueState(compartments: loaded)
    }

    private static func ccrSchreiner(
        initial: Double,
        inspiredStart: Double,
        inspiredRate: Double,
        k: Double,
        minutes: Double
    ) -> Double {
        guard k.isFinite, k > 0, minutes.isFinite, minutes >= 0 else { return initial }
        if abs(inspiredRate) < 0.000_000_1 {
            return inspiredStart + (initial - inspiredStart) * exp(-k * minutes)
        }
        return inspiredStart
            + inspiredRate * (minutes - (1.0 / k))
            - (inspiredStart - initial - inspiredRate / k) * exp(-k * minutes)
    }
}

enum CCROxygenExposureIntegration {
    static func exposure(
        segments: [(kind: DiveSegmentKind, fromDepth: Double, toDepth: Double, minutes: Double, setpointBar: Double)],
        diluent: CCRDiluent,
        environment: PlannerEnvironment,
        carryover: OxygenExposureCarryover = .zero
    ) -> Result<OxygenExposureResult, OxygenExposureWarningState> {
        guard !segments.isEmpty else {
            return .failure(.invalidExposureInput)
        }
        var runtimeSegments: [BuhlmannRuntimeSegment] = []
        for segment in segments {
            guard segment.minutes.isFinite, segment.minutes >= 0 else {
                return .failure(.invalidExposureInput)
            }
            let midDepth = (segment.fromDepth + segment.toDepth) / 2
            let gas = CCRInspiredGasModel.labelGas(
                diluent: diluent,
                setpointBar: segment.setpointBar,
                depthMeters: midDepth,
                environment: environment
            )
            let depth = segment.kind == .descent || segment.kind == .ascent ? segment.toDepth : segment.fromDepth
            runtimeSegments.append(
                BuhlmannRuntimeSegment(
                    kind: segment.kind,
                    depthMeters: depth,
                    minutes: segment.minutes,
                    gas: overridePPO2Gas(
                        gas,
                        diluent: diluent,
                        setpointBar: segment.setpointBar,
                        depthMeters: midDepth,
                        environment: environment
                    ),
                    note: "CCR \(diluent.label) SP \(segment.setpointBar)"
                )
            )
        }
        return OxygenExposureModel.from(segments: runtimeSegments, environment: environment, carryover: carryover)
    }

    private static func overridePPO2Gas(
        _ base: BuhlmannGas,
        diluent: CCRDiluent,
        setpointBar: Double,
        depthMeters: Double,
        environment: PlannerEnvironment
    ) -> BuhlmannGas {
        let ambient = max(0.001, CCRInspiredGasModel.ambientPressureBar(depthMeters: depthMeters, environment: environment))
        return BuhlmannGas(
            name: base.name,
            role: base.role,
            oxygenFraction: min(1, setpointBar / ambient),
            heliumFraction: diluent.heliumFraction,
            maxPPO2Bar: setpointBar + 0.2,
            switchDepthMeters: base.switchDepthMeters,
            gasMixId: base.gasMixId,
            cylinderId: base.cylinderId
        )
    }
}
