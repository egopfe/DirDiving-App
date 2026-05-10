import SwiftUI

struct AscentRateSettingsView: View {
    @EnvironmentObject private var settings: AscentRateSettingsStore

    var body: some View {
        List {
            limitStepper("40-30 m", value: $settings.limits.deepMetersPerMinute)
            limitStepper("30-20 m", value: $settings.limits.midMetersPerMinute)
            limitStepper("20-6 m", value: $settings.limits.shallowMetersPerMinute)
            limitStepper("6-0 m", value: $settings.limits.surfaceMetersPerMinute)
            limitStepper("Other", value: $settings.limits.fallbackMetersPerMinute)

            Button("RESET STD") {
                settings.resetToStandard()
            }
        }
        .navigationTitle("ASC SET")
    }

    private func limitStepper(_ title: String, value: Binding<Double>) -> some View {
        Stepper(value: value, in: 0.5...20, step: 0.5) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                Text("\(Formatters.one(value.wrappedValue)) m/min")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.cyan)
            }
        }
    }
}
