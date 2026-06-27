import SwiftUI

struct WatchWaterAutoOpenSettingsView: View {
    @State private var selectedMode = WatchWaterAutoOpenPolicy.mode
    @State private var preferredDestination = WatchWaterAutoOpenPolicy.preferredDestination

    var body: some View {
        ZStack {
            DiveScreenBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    modeSection
                    if selectedMode == .preferredMode {
                        preferredActivitySection
                        if preferredDestination.activity == .diving {
                            preferredDivingModeSection
                        }
                    }
                    explanationSection
                    systemLimitationSection
                    if selectedMode == .preferredMode,
                       preferredDestination.activity == .diving,
                       preferredDestination.divingMode == .fullComputer {
                        fullComputerWarningSection
                    }
                }
                .padding(.horizontal, 11)
                .padding(.vertical, 10)
            }
        }
        .navigationTitle(String(localized: "settings.water_auto_open.title"))
        .watchSubscreenBackToolbar()
        .onAppear {
            selectedMode = WatchWaterAutoOpenPolicy.mode
            preferredDestination = WatchWaterAutoOpenPolicy.preferredDestination
        }
    }

    private var modeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            WatchSettingsSectionHeader(title: String(localized: "settings.water_auto_open.mode.title"))

            ForEach(WatchWaterAutoOpenMode.allCases) { mode in
                Button {
                    selectedMode = mode
                    WatchWaterAutoOpenPolicy.mode = mode
                    HapticService.shared.confirm()
                } label: {
                    HStack {
                        Image(systemName: selectedMode == mode ? "largecircle.fill.circle" : "circle")
                            .foregroundStyle(selectedMode == mode ? DiveUI.green : DiveUI.secondaryText)
                        Text(mode.localizedLabel)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(.vertical, 5)
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(mode.localizedLabel)
                .accessibilityHint(String(localized: "settings.water_auto_open.mode.a11y.hint"))
                .accessibilityAddTraits(selectedMode == mode ? [.isSelected] : [])
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(settingsCardBackground)
    }

    private var preferredActivitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            WatchSettingsSectionHeader(title: String(localized: "settings.water_auto_open.preferred_activity"))

            ForEach(DIRActivityMode.allCases) { activity in
                Button {
                    preferredDestination.activity = activity
                    if activity != .diving {
                        preferredDestination.divingMode = .gauge
                    }
                    persistPreferredDestination()
                    HapticService.shared.confirm()
                } label: {
                    HStack {
                        Text(localizedActivityName(activity))
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                        Spacer()
                        if preferredDestination.activity == activity {
                            Image(systemName: "checkmark")
                                .foregroundStyle(DiveUI.green)
                        }
                    }
                    .padding(.vertical, 5)
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(localizedActivityName(activity))
                .accessibilityHint(String(localized: "settings.water_auto_open.preferred_activity.a11y.hint"))
                .accessibilityAddTraits(preferredDestination.activity == activity ? [.isSelected] : [])
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(settingsCardBackground)
    }

    private var preferredDivingModeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            WatchSettingsSectionHeader(title: String(localized: "settings.water_auto_open.preferred_diving_mode"))

            ForEach(DIRDivingMode.allCases) { mode in
                Button {
                    preferredDestination.divingMode = mode
                    persistPreferredDestination()
                    HapticService.shared.confirm()
                } label: {
                    HStack {
                        Text(localizedDivingModeName(mode))
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                        Spacer()
                        if preferredDestination.divingMode == mode {
                            Image(systemName: "checkmark")
                                .foregroundStyle(DiveUI.green)
                        }
                    }
                    .padding(.vertical, 5)
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(localizedDivingModeName(mode))
                .accessibilityHint(String(localized: "settings.water_auto_open.preferred_diving_mode.a11y.hint"))
                .accessibilityAddTraits(preferredDestination.divingMode == mode ? [.isSelected] : [])
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(settingsCardBackground)
    }

    private var explanationSection: some View {
        infoBlock(
            title: nil,
            body: String(localized: "settings.water_auto_open.explanation"),
            accessibilityLabel: String(localized: "settings.water_auto_open.explanation.a11y")
        )
    }

    private var systemLimitationSection: some View {
        infoBlock(
            title: nil,
            body: String(localized: "settings.water_auto_open.system_limitation"),
            accessibilityLabel: String(localized: "settings.water_auto_open.system_limitation.a11y")
        )
    }

    private var fullComputerWarningSection: some View {
        infoBlock(
            title: nil,
            body: String(localized: "settings.water_auto_open.full_computer_warning"),
            accessibilityLabel: String(localized: "settings.water_auto_open.full_computer_warning.a11y")
        )
    }

    private func infoBlock(title: String?, body: String, accessibilityLabel: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if let title {
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }
            Text(body)
                .font(DiveUI.Typography.hintCaption)
                .foregroundStyle(DiveUI.mutedText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(settingsCardBackground)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    private var settingsCardBackground: some View {
        RoundedRectangle(cornerRadius: 7, style: .continuous)
            .fill(Color.black.opacity(0.52))
            .overlay(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .stroke(.white.opacity(0.24), lineWidth: 1)
            )
    }

    private func persistPreferredDestination() {
        WatchWaterAutoOpenPolicy.preferredDestination = preferredDestination
    }

    private func localizedActivityName(_ mode: DIRActivityMode) -> String {
        switch mode {
        case .diving: return String(localized: "startup.activity.diving")
        case .apnea: return String(localized: "startup.activity.apnea")
        case .snorkeling: return String(localized: "startup.activity.snorkeling")
        }
    }

    private func localizedDivingModeName(_ mode: DIRDivingMode) -> String {
        switch mode {
        case .gauge: return String(localized: "startup.diving_mode.gauge.title")
        case .fullComputer: return String(localized: "startup.diving_mode.full_computer.title")
        }
    }
}
