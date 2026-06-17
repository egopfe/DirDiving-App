import Foundation

enum EquipmentPlannerMapper {
    /// Copies equipment gases/cylinders into planner input only. Does not run planner math.
    static func apply(profile: EquipmentProfile, to input: inout GasPlanInput, plannerMode: PlannerMode) -> EquipmentPlannerApplyResult {
        input.sacLitersPerMinute = profile.sacLitersMinute

        let cylinders = profile.enabledCylinders
        guard !cylinders.isEmpty else {
            return EquipmentPlannerApplyResult(appliedCylinderCount: 0, ignoredRoles: [])
        }

        var plannerEntries: [PlannerCylinderEntry] = []
        var ignoredRoles: [GasRole] = []

        for cylinder in cylinders {
            if !isRoleSupported(cylinder.role, mode: plannerMode) {
                ignoredRoles.append(cylinder.role)
                continue
            }
            var gas = cylinder.gas
            gas.role = cylinder.role
            plannerEntries.append(
                PlannerCylinderEntry(
                    id: cylinder.id,
                    role: cylinder.role,
                    tankSize: cylinder.tankSize,
                    gas: gas,
                    switchDepthMeters: cylinder.switchDepthMeters,
                    startPressure: cylinder.startPressureBar,
                    reservePressure: cylinder.reservePressureBar
                )
            )
        }

        guard !plannerEntries.isEmpty else {
            return EquipmentPlannerApplyResult(appliedCylinderCount: 0, ignoredRoles: ignoredRoles)
        }

        input.plannerCylinders = plannerEntries
        input.syncLegacyGasesFromPlannerCylinders()
        return EquipmentPlannerApplyResult(
            appliedCylinderCount: plannerEntries.count,
            ignoredRoles: ignoredRoles
        )
    }

    private static func isRoleSupported(_ role: GasRole, mode: PlannerMode) -> Bool {
        switch mode {
        case .ccr:
            return true
        case .base, .deco, .technical:
            return role.isOpenCircuitRole
        }
    }
}
