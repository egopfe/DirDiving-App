import SwiftUI

struct AlarmSettingsView: View {
    @AppStorage("dirdiving_watch_alarm_ascent_enabled") private var ascentAlarmEnabled = true
    @AppStorage("dirdiving_watch_alarm_depth_enabled") private var depthAlarmEnabled = false
    @AppStorage("dirdiving_watch_alarm_runtime_enabled") private var runtimeAlarmEnabled = false
    @AppStorage("dirdiving_watch_alarm_battery_enabled") private var batteryAlarmEnabled = true
    @AppStorage("dirdiving_watch_alarm_depth_threshold_m") private var depthThresholdMeters = 40.0
    @AppStorage("dirdiving_watch_alarm_runtime_threshold_min") private var runtimeThresholdMinutes = 60
    @AppStorage("dirdiving_watch_alarm_battery_threshold_pct") private var batteryThresholdPercent = 20

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
                    alarmRow(title: "Profondità massima", threshold: "> \(Formatters.one(depthThresholdMeters)) m", isOn: $depthAlarmEnabled)
                    thresholdStepper(title: "Soglia profondità", value: "\(Formatters.one(depthThresholdMeters)) m", color: DiveUI.blue) {
                        depthThresholdMeters = max(10, depthThresholdMeters - 1)
                    } increase: {
                        depthThresholdMeters = min(100, depthThresholdMeters + 1)
                    }
                    alarmRow(title: "Tempo immersione", threshold: "> \(runtimeThresholdMinutes) min", isOn: $runtimeAlarmEnabled)
                    thresholdStepper(title: "Soglia tempo", value: "\(runtimeThresholdMinutes) min", color: DiveUI.yellow) {
                        runtimeThresholdMinutes = max(10, runtimeThresholdMinutes - 5)
                    } increase: {
                        runtimeThresholdMinutes = min(240, runtimeThresholdMinutes + 5)
                    }
                    alarmRow(title: "Batteria bassa", threshold: "< \(batteryThresholdPercent)%", isOn: $batteryAlarmEnabled)
                    thresholdStepper(title: "Soglia batteria", value: "\(batteryThresholdPercent)%", color: DiveUI.red) {
                        batteryThresholdPercent = max(5, batteryThresholdPercent - 5)
                    } increase: {
                        batteryThresholdPercent = min(50, batteryThresholdPercent + 5)
                    }
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

    private func thresholdStepper(title: String, value: String, color: Color, decrease: @escaping () -> Void, increase: @escaping () -> Void) -> some View {
        HStack(spacing: 7) {
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(value)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(color)
                    .monospacedDigit()
            }

            Spacer(minLength: 0)

            Button(action: decrease) {
                Image(systemName: "minus")
                    .font(.system(size: 11, weight: .black))
                    .frame(width: 28, height: 26)
                    .background(RoundedRectangle(cornerRadius: 7, style: .continuous).fill(color.opacity(0.18)))
            }
            .buttonStyle(.plain)
            .foregroundStyle(color)

            Button(action: increase) {
                Image(systemName: "plus")
                    .font(.system(size: 11, weight: .black))
                    .frame(width: 28, height: 26)
                    .background(RoundedRectangle(cornerRadius: 7, style: .continuous).fill(color.opacity(0.18)))
            }
            .buttonStyle(.plain)
            .foregroundStyle(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(color.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(color.opacity(0.45), lineWidth: 1)
                )
        )
    }

}
