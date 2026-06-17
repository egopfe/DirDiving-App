import Foundation

enum EquipmentStructuredSupport {
    static let dueSoonWindowDays = 30

    static func maintenanceStatus(for item: EquipmentMaintenanceItem, now: Date = Date()) -> EquipmentMaintenanceStatus {
        guard !item.isCompleted, let dueDate = item.dueDate else { return .ok }
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: now)
        let startOfDue = calendar.startOfDay(for: dueDate)
        if startOfDue < startOfToday { return .overdue }
        if let soonLimit = calendar.date(byAdding: .day, value: dueSoonWindowDays, to: startOfToday),
           startOfDue <= soonLimit {
            return .dueSoon
        }
        return .ok
    }

    static func legacyDerivedCylinders(from profile: EquipmentProfile) -> [EquipmentGasCylinder] {
        var cylinders: [EquipmentGasCylinder] = []
        if !profile.bottomGas.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            cylinders.append(
                EquipmentGasCylinder(
                    name: profile.bottomGas,
                    role: .bottom,
                    tankSize: .liters12,
                    gas: defaultBottomGas(named: profile.bottomGas),
                    startPressureBar: 200,
                    reservePressureBar: 50
                )
            )
        }
        if !profile.decoGas1.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            cylinders.append(
                EquipmentGasCylinder(
                    name: profile.decoGas1,
                    role: .deco,
                    tankSize: .liters12,
                    gas: defaultDecoGas(named: profile.decoGas1, oxygen: 0.5),
                    startPressureBar: 200,
                    reservePressureBar: 50,
                    switchDepthMeters: 21
                )
            )
        }
        if !profile.decoGas2.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            cylinders.append(
                EquipmentGasCylinder(
                    name: profile.decoGas2,
                    role: .deco,
                    tankSize: .liters12,
                    gas: defaultDecoGas(named: profile.decoGas2, oxygen: 0.8),
                    startPressureBar: 200,
                    reservePressureBar: 50,
                    switchDepthMeters: 9
                )
            )
        }
        return cylinders
    }

    static func defaultBottomGas(named label: String) -> GasMix {
        GasMix(name: label, role: .bottom, mixKind: .trimix, oxygen: 0.18, helium: 0.45, maxPPO2: 1.4)
    }

    static func defaultDecoGas(named label: String, oxygen: Double) -> GasMix {
        GasMix(name: label, role: .deco, mixKind: .ean, oxygen: oxygen, helium: 0, maxPPO2: 1.6)
    }

    static func normalizedChecklistKey(title: String, kind: ChecklistItemKind) -> String {
        let normalized = title
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
        return "\(kind.rawValue)|\(normalized)"
    }

    static func syncLegacySummary(from profile: inout EquipmentProfile) {
        guard profile.hasStructuredSetup else { return }
        let enabled = profile.enabledCylinders
        guard !enabled.isEmpty else { return }

        let tankSummary = enabled.map(\.tankSize.rawValue).joined(separator: " + ")
        if !tankSummary.isEmpty {
            profile.cylinders = tankSummary
        }
        if let bottom = enabled.first(where: { $0.role == .bottom }) {
            profile.bottomGas = bottom.displayGasLabel
        }
        let deco = enabled.filter { $0.role == .deco }.sorted { ($0.switchDepthMeters ?? 0) > ($1.switchDepthMeters ?? 0) }
        if deco.indices.contains(0) { profile.decoGas1 = deco[0].displayGasLabel }
        if deco.indices.contains(1) { profile.decoGas2 = deco[1].displayGasLabel }
        if !profile.configuration.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // preserve user configuration text
        } else {
            profile.configuration = profile.setupMode.localizedTitle
        }
    }
}

extension EquipmentGasCylinder {
    var displayGasLabel: String {
        let trimmed = gas.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? name : trimmed
    }
}

extension EquipmentProfile {
    var hasStructuredSetup: Bool {
        !structuredCylinders.isEmpty
    }

    var effectiveCylinders: [EquipmentGasCylinder] {
        if !structuredCylinders.isEmpty { return structuredCylinders }
        return EquipmentStructuredSupport.legacyDerivedCylinders(from: self)
    }

    var enabledCylinders: [EquipmentGasCylinder] {
        effectiveCylinders.filter(\.isEnabled)
    }

    var activeGasSummary: String {
        let labels = enabledCylinders.map(\.displayGasLabel)
        guard !labels.isEmpty else {
            return [bottomGas, decoGas1, decoGas2]
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .joined(separator: " · ")
        }
        return labels.joined(separator: " · ")
    }

    var setupCompletenessNeedsAttention: Bool {
        if enabledCylinders.isEmpty { return true }
        if enabledCylinders.contains(where: { !$0.isPressureValid || !$0.isSwitchDepthValid }) { return true }
        if maintenanceItems.contains(where: {
            EquipmentStructuredSupport.maintenanceStatus(for: $0) != .ok
        }) { return true }
        return false
    }
}
