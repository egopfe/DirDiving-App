import Foundation

enum RatioDecoPlanner {
    static func makeSchedule(
        input: GasPlanInput,
        mode: PlannerMode,
        preset: RatioDecoPreset,
        environment: PlannerEnvironment,
        descentMinutes: Double,
        unitPreference: IOSUnitPreference = .metric
    ) -> RatioDecoSchedule? {
        guard mode != .base else {
            return unavailableSchedule(
                preset: preset,
                warnings: [.unavailableInBaseMode],
                input: input,
                descentMinutes: descentMinutes,
                environment: environment,
                unitPreference: unitPreference
            )
        }

        guard mode != .ccr else {
            return unavailableSchedule(
                preset: preset,
                warnings: [.unavailableInCCRMode],
                input: input,
                descentMinutes: descentMinutes,
                environment: environment,
                unitPreference: unitPreference
            )
        }

        var working = input
        working.ensurePlannerCylindersFromLegacy()

        let maxDepth = working.plannedDepthMeters
        let bottomMinutes = working.plannedBottomMinutes
        guard maxDepth.isFinite, maxDepth > 0, bottomMinutes.isFinite, bottomMinutes > 0 else {
            return nil
        }

        if mode == .deco, maxDepth > PlannerModeLimits.decoMaximumDepthMeters(for: working) + 0.01 {
            return unavailableSchedule(
                preset: preset,
                warnings: [],
                input: input,
                descentMinutes: descentMinutes,
                environment: environment,
                unitPreference: unitPreference
            )
        }

        var warnings: [RatioDecoWarning] = []
        if !working.plannerCylinders.contains(where: { $0.role == .deco }) {
            warnings.append(.noDecoGases)
        }
        let firstStop = resolvedFirstStopDepth(preset: preset, input: working)
        var stopDepths = stopDepths(from: firstStop, step: preset.stopStepMeters)

        if preset.deepStopsEnabled {
            let deepCandidates = [maxDepth * 0.75, maxDepth * 0.5]
                .map { roundToStep($0, step: preset.stopStepMeters) }
                .filter { $0 > firstStop + 0.5 && $0 < maxDepth - 0.5 }
            for depth in Set(deepCandidates).sorted(by: >) where !stopDepths.contains(where: { abs($0 - depth) < 0.05 }) {
                stopDepths.insert(depth, at: 0)
                warnings.append(.deepStopAdded(depthMeters: depth))
            }
        }

        guard !stopDepths.isEmpty else { return nil }

        let totalDeco = preset.estimatedTotalDecoMinutes(bottomTimeMinutes: bottomMinutes)
        let distributed = distributeStopMinutes(
            totalMinutes: max(totalDeco, Double(stopDepths.count) * preset.minimumStopMinutes),
            stopCount: stopDepths.count,
            minimumStopMinutes: preset.minimumStopMinutes,
            mode: preset.distributionMode
        )

        var runtime = descentMinutes + bottomMinutes
        var stops: [RatioDecoStop] = []
        for (index, depth) in stopDepths.enumerated() {
            let assignment = gasAssignment(for: depth, input: working, environment: environment)
            if let issue = assignment.modIssue {
                warnings.append(.modViolation(depthMeters: depth, gasLabel: issue.gasLabel))
            } else if assignment.usedFallback {
                warnings.append(.gasAssignmentFallback(depthMeters: depth))
            }
            let minutes = distributed[index]
            runtime += minutes
            stops.append(
                RatioDecoStop(
                    depthMeters: depth,
                    durationMinutes: minutes,
                    gasLabel: assignment.gas.label,
                    gasMix: assignment.gas,
                    ppO2: assignment.ppO2,
                    runtimeMinute: runtime
                )
            )
        }

        let ascentMinutes = estimateAscentMinutes(from: maxDepth, to: firstStop)
        let surfaceRuntime = runtime + estimateAscentMinutes(from: stopDepths.last ?? 3, to: 0)
        let totalRuntime = descentMinutes + bottomMinutes + ascentMinutes + totalDeco + estimateAscentMinutes(from: stopDepths.last ?? 3, to: 0)

        let depthProfile = buildDepthProfile(
            maxDepth: maxDepth,
            descentMinutes: descentMinutes,
            bottomMinutes: bottomMinutes,
            firstStop: firstStop,
            stops: stops
        )

        let tableRows = buildAscentRows(
            input: working,
            maxDepth: maxDepth,
            bottomMinutes: bottomMinutes,
            stops: stops,
            environment: environment,
            unitPreference: unitPreference
        )

        return RatioDecoSchedule(
            stops: stops,
            totalDecoMinutes: stops.reduce(0) { $0 + $1.durationMinutes },
            totalRuntimeMinutes: max(totalRuntime, surfaceRuntime),
            firstStopDepthMeters: firstStop,
            presetName: preset.name,
            warnings: warnings,
            depthProfilePoints: depthProfile,
            ascentTableRows: tableRows
        )
    }

    private static func unavailableSchedule(
        preset: RatioDecoPreset,
        warnings: [RatioDecoWarning],
        input: GasPlanInput,
        descentMinutes: Double,
        environment: PlannerEnvironment,
        unitPreference: IOSUnitPreference
    ) -> RatioDecoSchedule {
        RatioDecoSchedule(
            stops: [],
            totalDecoMinutes: 0,
            totalRuntimeMinutes: descentMinutes + input.plannedBottomMinutes,
            firstStopDepthMeters: preset.firstStopDepthMeters,
            presetName: preset.name,
            warnings: warnings,
            depthProfilePoints: [],
            ascentTableRows: []
        )
    }

    private static func resolvedFirstStopDepth(preset: RatioDecoPreset, input: GasPlanInput) -> Double {
        let decoSwitches = input.plannerCylinders
            .filter { $0.role == .deco }
            .map(\.switchDepthMeters)
            .filter { $0.isFinite && $0 > 0 }
        if let deepestDecoSwitch = decoSwitches.max() {
            return roundToStep(deepestDecoSwitch, step: preset.stopStepMeters)
        }
        return roundToStep(preset.firstStopDepthMeters, step: preset.stopStepMeters)
    }

    private static func stopDepths(from firstStop: Double, step: Double) -> [Double] {
        guard firstStop.isFinite, step.isFinite, step > 0 else { return [] }
        var depths: [Double] = []
        var depth = firstStop
        while depth >= 3 - 0.01 {
            depths.append(roundToStep(depth, step: step))
            depth -= step
        }
        return depths
    }

    private static func roundToStep(_ depth: Double, step: Double) -> Double {
        guard step > 0 else { return depth }
        return (depth / step).rounded() * step
    }

    /// Distributes rounded whole-minute stop times across stops.
    private static func distributeStopMinutes(
        totalMinutes: Double,
        stopCount: Int,
        minimumStopMinutes: Double,
        mode: RatioDecoDistributionMode
    ) -> [Double] {
        guard stopCount > 0 else { return [] }
        let minimumTotal = Double(stopCount) * minimumStopMinutes
        let target = max(totalMinutes, minimumTotal)
        var weights: [Double]
        switch mode {
        case .balanced:
            weights = Array(repeating: 1, count: stopCount).map(Double.init)
        case .linear:
            // Linear ramp: shallow stops receive progressively more time.
            weights = (0..<stopCount).map { Double($0 + 1) }
        case .shallowWeighted:
            weights = (0..<stopCount).map { index in
                Double(index + 1)
            }.reversed()
        }
        let weightSum = weights.reduce(0, +)
        let raw = weights.map { max(minimumStopMinutes, (target * $0) / weightSum) }
        var rounded = raw.map { max(minimumStopMinutes, Double(Int($0.rounded()))) }
        var diff = Int(target.rounded()) - Int(rounded.reduce(0, +))
        var index = rounded.count - 1
        while diff != 0, !rounded.isEmpty {
            let adjust = diff > 0 ? 1 : -1
            if rounded[index] + Double(adjust) >= minimumStopMinutes {
                rounded[index] += Double(adjust)
                diff -= adjust
            }
            index = (index - 1 + rounded.count) % rounded.count
            if index == rounded.count - 1, abs(diff) > Int(target.rounded()) * 2 {
                break
            }
        }
        return rounded
    }

    private static func estimateAscentMinutes(from: Double, to: Double) -> Double {
        max(0, (from - to) / 9.0)
    }

    private struct GasAssignment {
        let gas: GasMix
        let ppO2: Double
        let modIssue: MODValidationIssue?
        let usedFallback: Bool
    }

    private static func gasAssignment(
        for depthMeters: Double,
        input: GasPlanInput,
        environment: PlannerEnvironment
    ) -> GasAssignment {
        let cylinders = input.plannerCylinders.filter { $0.role != .bailout }
        let decoCandidates = cylinders
            .filter { $0.role == .deco && $0.switchDepthMeters + 0.05 >= depthMeters }
            .sorted { $0.switchDepthMeters > $1.switchDepthMeters }
        if let deco = decoCandidates.first {
            let issue = PlannerMODValidator.validateGasSwitch(depthMeters: depthMeters, gas: deco.gas, role: .deco, environment: environment)
            let ppO2 = deco.gas.ppO2AtDepth(depthMeters, environment: environment)
            return GasAssignment(gas: deco.gas, ppO2: ppO2, modIssue: issue, usedFallback: false)
        }

        let travelCandidates = cylinders
            .filter { $0.role == .travel && $0.switchDepthMeters + 0.05 >= depthMeters }
            .sorted { $0.switchDepthMeters > $1.switchDepthMeters }
        if let travel = travelCandidates.first {
            let issue = PlannerMODValidator.validateGasSwitch(depthMeters: depthMeters, gas: travel.gas, role: .travel, environment: environment)
            let ppO2 = travel.gas.ppO2AtDepth(depthMeters, environment: environment)
            return GasAssignment(gas: travel.gas, ppO2: ppO2, modIssue: issue, usedFallback: false)
        }

        let bottom = cylinders.first(where: { $0.role == .bottom })?.gas ?? input.bottomGas
        let issue = PlannerMODValidator.validateGasSwitch(depthMeters: depthMeters, gas: bottom, role: .bottom, environment: environment)
        let ppO2 = bottom.ppO2AtDepth(depthMeters, environment: environment)
        return GasAssignment(gas: bottom, ppO2: ppO2, modIssue: issue, usedFallback: true)
    }

    private static func buildDepthProfile(
        maxDepth: Double,
        descentMinutes: Double,
        bottomMinutes: Double,
        firstStop: Double,
        stops: [RatioDecoStop]
    ) -> [DepthProfilePoint] {
        var points: [DepthProfilePoint] = [DepthProfilePoint(elapsedMinutes: 0, depthMeters: 0)]
        var elapsed = descentMinutes
        points.append(DepthProfilePoint(elapsedMinutes: elapsed, depthMeters: maxDepth))
        elapsed += bottomMinutes
        points.append(DepthProfilePoint(elapsedMinutes: elapsed, depthMeters: maxDepth))
        var currentDepth = maxDepth
        if firstStop < currentDepth {
            elapsed += estimateAscentMinutes(from: currentDepth, to: firstStop)
            currentDepth = firstStop
            points.append(DepthProfilePoint(elapsedMinutes: elapsed, depthMeters: currentDepth))
        }
        for stop in stops {
            if abs(stop.depthMeters - currentDepth) > 0.05 {
                elapsed += estimateAscentMinutes(from: currentDepth, to: stop.depthMeters)
                currentDepth = stop.depthMeters
                points.append(DepthProfilePoint(elapsedMinutes: elapsed, depthMeters: currentDepth))
            }
            elapsed += stop.durationMinutes
            points.append(DepthProfilePoint(elapsedMinutes: elapsed, depthMeters: currentDepth))
        }
        if currentDepth > 0 {
            elapsed += estimateAscentMinutes(from: currentDepth, to: 0)
            points.append(DepthProfilePoint(elapsedMinutes: elapsed, depthMeters: 0))
        }
        return points
    }

    private static func buildAscentRows(
        input: GasPlanInput,
        maxDepth: Double,
        bottomMinutes: Double,
        stops: [RatioDecoStop],
        environment: PlannerEnvironment,
        unitPreference: IOSUnitPreference
    ) -> [PlannerAscentTableRow] {
        let bottomGas = input.plannerCylinders.first(where: { $0.role == .bottom })?.gas ?? input.bottomGas
        let bottomPPO2 = bottomGas.ppO2AtDepth(maxDepth, environment: environment)
        var rows: [PlannerAscentTableRow] = [
            PlannerAscentTableRow(
                kind: .bottom,
                depthMeters: maxDepth,
                depthLabel: Formatters.depth(maxDepth, units: unitPreference).text,
                minutes: bottomMinutes,
                timeLabel: "\(Int(bottomMinutes.rounded())) min",
                gas: bottomGas.label,
                ppO2: bottomPPO2,
                ppO2Label: Formatters.one(bottomPPO2)
            )
        ]
        for stop in stops {
            rows.append(
                PlannerAscentTableRow(
                    kind: .decoStop,
                    depthMeters: stop.depthMeters,
                    depthLabel: Formatters.depth(stop.depthMeters, units: unitPreference).text,
                    minutes: stop.durationMinutes,
                    timeLabel: "\(Int(stop.durationMinutes.rounded())) min",
                    gas: stop.gasLabel,
                    ppO2: stop.ppO2,
                    ppO2Label: Formatters.one(stop.ppO2)
                )
            )
        }
        rows.append(
            PlannerAscentTableRow(
                kind: .surface,
                depthMeters: 0,
                depthLabel: Formatters.depth(0, units: unitPreference).text,
                minutes: 0,
                timeLabel: "0 min",
                gas: DIRIOSLocalizer.string("planner.table.surface"),
                ppO2: 0.21,
                ppO2Label: Formatters.one(0.21)
            )
        )
        return rows
    }
}

private extension GasMix {
    func ppO2AtDepth(_ depthMeters: Double, environment: PlannerEnvironment) -> Double {
        guard let ambient = AmbientPressureModel.ambientPressureBar(depthMeters: depthMeters, environment: environment) else {
            return 0
        }
        return max(0, oxygen * ambient)
    }
}
