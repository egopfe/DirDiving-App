import SwiftUI

struct FullComputerImportedPlanView: View {
    @EnvironmentObject private var activitySelection: DIRActivitySelectionStore
    @ObservedObject private var importedPlan = FullComputerImportedPlanStore.shared
    @ObservedObject private var configuration = FullComputerPrediveConfigurationStore.shared
    @State private var showsGasVerification = false
    @State private var activationError: String?

    private var package: DivePlanPackage? { importedPlan.pendingPackage }

    var body: some View {
        NavigationStack {
            scrollContent
                .navigationDestination(isPresented: $showsGasVerification) {
                    FullComputerDecoGasListView()
                }
        }
    }

    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: DiveUI.spaceL) {
                VStack(spacing: 4) {
                    Text(String(localized: "fc.imported_plan.header"))
                        .font(DiveUI.Typography.screenTitle)
                        .foregroundStyle(DiveUI.cyan)
                        .multilineTextAlignment(.center)
                    Text(String(localized: "fc.imported_plan.subheader"))
                        .font(DiveUI.Typography.hintCaptionBold)
                        .foregroundStyle(DiveUI.mutedText)
                        .multilineTextAlignment(.center)
                }

                if let package {
                    technicalHeader(package)
                    DivePanel(stroke: DiveUI.cyan) {
                        VStack(spacing: 0) {
                            row(label: String(localized: "startup.fc_confirm.row.gas"), value: bottomGasLabel(package))
                            divider
                            row(label: String(localized: "fc.predive.confirm.deco_gases"), value: decoSummary(package))
                            divider
                            row(label: String(localized: "startup.fc_confirm.row.gf"), value: gfLabel(package))
                            divider
                            row(
                                label: String(localized: "fc.imported_plan.runtime"),
                                value: String(
                                    format: String(localized: "fc.imported_plan.runtime_minutes_format"),
                                    package.body.plannerSummary.totalRuntimeMinutes
                                )
                            )
                        }
                    }
                }

                if let activationError {
                    Text(activationError)
                        .font(DiveUI.Typography.hintCaptionBold)
                        .foregroundStyle(DiveUI.orange)
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: 8) {
                    Button {
                        showsGasVerification = true
                    } label: {
                        Text(String(localized: "fc.imported_plan.verify_gas"))
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
                        activatePlan()
                    } label: {
                        Text(String(localized: "fc.imported_plan.activate"))
                            .font(DiveUI.Typography.commandButton)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: DiveUI.Layout.commandButtonMinHeight)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(DiveUI.green)
                            )
                    }
                    .buttonStyle(.plain)
                }

                Button(String(localized: "fc.imported_plan.dismiss")) {
                    importedPlan.dismissPendingPlan()
                }
                .font(DiveUI.Typography.hintCaption)
                .foregroundStyle(DiveUI.mutedText)
                .buttonStyle(.plain)
            }
            .padding(.horizontal, DiveUI.spaceM)
            .padding(.vertical, DiveUI.spaceL)
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(DiveUI.subtleStroke.opacity(0.35))
            .frame(height: 1)
    }

    private func technicalHeader(_ package: DivePlanPackage) -> some View {
        Text(
            String(
                format: String(localized: "fc.imported_plan.technical_header"),
                String(package.body.planID.uuidString.prefix(8)),
                package.body.revision
            )
        )
            .font(DiveUI.Typography.hintCaption)
            .foregroundStyle(DiveUI.mutedText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func row(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(DiveUI.Typography.hintCaptionBold)
                .foregroundStyle(DiveUI.mutedText)
            Spacer(minLength: 8)
            Text(value)
                .font(DiveUI.Typography.statusValue)
                .foregroundStyle(.white)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 8)
    }

    private func bottomGasLabel(_ package: DivePlanPackage) -> String {
        package.body.gases.first(where: { $0.role == .bottom })?.name ?? "—"
    }

    private func decoSummary(_ package: DivePlanPackage) -> String {
        let deco = package.body.gases.filter { $0.role == .deco }
        guard !deco.isEmpty else { return String(localized: "fc.predive.settings.deco_none") }
        return deco.map(\.name).joined(separator: ", ")
    }

    private func gfLabel(_ package: DivePlanPackage) -> String {
        "\(Int(package.body.gfLow))/\(Int(package.body.gfHigh))"
    }

    private func activatePlan() {
        do {
            try importedPlan.activatePendingPlan(configuration: configuration)
            HapticService.shared.confirm()
            activitySelection.proceedToFullComputerConfirmation()
            activationError = nil
        } catch {
            activationError = String(localized: "fc.imported_plan.activate_failed")
        }
    }
}
