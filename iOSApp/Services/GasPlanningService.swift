import Foundation

enum GasPlanningService {
    static func analyze(input: GasPlanInput) -> TechnicalGasAnalysis {
        let gas = input.bottomGas
        let validation = PlannerInputValidator.validate(input)
        guard validation.isValid else {
            return unavailableAnalysis(input: input, gas: gas, validation: validation)
        }
        let ata = input.ambientPressureBar
        let ppO2 = ppO2(gas: gas, depthMeters: input.effectivePlanningDepthMeters)
        let density = gas.surfaceDensityGramsLiter * ata
        let rating = densityRating(density, warning: input.densityWarningLimit, danger: input.densityDangerLimit)
        let planningDepth = input.effectivePlanningDepthMeters
        let end = equivalentNarcoticDepth(gas: gas, depthMeters: planningDepth)
        let ead = equivalentAirDepth(gas: gas, depthMeters: planningDepth)
        let consumption = input.sacLitersPerMinute * ata * input.plannedBottomMinutes
        let remaining = input.availableGasLiters - consumption
        let remainingBar = remaining / input.primaryCylinder.volumeLiters
        let rockBottom = rockBottomLiters(input: input)
        let minimumGasBar = rockBottom / input.primaryCylinder.volumeLiters
        let usableBeforeMinimum = input.availableGasLiters - rockBottom
        let turnPressure = usableBeforeMinimum > 0
            ? min(input.startPressureBar, max(input.reservePressureBar, input.startPressureBar - (usableBeforeMinimum / 2.0 / input.primaryCylinder.volumeLiters)))
            : input.reservePressureBar
        let cns = oxygenExposureCNS(ppO2: ppO2, minutes: input.plannedBottomMinutes)
        let otu = oxygenToxicityUnits(ppO2: ppO2, minutes: input.plannedBottomMinutes)
        let states = mergeStates(
            validation.states,
            makeStates(
                input: input,
                ppO2: ppO2,
                density: density,
                endMeters: end,
                remainingLiters: remaining,
                rockBottomLiters: rockBottom
            )
        )
        let warnings = makeWarnings(states: states)

        return TechnicalGasAnalysis(
            gas: gas,
            ppO2AtDepth: ppO2,
            densityAtDepth: density,
            densityRating: rating,
            endMeters: end,
            eadMeters: ead,
            consumptionLiters: consumption,
            remainingLiters: remaining,
            remainingBar: remainingBar,
            rockBottomLiters: rockBottom,
            minimumGasBar: minimumGasBar,
            turnPressureBar: turnPressure,
            cnsPercent: cns,
            otu: otu,
            warnings: warnings,
            states: states
        )
    }

    static func ppO2(gas: GasMix, depthMeters: Double) -> Double {
        GasMixValidator.actualPPO2(oxygenFraction: gas.oxygen, depthMeters: depthMeters) ?? 0
    }

    /// Actual PPO2 at depth. Over-limit states are reported separately; the value is never clipped.
    static func boundedPPO2(gas: GasMix, depthMeters: Double) -> Double {
        ppO2(gas: gas, depthMeters: depthMeters)
    }

    static func profileSegments(input: GasPlanInput, stops: [DecoStop]) -> [DivePlanSegment] {
        var segments: [DivePlanSegment] = []
        let maxDepth = input.plannedDepthMeters
        let bottom = PlannerGasSchedule.bottomGas(from: input)
        let descentPoints = PlannerGasSchedule.descentSwitchPoints(input: input)

        for (index, point) in descentPoints.enumerated() {
            if index > 0 {
                let switchDepth = descentPoints[index - 1].depthMeters
                segments.append(
                    DivePlanSegment(
                        kind: .gasSwitch,
                        depthMeters: switchDepth,
                        minutes: 0.5,
                        gas: point.gas.label,
                        note: gasSwitchNote(for: point.role)
                    )
                )
            }
            let previousDepth = index == 0 ? 0 : descentPoints[index - 1].depthMeters
            let legDepth = point.depthMeters - previousDepth
            guard legDepth > 0 else { continue }
            let minutes = max(1, legDepth / 18.0)
            let note = point.role == .travel
                ? String(localized: "planner.segment.travel_descent")
                : String(localized: "planner.segment.back_gas_descent")
            segments.append(
                DivePlanSegment(
                    kind: .descent,
                    depthMeters: point.depthMeters,
                    minutes: minutes,
                    gas: point.gas.label,
                    note: note
                )
            )
        }

        if segments.isEmpty {
            segments.append(
                DivePlanSegment(
                    kind: .descent,
                    depthMeters: maxDepth,
                    minutes: max(1, maxDepth / 18.0),
                    gas: bottom.label,
                    note: String(localized: "planner.segment.back_gas_descent")
                )
            )
        }

        segments.append(
            DivePlanSegment(
                kind: .bottom,
                depthMeters: maxDepth,
                minutes: input.plannedBottomMinutes,
                gas: bottom.label,
                note: String(localized: "planner.segment.bottom_time")
            )
        )

        let shallowestStop = stops.map(\.depthMeters).min() ?? 0
        for travel in PlannerGasSchedule.ascentTravelSwitchPoints(input: input, shallowestStopDepth: shallowestStop) {
            segments.append(
                DivePlanSegment(
                    kind: .gasSwitch,
                    depthMeters: travel.depthMeters,
                    minutes: 0.5,
                    gas: travel.gas.label,
                    note: String(localized: "planner.segment.travel_ascent")
                )
            )
        }

        for stop in stops {
            segments.append(
                DivePlanSegment(
                    kind: .gasSwitch,
                    depthMeters: stop.depthMeters,
                    minutes: 0.5,
                    gas: stop.gas,
                    note: String(localized: "planner.segment.deco_switch")
                )
            )
            segments.append(
                DivePlanSegment(
                    kind: .stop,
                    depthMeters: stop.depthMeters,
                    minutes: Double(stop.minutes),
                    gas: stop.gas,
                    note: String(localized: "planner.segment.deco_stop")
                )
            )
        }

        for bailout in PlannerGasSchedule.bailoutCylinders(from: input) {
            let depth = min(bailout.switchDepthMeters, bailout.modMeters)
            segments.append(
                DivePlanSegment(
                    kind: .gasSwitch,
                    depthMeters: depth,
                    minutes: 0,
                    gas: bailout.gas.label,
                    note: String(localized: "planner.segment.bailout_emergency")
                )
            )
        }

        segments.append(
            DivePlanSegment(
                kind: .ascent,
                depthMeters: 0,
                minutes: max(1, maxDepth / 9.0),
                gas: stops.last?.gas ?? bottom.label,
                note: String(localized: "planner.segment.final_ascent")
            )
        )
        return segments
    }

    static func gfComparisons(input: GasPlanInput, baseTTS: Int, stopCount: Int) -> [GFComparison] {
        let presets: [(String, Double, Double, Double)] = [
            ("20/80", 20, 80, 1.08),
            ("30/70", 30, 70, 1.00),
            ("40/85", 40, 85, 0.88),
            ("CUSTOM", input.gfLow, input.gfHigh, max(0.72, min(1.24, (100 - input.gfHigh + input.gfLow) / 100.0 + 0.75)))
        ]

        return presets.map { preset in
            let tts = max(1, Int(Double(baseTTS) * preset.3))
            let note = preset.2 <= 70 ? "Conservativo" : "Piu aggressivo"
            return GFComparison(label: preset.0, gfLow: preset.1, gfHigh: preset.2, ttsMinutes: tts, stopCount: max(1, Int(Double(stopCount) * preset.3.rounded())), conservatismNote: note)
        }
    }

    static func contingencyPlans(input: GasPlanInput, baseAnalysis: TechnicalGasAnalysis, baseTTS: Int) -> [ContingencyPlan] {
        let lostGasLiters = baseAnalysis.rockBottomLiters * 1.35
        let delayedLiters = input.sacLitersPerMinute * input.ambientPressureBar * 5
        let extendedLiters = input.sacLitersPerMinute * input.ambientPressureBar * 10
        return [
            ContingencyPlan(scenario: .lostGas, ttsMinutes: baseTTS + 8, gasRequiredLiters: lostGasLiters, action: "Switch team protocol, usare gas disponibile e risalita conservativa.", warning: "Validare con procedura team"),
            ContingencyPlan(scenario: .delayedAscent, ttsMinutes: baseTTS + 5, gasRequiredLiters: baseAnalysis.consumptionLiters + delayedLiters, action: "Aggiungere buffer di risalita e controllare CNS/OTU.", warning: "Rischio gas reserve"),
            ContingencyPlan(scenario: .extendedBottom, ttsMinutes: baseTTS + 12, gasRequiredLiters: baseAnalysis.consumptionLiters + extendedLiters, action: "Ricalcolare turn pressure e soste prima del briefing.", warning: "Possibile deco aggiuntiva")
        ]
    }

    static func teamGasMatches(input: GasPlanInput, minimumGasLiters: Double) -> [TeamGasMatch] {
        input.teamMembers.map { member in
            let reserveLiters = member.cylinder.volumeLiters * member.cylinder.reservePressureBar
            let available = member.cylinder.availableGasLiters
            let status = available - minimumGasLiters > reserveLiters ? "MATCH" : "LOW"
            return TeamGasMatch(diverName: member.name, sacLitersMinute: member.sacLitersPerMinute, availableLiters: available, reserveLiters: reserveLiters, status: status)
        }
    }

    static func briefingLines(input: GasPlanInput, analysis: TechnicalGasAnalysis, tts: Int, stops: [DecoStop]) -> [String] {
        [
            "Mode: planned as \(input.plannedDepthMeters)m / \(Int(input.plannedBottomMinutes))min, \(input.bottomGas.label).",
            "GF: \(Int(input.gfLow))/\(Int(input.gfHigh)); TTS/TTR estimate \(tts) min.",
            "Gas: turn \(Int(analysis.turnPressureBar)) bar, minimum gas \(Int(analysis.minimumGasBar)) bar.",
            "Respirability: density \(String(format: "%.1f", analysis.densityAtDepth)) g/L, END \(Int(analysis.endMeters))m.",
            "Oxygen: PPO2 \(String(format: "%.1f", analysis.ppO2AtDepth)), CNS \(Int(analysis.cnsPercent))%, OTU \(Int(analysis.otu)).",
            "Stops: \(stops.map { "\(Int($0.depthMeters))m/\($0.minutes)min \($0.gas)" }.joined(separator: ", "))."
        ]
    }

    private static func gasSwitchNote(for role: GasRole) -> String {
        switch role {
        case .travel: return String(localized: "planner.segment.switch_travel")
        case .bottom: return String(localized: "planner.segment.switch_back_gas")
        case .deco: return String(localized: "planner.segment.deco_switch")
        case .bailout: return String(localized: "planner.segment.bailout_emergency")
        }
    }

    private static func densityRating(_ density: Double, warning: Double, danger: Double) -> GasDensityRating {
        if density >= danger { return .red }
        if density >= warning { return .yellow }
        return .green
    }

    private static func equivalentNarcoticDepth(gas: GasMix, depthMeters: Double) -> Double {
        guard gas.isValidMix, depthMeters.isFinite, depthMeters >= 0 else { return 0 }
        let narcoticFraction = gas.nitrogen + (gas.isOxygenNarcotic ? gas.oxygen : 0)
        let airNarcoticFraction = 0.79 + (gas.isOxygenNarcotic ? 0.21 : 0)
        let narcoticPressure = IOSUnitConversions.ambientPressureBar(depthMeters: depthMeters) * narcoticFraction
        return max(0, ((narcoticPressure / max(airNarcoticFraction, 0.01)) - 1.0) * 10.0)
    }

    private static func equivalentAirDepth(gas: GasMix, depthMeters: Double) -> Double? {
        guard gas.isValidMix, gas.helium == 0, gas.oxygen > 0.21, depthMeters.isFinite, depthMeters >= 0 else { return nil }
        let nitrogenPressure = IOSUnitConversions.ambientPressureBar(depthMeters: depthMeters) * gas.nitrogen
        return max(0, ((nitrogenPressure / 0.79) - 1.0) * 10.0)
    }

    private static func rockBottomLiters(input: GasPlanInput) -> Double {
        let averageAscentATA = IOSUnitConversions.ambientPressureBar(depthMeters: input.plannedDepthMeters / 2.0)
        let ascentMinutes = max(3, input.plannedDepthMeters / 9.0)
        let problemSolvingMinutes = 1.0
        let safetyStopMinutes = input.plannedDepthMeters > 10 ? 3.0 : 0.0
        let emergencyMinutes = problemSolvingMinutes + ascentMinutes + safetyStopMinutes
        return input.emergencySacLitersPerMinute * max(1, input.teamSize) * averageAscentATA * emergencyMinutes
    }

    private static func oxygenExposureCNS(ppO2: Double, minutes: Double) -> Double {
        guard ppO2 > 0.5 else { return 0 }
        let limitMinutes: Double
        switch ppO2 {
        case ..<1.0: limitMinutes = 720
        case ..<1.2: limitMinutes = 210
        case ..<1.4: limitMinutes = 150
        case ..<1.6: limitMinutes = 45
        default: limitMinutes = 10
        }
        return min(300, minutes / limitMinutes * 100)
    }

    private static func oxygenToxicityUnits(ppO2: Double, minutes: Double) -> Double {
        guard ppO2 > 0.5 else { return 0 }
        return minutes * pow((0.5 / (ppO2 - 0.5)), -0.833)
    }

    private static func makeStates(input: GasPlanInput, ppO2: Double, density: Double, endMeters: Double, remainingLiters: Double, rockBottomLiters: Double) -> [PlannerResultState] {
        var values: [PlannerResultState] = [.validReference, .simplifiedReferenceOnly]
        if ppO2 > input.bottomGas.maxPPO2 {
            values.append(.PPO2Exceeded)
        }
        if input.effectivePlanningDepthMeters > input.bottomGas.modMeters {
            values.append(.MODExceeded)
        }
        if density >= input.densityDangerLimit {
            values.append(.gasDensityDanger)
        } else if density >= input.densityWarningLimit {
            values.append(.gasDensityWarning)
        }
        if endMeters > 30 {
            values.append(.simplifiedReferenceOnly)
        }
        if remainingLiters < rockBottomLiters {
            values.append(.belowReserve)
        }
        if remainingLiters < 0 {
            values.append(.insufficientGas)
        }
        return Array(Set(values)).sorted { $0.rawValue < $1.rawValue }
    }

    private static func makeWarnings(states: [PlannerResultState]) -> [String] {
        states.compactMap(\.warningText)
    }

    private static func mergeStates(_ groups: [PlannerResultState]...) -> [PlannerResultState] {
        var seen = Set<PlannerResultState>()
        var merged: [PlannerResultState] = []
        for state in groups.flatMap({ $0 }) where seen.insert(state).inserted {
            merged.append(state)
        }
        return merged
    }

    private static func unavailableAnalysis(input: GasPlanInput, gas: GasMix, validation: PlannerValidationResult) -> TechnicalGasAnalysis {
        let states = validation.states.isEmpty ? [.invalidInput] : validation.states
        return TechnicalGasAnalysis(
            gas: gas,
            ppO2AtDepth: 0,
            densityAtDepth: 0,
            densityRating: .red,
            endMeters: 0,
            eadMeters: nil,
            consumptionLiters: 0,
            remainingLiters: 0,
            remainingBar: 0,
            rockBottomLiters: 0,
            minimumGasBar: 0,
            turnPressureBar: 0,
            cnsPercent: 0,
            otu: 0,
            warnings: makeWarnings(states: states),
            states: states
        )
    }
}
