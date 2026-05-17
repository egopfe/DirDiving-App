import SwiftUI

struct AlarmSettingsView: View {
    @AppStorage("dirdiving_alarm_ascent_enabled") private var ascentAlarmEnabled = true
    @AppStorage("dirdiving_alarm_depth_enabled") private var depthAlarmEnabled = false
    @AppStorage("dirdiving_alarm_runtime_enabled") private var runtimeAlarmEnabled = false
    @AppStorage("dirdiving_alarm_battery_enabled") private var batteryAlarmEnabled = true
    @AppStorage("dirdiving_alarm_max_depth_meters") private var maxDepthMeters = 40.0
    @AppStorage("dirdiving_alarm_max_runtime_minutes") private var maxRuntimeMinutes = 60
    @AppStorage("dirdiving_alarm_low_battery_percent") private var lowBatteryPercent = 20

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
                    alarmToggle(title: "Velocità risalita", threshold: "DiveManager limits", isOn: $ascentAlarmEnabled)
                    alarmToggle(title: "Profondità massima", threshold: "> \(Formatters.one(maxDepthMeters)) m", isOn: $depthAlarmEnabled)
                    alarmAdjustRow(title: "Soglia profondità", value: "\(Formatters.one(maxDepthMeters)) m", decrement: { maxDepthMeters = max(10, maxDepthMeters - 1) }, increment: { maxDepthMeters = min(80, maxDepthMeters + 1) })
                    alarmToggle(title: "Tempo immersione", threshold: "> \(maxRuntimeMinutes) min", isOn: $runtimeAlarmEnabled)
                    alarmAdjustRow(title: "Soglia tempo", value: "\(maxRuntimeMinutes) min", decrement: { maxRuntimeMinutes = max(10, maxRuntimeMinutes - 5) }, increment: { maxRuntimeMinutes = min(240, maxRuntimeMinutes + 5) })
                    alarmToggle(title: "Batteria bassa", threshold: "< \(lowBatteryPercent)%", isOn: $batteryAlarmEnabled)
                    alarmAdjustRow(title: "Soglia batteria", value: "\(lowBatteryPercent)%", decrement: { lowBatteryPercent = max(5, lowBatteryPercent - 5) }, increment: { lowBatteryPercent = min(50, lowBatteryPercent + 5) })
                }
                Text("Le soglie generali sono persistenti. Risalita usa i limiti Ascent; profondità/tempo/batteria globale sono configurate ma non sostituiscono gli allarmi specifici Snorkeling/Apnea.")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(DiveUI.yellow)
                    .fixedSize(horizontal: false, vertical: true)
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

    private func alarmToggle(title: String, threshold: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            alarmContent(title: title, threshold: threshold)
        }
        .tint(DiveUI.green)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(minHeight: 39)
        .background(rowBackground)
    }

    private func alarmAdjustRow(title: String, value: String, decrement: @escaping () -> Void, increment: @escaping () -> Void) -> some View {
        HStack(spacing: 8) {
            alarmContent(title: title, threshold: value)
            Spacer(minLength: 0)
            Button(action: decrement) { Image(systemName: "minus").frame(width: 24, height: 24) }
                .buttonStyle(.plain)
                .foregroundStyle(DiveUI.cyan)
            Button(action: increment) { Image(systemName: "plus").frame(width: 24, height: 24) }
                .buttonStyle(.plain)
                .foregroundStyle(DiveUI.cyan)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(minHeight: 39)
        .background(rowBackground)
    }

    private func alarmContent(title: String, threshold: String) -> some View {
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
    }

    private var rowBackground: some View {
        RoundedRectangle(cornerRadius: 7, style: .continuous)
            .fill(Color.black.opacity(0.52))
            .overlay(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .stroke(.white.opacity(0.24), lineWidth: 1)
            )
    }
}
