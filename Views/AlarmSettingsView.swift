import SwiftUI

struct AlarmSettingsView: View {
    @AppStorage("dirdiving_watch_alarm_ascent_enabled") private var ascentAlarmEnabled = true
    @AppStorage("dirdiving_watch_alarm_depth_enabled") private var depthAlarmEnabled = false
    @AppStorage("dirdiving_watch_alarm_runtime_enabled") private var runtimeAlarmEnabled = false
    @AppStorage("dirdiving_watch_alarm_battery_enabled") private var batteryAlarmEnabled = true
    @AppStorage("dirdiving_watch_alarm_depth_threshold_m") private var depthThresholdMeters = 40.0
    @AppStorage("dirdiving_watch_alarm_runtime_threshold_min") private var runtimeThresholdMinutes = WatchAlarmDefaults.runtimeThresholdMinutes
    @AppStorage("dirdiving_watch_alarm_battery_threshold_pct") private var batteryThresholdPercent = 20
    @AppStorage(DIRUnitPreference.storageKey) private var watchUnits = DIRUnitPreference.metric.rawValue

    private var unitPreference: DIRUnitPreference { DIRUnitPreference.fromStorage(watchUnits) }

    private var depthThresholdLabel: String {
        let display = unitPreference.depthDisplay(meters: depthThresholdMeters)
        return "\(Formatters.one(display.value)) \(display.unit)"
    }


    var body: some View {
        ZStack {
            DiveScreenBackground()

            ScrollView {
                VStack(spacing: 6) {
                    header

                    Text("ALLARMI")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)

                    Text("Soglie locali sul Watch. Non sincronizzate con iPhone.")
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .foregroundStyle(DiveUI.secondaryText)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(spacing: 5) {
                        alarmRow(title: "Velocità risalita", threshold: "Usa limiti ASC SET", isOn: $ascentAlarmEnabled)
                        alarmRow(title: "Profondità massima", threshold: "> \(depthThresholdLabel)", isOn: $depthAlarmEnabled)
                        crownThresholdStepper(title: "Soglia profondità", value: $depthThresholdMeters, display: depthThresholdLabel, range: 10...100, step: 1, color: DiveUI.blue) {
                            depthThresholdMeters = max(10, depthThresholdMeters - 1)
                        } increase: {
                            depthThresholdMeters = min(100, depthThresholdMeters + 1)
                        }
                        alarmRow(title: "Tempo immersione", threshold: "> \(runtimeThresholdMinutes) min", isOn: $runtimeAlarmEnabled)
                        crownThresholdStepper(title: "Soglia tempo", value: runtimeThresholdBinding, display: "\(runtimeThresholdMinutes) min", range: 10...240, step: 5, color: DiveUI.yellow) {
                            runtimeThresholdMinutes = max(10, runtimeThresholdMinutes - 5)
                        } increase: {
                            runtimeThresholdMinutes = min(240, runtimeThresholdMinutes + 5)
                        }
                        alarmRow(title: "Batteria bassa", threshold: "< \(batteryThresholdPercent)%", isOn: $batteryAlarmEnabled)
                        crownThresholdStepper(title: "Soglia batteria", value: batteryThresholdBinding, display: "\(batteryThresholdPercent)%", range: 5...50, step: 5, color: DiveUI.red) {
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
        .navigationTitle("Allarmi")
        .watchSubscreenBackToolbar()
    }

    private var runtimeThresholdBinding: Binding<Double> {
        Binding(
            get: { Double(runtimeThresholdMinutes) },
            set: { runtimeThresholdMinutes = Int($0.rounded()) }
        )
    }

    private var batteryThresholdBinding: Binding<Double> {
        Binding(
            get: { Double(batteryThresholdPercent) },
            set: { batteryThresholdPercent = Int($0.rounded()) }
        )
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

    private func crownThresholdStepper(title: String, value: Binding<Double>, display: String, range: ClosedRange<Double>, step: Double, color: Color, decrease: @escaping () -> Void, increase: @escaping () -> Void) -> some View {
        HStack(spacing: 7) {
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(display)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(color)
                    .monospacedDigit()
            }

            Spacer(minLength: 0)

            Button(action: decrease) {
                Image(systemName: "minus")
                    .font(.system(size: 13, weight: .black))
                    .frame(width: 40, height: 34)
                    .background(RoundedRectangle(cornerRadius: 9, style: .continuous).fill(color.opacity(0.18)))
            }
            .buttonStyle(.plain)
            .foregroundStyle(color)

            Button(action: increase) {
                Image(systemName: "plus")
                    .font(.system(size: 13, weight: .black))
                    .frame(width: 40, height: 34)
                    .background(RoundedRectangle(cornerRadius: 9, style: .continuous).fill(color.opacity(0.18)))
            }
            .buttonStyle(.plain)
            .foregroundStyle(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(minHeight: 46)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(color.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(color.opacity(0.45), lineWidth: 1)
                )
        )
        .focusable(true)
        .digitalCrownRotation(value, from: range.lowerBound, through: range.upperBound, by: step, sensitivity: .medium, isContinuous: false, isHapticFeedbackEnabled: true)
    }

}
