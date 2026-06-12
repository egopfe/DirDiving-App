import Foundation

enum EquipmentChecklistGenerator {
    static func generate(from profile: EquipmentProfile) -> [EquipmentChecklistItem] {
        var items: [EquipmentChecklistItem] = []

        for cylinder in profile.enabledCylinders {
            items.append(
                EquipmentChecklistItem(
                    title: String(format: DIRIOSLocalizer.string("equipment.checklist.check_cylinder"), cylinder.name),
                    isReady: false,
                    usesGas: true,
                    gasMixKind: cylinder.gas.mixKind,
                    gasText: cylinder.gas.name,
                    switchDepthMeters: cylinder.switchDepthMeters,
                    pressureText: Formatters.zero(cylinder.startPressureBar),
                    pressureUnit: .bar,
                    tankSize: cylinder.tankSize,
                    gasRole: cylinder.role,
                    kind: .equipment,
                    isRequired: true
                )
            )
            items.append(
                EquipmentChecklistItem(
                    title: String(format: DIRIOSLocalizer.string("equipment.checklist.analyze_gas"), cylinder.displayGasLabel),
                    isReady: false,
                    kind: .gas,
                    isRequired: true
                )
            )
            items.append(
                EquipmentChecklistItem(
                    title: String(format: DIRIOSLocalizer.string("equipment.checklist.verify_mod"), cylinder.displayGasLabel),
                    isReady: false,
                    kind: .gas,
                    isRequired: true
                )
            )
            items.append(
                EquipmentChecklistItem(
                    title: String(format: DIRIOSLocalizer.string("equipment.checklist.verify_pressure"), cylinder.name),
                    isReady: false,
                    kind: .gas,
                    isRequired: true
                )
            )
        }

        items.append(
            EquipmentChecklistItem(
                title: DIRIOSLocalizer.string("checklist.quick.confirm_rock_bottom"),
                isReady: false,
                kind: .task,
                isRequired: true
            )
        )
        items.append(
            EquipmentChecklistItem(
                title: DIRIOSLocalizer.string("checklist.quick.confirm_team_plan"),
                isReady: false,
                kind: .task,
                isRequired: true
            )
        )
        items.append(
            EquipmentChecklistItem(
                title: DIRIOSLocalizer.string("checklist.quick.bubble_check"),
                isReady: false,
                kind: .safety,
                isRequired: true
            )
        )
        items.append(
            EquipmentChecklistItem(
                title: DIRIOSLocalizer.string("checklist.quick.send_watch_briefing"),
                isReady: false,
                kind: .task,
                isRequired: false
            )
        )

        switch profile.setupMode {
        case .technicalOC, .dirTwinset, .sidemount:
            items.append(
                EquipmentChecklistItem(
                    title: DIRIOSLocalizer.string("checklist.quick.valve_drill"),
                    isReady: false,
                    kind: .safety,
                    isRequired: true
                )
            )
        case .ccrAirDiluent, .ccrTrimix:
            items.append(
                EquipmentChecklistItem(
                    title: DIRIOSLocalizer.string("checklist.template.pre_breathe"),
                    isReady: false,
                    kind: .safety,
                    isRequired: true
                )
            )
            items.append(
                EquipmentChecklistItem(
                    title: DIRIOSLocalizer.string("checklist.template.verify_scrubber_time"),
                    isReady: false,
                    kind: .task,
                    isRequired: true
                )
            )
            items.append(
                EquipmentChecklistItem(
                    title: DIRIOSLocalizer.string("checklist.template.verify_o2_sensors"),
                    isReady: false,
                    kind: .gas,
                    isRequired: true
                )
            )
            items.append(
                EquipmentChecklistItem(
                    title: DIRIOSLocalizer.string("checklist.template.confirm_bailout_plan"),
                    isReady: false,
                    kind: .task,
                    isRequired: true
                )
            )
        case .recreationalOC, .custom:
            break
        }

        for maintenance in profile.maintenanceItems where maintenance.isRequired && !maintenance.isCompleted {
            let status = EquipmentStructuredSupport.maintenanceStatus(for: maintenance)
            guard status == .overdue || status == .dueSoon else { continue }
            items.append(
                EquipmentChecklistItem(
                    title: String(format: DIRIOSLocalizer.string("equipment.checklist.maintenance_task"), maintenance.title),
                    isReady: false,
                    kind: .task,
                    isRequired: true
                )
            )
        }

        return items
    }

    static func merge(
        generated: [EquipmentChecklistItem],
        into existing: [EquipmentChecklistItem],
        strategy: ChecklistMergeStrategy
    ) -> [EquipmentChecklistItem] {
        switch strategy {
        case .replace:
            return generated
        case .appendMissing:
            var result = existing
            let existingKeys = Set(existing.map {
                EquipmentStructuredSupport.normalizedChecklistKey(title: $0.title, kind: $0.kind)
            })
            for item in generated {
                let key = EquipmentStructuredSupport.normalizedChecklistKey(title: item.title, kind: item.kind)
                guard !existingKeys.contains(key) else { continue }
                result.append(item)
            }
            return result
        }
    }
}
