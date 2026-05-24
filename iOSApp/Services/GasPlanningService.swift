import Foundation

enum GasPlanningService {
    static func analyze(input: GasPlanInput) -> TechnicalGasAnalysis {
        let gas = input.bottomGas
        let ata = input.ambientPressureBar
        let ppO2 = gas.oxygen * ata
        let density = gas.surfaceDensityGramsLiter * ata
        let rating = densityRating(density, warning: input.densityWarningLimit, danger: input.densityDangerLimit)
        let planningDepth = input.effectivePlanningDepthMeters
        let end = equivalentNarcoticDepth(gas: gas, depthMeters: planningDepth)
        let ead = equivalentAirDepth(gas: gas, depthMeters: planningDepth)
        let consumption = input.sacLitersPerMinute * ata * input.plannedBottomMinutes
        let remaining = input.availableGasLiters - consumption
        let remainingBar = remaining / max(input.cylinder.volumeLiters, 0.1)
        let rockBottom = rockBottomLiters(input: input)
        let minimumGasBar = rockBottom / max(input.cylinder.volumeLiters, 0.1)
        let usableBeforeMinimum = max(0, input.availableGasLiters - rockBottom)
        let turnPressure = min(input.startPressureBar, max(input.reservePressureBar, input.startPressureBar - (usableBeforeMinimum / 2.0 / max(input.cylinder.volumeLiters, 0.1))))
        let cns = oxygenExposureCNS(ppO2: ppO2, minutes: input.plannedBottomMinutes)
        let otu = oxygenToxicityUnits(ppO2: ppO2, minutes: input.plannedBottomMinutes)
        let warnings = makeWarnings(
            input: input,
            ppO2: ppO2,
            density: density,
            endMeters: end,
            remainingLiters: remaining,
            rockBottomLiters: rockBottom
        )

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
            warnings: warnings
        )
    }

    static func ppO2(gas: GasMix, depthMeters: Double) -> Double {
        gas.oxygen * (depthMeters / 10.0 + 1.0)
    }

    static func profileSegments(input: GasPlanInput, stops: [DecoStop]) -> [DivePlanSegment] {
        var segments: [DivePlanSegment] = [
            DivePlanSegment(kind: .descent, depthMeters: input.plannedDepthMeters, minutes: max(1, input.plannedDepthMeters / 18.0), gas: input.bottomGas.label, note: "Discesa controllata"),
            DivePlanSegment(kind: .bottom, depthMeters: input.plannedDepthMeters, minutes: input.plannedBottomMinutes, gas: input.bottomGas.label, note: "Tempo fondo pianificato")
        ]

        for stop in stops {
            segments.append(DivePlanSegment(kind: .gasSwitch, depthMeters: stop.depthMeters, minutes: 0.5, gas: stop.gas, note: "Verifica gas e PPO2"))
            segments.append(DivePlanSegment(kind: .stop, depthMeters: stop.depthMeters, minutes: Double(stop.minutes), gas: stop.gas, note: "Sosta pianificata"))
        }

        segments.append(DivePlanSegment(kind: .ascent, depthMeters: 0, minutes: max(1, input.plannedDepthMeters / 9.0), gas: stops.last?.gas ?? input.bottomGas.label, note: "Risalita finale"))
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

    private static func densityRating(_ density: Double, warning: Double, danger: Double) -> GasDensityRating {
        if density >= danger { return .red }
        if density >= warning { return .yellow }
        return .green
    }

    private static func equivalentNarcoticDepth(gas: GasMix, depthMeters: Double) -> Double {
        let narcoticFraction = gas.nitrogen + (gas.isOxygenNarcotic ? gas.oxygen : 0)
        let airNarcoticFraction = 0.79 + (gas.isOxygenNarcotic ? 0.21 : 0)
        let narcoticPressure = (depthMeters / 10.0 + 1.0) * narcoticFraction
        return max(0, ((narcoticPressure / max(airNarcoticFraction, 0.01)) - 1.0) * 10.0)
    }

    private static func equivalentAirDepth(gas: GasMix, depthMeters: Double) -> Double? {
        guard gas.helium == 0, gas.oxygen > 0.21 else { return nil }
        let nitrogenPressure = (depthMeters / 10.0 + 1.0) * gas.nitrogen
        return max(0, ((nitrogenPressure / 0.79) - 1.0) * 10.0)
    }

    private static func rockBottomLiters(input: GasPlanInput) -> Double {
        let averageAscentATA = ((input.plannedDepthMeters / 2.0) / 10.0) + 1.0
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

    private static func makeWarnings(input: GasPlanInput, ppO2: Double, density: Double, endMeters: Double, remainingLiters: Double, rockBottomLiters: Double) -> [String] {
        var values: [String] = []
        if ppO2 > input.bottomGas.maxPPO2 {
            values.append("PPO2 oltre limite gas")
        }
        if input.effectivePlanningDepthMeters > input.bottomGas.modMeters {
            values.append(String(localized: "planner.warning.profile_above_mod"))
        }
        if density >= input.densityDangerLimit {
            values.append("Densita gas in zona rossa")
        } else if density >= input.densityWarningLimit {
            values.append("Densita gas in warning")
        }
        if endMeters > 30 {
            values.append("END elevata")
        }
        if remainingLiters < rockBottomLiters {
            values.append("Gas residuo sotto rock bottom")
        }
        return values
    }
}
