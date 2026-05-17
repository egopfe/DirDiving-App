import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var navigation: AppNavigationStore
    @AppStorage(HapticService.experimentalHapticsEnabledKey) private var experimentalHapticsEnabled = true
    @AppStorage("dirdiving_watch_metric_units") private var metricUnits = true
    @AppStorage("dirdiving_watch_always_on_safe") private var alwaysOnSafe = true

    var body: some View {
        ZStack {
            DiveScreenBackground()

            ScrollView {
            VStack(spacing: 7) {
                header

                Text("IMPOSTAZIONI")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)

                VStack(spacing: 6) {
                    Toggle(isOn: $metricUnits) {
                        settingsRowContent(
                        icon: "ruler",
                        iconColor: .white,
                        title: "Unità di misura",
                        subtitle: metricUnits ? "Metrico (m, °C)" : "Imperiale LAB OFF"
                        )
                    }
                    .tint(DiveUI.blue)
                    Button {
                        navigation.selectedPage = .alarmSettings
                    } label: {
                        settingsRowContent(
                            icon: "bell",
                            iconColor: DiveUI.yellow,
                            title: "Allarmi",
                            subtitle: "Apri soglie safety persistenti"
                        )
                    }
                    .buttonStyle(.plain)
                    Toggle(isOn: $alwaysOnSafe) {
                        settingsRowContent(
                            icon: "sun.max",
                            iconColor: DiveUI.yellow,
                            title: "Schermo",
                            subtitle: alwaysOnSafe ? "Always On safe: ON" : "Always On safe: OFF"
                        )
                    }
                    .tint(DiveUI.yellow)
                    Toggle(isOn: $experimentalHapticsEnabled) {
                        settingsRowContent(
                            icon: "iphone.radiowaves.left.and.right",
                            iconColor: DiveUI.blue,
                            title: "Haptics sperimentali",
                            subtitle: experimentalHapticsEnabled ? "Attivi" : "Disattivati"
                        )
                    }
                    .tint(DiveUI.green)
                    Button {
                        navigation.selectedPage = .ascentSettings
                    } label: {
                        settingsRowContent(
                            icon: "arrow.up.right.circle",
                            iconColor: DiveUI.blue,
                            title: "Limiti risalita",
                            subtitle: "Soglie applicate da DiveManager"
                        )
                    }
                    .buttonStyle(.plain)
                    Button {
                        navigation.selectedPage = .info
                    } label: {
                        settingsRowContent(
                            icon: "info.circle",
                            iconColor: DiveUI.cyan,
                            title: "Info e limiti",
                            subtitle: "Safety, mock e hardware"
                        )
                    }
                    .buttonStyle(.plain)
                    Text("GPS e sync non hanno preferenze globali complete: usa le impostazioni Snorkeling/Apnea e i pannelli sync sperimentali.")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(DiveUI.yellow)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 11)
            .padding(.top, 9)
            .padding(.bottom, 8)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            HStack(spacing: 5) {
                DiveOctopusLogo(accent: DiveUI.yellow)
                    .frame(width: 23, height: 22, alignment: .leading)
                    .scaleEffect(0.68)
                Text("DIR DIVING")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(DiveUI.yellow)
                    .lineLimit(1)
            }

            Spacer()

            Text("--:--")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
    }

    private func settingsRowContent(icon: String, iconColor: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 9) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(iconColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .frame(minHeight: 35)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color.black.opacity(0.52))
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(.white.opacity(0.24), lineWidth: 1)
                    )
        )
    }
}
