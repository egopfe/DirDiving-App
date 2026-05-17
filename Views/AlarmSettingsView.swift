import SwiftUI

struct AlarmSettingsView: View {
    @AppStorage("dirdiving_watch_alarm_ascent_enabled") private var ascentAlarmEnabled = true
    @AppStorage("dirdiving_watch_alarm_depth_enabled") private var depthAlarmEnabled = false
    @AppStorage("dirdiving_watch_alarm_runtime_enabled") private var runtimeAlarmEnabled = false
    @AppStorage("dirdiving_watch_alarm_battery_enabled") private var batteryAlarmEnabled = true

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
                    alarmRow(title: "Velocità risalita", threshold: "Usa limiti ASC SET", isOn: $ascentAlarmEnabled)
                    alarmRow(title: "Profondità massima", threshold: "> 40.0 m", isOn: $depthAlarmEnabled)
                    alarmRow(title: "Tempo immersione", threshold: "> 60 min", isOn: $runtimeAlarmEnabled)
                    alarmRow(title: "Batteria bassa", threshold: "< 20%", isOn: $batteryAlarmEnabled)
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

            DiveClockText(size: 14)
        }
    }

    private func alarmRow(title: String, threshold: String, isOn: Binding<Bool>) -> some View {
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

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(DiveUI.green)
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

}
