import SwiftUI

struct FullComputerDecoGasListView: View {
    @ObservedObject private var configuration = FullComputerPrediveConfigurationStore.shared
    @State private var editingGas: FullComputerConfiguredGas?
    @State private var showsAddSheet = false

    private var gases: [FullComputerConfiguredGas] {
        configuration.draftProfile.decoGases.sorted { $0.switchDepthMeters > $1.switchDepthMeters }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: DiveUI.spaceM) {
                DiveScreenHeader(
                    String(localized: "fc.predive.deco_list.title"),
                    subtitle: nil,
                    accent: DiveUI.red,
                    systemImage: "water.waves"
                )

                ForEach(gases) { gas in
                    decoGasRow(gas)
                        .onTapGesture {
                            editingGas = gas
                        }
                }

                Button {
                    showsAddSheet = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                        Text(String(localized: "fc.predive.deco_list.add"))
                            .font(DiveUI.Typography.commandButton)
                    }
                    .foregroundStyle(DiveUI.blue)
                    .frame(maxWidth: .infinity, minHeight: DiveUI.Layout.commandButtonMinHeight)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(DiveUI.blue.opacity(0.75), lineWidth: 1.2)
                    )
                }
                .buttonStyle(.plain)
                .disabled(!configuration.canEdit)

                Text(String(localized: "fc.predive.deco_list.footer"))
                    .font(DiveUI.Typography.hintCaption)
                    .foregroundStyle(DiveUI.mutedText)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, DiveUI.screenPadding)
            .padding(.vertical, 10)
        }
        .sheet(item: $editingGas) { gas in
            FullComputerDecoGasEditorSheet(gas: gas) { updated in
                configuration.upsertDecoGas(updated)
            } onDelete: {
                configuration.removeDecoGas(id: gas.id)
            }
        }
        .sheet(isPresented: $showsAddSheet) {
            FullComputerDecoGasEditorSheet(
                gas: FullComputerConfiguredGas(
                    name: "EAN50",
                    role: .deco,
                    oxygenFraction: 0.50,
                    heliumFraction: 0,
                    maxPPO2Bar: 1.6,
                    switchDepthMeters: 21
                )
            ) { updated in
                configuration.upsertDecoGas(updated)
            } onDelete: {}
        }
    }

    private func decoGasRow(_ gas: FullComputerConfiguredGas) -> some View {
        let statusColor = rowAccent(for: gas)
        return DivePanel(stroke: statusColor) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(gas.displayName)
                        .font(DiveUI.Typography.rowTitle)
                        .foregroundStyle(.white)
                    Text(String(format: String(localized: "fc.predive.deco_list.switch_at"), Formatters.one(gas.switchDepthMeters)))
                        .font(DiveUI.Typography.hintCaption)
                        .foregroundStyle(DiveUI.blue)
                }
                Spacer(minLength: 0)
                Text(statusLabel(for: gas))
                    .font(DiveUI.Typography.hintCaptionBold)
                    .foregroundStyle(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(statusColor.opacity(0.14)))
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(statusColor)
            }
            .padding(.vertical, 4)
        }
        .accessibilityElement(children: .combine)
    }

    private func rowAccent(for gas: FullComputerConfiguredGas) -> Color {
        if !gas.isEnabled || gas.availability == .disabled {
            return DiveUI.mutedText
        }
        let buhlmann = gas.toBuhlmannGas()
        let depth = gas.switchDepthMeters
        if buhlmann.ppO2(depthMeters: depth) < BuhlmannConstants.minBreathablePPO2Bar
            || buhlmann.ppO2(depthMeters: depth) > gas.maxPPO2Bar + 0.000_1 {
            return DiveUI.red
        }
        return DiveUI.green
    }

    private func statusLabel(for gas: FullComputerConfiguredGas) -> String {
        if !gas.isEnabled { return String(localized: "fc.predive.deco_list.disabled") }
        return String(localized: "fc.predive.deco_list.active")
    }
}

struct FullComputerDecoGasEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: FullComputerConfiguredGas
    let onSave: (FullComputerConfiguredGas) -> Void
    let onDelete: () -> Void

    init(
        gas: FullComputerConfiguredGas,
        onSave: @escaping (FullComputerConfiguredGas) -> Void,
        onDelete: @escaping () -> Void
    ) {
        _draft = State(initialValue: gas)
        self.onSave = onSave
        self.onDelete = onDelete
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text(String(localized: "fc.predive.deco_editor.title"))
                    .font(DiveUI.Typography.screenTitle)
                    .foregroundStyle(DiveUI.cyan)

                TextField(String(localized: "fc.predive.deco_editor.name"), text: $draft.name)
                    .font(DiveUI.Typography.rowTitle)

                Stepper(
                    String(format: String(localized: "fc.predive.deco_editor.fo2"), Int((draft.oxygenFraction * 100).rounded())),
                    value: fo2Percent,
                    in: 21...100
                )
                Stepper(
                    String(format: String(localized: "fc.predive.deco_editor.switch"), Formatters.one(draft.switchDepthMeters)),
                    value: $draft.switchDepthMeters,
                    in: 3...60,
                    step: 3
                )

                Toggle(String(localized: "fc.predive.deco_list.active"), isOn: $draft.isEnabled)

                HStack(spacing: 8) {
                    if draft.role == .deco {
                        Button(String(localized: "log.delete.cancel"), role: .cancel) { dismiss() }
                        Button(String(localized: "fc.predive.deco_editor.delete"), role: .destructive) {
                            onDelete()
                            dismiss()
                        }
                    }
                    Button(String(localized: "fc.predive.deco_editor.save")) {
                        onSave(draft)
                        dismiss()
                    }
                }
            }
            .padding()
        }
    }

    private var fo2Percent: Binding<Int> {
        Binding(
            get: { Int((draft.oxygenFraction * 100).rounded()) },
            set: { draft.oxygenFraction = Double($0) / 100.0 }
        )
    }
}

