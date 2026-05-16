import SwiftUI

struct AlarmSettingsView: View {
    var body: some View {
        ZStack {
            DiveScreenBackground()

            VStack(spacing: 5) {
                header

                Text("ALLARMI")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)

                VStack(spacing: 4) {
                    alarmRow(title: "Velocità risalita", threshold: "> 0.5 m/min", isOn: true)
                    alarmRow(title: "Profondità massima", threshold: "> 40.0 m", isOn: false)
                    alarmRow(title: "Tempo immersione", threshold: "> 60 min", isOn: false)
                    alarmRow(title: "Batteria bassa", threshold: "< 20%", isOn: true)
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

    private func alarmRow(title: String, threshold: String, isOn: Bool) -> some View {
        // TODO: Wire toggle states to persistent alarm settings when those settings exist.
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(threshold)
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            Spacer(minLength: 0)

            visualToggle(isOn: isOn)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(minHeight: 39)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color.black.opacity(0.52))
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(.white.opacity(0.24), lineWidth: 1)
                )
        )
    }

    private func visualToggle(isOn: Bool) -> some View {
        ZStack(alignment: isOn ? .trailing : .leading) {
            Capsule()
                .fill(isOn ? DiveUI.green : .white.opacity(0.28))
                .frame(width: 34, height: 19)
                .overlay(
                    Capsule()
                        .stroke(.white.opacity(isOn ? 0.12 : 0.35), lineWidth: 1)
                )
            Circle()
                .fill(.white)
                .frame(width: 15, height: 15)
                .padding(.horizontal, 2)
                .shadow(color: .black.opacity(0.35), radius: 2, x: 0, y: 1)
        }
        .frame(width: 34, height: 19)
        .accessibilityLabel(isOn ? "Attivo" : "Disattivo")
    }
}
