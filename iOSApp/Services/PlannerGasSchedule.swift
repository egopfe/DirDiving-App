import Foundation

/// Builds role-aware gas switch order for planner segments and deco stops (no Bühlmann math).
enum PlannerGasSchedule {
    struct SwitchPoint: Hashable {
        let depthMeters: Double
        let gas: GasMix
        let role: GasRole
    }

    struct DecoStopPlan {
        let requested: [DecoStop]
        let applied: [DecoStop]
    }

    static func bottomGas(from input: GasPlanInput) -> GasMix {
        var working = input
        working.syncLegacyGasesFromPlannerCylinders()
        return working.bottomGas
    }

    static func sortedDecoCylinders(from input: GasPlanInput) -> [PlannerCylinderEntry] {
        input.plannerCylinders
            .filter { $0.role == .deco }
            .sorted { $0.switchDepthMeters > $1.switchDepthMeters }
    }

    static func sortedTravelCylinders(from input: GasPlanInput) -> [PlannerCylinderEntry] {
        input.plannerCylinders
            .filter { $0.role == .travel }
            .sorted { $0.switchDepthMeters > $1.switchDepthMeters }
    }

    static func bailoutCylinders(from input: GasPlanInput) -> [PlannerCylinderEntry] {
        input.plannerCylinders.filter { $0.role == .bailout }
    }

    /// Descent switch points from shallow to deep (travel segments, then back gas at max depth).
    static func descentSwitchPoints(input: GasPlanInput) -> [SwitchPoint] {
        let maxDepth = input.plannedDepthMeters
        var points: [SwitchPoint] = []

        for travel in sortedTravelCylinders(from: input) {
            let depth = travel.switchDepthMeters
            guard depth > 0.5, depth < maxDepth - 0.5 else { continue }
            points.append(SwitchPoint(depthMeters: depth, gas: travel.gas, role: .travel))
        }

        points.append(SwitchPoint(depthMeters: maxDepth, gas: bottomGas(from: input), role: .bottom))
        return points.sorted { $0.depthMeters < $1.depthMeters }
    }

    /// Ascent-related travel switches between bottom and shallowest planned stop.
    static func ascentTravelSwitchPoints(input: GasPlanInput, shallowestStopDepth: Double) -> [SwitchPoint] {
        let maxDepth = input.plannedDepthMeters
        return sortedTravelCylinders(from: input).compactMap { travel in
            let depth = travel.switchDepthMeters
            guard depth > shallowestStopDepth + 0.5, depth < maxDepth - 0.5 else { return nil }
            return SwitchPoint(depthMeters: depth, gas: travel.gas, role: .travel)
        }.sorted { $0.depthMeters > $1.depthMeters }
    }

  /// Deco stops are built exclusively from `plannerCylinders` with role `.deco` when present.
    static func buildDecoStops(needsDeco: Bool, input: GasPlanInput) -> DecoStopPlan {
        var working = input
        working.syncLegacyGasesFromPlannerCylinders()

        guard needsDeco else {
            let stop = makeDecoStop(depthMeters: 5, minutes: 3, gas: bottomGas(from: working))
            return DecoStopPlan(requested: [stop], applied: [stop])
        }

        let decos = sortedDecoCylinders(from: working)
        guard !decos.isEmpty else {
            return legacyFallbackDecoStops(input: working)
        }

        let deep = decos.first!
        let shallow = decos.last!
        let mid = decos.count >= 3 ? decos[1] : deep

        let deepGas = deep.gas
        let midGas = mid.gas
        let shallowGas = shallow.gas
        let modDeep = PlannerMODValidator.modMeters(for: deepGas)
        let modMid = PlannerMODValidator.modMeters(for: midGas)
        let modShallow = PlannerMODValidator.modMeters(for: shallowGas)
        let rawDeep = deep.switchDepthMeters
        let rawShallow = shallow.switchDepthMeters

        let requested: [DecoStop] = [
            makeDecoStop(depthMeters: rawDeep, minutes: 2, gas: deepGas),
            makeDecoStop(depthMeters: 15, minutes: 3, gas: midGas),
            makeDecoStop(depthMeters: rawShallow, minutes: 5, gas: shallowGas),
            makeDecoStop(depthMeters: 6, minutes: 8, gas: shallowGas),
            makeDecoStop(depthMeters: 3, minutes: 4, gas: shallowGas)
        ]
        let applied: [DecoStop] = [
            makeDecoStop(depthMeters: min(rawDeep, modDeep), minutes: 2, gas: deepGas),
            makeDecoStop(depthMeters: min(15, modMid), minutes: 3, gas: midGas),
            makeDecoStop(depthMeters: min(rawShallow, modShallow), minutes: 5, gas: shallowGas),
            makeDecoStop(depthMeters: min(6, modShallow), minutes: 8, gas: shallowGas),
            makeDecoStop(depthMeters: min(3, modShallow), minutes: 4, gas: shallowGas)
        ]
        return DecoStopPlan(requested: requested, applied: applied)
    }

    /// Used only when no `.deco` cylinders exist after sync (legacy saved state).
    private static func legacyFallbackDecoStops(input: GasPlanInput) -> DecoStopPlan {
        let decoA = input.decoGas1
        let decoB = input.decoGas2
        let modA = PlannerMODValidator.modMeters(for: decoA)
        let modB = PlannerMODValidator.modMeters(for: decoB)
        let requested: [DecoStop] = [
            makeDecoStop(depthMeters: 21, minutes: 2, gas: decoA),
            makeDecoStop(depthMeters: 15, minutes: 3, gas: decoA),
            makeDecoStop(depthMeters: 9, minutes: 5, gas: decoB),
            makeDecoStop(depthMeters: 6, minutes: 8, gas: decoB),
            makeDecoStop(depthMeters: 3, minutes: 4, gas: decoB)
        ]
        let applied: [DecoStop] = [
            makeDecoStop(depthMeters: min(21, modA), minutes: 2, gas: decoA),
            makeDecoStop(depthMeters: min(15, modA), minutes: 3, gas: decoA),
            makeDecoStop(depthMeters: min(9, modB), minutes: 5, gas: decoB),
            makeDecoStop(depthMeters: min(6, modB), minutes: 8, gas: decoB),
            makeDecoStop(depthMeters: min(3, modB), minutes: 4, gas: decoB)
        ]
        return DecoStopPlan(requested: requested, applied: applied)
    }

    static func hasMODBlockingIssues(input: GasPlanInput) -> Bool {
        guard PlannerInputValidator.validate(input).isValid else { return true }
        var working = input
        working.syncLegacyGasesFromPlannerCylinders()
        if !PlannerMODValidator.validatePlannerCylinders(input: working).isEmpty {
            return true
        }
        let bottom = bottomGas(from: working)
        let planningDepth = working.buhlmannPlanningDepthMeters
        let buhlmann = BuhlmannPlanner.plan(depthMeters: planningDepth, bottomGas: bottom)
        let needsDeco = buhlmann.modelState == .simplifiedReferenceOnly
            && (working.plannedBottomMinutes > buhlmann.ndlMinutes || planningDepth >= 35)
        let stopPlan = buildDecoStops(needsDeco: needsDeco, input: working)
        return !PlannerMODValidator.validateAll(input: working, requestedStops: stopPlan.requested).isEmpty
    }

    static func makeDecoStop(depthMeters: Double, minutes: Int, gas: GasMix) -> DecoStop {
        let actualPPO2 = GasPlanningService.ppO2(gas: gas, depthMeters: depthMeters)
        let states: [PlannerResultState] = actualPPO2 > gas.maxPPO2 ? [.PPO2Exceeded] : []
        DecoStop(
            depthMeters: depthMeters,
            minutes: minutes,
            gas: gas.label,
            ppO2: actualPPO2,
            maxPPO2: gas.maxPPO2,
            states: states
        )
    }

    static func roleScheduleLines(input: GasPlanInput) -> [String] {
        var lines: [String] = []
        let travels = sortedTravelCylinders(from: input)
        if !travels.isEmpty {
            let travelSummary = travels.map { "\($0.gas.label) @ \(Int($0.switchDepthMeters))m" }.joined(separator: ", ")
            lines.append(String(format: String(localized: "planner.schedule.travel"), travelSummary))
        }
        lines.append(String(format: String(localized: "planner.schedule.back_gas"), bottomGas(from: input).label, Int(input.plannedDepthMeters)))
        let decos = sortedDecoCylinders(from: input)
        if !decos.isEmpty {
            let decoSummary = decos.map { "\($0.gas.label) @ \(Int($0.switchDepthMeters))m" }.joined(separator: ", ")
            lines.append(String(format: String(localized: "planner.schedule.deco"), decoSummary))
        }
        for bailout in bailoutCylinders(from: input) {
            lines.append(
                String(
                    format: String(localized: "planner.schedule.bailout"),
                    bailout.gas.label,
                    Int(min(bailout.switchDepthMeters, bailout.modMeters))
                )
            )
        }
        return lines
    }
}
