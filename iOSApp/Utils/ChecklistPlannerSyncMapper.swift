import Foundation

/// Fingerprints gas cylinders for deduplication between Checklist and Planner.
struct ChecklistPlannerGasFingerprint: Hashable {
    let tankSize: TankSize
    let role: GasRole?
    let oxygenPercent: Int
    let heliumPercent: Int
    let pressureUnit: PressureUnit
}

enum ChecklistPlannerDuplicateAction: String, CaseIterable, Identifiable {
    case skip
    case replace

    var id: String { rawValue }
}

struct ChecklistPlannerImportCandidate: Identifiable {
    let id: UUID
    let checklistItem: EquipmentChecklistItem
    var assignedRole: GasRole?
    var isSelected: Bool
    let duplicatePlannerIndex: Int?
    var duplicateAction: ChecklistPlannerDuplicateAction

    var needsRoleAssignment: Bool { assignedRole == nil }
}

struct ChecklistPlannerExportCandidate: Identifiable {
    let id: UUID
    let cylinder: PlannerCylinderEntry
    var isSelected: Bool
    let duplicateChecklistIndex: Int?
    var duplicateAction: ChecklistPlannerDuplicateAction
}

struct CCRChecklistExportCandidate: Identifiable {
    let id: UUID
    var item: EquipmentChecklistItem
    var isSelected: Bool
}

enum ChecklistPlannerSyncMapper {
    static func checklistGasItems(from checklist: [EquipmentChecklistItem]) -> [EquipmentChecklistItem] {
        checklist.filter(\.usesGas)
    }

    static func importCandidates(
        checklist: [EquipmentChecklistItem],
        plannerCylinders: [PlannerCylinderEntry]
    ) -> [ChecklistPlannerImportCandidate] {
        checklistGasItems(from: checklist).map { item in
            let role = resolvedRole(for: item)
            let duplicateIndex = role.flatMap { findMatchingPlannerIndex(for: item, role: $0, in: plannerCylinders) }
            return ChecklistPlannerImportCandidate(
                id: item.id,
                checklistItem: item,
                assignedRole: role,
                isSelected: true,
                duplicatePlannerIndex: duplicateIndex,
                duplicateAction: duplicateIndex == nil ? .skip : .replace
            )
        }
    }

    /// Default duplicate handling: import replaces planner cylinders; export replaces checklist rows.
    /// `.skip` leaves the existing row/cylinder unchanged when the user keeps the default.

    static func exportCandidates(
        plannerCylinders: [PlannerCylinderEntry],
        checklist: [EquipmentChecklistItem]
    ) -> [ChecklistPlannerExportCandidate] {
        plannerCylinders.map { cylinder in
            let duplicateIndex = findMatchingChecklistIndex(for: cylinder, in: checklist)
            return ChecklistPlannerExportCandidate(
                id: cylinder.id,
                cylinder: cylinder,
                isSelected: true,
                duplicateChecklistIndex: duplicateIndex,
                duplicateAction: duplicateIndex == nil ? .skip : .replace
            )
        }
    }

    static func cylindersMissingFromChecklist(
        plannerCylinders: [PlannerCylinderEntry],
        checklist: [EquipmentChecklistItem]
    ) -> [PlannerCylinderEntry] {
        plannerCylinders.filter { cylinder in
            findMatchingChecklistIndex(for: cylinder, in: checklist) == nil
        }
    }

    static func applyImport(
        candidates: [ChecklistPlannerImportCandidate],
        to plannerCylinders: inout [PlannerCylinderEntry],
        environment: PlannerEnvironment
    ) {
        for candidate in candidates where candidate.isSelected {
            guard let role = candidate.assignedRole ?? resolvedRole(for: candidate.checklistItem) else { continue }
            let imported = plannerCylinder(from: candidate.checklistItem, role: role, environment: environment)
            if let duplicateIndex = candidate.duplicatePlannerIndex,
               plannerCylinders.indices.contains(duplicateIndex) {
                guard candidate.duplicateAction == .replace else { continue }
                var replacement = imported
                replacement.id = plannerCylinders[duplicateIndex].id
                plannerCylinders[duplicateIndex] = replacement
            } else if candidate.duplicatePlannerIndex == nil {
                plannerCylinders.append(imported)
            }
        }
    }

    static func applyExport(
        candidates: [ChecklistPlannerExportCandidate],
        to checklist: inout [EquipmentChecklistItem]
    ) {
        for candidate in candidates where candidate.isSelected {
            let item = checklistItem(from: candidate.cylinder)
            if let duplicateIndex = candidate.duplicateChecklistIndex,
               checklist.indices.contains(duplicateIndex) {
                guard candidate.duplicateAction == .replace else { continue }
                var replacement = item
                replacement.id = checklist[duplicateIndex].id
                replacement.isReady = checklist[duplicateIndex].isReady
                checklist[duplicateIndex] = replacement
            } else if candidate.duplicateChecklistIndex == nil {
                checklist.append(item)
            }
        }
    }

    static func ccrChecklistItems(from input: CCRPlanInput) -> [EquipmentChecklistItem] {
        var items: [EquipmentChecklistItem] = [
            EquipmentChecklistItem(
                title: String(localized: "equipment.ccr.diluent_cylinder"),
                isReady: false,
                usesGas: true,
                gasMixKind: input.diluent.mixKind,
                gasText: input.diluent.label,
                gasRole: .ccrDiluent
            )
        ]
        for (index, bailout) in input.bailoutGases.enumerated() {
            items.append(
                EquipmentChecklistItem(
                    title: String(format: String(localized: "equipment.ccr.bailout_number"), index + 1),
                    isReady: false,
                    usesGas: true,
                    gasMixKind: bailout.mixKind,
                    gasText: bailout.label,
                    switchDepthMeters: bailout.switchDepthMeters,
                    tankSize: bailout.tankSize,
                    gasRole: .ccrBailout
                )
            )
        }
        return items
    }

    static func ccrItemsMissingFromChecklist(input: CCRPlanInput, checklist: [EquipmentChecklistItem]) -> [EquipmentChecklistItem] {
        ccrChecklistItems(from: input).filter { proposed in
            guard let role = proposed.gasRole else { return true }
            return !checklist.contains { existing in
                existing.usesGas && existing.gasRole == role
                    && existing.gasText.caseInsensitiveCompare(proposed.gasText) == .orderedSame
            }
        }
    }

    static func hasCCRChecklistItemsMissing(input: CCRPlanInput, checklist: [EquipmentChecklistItem]) -> Bool {
        !ccrItemsMissingFromChecklist(input: input, checklist: checklist).isEmpty
    }

    static func ccrExportCandidates(input: CCRPlanInput, checklist: [EquipmentChecklistItem]) -> [CCRChecklistExportCandidate] {
        ccrChecklistItems(from: input).map {
            CCRChecklistExportCandidate(id: $0.id, item: $0, isSelected: true)
        }
    }

    static func applyCCRExport(input: CCRPlanInput, to checklist: inout [EquipmentChecklistItem]) {
        applyCCRChecklistItems(ccrChecklistItems(from: input), to: &checklist)
    }

    static func applyCCRExport(candidates: [CCRChecklistExportCandidate], to checklist: inout [EquipmentChecklistItem]) {
        let selected = candidates.filter(\.isSelected).map(\.item)
        guard !selected.isEmpty else { return }
        applyCCRChecklistItems(selected, to: &checklist)
    }

    private static func applyCCRChecklistItems(_ proposed: [EquipmentChecklistItem], to checklist: inout [EquipmentChecklistItem]) {
        let bailoutIndices = checklist.indices.filter { checklist[$0].usesGas && checklist[$0].gasRole == .ccrBailout }
        var bailoutCursor = 0

        for item in proposed {
            guard let role = item.gasRole else { continue }
            let matchIndex: Int?
            switch role {
            case .ccrDiluent:
                matchIndex = checklist.firstIndex(where: { $0.usesGas && $0.gasRole == .ccrDiluent })
            case .ccrBailout:
                if bailoutCursor < bailoutIndices.count {
                    matchIndex = bailoutIndices[bailoutCursor]
                    bailoutCursor += 1
                } else {
                    matchIndex = nil
                }
            default:
                matchIndex = checklist.firstIndex(where: { $0.usesGas && $0.gasRole == role })
            }

            if let index = matchIndex {
                var replacement = item
                replacement.id = checklist[index].id
                replacement.isReady = checklist[index].isReady
                checklist[index] = replacement
            } else {
                checklist.append(item)
            }
        }
    }

    static func resolvedRole(for item: EquipmentChecklistItem) -> GasRole? {
        if let role = item.gasRole { return role }
        return inferRole(from: item.title)
    }

    static func fingerprint(for item: EquipmentChecklistItem, role: GasRole) -> ChecklistPlannerGasFingerprint {
        let mix = gasMix(from: item, role: role)
        return ChecklistPlannerGasFingerprint(
            tankSize: item.tankSize,
            role: role,
            oxygenPercent: Int((mix.oxygen * 100).rounded()),
            heliumPercent: Int((mix.helium * 100).rounded()),
            pressureUnit: item.pressureUnit
        )
    }

    static func fingerprint(for entry: PlannerCylinderEntry) -> ChecklistPlannerGasFingerprint {
        ChecklistPlannerGasFingerprint(
            tankSize: entry.tankSize,
            role: entry.role,
            oxygenPercent: Int((entry.gas.oxygen * 100).rounded()),
            heliumPercent: Int((entry.gas.helium * 100).rounded()),
            pressureUnit: entry.pressureUnit
        )
    }

    static func findMatchingPlannerIndex(
        for item: EquipmentChecklistItem,
        role: GasRole,
        in cylinders: [PlannerCylinderEntry]
    ) -> Int? {
        let target = fingerprint(for: item, role: role)
        return cylinders.firstIndex { fingerprint(for: $0) == target }
    }

    static func findMatchingChecklistIndex(
        for entry: PlannerCylinderEntry,
        in checklist: [EquipmentChecklistItem]
    ) -> Int? {
        let target = fingerprint(for: entry)
        return checklist.firstIndex { item in
            guard item.usesGas, let role = resolvedRole(for: item) else { return false }
            return fingerprint(for: item, role: role) == target
        }
    }

    static func plannerCylinder(
        from item: EquipmentChecklistItem,
        role: GasRole,
        environment: PlannerEnvironment
    ) -> PlannerCylinderEntry {
        var gas = gasMix(from: item, role: role)
        gas.role = role
        var entry = PlannerCylinderEntry(
            role: role,
            tankSize: item.tankSize,
            gas: gas,
            startPressure: startPressure(from: item),
            reservePressure: 50,
            pressureUnit: item.pressureUnit
        )
        if role != .bottom {
            entry.updateSwitchDepthAfterGasOrPPO2Change(environment: environment, shouldInitializeToMOD: true)
            if let switchDepth = item.switchDepthMeters, switchDepth.isFinite, switchDepth > 0 {
                entry.switchDepthMeters = switchDepth
            }
        }
        return entry
    }

    static func checklistItem(from entry: PlannerCylinderEntry) -> EquipmentChecklistItem {
        EquipmentChecklistItem(
            title: checklistTitle(for: entry),
            isReady: false,
            usesGas: true,
            gasMixKind: entry.gas.mixKind,
            gasText: entry.gas.label,
            switchDepthMeters: entry.role == .bottom ? nil : entry.switchDepthMeters,
            pressureText: pressureText(from: entry),
            pressureUnit: entry.pressureUnit,
            tankSize: entry.tankSize,
            gasRole: entry.role
        )
    }

    static func gasMix(from item: EquipmentChecklistItem, role: GasRole) -> GasMix {
        var oxygen = 0.21
        var helium = 0.0
        parseComposition(from: item.gasText, mixKind: item.gasMixKind, oxygen: &oxygen, helium: &helium)
        if item.gasText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            switch item.gasMixKind {
            case .air:
                oxygen = 0.21
                helium = 0
            case .ean:
                oxygen = max(oxygen, 0.32)
            case .trimix:
                if oxygen <= 0.21, helium <= 0 {
                    oxygen = 0.18
                    helium = 0.45
                }
            case .oxygen:
                oxygen = 1.0
                helium = 0
            }
        }
        var resolvedKind = item.gasMixKind
        if resolvedKind == .ean, oxygen > 0.985 { resolvedKind = .oxygen }
        let name = item.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Gas" : item.title
        var mix = GasMix(
            name: name,
            role: role,
            mixKind: resolvedKind,
            oxygen: oxygen,
            helium: helium,
            maxPPO2: defaultMaxPPO2(for: role)
        )
        mix.normalizeMixAndPPO2()
        return mix
    }

    private static func checklistTitle(for entry: PlannerCylinderEntry) -> String {
        let roleLabel = entry.role.localizedTitle
        return "\(roleLabel) · \(entry.gas.label)"
    }

    private static func pressureText(from entry: PlannerCylinderEntry) -> String {
        Formatters.zero(entry.startPressure)
    }

    private static func startPressure(from item: EquipmentChecklistItem) -> Double {
        let trimmed = item.pressureText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        guard let value = Double(trimmed), value.isFinite, value > 0 else { return 200 }
        return value
    }

    private static func defaultMaxPPO2(for role: GasRole) -> Double {
        switch role {
        case .bottom, .travel, .ccrDiluent: return 1.4
        case .deco, .bailout, .ccrBailout: return 1.6
        }
    }

    private static func inferRole(from title: String) -> GasRole? {
        let lower = title.lowercased()
        if lower.contains("diluent") || lower.contains("diluente") || lower.contains("mav diluent") || lower.contains("bombola diluente") {
            if lower.contains("ccr") || lower.contains("rebreather") || lower.contains("rebreat") || lower.contains("mav") {
                return .ccrDiluent
            }
        }
        if lower.contains("bailout") || lower.contains("emerg") || lower.contains("emergenza") {
            if lower.contains("ccr") || lower.contains("rebreather") || lower.hasPrefix("bailout ") || lower.contains("offboard") {
                return .ccrBailout
            }
            return .bailout
        }
        if lower.contains("travel") || lower.contains("viaggio") { return .travel }
        if lower.contains("deco") || lower.contains("stage") || lower.contains("decompression") { return .deco }
        if lower.contains("back") || lower.contains("bottom") || lower.contains("fondo") { return .bottom }
        return nil
    }

    private static func parseComposition(
        from text: String,
        mixKind: GasMixKind,
        oxygen: inout Double,
        helium: inout Double
    ) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let upper = trimmed.uppercased()

        if upper.contains("O2") && !upper.contains("EAN") {
            oxygen = 1.0
            helium = 0
            return
        }

        if let ean = upper.range(of: #"EAN\s*(\d{2,3})"#, options: .regularExpression) {
            let digits = upper[ean].filter(\.isNumber)
            if let value = Double(digits) {
                oxygen = min(max(value / 100.0, 0.10), 1.0)
                helium = 0
                return
            }
        }

        if let trimix = upper.range(of: #"(\d{1,2})\s*/\s*(\d{1,2})"#, options: .regularExpression) {
            let parts = upper[trimix].split(separator: "/").map { $0.filter(\.isNumber) }
            if parts.count == 2,
               let o2 = Double(parts[0]),
               let he = Double(parts[1]) {
                oxygen = min(max(o2 / 100.0, 0.10), 1.0)
                helium = min(max(he / 100.0, 0), 1.0 - oxygen)
                return
            }
        }

        if mixKind == .air {
            oxygen = 0.21
            helium = 0
        }
    }
}
