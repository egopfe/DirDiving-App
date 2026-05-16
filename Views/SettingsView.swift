import SwiftUI

struct SettingsView: View {
    var body: some View {
        ZStack {
            DiveScreenBackground()

            VStack(spacing: 5) {
                header

                Text("IMPOSTAZIONI")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)

                VStack(spacing: 3) {
                    settingsRow(
                        icon: "ruler",
                        iconColor: .white,
                        title: "Unità di misura",
                        subtitle: "Metrico (m, \u{00B0}C)"
                    )
                    settingsRow(
                        icon: "bell",
                        iconColor: DiveUI.yellow,
                        title: "Allarmi",
                        subtitle: "Impostazioni alert"
                    )
                    settingsRow(
                        icon: "sun.max",
                        iconColor: DiveUI.yellow,
                        title: "Schermo",
                        subtitle: "Luminosità, Always On"
                    )
                    settingsRow(
                        icon: "iphone.radiowaves.left.and.right",
                        iconColor: DiveUI.blue,
                        title: "Vibrazione",
                        subtitle: "Attiva"
                    )
                    settingsRow(
                        icon: "speaker.wave.2",
                        iconColor: DiveUI.blue,
                        title: "Suoni",
                        subtitle: "Attivi"
                    )
                }
            }
            .padding(.horizontal, 11)
            .padding(.top, 9)
            .padding(.bottom, 8)
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

            // TODO: Replace this visual placeholder if a watch clock value becomes part of the view model.
            Text("--:--")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
    }

    private func settingsRow(icon: String, iconColor: Color, title: String, subtitle: String) -> some View {
        // TODO: Wire these rows to real settings destinations when those view models exist.
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
