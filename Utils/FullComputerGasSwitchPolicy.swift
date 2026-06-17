import Foundation

enum FullComputerGasSwitchPolicy {
    static let switchDepthToleranceMeters = 0.05
    static let confirmationHoldSeconds: TimeInterval = 0.8

    static func isBreathable(_ gas: BuhlmannGas, depthMeters: Double, environment: PlannerEnvironment) -> Bool {
        let ppo2 = gas.ppO2(depthMeters: depthMeters, environment: environment)
        return ppo2 >= BuhlmannConstants.minBreathablePPO2Bar
            && ppo2 <= gas.maxPPO2Bar + BuhlmannCoreConfiguration.ppo2HardValidationToleranceBar
    }

    static func suggestedSwitchGas(
        activeGas: BuhlmannGas,
        depthMeters: Double,
        plannedGases: [BuhlmannGas],
        tracker: FullComputerGasSwitchTracker,
        environment: PlannerEnvironment
    ) -> BuhlmannGas? {
        let candidates = plannedGases
            .filter { !tracker.unavailableGasMixIds.contains($0.gasMixId) }
            .filter { $0.gasMixId != activeGas.gasMixId }
            .filter { $0.switchDepthMeters + switchDepthToleranceMeters >= depthMeters }
            .filter { isBreathable($0, depthMeters: depthMeters, environment: environment) }
            .sorted { $0.oxygenFraction > $1.oxygenFraction }
        return candidates.first
    }

    static func projectionGases(
        from plan: FullComputerRuntimePlan,
        tracker: FullComputerGasSwitchTracker
    ) -> (travel: [BuhlmannGas], deco: [BuhlmannGas]) {
        let travel = plan.travelGases.filter { tracker.confirmedGasMixIds.contains($0.gasMixId) }
        let deco = plan.decoGases.filter { tracker.confirmedGasMixIds.contains($0.gasMixId) }
        return (travel, deco)
    }

    static func evaluateSurface(
        activeGas: BuhlmannGas,
        depthMeters: Double,
        plannedGases: [BuhlmannGas],
        tracker: FullComputerGasSwitchTracker,
        environment: PlannerEnvironment
    ) -> FullComputerGasSwitchSurface {
        if let missedID = tracker.activeMissedGasMixId,
           let missedGas = plannedGases.first(where: { $0.gasMixId == missedID }),
           missedGas.gasMixId != activeGas.gasMixId,
           !tracker.unavailableGasMixIds.contains(missedID) {
            let canStillSwitch = isBreathable(missedGas, depthMeters: depthMeters, environment: environment)
            return .missed(
                FullComputerGasSwitchMissedPrompt(
                    activeGasLabel: activeGas.label,
                    suggestedGasLabel: missedGas.label,
                    suggestedGasMixId: missedGas.gasMixId,
                    switchDepthMeters: missedGas.switchDepthMeters,
                    canStillSwitch: canStillSwitch,
                    ttsUsesActiveGasOnly: true
                )
            )
        }

        guard let suggested = suggestedSwitchGas(
            activeGas: activeGas,
            depthMeters: depthMeters,
            plannedGases: plannedGases,
            tracker: tracker,
            environment: environment
        ) else {
            return .none
        }

        let key = FullComputerGasSwitchTracker.opportunityKey(
            gasMixId: suggested.gasMixId,
            switchDepthMeters: suggested.switchDepthMeters
        )
        if tracker.ignoredOpportunityKeys.contains(key) {
            return .none
        }

        let plannedIDs = Set(plannedGases.map(\.gasMixId))
        let isOffPlan = !plannedIDs.contains(suggested.gasMixId)
        let breathable = isBreathable(suggested, depthMeters: depthMeters, environment: environment)
        let ppo2 = suggested.ppO2(depthMeters: depthMeters, environment: environment)

        return .available(
            FullComputerGasSwitchPrompt(
                activeGasLabel: activeGas.label,
                suggestedGasLabel: suggested.label,
                suggestedGasMixId: suggested.gasMixId,
                switchDepthMeters: suggested.switchDepthMeters,
                currentDepthMeters: depthMeters,
                currentPPO2: ppo2,
                isBreathable: breathable,
                isOffPlan: isOffPlan,
                verifyCylinderNoteKey: "live.fc.gas_switch.verify_cylinder"
            )
        )
    }

    static func runtimeGasRows(
        activeGas: BuhlmannGas,
        depthMeters: Double,
        plannedGases: [BuhlmannGas],
        tracker: FullComputerGasSwitchTracker,
        environment: PlannerEnvironment
    ) -> [FullComputerRuntimeGasRow] {
        plannedGases
            .sorted { ($0.switchDepthMeters) > ($1.switchDepthMeters) }
            .map { gas in
                let ppo2 = gas.ppO2(depthMeters: depthMeters, environment: environment)
                if gas.gasMixId == activeGas.gasMixId {
                    return FullComputerRuntimeGasRow(
                        id: gas.gasMixId,
                        label: gas.label,
                        switchDepthMeters: gas.switchDepthMeters > 0 ? gas.switchDepthMeters : nil,
                        status: .active,
                        currentPPO2: ppo2,
                        isSelectable: false
                    )
                }
                if tracker.unavailableGasMixIds.contains(gas.gasMixId) {
                    return FullComputerRuntimeGasRow(
                        id: gas.gasMixId,
                        label: gas.label,
                        switchDepthMeters: gas.switchDepthMeters > 0 ? gas.switchDepthMeters : nil,
                        status: .unavailable,
                        currentPPO2: ppo2,
                        isSelectable: false
                    )
                }
                let breathable = isBreathable(gas, depthMeters: depthMeters, environment: environment)
                if !breathable {
                    return FullComputerRuntimeGasRow(
                        id: gas.gasMixId,
                        label: gas.label,
                        switchDepthMeters: gas.switchDepthMeters > 0 ? gas.switchDepthMeters : nil,
                        status: .unsafe,
                        currentPPO2: ppo2,
                        isSelectable: false
                    )
                }
                return FullComputerRuntimeGasRow(
                    id: gas.gasMixId,
                    label: gas.label,
                    switchDepthMeters: gas.switchDepthMeters > 0 ? gas.switchDepthMeters : nil,
                    status: .available,
                    currentPPO2: ppo2,
                    isSelectable: true
                )
            }
    }
}
