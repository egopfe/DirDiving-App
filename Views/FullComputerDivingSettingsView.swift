import SwiftUI

/// Settings → Diving → Full Computer submenu (mockup screens 1–3).
struct FullComputerDivingSettingsView: View {
    @EnvironmentObject private var dive: DiveManager
    @ObservedObject private var configuration = FullComputerPrediveConfigurationStore.shared
    @ObservedObject private var importedPlan = FullComputerImportedPlanStore.shared
    @ObservedObject private var gradientFactorStore = FullComputerGradientFactorSettingsStore.shared

    private var resolved: FullComputerResolvedGradientFactors {
        configuration.resolvedGradientFactorsForRuntime()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                WatchSettingsSectionHeader(title: String(localized: "settings.section.full_computer"))

                settingsRow(
                    icon: "doc.text",
                    iconColor: DiveUI.cyan,
                    title: String(localized: "full_computer.settings.dive_plan"),
                    subtitle: divePlanSubtitle,
                    informational: true
                )

                NavigationLink {
                    FullComputerConservatismSettingsView()
                } label: {
                    settingsRow(
                        icon: "slider.horizontal.3",
                        iconColor: DiveUI.green,
                        title: String(localized: "full_computer.conservatism.title"),
                        subtitle: conservatismSubtitle,
                        showsChevron: true
                    )
                }
                .buttonStyle(.plain)
                .disabled(dive.isDiveActive)

                settingsRow(
                    icon: "cylinder.split.1x2",
                    iconColor: DiveUI.cyan,
                    title: String(localized: "full_computer.settings.gas_setup"),
                    subtitle: gasSetupSubtitle,
                    informational: true
                )

                settingsRow(
                    icon: "function",
                    iconColor: DiveUI.blue,
                    title: String(localized: "full_computer.settings.algorithm"),
                    subtitle: String(localized: "full_computer.settings.algorithm_value"),
                    informational: true
                )

                Text(String(localized: "full_computer.settings.footer"))
                    .font(DiveUI.Typography.hintCaption)
                    .foregroundStyle(DiveUI.mutedText)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .navigationTitle(String(localized: "settings.section.full_computer"))
        .onAppear {
            gradientFactorStore.syncDraftProfileFromWatchSettingsIfAllowed(
                isDiveActive: dive.isDiveActive,
                isApneaActive: ApneaWatchRuntimeStore.shared?.isSessionActive ?? false,
                isSnorkelingActive: SnorkelingWatchRuntimeStore.shared?.isSessionActive ?? false,
                isFullComputerRuntimeStarted: dive.hasActiveFullComputerEngine
            )
        }
    }

    private var divePlanSubtitle: String {
        if importedPlan.hasActiveImportedIOSPlan {
            return String(localized: "full_computer.settings.dive_plan.ios_active")
        }
        if importedPlan.hasPendingActivation {
            return String(localized: "full_computer.settings.dive_plan.pending")
        }
        return String(localized: "full_computer.settings.dive_plan.none")
    }

    private var conservatismSubtitle: String {
        if resolved.isLocked, resolved.lockReason == .activeDive {
            return String(
                format: String(localized: "full_computer.conservatism.summary.locked"),
                resolved.valueText
            )
        }
        if resolved.source == .iosPlan {
            return String(
                format: String(localized: "full_computer.conservatism.summary.ios_plan"),
                resolved.valueText
            )
        }
        return resolved.preset.settingsSummary
    }

    private var gasSetupSubtitle: String {
        let profile = configuration.confirmedProfile ?? configuration.draftProfile
        return profile.bottomGas.displayName
    }

    private func settingsRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        showsChevron: Bool = false,
        informational: Bool = false
    ) -> some View {
        WatchSettingsRow(
            icon: icon,
            iconColor: iconColor,
            title: title,
            subtitle: subtitle,
            showsChevron: showsChevron,
            informational: informational
        )
    }
}
