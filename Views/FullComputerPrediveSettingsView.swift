import SwiftUI

struct FullComputerPrediveSettingsView: View {
    @EnvironmentObject private var activitySelection: DIRActivitySelectionStore
    @EnvironmentObject private var dive: DiveManager
    @ObservedObject private var configuration = FullComputerPrediveConfigurationStore.shared
    @State private var showsDecoGasList = false

    private var profile: FullComputerGasProfile { configuration.draftProfile }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DiveUI.spaceL) {
                    DiveScreenHeader(
                        String(localized: "fc.predive.settings.title"),
                        subtitle: nil,
                        accent: DiveUI.red,
                        systemImage: "water.waves"
                    )

                    bottomGasSection
                    compositionSection
                    gfSection
                    sensorSection

                    NavigationLink {
                        FullComputerDecoGasListView()
                    } label: {
                        settingsRow(
                            title: String(localized: "fc.predive.settings.deco_gases"),
                            value: decoSummary,
                            accent: DiveUI.green
                        )
                    }
                    .buttonStyle(.plain)

                    if let issue = configuration.validationIssues.first {
                        validationMessage(issue)
                    }

                    Text(String(localized: "fc.predive.settings.footer"))
                        .font(DiveUI.Typography.hintCaption)
                        .foregroundStyle(DiveUI.blue)
                        .multilineTextAlignment(.center)

                    HStack(spacing: 8) {
                        Button {
                            HapticService.shared.confirm()
                            activitySelection.cancelFullComputerPrediveToModeSelection()
                        } label: {
                            Text(String(localized: "startup.fc_confirm.back"))
                                .font(DiveUI.Typography.commandButton)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, minHeight: DiveUI.Layout.commandButtonMinHeight)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(DiveUI.subtleStroke, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)

                        Button {
                            guard configuration.isDraftValid else { return }
                            HapticService.shared.confirm()
                            activitySelection.proceedToFullComputerConfirmation()
                        } label: {
                            Text(String(localized: "fc.predive.settings.review"))
                                .font(DiveUI.Typography.commandButton)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, minHeight: DiveUI.Layout.commandButtonMinHeight)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(configuration.isDraftValid ? DiveUI.green : DiveUI.mutedText)
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(!configuration.isDraftValid)
                    }
                }
                .padding(.horizontal, DiveUI.screenPadding)
                .padding(.vertical, 10)
            }
        }
    }

    private var bottomGasSection: some View {
        DivePanel(stroke: DiveUI.green) {
            VStack(alignment: .leading, spacing: 8) {
                Text(String(localized: "fc.predive.settings.bottom_gas"))
                    .font(DiveUI.Typography.rowSubtitle)
                    .foregroundStyle(DiveUI.secondaryText)
                HStack(spacing: 6) {
                    bottomGasKindButton(.air, label: String(localized: "fc.predive.gas.air"))
                    bottomGasKindButton(.ean, label: String(localized: "fc.predive.gas.ean"))
                    bottomGasKindButton(.trimix, label: String(localized: "fc.predive.gas.trimix"))
                }
            }
        }
    }

    private func bottomGasKindButton(_ kind: FullComputerBottomGasKind, label: String) -> some View {
        let selected = profile.bottomGasKind == kind
        return Button {
            configuration.setBottomGasKind(kind)
        } label: {
            Text(label)
                .font(DiveUI.Typography.hintCaptionBold)
                .foregroundStyle(selected ? .black : .white)
                .frame(maxWidth: .infinity, minHeight: 30)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(selected ? DiveUI.green : Color.white.opacity(0.08))
                )
        }
        .buttonStyle(.plain)
        .disabled(!configuration.canEdit)
    }

    private var compositionSection: some View {
        DivePanel(stroke: DiveUI.cyan) {
            VStack(spacing: 0) {
                if profile.bottomGasKind != .air {
                    Stepper(
                        String(format: String(localized: "fc.predive.deco_editor.fo2"), Int((profile.bottomGas.oxygenFraction * 100).rounded())),
                        value: fo2Percent,
                        in: profile.bottomGasKind == .ean ? 22...40 : 10...40
                    )
                    .font(DiveUI.Typography.rowSubtitle)
                    divider
                }
                if profile.bottomGasKind == .trimix {
                    Stepper(
                        String(format: String(localized: "fc.predive.settings.fhe")) + " \(Int((profile.bottomGas.heliumFraction * 100).rounded()))%",
                        value: fhePercent,
                        in: 0...70
                    )
                    .font(DiveUI.Typography.rowSubtitle)
                    divider
                }
                settingsReadOnlyRow(
                    title: String(localized: "fc.predive.settings.fn2"),
                    value: "\(Int((profile.bottomGas.nitrogenFraction * 100).rounded()))%",
                )
                divider
                Stepper(
                    String(localized: "fc.predive.settings.ppo2_max") + " \(Formatters.one(profile.bottomGas.maxPPO2Bar)) bar",
                    value: ppo2Tenths,
                    in: 12...16
                )
                .font(DiveUI.Typography.rowSubtitle)
                divider
                settingsReadOnlyRow(
                    title: String(localized: "fc.predive.settings.mod"),
                    value: "\(modText) m"
                )
            }
        }
    }

    private var fo2Percent: Binding<Int> {
        Binding(
            get: { Int((profile.bottomGas.oxygenFraction * 100).rounded()) },
            set: { newValue in configuration.updateDraft { $0.bottomGas.oxygenFraction = Double(newValue) / 100.0 } }
        )
    }

    private var fhePercent: Binding<Int> {
        Binding(
            get: { Int((profile.bottomGas.heliumFraction * 100).rounded()) },
            set: { newValue in configuration.updateDraft { $0.bottomGas.heliumFraction = Double(newValue) / 100.0 } }
        )
    }

    private var ppo2Tenths: Binding<Int> {
        Binding(
            get: { Int((profile.bottomGas.maxPPO2Bar * 10).rounded()) },
            set: { newValue in configuration.updateDraft { $0.bottomGas.maxPPO2Bar = Double(newValue) / 10.0 } }
        )
    }

    private var gfSection: some View {
        DivePanel(stroke: DiveUI.green) {
            HStack {
                Text(String(localized: "startup.fc_confirm.row.gf"))
                    .font(DiveUI.Typography.rowSubtitle)
                    .foregroundStyle(DiveUI.secondaryText)
                Spacer()
                Text("\(Int(profile.gfLow))/\(Int(profile.gfHigh))")
                    .font(DiveUI.Typography.rowTitle)
                    .foregroundStyle(DiveUI.green)
                    .monospacedDigit()
            }
            .padding(.vertical, 6)
        }
    }

    private var sensorSection: some View {
        settingsRow(
            title: String(localized: "startup.fc_confirm.row.sensor"),
            value: sensorLabel,
            accent: DiveUI.green
        )
    }


    private var modText: String {
        if let mod = profile.bottomGas.modMeters() {
            return Formatters.one(mod)
        }
        return "—"
    }

    private var decoSummary: String {
        let count = profile.enabledDecoGases.count
        if count == 0 { return String(localized: "fc.predive.settings.deco_none") }
        return String(format: String(localized: "fc.predive.settings.deco_count"), count)
    }

    private var sensorLabel: String {
        dive.isDepthAutomationAvailable
            ? String(localized: "startup.fc_confirm.sensor.automatic")
            : String(localized: "startup.fc_confirm.sensor.manual")
    }

    private var divider: some View {
        Rectangle().fill(DiveUI.hairline).frame(height: 1)
    }

    private func settingsRow(title: String, value: String, accent: Color) -> some View {
        DivePanel(stroke: accent) {
            HStack {
                Text(title)
                    .font(DiveUI.Typography.rowSubtitle)
                    .foregroundStyle(DiveUI.secondaryText)
                Spacer(minLength: 4)
                Text(value)
                    .font(DiveUI.Typography.rowTitle)
                    .foregroundStyle(accent)
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(accent)
            }
            .padding(.vertical, 6)
        }
    }

    private func settingsReadOnlyRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(DiveUI.Typography.rowSubtitle)
                .foregroundStyle(DiveUI.secondaryText)
            Spacer()
            Text(value)
                .font(DiveUI.Typography.rowTitle)
                .foregroundStyle(DiveUI.green)
                .monospacedDigit()
        }
        .padding(.vertical, 8)
    }

    private func validationMessage(_ issue: FullComputerGasValidationIssue) -> some View {
        let key = issue.localizationKey
        let text: String
        if let arg = issue.argument {
            text = String(format: String(localized: String.LocalizationValue(key)), arg)
        } else {
            text = String(localized: String.LocalizationValue(key))
        }
        return Text(text)
            .font(DiveUI.Typography.hintCaptionBold)
            .foregroundStyle(DiveUI.red)
            .multilineTextAlignment(.center)
    }
}
