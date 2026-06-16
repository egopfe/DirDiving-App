import SwiftUI

struct FullComputerPrediveConfirmationView: View {
    @EnvironmentObject private var activitySelection: DIRActivitySelectionStore
    @EnvironmentObject private var dive: DiveManager

    private var readiness: FullComputerPrediveReadiness {
        FullComputerPrediveReadiness.evaluate(depthAutomationAvailable: dive.isDepthAutomationAvailable)
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
                            value: String(localized: "startup.fc_confirm.gas.air")
                        )
                        divider
                        confirmRow(
                            label: String(localized: "startup.fc_confirm.row.gf"),
                            value: "30/70"
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
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}

enum FullComputerPrediveReadiness: Equatable {
    case ready
    case sensorUnavailable

    var isReady: Bool {
        switch self {
        case .ready: return true
        case .sensorUnavailable: return false
        }
    }

    var errorMessage: String? {
        switch self {
        case .ready: return nil
        case .sensorUnavailable:
            return String(localized: "startup.fc_confirm.error.sensor")
        }
    }

    static func evaluate(depthAutomationAvailable: Bool) -> FullComputerPrediveReadiness {
        // Full Computer pre-dive requires depth input path (automatic or manual lifecycle).
        // Manual lifecycle remains available on all supported watches.
        if depthAutomationAvailable {
            return .ready
        }
        return .ready
    }
}
