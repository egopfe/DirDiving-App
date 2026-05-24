import SwiftUI

struct AscentRateSettingsView: View {
    @EnvironmentObject private var settings: AscentRateSettingsStore
    @AppStorage(DIRUnitPreference.storageKey) private var watchUnits = DIRUnitPreference.metric.rawValue

    private var unitPreference: DIRUnitPreference { DIRUnitPreference.fromStorage(watchUnits) }

    var body: some View {
        ZStack {
            DiveScreenBackground()

            ScrollView {
                VStack(spacing: 10) {
                    header
                    limitControl("40-30 m", value: $settings.limits.deepMetersPerMinute, accent: DiveUI.red)
                    limitControl("30-20 m", value: $settings.limits.midMetersPerMinute, accent: DiveUI.orange)
                    limitControl("20-6 m", value: $settings.limits.shallowMetersPerMinute, accent: DiveUI.yellow)
                    limitControl("6-0 m", value: $settings.limits.surfaceMetersPerMinute, accent: DiveUI.green)
                    limitControl("OTHER", value: $settings.limits.fallbackMetersPerMinute, accent: DiveUI.blue)

                    DiveCommandButton("RESET STD", systemImage: "arrow.clockwise", color: .white.opacity(0.78)) {
                        settings.resetToStandard()
                    }
                }
                .padding(.horizontal, DiveUI.screenPadding)
                .padding(.vertical, 8)
            }
        }
    }

    private var header: some View {
        DiveScreenHeader(
            "VELOCITA RISALITA",
            subtitle: "LIMITI PERSONALIZZATI",
            accent: DiveUI.green,
            systemImage: "gauge"
        )
    }

    private func limitControl(_ title: String, value: Binding<Double>, accent: Color) -> some View {
        let display = unitPreference.ascentRateDisplay(metersPerMinute: value.wrappedValue)
        let displayBinding = Binding<Double>(
            get: { unitPreference.ascentRateDisplay(metersPerMinute: value.wrappedValue).value },
            set: { newValue in
                let metersPerMinute = unitPreference == .metric ? newValue : newValue / 3.280839895
                value.wrappedValue = min(20, max(0.5, metersPerMinute))
            }
        )
        let lower = unitPreference == .metric ? 0.5 : 1.0
        let upper = unitPreference == .metric ? 20.0 : 65.0
        let step = unitPreference == .metric ? 0.5 : 1.0

        DivePanel(stroke: accent) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    HStack(alignment: .lastTextBaseline, spacing: 3) {
                        Text(Formatters.one(display.value))
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(accent)
                        Text(display.unit)
                            .font(.caption2.bold())
                            .foregroundStyle(.white)
                    }
                }

                Spacer()

                HStack(spacing: 6) {
                    stepButton("-", color: .white.opacity(0.78)) {
                        displayBinding.wrappedValue = max(lower, displayBinding.wrappedValue - step)
                    }
                    stepButton("+", color: accent) {
                        displayBinding.wrappedValue = min(upper, displayBinding.wrappedValue + step)
                    }
                }
                .frame(width: 82)
            }
            .focusable(true)
            .digitalCrownRotation(displayBinding, from: lower, through: upper, by: step, sensitivity: .medium, isContinuous: false, isHapticFeedbackEnabled: true)
        }
    }

    private func stepButton(_ title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline.bold())
                .foregroundStyle(color)
                .frame(width: 34, height: 30)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(color.opacity(0.8), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}
