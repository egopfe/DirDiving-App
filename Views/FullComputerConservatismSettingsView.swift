import SwiftUI

/// Full Computer → Conservatism (mockup screen 3).
struct FullComputerConservatismSettingsView: View {
    @EnvironmentObject private var dive: DiveManager
    @ObservedObject private var configuration = FullComputerPrediveConfigurationStore.shared

    private var resolved: FullComputerResolvedGradientFactors {
        configuration.resolvedGradientFactorsForRuntime()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                WatchSettingsSectionHeader(title: String(localized: "full_computer.conservatism.title"))

                NavigationLink {
                    FullComputerGradientFactorsInfoView()
                } label: {
                    settingsRow(
                        icon: "chart.line.uptrend.xyaxis",
                        iconColor: DiveUI.green,
                        title: String(localized: "full_computer.gradient_factors.title"),
                        subtitle: resolved.preset.settingsSummary,
                        showsChevron: true
                    )
                }
                .buttonStyle(.plain)

                Text(String(localized: "full_computer.gradient_factors.info"))
                    .font(DiveUI.Typography.hintCaption)
                    .foregroundStyle(DiveUI.mutedText)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .navigationTitle(String(localized: "full_computer.conservatism.title"))
    }

    private func settingsRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        showsChevron: Bool
    ) -> some View {
        WatchSettingsRow(
            icon: icon,
            iconColor: iconColor,
            title: title,
            subtitle: subtitle,
            showsChevron: showsChevron
        )
    }
}
