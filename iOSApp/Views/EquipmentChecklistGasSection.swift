import SwiftUI

struct EquipmentChecklistGasSection: View {
    @Binding var item: EquipmentChecklistItem

    var body: some View {
        if item.usesGas {
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
            }
            .font(.callout)
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
            .font(.callout)
        }
    }
}
