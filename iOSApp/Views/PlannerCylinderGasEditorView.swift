import SwiftUI

struct PlannerGasWheelPickerSheet<Value: Hashable>: View {
    let title: String
    let values: [Value]
    @Binding var selection: Value
    let valueLabel: (Value) -> String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    @State private var draft: Value

    init(
        title: String,
        values: [Value],
        selection: Binding<Value>,
        valueLabel: @escaping (Value) -> String,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.title = title
        self.values = values
        self._selection = selection
        self.valueLabel = valueLabel
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        _draft = State(initialValue: selection.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.white.opacity(0.25))
                .frame(width: 36, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 14)

            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.bottom, 8)

            Picker("", selection: $draft) {
                ForEach(values, id: \.self) { value in
                    Text(valueLabel(value))
                        .tag(value)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .frame(maxWidth: .infinity)
            .tint(DIRTheme.cyan)

            Button {
                selection = draft
                onConfirm()
            } label: {
                Text(DIRIOSLocalizer.string("planner.gas.editor.confirm"))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: 12).fill(DIRTheme.cyan.opacity(0.92)))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.top, 8)

            Button(DIRIOSLocalizer.string("planner.gas.editor.cancel"), role: .cancel) {
                onCancel()
            }
            .font(.callout.weight(.semibold))
            .foregroundStyle(DIRTheme.muted)
            .padding(.vertical, 12)
        }
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity)
        .background(DIRTheme.surface2.ignoresSafeArea())
        .presentationDetents([.height(340)])
        .presentationDragIndicator(.hidden)
        .presentationBackground(DIRTheme.surface2)
    }
}

enum PlannerGasPickerField: Identifiable {
    case mixKind
    case tankSize
    case role
    case oxygen
    case helium
    case maxPPO2
    case workingPressure

    var id: String {
        switch self {
        case .mixKind: return "mixKind"
        case .tankSize: return "tankSize"
        case .role: return "role"
        case .oxygen: return "oxygen"
        case .helium: return "helium"
        case .maxPPO2: return "maxPPO2"
        case .workingPressure: return "workingPressure"
        }
    }
}

struct PlannerCylinderGasEditorView: View {
    @Binding var entry: PlannerCylinderEntry
    let cylinderNumber: Int
    let plannerMode: PlannerMode
    let allowedMixKinds: [GasMixKind]
    let unitPreference: IOSUnitPreference
    let plannerEnvironment: PlannerEnvironment
    let plannedDepthMeters: Double
    var showsRoleEditor: Bool
    var showsTankEditor: Bool
    var switchDepthMeters: Binding<Double>?
    var maxSwitchDepthMeters: Double?
    let onGasOrPPO2Changed: () -> Void
    let onPressureChanged: () -> Void

    @State private var activePicker: PlannerGasPickerField?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(DIRIOSLocalizer.formatted("planner.gas.editor.cylinder_section", cylinderNumber))
                .font(.caption.weight(.semibold))
                .foregroundStyle(DIRTheme.muted)
                .textCase(.uppercase)

            groupedCard {
                editorRow(
                    label: DIRIOSLocalizer.string("planner.gas.editor.mix_type"),
                    value: entry.gas.mixKind.plannerPickerTitle,
                    editable: true
                ) { activePicker = .mixKind }

                rowDivider()

                if showsTankEditor {
                    editorRow(
                        label: DIRIOSLocalizer.string("planner.gas.editor.cylinder"),
                        value: entry.tankSize.rawValue,
                        editable: true
                    ) { activePicker = .tankSize }
                    rowDivider()
                }

                if showsRoleEditor {
                    editorRow(
                        label: DIRIOSLocalizer.string("planner.gas.editor.role"),
                        value: entry.role.localizedTitle,
                        editable: true
                    ) { activePicker = .role }
                } else {
                    editorRow(
                        label: DIRIOSLocalizer.string("planner.gas.editor.role"),
                        value: entry.role.localizedTitle,
                        editable: false
                    ) {}
                }
            }

            groupedCard {
                editorRow(
                    label: DIRIOSLocalizer.string("planner.gas.oxygen"),
                    value: "\(PlannerGasEditingSupport.oxygenPercent(from: entry.gas)) %",
                    editable: entry.gas.canEditOxygen
                ) {
                    if entry.gas.canEditOxygen { activePicker = .oxygen }
                }

                rowDivider()

                editorRow(
                    label: DIRIOSLocalizer.string("planner.gas.helium"),
                    value: "\(PlannerGasEditingSupport.heliumPercent(from: entry.gas)) %",
                    editable: entry.gas.canEditHelium
                ) {
                    if entry.gas.canEditHelium { activePicker = .helium }
                }

                rowDivider()

                editorRow(
                    label: DIRIOSLocalizer.string("planner.gas.nitrogen"),
                    value: "\(PlannerGasEditingSupport.nitrogenPercent(from: entry.gas)) %",
                    editable: false
                ) {}

                rowDivider()

                editorRow(
                    label: DIRIOSLocalizer.string("planner.gas.ppo2_max"),
                    value: Formatters.one(entry.gas.maxPPO2),
                    editable: true
                ) { activePicker = .maxPPO2 }

                rowDivider()

                editorRow(
                    label: DIRIOSLocalizer.string("planner.gas.editor.mod"),
                    value: modDisplayText,
                    editable: false
                ) {}
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(DIRIOSLocalizer.string("planner.gas.editor.working_pressure_section"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DIRTheme.muted)
                    .textCase(.uppercase)

                Picker("", selection: pressureUnitBinding) {
                    ForEach(PressureUnit.allCases) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
                .tint(DIRTheme.cyan)

                groupedCard {
                    editorRow(
                        label: entry.pressureUnit.rawValue,
                        value: workingPressureDisplay,
                        editable: true
                    ) { activePicker = .workingPressure }
                }
            }

            if let switchDepthMeters, entry.role != .bottom {
                switchDepthEditor(binding: switchDepthMeters)
            }

            modStatusCard
        }
        .sheet(item: $activePicker) { field in
            pickerSheet(for: field)
        }
    }

    private var modDisplayText: String {
        Formatters.depth(
            PlannerGasEditingSupport.modMeters(for: entry.gas, environment: plannerEnvironment),
            units: unitPreference
        ).text
    }

    private var workingPressureDisplay: String {
        let value = PlannerGasEditingSupport.nearestWorkingPressure(entry.startPressure, unit: entry.pressureUnit)
        return "\(value) \(entry.pressureUnit.rawValue.lowercased())"
    }

    private var pressureUnitBinding: Binding<PressureUnit> {
        Binding(
            get: { entry.pressureUnit },
            set: { newUnit in
                PlannerGasEditingSupport.convertPressureUnit(on: &entry, to: newUnit)
                onPressureChanged()
            }
        )
    }

    private var modStatusCard: some View {
        let hasConflict = PlannerGasEditingSupport.hasMODConflict(
            entry: entry,
            plannedDepthMeters: plannedDepthMeters,
            environment: plannerEnvironment
        )
        return Group {
            if hasConflict {
                VStack(alignment: .leading, spacing: 6) {
                    Text(DIRIOSLocalizer.string("planner.gas.editor.mod_switch_exceeds_title"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(DIRTheme.red)
                    Text(DIRIOSLocalizer.string("planner.gas.editor.mod_switch_exceeds_message"))
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: DIRTheme.compactRadius)
                        .fill(DIRTheme.red.opacity(0.14))
                        .overlay(
                            RoundedRectangle(cornerRadius: DIRTheme.compactRadius)
                                .stroke(DIRTheme.red.opacity(0.45), lineWidth: 1)
                        )
                )
            } else if entry.gas.isValidMix {
                VStack(alignment: .leading, spacing: 6) {
                    Text(DIRIOSLocalizer.string("planner.gas.editor.mod_valid_title"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(DIRTheme.green)
                    Text(DIRIOSLocalizer.string("planner.gas.editor.mod_valid_message"))
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: DIRTheme.compactRadius)
                        .fill(DIRTheme.green.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: DIRTheme.compactRadius)
                                .stroke(DIRTheme.green.opacity(0.4), lineWidth: 1)
                        )
                )
            }
        }
    }

    @ViewBuilder
    private func switchDepthEditor(binding: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(DIRIOSLocalizer.string("planner.field.switch_depth"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(DIRTheme.muted)
            HStack {
                Text(Formatters.depth(binding.wrappedValue, units: unitPreference).text)
                    .font(.callout.monospacedDigit().weight(.semibold))
                    .foregroundStyle(DIRTheme.cyan)
                Spacer()
                if let maxSwitchDepthMeters {
                    Text(
                        String(
                            format: DIRIOSLocalizer.string("planner.gas.editor.switch_depth_max"),
                            Formatters.depth(maxSwitchDepthMeters, units: unitPreference).text
                        )
                    )
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
                }
            }
            Slider(
                value: binding,
                in: 0...(maxSwitchDepthMeters ?? binding.wrappedValue),
                step: 1
            )
            .tint(DIRTheme.cyan)
        }
    }

    @ViewBuilder
    private func pickerSheet(for field: PlannerGasPickerField) -> some View {
        switch field {
        case .mixKind:
            PlannerGasWheelPickerSheet(
                title: DIRIOSLocalizer.string("planner.gas.editor.mix_type"),
                values: allowedMixKinds,
                selection: mixKindSelection,
                valueLabel: { $0.plannerPickerTitle },
                onConfirm: {
                    activePicker = nil
                    onGasOrPPO2Changed()
                },
                onCancel: { activePicker = nil }
            )
        case .tankSize:
            PlannerGasWheelPickerSheet(
                title: DIRIOSLocalizer.string("planner.gas.editor.cylinder"),
                values: TankSize.allCases,
                selection: tankSizeSelection,
                valueLabel: { $0.rawValue },
                onConfirm: { activePicker = nil },
                onCancel: { activePicker = nil }
            )
        case .role:
            PlannerGasWheelPickerSheet(
                title: DIRIOSLocalizer.string("planner.gas.editor.role"),
                values: GasRole.allCases,
                selection: roleSelection,
                valueLabel: { $0.localizedTitle },
                onConfirm: {
                    activePicker = nil
                    onGasOrPPO2Changed()
                },
                onCancel: { activePicker = nil }
            )
        case .oxygen:
            PlannerGasWheelPickerSheet(
                title: DIRIOSLocalizer.string("planner.gas.oxygen"),
                values: PlannerGasEditingSupport.oxygenPercentValues,
                selection: oxygenSelection,
                valueLabel: { "\($0) %" },
                onConfirm: {
                    activePicker = nil
                    onGasOrPPO2Changed()
                },
                onCancel: { activePicker = nil }
            )
        case .helium:
            PlannerGasWheelPickerSheet(
                title: DIRIOSLocalizer.string("planner.gas.helium"),
                values: PlannerGasEditingSupport.heliumPercentValues(
                    oxygenPercent: PlannerGasEditingSupport.oxygenPercent(from: entry.gas)
                ),
                selection: heliumSelection,
                valueLabel: { "\($0) %" },
                onConfirm: {
                    activePicker = nil
                    onGasOrPPO2Changed()
                },
                onCancel: { activePicker = nil }
            )
        case .maxPPO2:
            PlannerGasWheelPickerSheet(
                title: DIRIOSLocalizer.string("planner.gas.ppo2_max"),
                values: PlannerGasEditingSupport.ppo2PickerValues,
                selection: maxPPO2Selection,
                valueLabel: { Formatters.one($0) },
                onConfirm: {
                    activePicker = nil
                    onGasOrPPO2Changed()
                },
                onCancel: { activePicker = nil }
            )
        case .workingPressure:
            PlannerGasWheelPickerSheet(
                title: DIRIOSLocalizer.string("planner.gas.editor.working_pressure_section"),
                values: PlannerGasEditingSupport.workingPressureValues(for: entry.pressureUnit),
                selection: workingPressureSelection,
                valueLabel: { "\($0) \(entry.pressureUnit.rawValue.lowercased())" },
                onConfirm: {
                    activePicker = nil
                    onPressureChanged()
                },
                onCancel: { activePicker = nil }
            )
        }
    }

    private var mixKindSelection: Binding<GasMixKind> {
        Binding(
            get: { entry.gas.mixKind },
            set: { entry.gas.applyMixKind($0) }
        )
    }

    private var tankSizeSelection: Binding<TankSize> {
        Binding(get: { entry.tankSize }, set: { entry.tankSize = $0 })
    }

    private var roleSelection: Binding<GasRole> {
        Binding(
            get: { entry.role },
            set: {
                entry.role = $0
                entry.gas.role = $0
            }
        )
    }

    private var oxygenSelection: Binding<Int> {
        Binding(
            get: { PlannerGasEditingSupport.oxygenPercent(from: entry.gas) },
            set: { entry.gas.setOxygenPercent($0) }
        )
    }

    private var heliumSelection: Binding<Int> {
        Binding(
            get: { PlannerGasEditingSupport.heliumPercent(from: entry.gas) },
            set: { entry.gas.setHeliumPercent($0) }
        )
    }

    private var maxPPO2Selection: Binding<Double> {
        Binding(
            get: { entry.gas.maxPPO2 },
            set: { entry.gas.setMaxPPO2($0) }
        )
    }

    private var workingPressureSelection: Binding<Int> {
        Binding(
            get: { PlannerGasEditingSupport.nearestWorkingPressure(entry.startPressure, unit: entry.pressureUnit) },
            set: { entry.startPressure = Double($0) }
        )
    }

    @ViewBuilder
    private func groupedCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(
            RoundedRectangle(cornerRadius: DIRTheme.compactRadius, style: .continuous)
                .fill(DIRTheme.surface2.opacity(0.95))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DIRTheme.compactRadius, style: .continuous)
                .stroke(DIRTheme.hairline, lineWidth: 1)
        )
    }

    private func rowDivider() -> some View {
        Divider().overlay(DIRTheme.hairline).padding(.leading, 14)
    }

    private func editorRow(
        label: String,
        value: String,
        editable: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(label)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Spacer(minLength: 8)
                Text(value)
                    .foregroundStyle(editable ? DIRTheme.cyan : DIRTheme.muted)
                    .monospacedDigit()
                    .lineLimit(1)
                if editable {
                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(DIRTheme.muted)
                }
            }
            .font(.callout)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!editable)
    }
}

/// Full-screen cylinder gas editor sheet with navigation chrome (mockup back / title / save).
struct PlannerCylinderGasEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var entry: PlannerCylinderEntry
    let cylinderNumber: Int
    let plannerMode: PlannerMode
    let allowedMixKinds: [GasMixKind]
    let unitPreference: IOSUnitPreference
    let plannerEnvironment: PlannerEnvironment
    let plannedDepthMeters: Double
    var showsRoleEditor: Bool
    var showsTankEditor: Bool
    var switchDepthMeters: Binding<Double>?
    var maxSwitchDepthMeters: Double?
    let onSave: () -> Void

    @State private var draft: PlannerCylinderEntry

    init(
        entry: Binding<PlannerCylinderEntry>,
        cylinderNumber: Int,
        plannerMode: PlannerMode,
        allowedMixKinds: [GasMixKind],
        unitPreference: IOSUnitPreference,
        plannerEnvironment: PlannerEnvironment,
        plannedDepthMeters: Double,
        showsRoleEditor: Bool,
        showsTankEditor: Bool,
        switchDepthMeters: Binding<Double>? = nil,
        maxSwitchDepthMeters: Double? = nil,
        onSave: @escaping () -> Void
    ) {
        self._entry = entry
        self.cylinderNumber = cylinderNumber
        self.plannerMode = plannerMode
        self.allowedMixKinds = allowedMixKinds
        self.unitPreference = unitPreference
        self.plannerEnvironment = plannerEnvironment
        self.plannedDepthMeters = plannedDepthMeters
        self.showsRoleEditor = showsRoleEditor
        self.showsTankEditor = showsTankEditor
        self.switchDepthMeters = switchDepthMeters
        self.maxSwitchDepthMeters = maxSwitchDepthMeters
        self.onSave = onSave
        _draft = State(initialValue: entry.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            DIRScreenContainer {
                ScrollView(showsIndicators: false) {
                    PlannerCylinderGasEditorView(
                        entry: $draft,
                        cylinderNumber: cylinderNumber,
                        plannerMode: plannerMode,
                        allowedMixKinds: allowedMixKinds,
                        unitPreference: unitPreference,
                        plannerEnvironment: plannerEnvironment,
                        plannedDepthMeters: plannedDepthMeters,
                        showsRoleEditor: showsRoleEditor,
                        showsTankEditor: showsTankEditor,
                        switchDepthMeters: switchDepthBinding,
                        maxSwitchDepthMeters: maxSwitchDepthMeters,
                        onGasOrPPO2Changed: {},
                        onPressureChanged: {}
                    )
                    .padding(16)
                }
                .dirCompanionScrollSurface()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.body.weight(.semibold))
                    }
                    .accessibilityLabel(DIRIOSLocalizer.string("planner.gas.editor.cancel"))
                }
                ToolbarItem(placement: .principal) {
                    Text(DIRIOSLocalizer.string("planner.gas.editor.planning_title"))
                        .font(.headline.weight(.semibold))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(DIRIOSLocalizer.string("planner.gas.editor.save")) {
                        entry = draft
                        onSave()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .toolbarBackground(DIRTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    private var switchDepthBinding: Binding<Double>? {
        guard switchDepthMeters != nil else { return nil }
        return Binding(
            get: { draft.switchDepthMeters },
            set: { draft.switchDepthMeters = $0 }
        )
    }
}
