import SwiftUI

struct EquipmentChecklistGasSection: View {
    @Binding var item: EquipmentChecklistItem

    private var resolvedRole: GasRole {
        item.gasRole ?? ChecklistPlannerSyncMapper.resolvedRole(for: item) ?? .bottom
    }

    private var showsSwitchDepth: Bool {
        item.usesGas && (resolvedRole == .deco || resolvedRole == .travel)
    }

    var body: some View {
        if item.usesGas {
            VStack(alignment: .leading, spacing: DIRTheme.spaceS) {
            HStack {
                Text(String(localized: "equipment.checklist.gas_type"))
                    .foregroundStyle(DIRTheme.muted)
                Spacer()
                Picker("", selection: $item.gasMixKind) {
                    ForEach(GasMixKind.allCases) { kind in
                        Text(kind.localizedTitle).tag(kind)
                    }
                }
                .labelsHidden()
                .tint(DIRTheme.cyan)
                .accessibilityLabel(String(localized: "equipment.picker.gas_type.a11y"))
            }
            .font(.callout)
            HStack {
                Text(String(localized: "checklist_planner.sync.select_gas_role"))
                    .foregroundStyle(DIRTheme.muted)
                Spacer()
                Picker("", selection: Binding(
                    get: { item.gasRole ?? .bottom },
                    set: { item.gasRole = $0 }
                )) {
                    ForEach(GasRole.allCases) { role in
                        Text(role.localizedTitle).tag(role)
                    }
                }
                .labelsHidden()
                .tint(DIRTheme.cyan)
            }
            .font(.callout)
            HStack {
                Text(String(localized: "equipment.checklist.gas_composition"))
                    .foregroundStyle(DIRTheme.muted)
                TextField(String(localized: "equipment.checklist.gas_composition_placeholder"), text: $item.gasText)
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.white)
                    .tint(DIRTheme.cyan)
            }
            .font(DIRTypography.body)
            if showsSwitchDepth {
                switchDepthRow
            }
            HStack {
                Text(String(localized: "equipment.checklist.pressure_unit"))
                    .foregroundStyle(DIRTheme.muted)
                Spacer()
                Picker("", selection: $item.pressureUnit) {
                    ForEach(PressureUnit.allCases) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }
                .labelsHidden()
                .tint(DIRTheme.cyan)
                .accessibilityLabel(String(localized: "equipment.picker.pressure_unit.a11y"))
            }
            .font(.callout)
            HStack {
                Text(String(localized: "equipment.checklist.tank_size"))
                    .foregroundStyle(DIRTheme.muted)
                Spacer()
                Picker("", selection: $item.tankSize) {
                    ForEach(TankSize.allCases) { size in
                        Text(size.rawValue).tag(size)
                    }
                }
                .labelsHidden()
                .tint(DIRTheme.cyan)
                .accessibilityLabel(String(localized: "equipment.picker.tank_size.a11y"))
            }
            .font(.callout)
            HStack {
                Text(item.pressureUnit == .bar ? String(localized: "equipment.checklist.bar") : String(localized: "equipment.checklist.psi"))
                    .foregroundStyle(DIRTheme.muted)
                TextField(String(localized: "equipment.checklist.pressure"), text: $item.pressureText)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                    .foregroundStyle(.white)
                    .tint(DIRTheme.cyan)
            }
            .font(DIRTypography.body)
            }
            .padding(DIRTheme.spaceM)
            .background(
                RoundedRectangle(cornerRadius: DIRTheme.compactRadius, style: .continuous)
                    .fill(DIRTheme.surface.opacity(0.65))
                    .overlay(
                        RoundedRectangle(cornerRadius: DIRTheme.compactRadius, style: .continuous)
                            .stroke(DIRTheme.yellow.opacity(0.35), lineWidth: 1)
                    )
            )
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    private var switchDepthRow: some View {
        HStack {
            Text(String(localized: "equipment.checklist.switch_depth"))
                .foregroundStyle(DIRTheme.muted)
            TextField(
                String(localized: "equipment.checklist.switch_depth_placeholder"),
                text: Binding(
                    get: {
                        guard let meters = item.switchDepthMeters else { return "" }
                        return Formatters.zero(meters)
                    },
                    set: { newValue in
                        let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".")
                        if trimmed.isEmpty {
                            item.switchDepthMeters = nil
                        } else if let value = Double(trimmed), value.isFinite, value > 0 {
                            item.switchDepthMeters = value
                        }
                    }
                )
            )
            .multilineTextAlignment(.trailing)
            .keyboardType(.decimalPad)
            .foregroundStyle(.white)
            .tint(DIRTheme.cyan)
            Text(String(localized: "equipment.checklist.switch_depth_unit"))
                .foregroundStyle(DIRTheme.muted)
        }
        .font(DIRTypography.body)
    }
}
