import SwiftUI

struct FullComputerGasSwitchAvailableView: View {
    let prompt: FullComputerGasSwitchPrompt
    let onIgnore: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: DiveUI.spaceM) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.left.arrow.right.circle.fill")
                    .foregroundStyle(DiveUI.yellow)
                Text(String(localized: "live.fc.gas_switch.available.title"))
                    .font(DiveUI.Typography.warningTitle)
                    .foregroundStyle(DiveUI.yellow)
            }


            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(Formatters.one(prompt.currentDepthMeters))
                    .font(DiveUI.Typography.metricValueHero)
                    .foregroundStyle(.white)
                Text("m")
                    .font(DiveUI.Typography.metricUnitHero)
                    .foregroundStyle(DiveUI.blue)
            }

            DivePanel(stroke: DiveUI.yellow) {
                VStack(spacing: 0) {
                    infoRow(
                        label: String(localized: "live.fc.gas_switch.active_gas"),
                        value: prompt.activeGasLabel,
                        valueColor: DiveUI.yellow
                    )
                    divider
                    infoRow(
                        label: String(localized: "live.fc.gas_switch.suggested_gas"),
                        value: prompt.suggestedGasLabel,
                        valueColor: DiveUI.green
                    )
                    divider
                    infoRow(
                        label: String(localized: "live.fc.gas_switch.switch_depth"),
                        value: "\(Formatters.one(prompt.switchDepthMeters)) m",
                        valueColor: DiveUI.yellow
                    )
                    divider
                    infoRow(
                        label: "PPO2",
                        value: Formatters.one(prompt.currentPPO2),
                        valueColor: DiveUI.yellow
                    )
                }
            }

            HStack(spacing: 6) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 11, weight: .black))
                Text(String(localized: "live.fc.gas_switch.tts_after_confirm"))
                    .font(DiveUI.Typography.hintCaption)
            }
            .foregroundStyle(DiveUI.yellow)
            .multilineTextAlignment(.center)

            HStack(spacing: 8) {
                Button(action: onIgnore) {
                    Text(String(localized: "live.fc.gas_switch.ignore"))
                        .font(DiveUI.Typography.commandButton)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: DiveUI.Layout.commandButtonMinHeight)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(DiveUI.subtleStroke, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                confirmButton
            }
        }
        .padding(.horizontal, DiveUI.screenPadding)
        .padding(.vertical, 8)
        .accessibilityElement(children: .contain)
    }

    private var confirmButton: some View {
        Button {
            guard prompt.isBreathable else { return }
            onConfirm()
        } label: {
            Text(String(localized: "live.fc.gas_switch.confirm"))
                .font(DiveUI.Typography.commandButton)
                .foregroundStyle(prompt.isBreathable ? .black : DiveUI.mutedText)
                .frame(maxWidth: .infinity, minHeight: DiveUI.Layout.commandButtonMinHeight)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(prompt.isBreathable ? DiveUI.green : DiveUI.mutedText.opacity(0.4))
                )
        }
        .buttonStyle(.plain)
        .disabled(!prompt.isBreathable)
        .onLongPressGesture(minimumDuration: FullComputerGasSwitchPolicy.confirmationHoldSeconds) {
            guard prompt.isBreathable else { return }
            onConfirm()
        }
        .accessibilityHint(String(localized: "live.fc.gas_switch.confirm.a11y"))
    }

    private var divider: some View {
        Rectangle()
            .fill(DiveUI.subtleStroke.opacity(0.35))
            .frame(height: 1)
    }

    private func infoRow(label: String, value: String, valueColor: Color) -> some View {
        HStack {
            Text(label)
                .font(DiveUI.Typography.hintCaptionBold)
                .foregroundStyle(DiveUI.mutedText)
            Spacer(minLength: 6)
            Text(value)
                .font(DiveUI.Typography.rowTitle)
                .foregroundStyle(valueColor)
        }
        .padding(.vertical, 7)
    }
}

struct FullComputerGasSwitchMissedPanel: View {
    let prompt: FullComputerGasSwitchMissedPrompt
    let onContinue: () -> Void
    let onChangeGas: () -> Void

    var body: some View {
        DivePanel(stroke: DiveUI.orange) {
            VStack(alignment: .leading, spacing: 8) {
                Text(String(localized: "live.fc.gas_switch.missed.title"))
                    .font(DiveUI.Typography.warningTitle)
                    .foregroundStyle(DiveUI.yellow)

                HStack {
                    Text(String(localized: "live.fc.gas_switch.available_gas"))
                        .font(DiveUI.Typography.hintCaptionBold)
                        .foregroundStyle(DiveUI.mutedText)
                    Spacer(minLength: 4)
                    Text(prompt.suggestedGasLabel)
                        .font(DiveUI.Typography.rowTitle)
                        .foregroundStyle(DiveUI.green)
                }
                HStack {
                    Text(String(localized: "live.fc.gas_switch.active_gas"))
                        .font(DiveUI.Typography.hintCaptionBold)
                        .foregroundStyle(DiveUI.mutedText)
                    Spacer(minLength: 4)
                    Text(prompt.activeGasLabel)
                        .font(DiveUI.Typography.rowTitle)
                        .foregroundStyle(DiveUI.red)
                }

                Text(
                    String(
                        format: String(localized: "live.fc.gas_switch.still_available"),
                        Formatters.one(prompt.switchDepthMeters)
                    )
                )
                .font(DiveUI.Typography.hintCaption)
                .foregroundStyle(DiveUI.yellow)

                Text(String(localized: "live.fc.gas_switch.tts_active_only"))
                    .font(DiveUI.Typography.hintCaption)
                    .foregroundStyle(DiveUI.mutedText)

                HStack(spacing: 8) {
                    Button(action: onContinue) {
                        Text(String(localized: "live.fc.gas_switch.continue"))
                            .font(DiveUI.Typography.commandButton)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: DiveUI.Layout.commandButtonMinHeight)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(DiveUI.subtleStroke, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)

                    Button(action: onChangeGas) {
                        Text(String(localized: "live.fc.gas_switch.change_gas"))
                            .font(DiveUI.Typography.commandButton)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity, minHeight: DiveUI.Layout.commandButtonMinHeight)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(prompt.canStillSwitch ? DiveUI.yellow : DiveUI.mutedText)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(!prompt.canStillSwitch)
                }
            }
        }
    }
}

struct FullComputerRuntimeDecoGasListView: View {
    @EnvironmentObject private var dive: DiveManager
    @Environment(\.dismiss) private var dismiss
    @State private var pendingConfirmGasMixId: UUID?
    @State private var showsConfirmSheet = false

    private var rows: [FullComputerRuntimeGasRow] {
        dive.fullComputerSnapshot?.runtimeGasRows ?? []
    }

    var body: some View {
        ScrollView {
            VStack(spacing: DiveUI.spaceM) {
                DiveScreenHeader(
                    String(localized: "live.fc.gas_list.title"),
                    subtitle: nil,
                    accent: DiveUI.red,
                    systemImage: "water.waves"
                )

                ForEach(rows) { row in
                    gasRow(row)
                }

                Text(String(localized: "live.fc.gas_list.footer"))
                    .font(DiveUI.Typography.hintCaption)
                    .foregroundStyle(DiveUI.mutedText)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, DiveUI.screenPadding)
            .padding(.vertical, 8)
        }
        .sheet(isPresented: $showsConfirmSheet) {
            if let gasMixId = pendingConfirmGasMixId,
               let prompt = confirmPrompt(for: gasMixId) {
                FullComputerGasSwitchAvailableView(
                    prompt: prompt,
                    onIgnore: {
                        showsConfirmSheet = false
                        pendingConfirmGasMixId = nil
                    },
                    onConfirm: {
                        dive.confirmFullComputerGasSwitch(gasMixId: gasMixId)
                        showsConfirmSheet = false
                        pendingConfirmGasMixId = nil
                        dismiss()
                    }
                )
            }
        }
    }

    private func confirmPrompt(for gasMixId: UUID) -> FullComputerGasSwitchPrompt? {
        guard let snapshot = dive.fullComputerSnapshot else { return nil }
        if case .available(let prompt) = snapshot.gasSwitchSurface, prompt.suggestedGasMixId == gasMixId {
            return prompt
        }
        if let row = snapshot.runtimeGasRows.first(where: { $0.id == gasMixId }),
           row.isSelectable {
            return FullComputerGasSwitchPrompt(
                activeGasLabel: snapshot.activeGas.label,
                suggestedGasLabel: row.label,
                suggestedGasMixId: gasMixId,
                switchDepthMeters: row.switchDepthMeters ?? snapshot.depthMeters,
                currentDepthMeters: snapshot.depthMeters,
                currentPPO2: row.currentPPO2 ?? 0,
                isBreathable: true,
                isOffPlan: false,
                verifyCylinderNoteKey: "live.fc.gas_switch.verify_cylinder"
            )
        }
        return nil
    }

    private func gasRow(_ row: FullComputerRuntimeGasRow) -> some View {
        let accent = accentColor(for: row.status)
        return Button {
            guard row.isSelectable else { return }
            pendingConfirmGasMixId = row.id
            showsConfirmSheet = true
        } label: {
            DivePanel(stroke: accent) {
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(row.label)
                            .font(DiveUI.Typography.rowTitle)
                            .foregroundStyle(.white)
                        if let depth = row.switchDepthMeters {
                            Text(String(format: String(localized: "fc.predive.deco_list.switch_at"), Formatters.one(depth)))
                                .font(DiveUI.Typography.hintCaption)
                                .foregroundStyle(DiveUI.blue)
                        }
                    }
                    Spacer(minLength: 0)
                    Text(statusLabel(for: row.status))
                        .font(DiveUI.Typography.hintCaptionBold)
                        .foregroundStyle(accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(accent.opacity(0.14)))
                    if row.isSelectable {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .black))
                            .foregroundStyle(accent)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .buttonStyle(.plain)
        .disabled(!row.isSelectable && row.status != .unavailable)
        .contextMenu {
            if row.status == .available || row.status == .unsafe {
                Button(String(localized: "live.fc.gas_switch.mark_unavailable"), role: .destructive) {
                    dive.markFullComputerGasUnavailable(gasMixId: row.id)
                }
            }
        }
    }

    private func accentColor(for status: FullComputerRuntimeGasRow.Status) -> Color {
        switch status {
        case .active: return DiveUI.green
        case .available: return DiveUI.green
        case .unavailable: return DiveUI.mutedText
        case .unsafe: return DiveUI.red
        case .disabled: return DiveUI.mutedText
        }
    }

    private func statusLabel(for status: FullComputerRuntimeGasRow.Status) -> String {
        switch status {
        case .active: return String(localized: "live.fc.gas_list.active")
        case .available: return String(localized: "live.fc.gas_list.available")
        case .unavailable: return String(localized: "live.fc.gas_list.unavailable")
        case .unsafe: return String(localized: "live.fc.gas_list.unsafe")
        case .disabled: return String(localized: "fc.predive.deco_list.disabled")
        }
    }
}
