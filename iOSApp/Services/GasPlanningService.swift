import Foundation

enum GasPlanningService {
    static func analyze(input: GasPlanInput) -> TechnicalGasAnalysis {
        analyze(input: input, mode: .technical)
    }

    static func analyze(input: GasPlanInput, mode: PlannerMode) -> TechnicalGasAnalysis {
        let active = PlannerModePolicy.activePlanInput(from: input, mode: mode)
        return analyzeProjectedInput(active, mode: mode)
    }

    private static func analyzeProjectedInput(_ input: GasPlanInput, mode: PlannerMode) -> TechnicalGasAnalysis {
        let gas = input.bottomGas
        let validation = PlannerInputValidator.validate(input, mode: mode)
        guard validation.isValid else {
            return unavailableAnalysis(input: input, gas: gas, validation: validation)
        }
        guard case .success(let environment) = PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) else {
            var invalid = validation
            invalid.add(.invalidEnvironment, message: String(localized: "planner.validation.invalid_environment"))
            return unavailableAnalysis(input: input, gas: gas, validation: invalid)
        }
        let planningDepth = input.effectivePlanningDepthMeters
        let ata = AmbientPressureModel.ambientPressureBar(depthMeters: planningDepth, environment: environment) ?? environment.surfacePressureBar
        let ppO2 = boundedPPO2(gas: gas, depthMeters: planningDepth, environment: environment)
        let density = gas.surfaceDensityGramsLiter * ata
        let rating = densityRating(density, warning: input.densityWarningLimit, danger: input.densityDangerLimit)
        let end = equivalentNarcoticDepth(gas: gas, depthMeters: planningDepth, environment: environment)
        let ead = equivalentAirDepth(gas: gas, depthMeters: planningDepth, environment: environment)
        let consumption = input.sacLitersPerMinute * ata * input.plannedBottomMinutes
        let remaining = input.availableGasLiters - consumption
        let remainingBar = remaining / input.primaryCylinder.volumeLiters
        let rockBottom = rockBottomLiters(input: input, environment: environment)
        let minimumGasBar = rockBottom / input.primaryCylinder.volumeLiters
        let usableBeforeMinimum = input.availableGasLiters - rockBottom
        let turnPressure = usableBeforeMinimum > 0
            ? min(input.startPressureBar, max(input.reservePressureBar, input.startPressureBar - (usableBeforeMinimum / 2.0 / input.primaryCylinder.volumeLiters)))
            : input.reservePressureBar
        let bottomSegment = BuhlmannRuntimeSegment(
            kind: .bottom,
            depthMeters: planningDepth,
            minutes: input.plannedBottomMinutes,
            gas: BuhlmannGas(gas: gas, role: .bottom, switchDepthMeters: planningDepth),
            note: "Bottom"
        )
        let previewDescentBottomCNS: Double
        switch OxygenExposureModel.cnsPercentDescentAndBottom(segments: [bottomSegment], environment: environment) {
        case .success(let percent):
            previewDescentBottomCNS = min(300, max(0, percent))
        case .failure:
            previewDescentBottomCNS = 0
        }
        switch OxygenExposureModel.from(segments: [bottomSegment], environment: environment, carryover: .zero) {
        case .success(let exposure):
            return buildAnalysis(
                input: input,
                gas: gas,
                ppO2: ppO2,
                density: density,
                rating: rating,
                end: end,
                ead: ead,
                consumption: consumption,
                remaining: remaining,
                remainingBar: remainingBar,
                rockBottom: rockBottom,
                minimumGasBar: minimumGasBar,
                turnPressure: turnPressure,
                exposure: exposure,
                cnsDescentBottomPercent: previewDescentBottomCNS,
                extraStates: validation.states,
                exposureSegments: [bottomSegment],
                usesBottomPhaseConsumptionEstimate: true
            )
        case .failure:
            var invalid = validation
            invalid.add(.invalidEnvironment, message: String(localized: "planner.validation.invalid_oxygen_exposure"))
            return unavailableAnalysis(input: input, gas: gas, validation: invalid)
        }
    }

    static func analyze(input: GasPlanInput, enginePlan: BuhlmannEngineResult, oxygenCarryover: OxygenExposureCarryover = .zero, mode: PlannerMode = .technical) -> TechnicalGasAnalysis {
        let base = analyze(input: input, mode: mode)
        guard !enginePlan.segments.isEmpty, enginePlan.modelState == .validReference else {
            return base
        }
        let environment: PlannerEnvironment
        let cnsDescentBottomPercent: Double
        switch PlannerEnvironment.make(altitudeMeters: input.altitudeMeters, salinity: input.salinity) {
        case .success(let value):
            environment = value
            cnsDescentBottomPercent = resolvedCNSDescentBottomPercent(enginePlan: enginePlan, environment: value)
        case .failure:
            return TechnicalGasAnalysis(
                gas: base.gas,
                ppO2AtDepth: base.ppO2AtDepth,
                densityAtDepth: base.densityAtDepth,
                densityRating: base.densityRating,
                endMeters: base.endMeters,
                eadMeters: base.eadMeters,
                consumptionLiters: base.consumptionLiters,
                remainingLiters: base.remainingLiters,
                remainingBar: base.remainingBar,
                rockBottomLiters: base.rockBottomLiters,
                minimumGasBar: base.minimumGasBar,
                turnPressureBar: base.turnPressureBar,
                cnsPercent: base.cnsPercent,
                cnsDescentBottomPercent: 0,
                otu: base.otu,
                cnsDailyPercent: base.cnsDailyPercent,
                otuDaily24h: base.otuDaily24h,
                otuWeekly: base.otuWeekly,
                airBreakRecoveryApplied: base.airBreakRecoveryApplied,
                warnings: makeWarnings(states: mergeStates(base.states, [.invalidEnvironment])),
                states: mergeStates(base.states, [.invalidEnvironment]),
                usesBottomPhaseConsumptionEstimate: base.usesBottomPhaseConsumptionEstimate
            )
        }

        var maxDensity = base.densityAtDepth
        for segment in enginePlan.segments where segment.minutes.isFinite && segment.minutes > 0 {
            let depth = max(0, segment.depthMeters)
            let density = surfaceDensityGramsPerLiter(gas: segment.gas)
                * (IOSUnitConversions.ambientPressureBar(depthMeters: depth, environment: environment) ?? 0)
            if density.isFinite {
                maxDensity = max(maxDensity, density)
            }
        }

        var exposureResult: OxygenExposureResult?
        switch OxygenExposureModel.from(segments: enginePlan.segments, environment: environment, carryover: oxygenCarryover) {
        case .success(let exposure):
            exposureResult = exposure
        case .failure:
            return TechnicalGasAnalysis(
                gas: base.gas,
                ppO2AtDepth: base.ppO2AtDepth,
                densityAtDepth: base.densityAtDepth,
                densityRating: base.densityRating,
                endMeters: base.endMeters,
                eadMeters: base.eadMeters,
                consumptionLiters: base.consumptionLiters,
                remainingLiters: base.remainingLiters,
                remainingBar: base.remainingBar,
                rockBottomLiters: base.rockBottomLiters,
                minimumGasBar: base.minimumGasBar,
                turnPressureBar: base.turnPressureBar,
                cnsPercent: base.cnsPercent,
                cnsDescentBottomPercent: cnsDescentBottomPercent,
                otu: base.otu,
                cnsDailyPercent: base.cnsDailyPercent,
                otuDaily24h: base.otuDaily24h,
                otuWeekly: base.otuWeekly,
                airBreakRecoveryApplied: base.airBreakRecoveryApplied,
                warnings: makeWarnings(states: mergeStates(base.states, [.invalidEnvironment])),
                states: mergeStates(base.states, [.invalidEnvironment]),
                usesBottomPhaseConsumptionEstimate: base.usesBottomPhaseConsumptionEstimate
            )
        }

        guard let exposure = exposureResult else {
            return base
        }

        let densityRating = densityRating(maxDensity, warning: input.densityWarningLimit, danger: input.densityDangerLimit)
        var states = mergeStates(
            base.states,
            makeStates(
                input: input,
                ppO2: base.ppO2AtDepth,
                density: maxDensity,
                endMeters: base.endMeters,
                remainingLiters: base.remainingLiters,
                rockBottomLiters: base.rockBottomLiters,
                environment: environment
            ),
            exposurePlannerStates(
                from: exposure,
                segments: enginePlan.segments,
                environment: environment,
                cnsDescentBottomPercent: cnsDescentBottomPercent
            )
        )
        if maxDensity >= input.densityDangerLimit {
            states = mergeStates(states, [.gasDensityDanger])
        } else if maxDensity >= input.densityWarningLimit {
            states = mergeStates(states, [.gasDensityWarning])
        }
        switch ScheduleGasConsumptionService.analyze(input: input, enginePlan: enginePlan, environment: environment) {
        case .success(let ledger):
            let bottomEntry = ledger.bottomGasEntry(from: input)
            let summaryRemainingBar = bottomEntry?.remainingBar ?? base.remainingBar
            let summaryRemainingLiters = bottomEntry?.remainingLiters ?? base.remainingLiters
            if ledger.warnings.contains(where: {
                if case .reserveBreached = $0 { return true }
                return false
            }) {
                states = mergeStates(states, [.belowReserve])
            }
            if ledger.warnings.contains(where: {
                if case .minimumGasBreached = $0 { return true }
                return false
            }) {
                states = mergeStates(states, [.insufficientGas])
            }
            if ledger.warnings.contains(where: {
                if case .lostGasContingencyFailed = $0 { return true }
                return false
            }) {
                states = mergeStates(states, [.belowReserve])
            }
            return TechnicalGasAnalysis(
                gas: base.gas,
                ppO2AtDepth: base.ppO2AtDepth,
                densityAtDepth: maxDensity,
                densityRating: densityRating,
                endMeters: base.endMeters,
                eadMeters: base.eadMeters,
                consumptionLiters: ledger.totalConsumedLiters,
                remainingLiters: summaryRemainingLiters,
                remainingBar: summaryRemainingBar,
                rockBottomLiters: rockBottomLiters(input: input, environment: environment),
                minimumGasBar: base.minimumGasBar,
                turnPressureBar: base.turnPressureBar,
                cnsPercent: min(300, exposure.cnsSinglePercent),
                cnsDescentBottomPercent: cnsDescentBottomPercent,
                otu: exposure.otuDive,
                cnsDailyPercent: min(300, exposure.cnsDailyPercent),
                otuDaily24h: exposure.otuDaily24h,
                otuWeekly: exposure.otuWeekly,
                airBreakRecoveryApplied: exposure.airBreakRecoveryApplied,
                warnings: makeWarnings(states: states),
                states: states,
                usesBottomPhaseConsumptionEstimate: false
            )
        case .failure:
            states = mergeStates(states, [.gasAllocationIncomplete])
        }

        return TechnicalGasAnalysis(
            gas: base.gas,
            ppO2AtDepth: base.ppO2AtDepth,
            densityAtDepth: maxDensity,
            densityRating: densityRating,
            endMeters: base.endMeters,
            eadMeters: base.eadMeters,
            consumptionLiters: base.consumptionLiters,
            remainingLiters: base.remainingLiters,
            remainingBar: base.remainingBar,
            rockBottomLiters: base.rockBottomLiters,
            minimumGasBar: base.minimumGasBar,
            turnPressureBar: base.turnPressureBar,
            cnsPercent: min(300, exposure.cnsSinglePercent),
            cnsDescentBottomPercent: cnsDescentBottomPercent,
            otu: exposure.otuDive,
            cnsDailyPercent: min(300, exposure.cnsDailyPercent),
            otuDaily24h: exposure.otuDaily24h,
            otuWeekly: exposure.otuWeekly,
            airBreakRecoveryApplied: exposure.airBreakRecoveryApplied,
            warnings: makeWarnings(states: states),
            states: states,
            usesBottomPhaseConsumptionEstimate: false
        )
    }

    private static func resolvedCNSDescentBottomPercent(
        enginePlan: BuhlmannEngineResult,
        environment: PlannerEnvironment
    ) -> Double {
        switch OxygenExposureModel.cnsPercentDescentAndBottom(segments: enginePlan.segments, environment: environment) {
        case .success(let percent):
            guard percent.isFinite else { return 0 }
            return min(300, max(0, percent))
        case .failure:
            return 0
        }
    }

    static func ppO2(gas: GasMix, depthMeters: Double, environment: PlannerEnvironment = .seaLevelSaltWater) -> Double {
        guard let ambient = AmbientPressureModel.ambientPressureBar(depthMeters: depthMeters, environment: environment) else { return 0 }
        return max(0, gas.oxygen * ambient)
    }

    /// Actual PPO2 at depth. Over-limit states are reported separately; the value is never clipped.
    static func boundedPPO2(gas: GasMix, depthMeters: Double, environment: PlannerEnvironment = .seaLevelSaltWater) -> Double {
        ppO2(gas: gas, depthMeters: depthMeters, environment: environment)
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
            let environment = input.plannerEnvironment
            let depth = min(bailout.switchDepthMeters, bailout.modMeters(environment: environment))
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

    static func contingencyPlans(
        input: GasPlanInput,
        baseAnalysis: TechnicalGasAnalysis,
        baseTTS: Int,
        environment: PlannerEnvironment = .seaLevelSaltWater
    ) -> [ContingencyPlan] {
        let baseRequest = BuhlmannPlanner.makeRequest(input: input, environment: environment)

        func ttsMinutes(for request: BuhlmannPlanRequest) -> Int {
            BuhlmannEngine.plan(request).ttsMinutes
        }

        func gasRequiredLiters(for request: BuhlmannPlanRequest) -> Double {
            let plan = BuhlmannEngine.plan(request)
            switch ScheduleGasConsumptionService.analyze(input: input, enginePlan: plan, environment: environment) {
            case .success(let ledger):
                return ledger.totalConsumedLiters
            case .failure:
                let bottomATA = AmbientPressureModel.ambientPressureBar(
                    depthMeters: request.maxDepthMeters,
                    environment: environment
                ) ?? environment.surfacePressureBar
                return input.sacLitersPerMinute * bottomATA * request.bottomMinutes
            }
        }

        var delayed = baseRequest
        delayed.bottomMinutes += 5
        var extended = baseRequest
        extended.bottomMinutes += 10
        var deeper = baseRequest
        deeper.maxDepthMeters = min(
            IOSAlgorithmConfiguration.maxPlannerDepthMeters,
            baseRequest.maxDepthMeters + 3
        )
        let sourceBottom = deeper.bottomGas
        deeper.bottomGas = BuhlmannGas(
            name: sourceBottom.name,
            role: sourceBottom.role,
            oxygenFraction: sourceBottom.oxygenFraction,
            heliumFraction: sourceBottom.heliumFraction,
            maxPPO2Bar: sourceBottom.maxPPO2Bar,
            switchDepthMeters: deeper.maxDepthMeters,
            gasMixId: sourceBottom.gasMixId,
            cylinderId: sourceBottom.cylinderId
        )

        let lostGasLiters = baseAnalysis.rockBottomLiters
        let delayedTTS = ttsMinutes(for: delayed)
        let extendedTTS = ttsMinutes(for: extended)
        let deeperTTS = ttsMinutes(for: deeper)
        let extendedLiters = gasRequiredLiters(for: extended)
        let deeperLiters = gasRequiredLiters(for: deeper)
        let stressTTS = max(extendedTTS, deeperTTS)
        let stressLiters = extendedTTS >= deeperTTS ? extendedLiters : deeperLiters
        let stressAction = extendedTTS >= deeperTTS
            ? String(localized: "planner.contingency.extended_bottom.action")
            : String(format: String(localized: "planner.contingency.deeper_depth.action"), Int(deeper.maxDepthMeters))

        return [
            ContingencyPlan(
                scenario: .lostGas,
                ttsMinutes: baseTTS,
                gasRequiredLiters: lostGasLiters,
                action: String(localized: "planner.contingency.lost_gas.action"),
                warning: String(localized: "planner.contingency.lost_gas.warning")
            ),
            ContingencyPlan(
                scenario: .delayedAscent,
                ttsMinutes: delayedTTS,
                gasRequiredLiters: gasRequiredLiters(for: delayed),
                action: String(localized: "planner.contingency.delayed_ascent.action"),
                warning: String(localized: "planner.contingency.delayed_ascent.warning")
            ),
            ContingencyPlan(
                scenario: .extendedBottom,
                ttsMinutes: stressTTS,
                gasRequiredLiters: stressLiters,
                action: stressAction,
                warning: String(localized: "planner.contingency.extended_bottom.warning")
            )
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
            String(
                format: String(localized: "planner.briefing.mode"),
                input.plannedDepthMeters,
                Int(input.plannedBottomMinutes),
                input.bottomGas.label
            ),
            String(
                format: String(localized: "planner.briefing.gf_tts"),
                Int(input.gfLow),
                Int(input.gfHigh),
                tts
            ),
            String(
                format: String(localized: "planner.briefing.gas_pressure"),
                Int(analysis.turnPressureBar),
                Int(analysis.minimumGasBar)
            ),
            String(
                format: String(localized: "planner.briefing.respirability"),
                analysis.densityAtDepth,
                Int(analysis.endMeters)
            ),
            String(
                format: String(localized: "planner.briefing.oxygen"),
                analysis.ppO2AtDepth,
                Int(analysis.cnsPercent),
                Int(analysis.cnsDailyPercent),
                Int(analysis.otu),
                Int(analysis.otuDaily24h)
            ),
            String(
                format: String(localized: "planner.briefing.stops"),
                stops.map { "\(Int($0.depthMeters))m/\($0.minutes)min \($0.gas)" }.joined(separator: ", ")
            )
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

    private static func equivalentNarcoticDepth(gas: GasMix, depthMeters: Double, environment: PlannerEnvironment) -> Double {
        guard gas.isValidMix, depthMeters.isFinite, depthMeters >= 0 else { return 0 }
        let narcoticFraction = gas.nitrogen + (gas.isOxygenNarcotic ? gas.oxygen : 0)
        let airNarcoticFraction = 0.79 + (gas.isOxygenNarcotic ? 0.21 : 0)
        let ambient = AmbientPressureModel.ambientPressureBar(depthMeters: depthMeters, environment: environment) ?? environment.surfacePressureBar
        let narcoticPressure = ambient * narcoticFraction
        let equivalentAmbient = narcoticPressure / max(airNarcoticFraction, 0.01)
        guard equivalentAmbient.isFinite, equivalentAmbient >= environment.surfacePressureBar,
              let endMeters = AmbientPressureModel.depthMeters(ambientPressureBar: equivalentAmbient, environment: environment) else {
            return 0
        }
        return max(0, endMeters)
    }

    private static func equivalentAirDepth(gas: GasMix, depthMeters: Double, environment: PlannerEnvironment) -> Double? {
        guard gas.isValidMix, gas.helium == 0, gas.oxygen > 0.21, depthMeters.isFinite, depthMeters >= 0 else { return nil }
        let ambient = AmbientPressureModel.ambientPressureBar(depthMeters: depthMeters, environment: environment) ?? environment.surfacePressureBar
        let nitrogenPressure = ambient * gas.nitrogen
        let equivalentAmbient = nitrogenPressure / 0.79
        guard equivalentAmbient.isFinite, equivalentAmbient >= environment.surfacePressureBar,
              let eadMeters = AmbientPressureModel.depthMeters(ambientPressureBar: equivalentAmbient, environment: environment) else {
            return nil
        }
        return max(0, eadMeters)
    }

    private static func rockBottomLiters(input: GasPlanInput, environment: PlannerEnvironment) -> Double {
        ScheduleGasConsumptionService.rockBottomLiters(input: input, environment: environment)
    }

    private static func surfaceDensityGramsPerLiter(gas: BuhlmannGas) -> Double {
        guard gas.isCompositionValid else { return 0 }
        return gas.oxygenFraction * 1.429
            + gas.nitrogenFraction * 1.251
            + gas.heliumFraction * 0.1786
    }

    private static func makeStates(
        input: GasPlanInput,
        ppO2: Double,
        density: Double,
        endMeters: Double,
        remainingLiters: Double,
        rockBottomLiters: Double,
        environment: PlannerEnvironment = .seaLevelSaltWater
    ) -> [PlannerResultState] {
        var values: [PlannerResultState] = [.validReference, .nonCertifiedReference]
        if ppO2 > input.bottomGas.maxPPO2 {
            values.append(.PPO2Exceeded)
        }
        if input.plannedDepthMeters > input.bottomGas.modMeters(environment: environment) {
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

    private static func buildAnalysis(
        input: GasPlanInput,
        gas: GasMix,
        ppO2: Double,
        density: Double,
        rating: GasDensityRating,
        end: Double,
        ead: Double?,
        consumption: Double,
        remaining: Double,
        remainingBar: Double,
        rockBottom: Double,
        minimumGasBar: Double,
        turnPressure: Double,
        exposure: OxygenExposureResult,
        cnsDescentBottomPercent: Double,
        extraStates: [PlannerResultState],
        exposureSegments: [BuhlmannRuntimeSegment] = [],
        usesBottomPhaseConsumptionEstimate: Bool = false
    ) -> TechnicalGasAnalysis {
        let states = mergeStates(
            extraStates,
            makeStates(
                input: input,
                ppO2: ppO2,
                density: density,
                endMeters: end,
                remainingLiters: remaining,
                rockBottomLiters: rockBottom,
                environment: input.plannerEnvironment
            ),
            exposurePlannerStates(
                from: exposure,
                segments: exposureSegments,
                environment: input.plannerEnvironment,
                cnsDescentBottomPercent: cnsDescentBottomPercent
            )
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
            cnsPercent: min(300, exposure.cnsSinglePercent),
            cnsDescentBottomPercent: cnsDescentBottomPercent,
            otu: exposure.otuDive,
            cnsDailyPercent: min(300, exposure.cnsDailyPercent),
            otuDaily24h: exposure.otuDaily24h,
            otuWeekly: exposure.otuWeekly,
            airBreakRecoveryApplied: exposure.airBreakRecoveryApplied,
            warnings: makeWarnings(states: states),
            states: states,
            usesBottomPhaseConsumptionEstimate: usesBottomPhaseConsumptionEstimate
        )
    }

    private static func exposurePlannerStates(
        from exposure: OxygenExposureResult,
        segments: [BuhlmannRuntimeSegment] = [],
        environment: PlannerEnvironment = .seaLevelSaltWater,
        cnsDescentBottomPercent: Double = 0,
        cnsDescentBottomCheckEnabled: Bool = PlannerCNSDescentBottomCheckSettings.defaultEnabled
    ) -> [PlannerResultState] {
        var states: [PlannerResultState] = []
        if segmentsExceedGasPPO2Limit(segments, environment: environment) {
            states.append(.PPO2Exceeded)
        }
        for warning in exposure.warningStates {
            switch warning {
            case .elevatedCNS:
                states.append(.cnsSingleElevated)
            case .elevatedDailyCNS:
                states.append(.cnsDailyElevated)
            case .elevatedOTU:
                states.append(.otuDiveElevated)
            case .elevatedDailyOTU:
                states.append(.otuDailyElevated)
            case .elevatedWeeklyOTU:
                states.append(.otuWeeklyElevated)
            case .invalidExposureInput:
                break
            }
        }
        if cnsDescentBottomCheckEnabled,
           CNSDescentBottomPlannerRule.exceedsPlannerThreshold(percent: cnsDescentBottomPercent) {
            states.append(.cnsDescentBottomThresholdExceeded)
        }
        if !exposure.warningStates.isEmpty {
            states.append(.oxygenExposureElevated)
        }
        return states
    }

    private static func segmentsExceedGasPPO2Limit(_ segments: [BuhlmannRuntimeSegment], environment: PlannerEnvironment) -> Bool {
        segments.contains { segment in
            let ppO2 = segment.gas.ppO2(depthMeters: segment.depthMeters, environment: environment)
            return ppO2 > segment.gas.maxPPO2Bar + IOSAlgorithmConfiguration.ppo2HardValidationToleranceBar
        }
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
            cnsDescentBottomPercent: 0,
            otu: 0,
            cnsDailyPercent: 0,
            otuDaily24h: 0,
            otuWeekly: 0,
            airBreakRecoveryApplied: false,
            warnings: makeWarnings(states: states),
            states: states,
            usesBottomPhaseConsumptionEstimate: false
        )
    }
}
