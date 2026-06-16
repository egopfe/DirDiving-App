import SwiftUI

struct FullComputerPrediveConfirmationView: View {
    @EnvironmentObject private var activitySelection: DIRActivitySelectionStore
    @EnvironmentObject private var dive: DiveManager
    @ObservedObject private var configuration = FullComputerPrediveConfigurationStore.shared

    private var profile: FullComputerGasProfile { configuration.draftProfile }

    private var readiness: FullComputerPrediveReadiness {
        FullComputerPrediveReadiness.evaluate(
            depthAutomationAvailable: dive.isDepthAutomationAvailable,
            validationIssues: configuration.validationIssues
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: DiveUI.spaceL) {
                VStack(spacing: 4) {
                    Text(String(localized: "startup.fc_confirm.header"))
                        .font(DiveUI.Typography.screenTitle)
                        .foregroundStyle(DiveUI.cyan)
                        .multilineTextAlignment(.center)
                    Text(String(localized: "startup.fc_confirm.subheader"))
                        .font(DiveUI.Typography.hintCaptionBold)
                        .foregroundStyle(DiveUI.mutedText)
                        .multilineTextAlignment(.center)
                }

                DivePanel(stroke: readiness.isReady ? DiveUI.green : DiveUI.orange) {
                    VStack(spacing: 0) {
                        confirmRow(
                            label: String(localized: "startup.fc_confirm.row.gas"),
                            value: profile.bottomGas.displayName
                        )
                        divider
                        confirmRow(
                            label: String(localized: "fc.predive.confirm.deco_gases"),
                            value: decoSummary
                        )
                        divider
                        confirmRow(
                            label: String(localized: "startup.fc_confirm.row.gf"),
                            value: "\(Int(profile.gfLow))/\(Int(profile.gfHigh))"
                        )
                        divider
                        confirmRow(
                            label: String(localized: "startup.fc_confirm.row.sensor"),
                            value: sensorLabel
                        )
                        divider
                        confirmRow(
                            label: String(localized: "startup.fc_confirm.row.activity"),
                            value: String(localized: "startup.activity.diving")
                        )
                    }
                }

                if let error = readiness.errorMessage {
                    Text(error)
                        .font(DiveUI.Typography.hintCaptionBold)
                        .foregroundStyle(DiveUI.orange)
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: 8) {
                    Button {
                        HapticService.shared.confirm()
                        activitySelection.cancelFullComputerPredive()
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
                        guard readiness.isReady else { return }
                        HapticService.shared.confirm()
                        activitySelection.confirmFullComputerPredive()
                    } label: {
                        Text(String(localized: "startup.fc_confirm.start"))
                            .font(DiveUI.Typography.commandButton)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: DiveUI.Layout.commandButtonMinHeight)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(readiness.isReady ? DiveUI.green : DiveUI.mutedText)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(!readiness.isReady)
                }
            }
            .padding(.horizontal, DiveUI.screenPadding)
            .padding(.vertical, 10)
        }
        .accessibilityElement(children: .contain)
    }

    private var decoSummary: String {
        let gases = profile.enabledDecoGases
        if gases.isEmpty { return String(localized: "fc.predive.settings.deco_none") }
        return gases.map(\.displayName).joined(separator: ", ")
    }

    private var sensorLabel: String {
        if dive.isDepthAutomationAvailable {
            return String(localized: "startup.fc_confirm.sensor.automatic")
        }
        return String(localized: "startup.fc_confirm.sensor.manual")
    }

    private var divider: some View {
        Rectangle()
            .fill(DiveUI.hairline)
            .frame(height: 1)
    }

    private func confirmRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(DiveUI.Typography.rowSubtitle)
                .foregroundStyle(DiveUI.secondaryText)
            Spacer(minLength: 4)
            Text(value)
                .font(DiveUI.Typography.rowTitle)
                .foregroundStyle(.white)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}
