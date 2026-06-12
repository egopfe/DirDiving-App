import SwiftUI

struct PlannerAscentSpeedSettingsView: View {
    @EnvironmentObject private var store: PlannerAscentSpeedSettingsStore

    var body: some View {
        DIRScreenContainer {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text(DIRIOSLocalizer.string("settings.planner_ascent_speeds.title"))
                            .dirScreenTitleStyle()
                        Text(DIRIOSLocalizer.string("settings.planner_ascent_speeds.subtitle"))
                            .font(.callout)
                            .foregroundStyle(DIRTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    DIRCard(DIRIOSLocalizer.string("settings.planner_ascent_speeds.title"), icon: "arrow.up.circle.fill", accent: DIRTheme.cyan) {
                        VStack(spacing: 0) {
                            speedField(
                                DIRIOSLocalizer.string("settings.planner_ascent_speeds.deeper_than_40"),
                                value: binding(\.deeperThan40Meters)
                            )
                            Divider().overlay(DIRTheme.hairline)
                            speedField(
                                DIRIOSLocalizer.string("settings.planner_ascent_speeds.40_to_30"),
                                value: binding(\.from40To30Meters)
                            )
                            Divider().overlay(DIRTheme.hairline)
                            speedField(
                                DIRIOSLocalizer.string("settings.planner_ascent_speeds.30_to_20"),
                                value: binding(\.from30To20Meters)
                            )
                            Divider().overlay(DIRTheme.hairline)
                            speedField(
                                DIRIOSLocalizer.string("settings.planner_ascent_speeds.20_to_6"),
                                value: binding(\.from20To6Meters)
                            )
                            Divider().overlay(DIRTheme.hairline)
                            speedField(
                                DIRIOSLocalizer.string("settings.planner_ascent_speeds.6_to_0"),
                                value: binding(\.from6To0Meters)
                            )
                            Divider().overlay(DIRTheme.hairline)
                            Button {
                                store.resetToDefaults()
                            } label: {
                                Text(DIRIOSLocalizer.string("settings.planner_ascent_speeds.reset"))
                                    .font(.callout.weight(.semibold))
                                    .foregroundStyle(DIRTheme.cyan)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                            }
                            .buttonStyle(.plain)
                            Text(DIRIOSLocalizer.string("settings.planner_ascent_speeds.footnote"))
                                .font(.caption2)
                                .foregroundStyle(DIRTheme.muted)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 6)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 18)
            }
            .dirCompanionScrollSurface()
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func binding(_ keyPath: WritableKeyPath<PlannerAscentSpeedSettings, Double>) -> Binding<Double> {
        Binding(
            get: { store.settings[keyPath: keyPath] },
            set: { store.settings[keyPath: keyPath] = $0 }
        )
    }

    private func speedField(_ title: String, value: Binding<Double>) -> some View {
        HStack {
            Text(title)
                .font(.callout)
                .foregroundStyle(.white)
            Spacer()
            Text("\(Formatters.one(value.wrappedValue)) m/min")
                .font(.callout.monospacedDigit())
                .foregroundStyle(.white)
                .frame(width: 96, alignment: .trailing)
            HStack(spacing: 1) {
                Button {
                    value.wrappedValue = max(
                        IOSAlgorithmConfiguration.minPlannerAscentSpeedMetersPerMinute,
                        value.wrappedValue - 0.5
                    )
                } label: {
                    Image(systemName: "minus")
                        .frame(width: 28, height: 24)
                }
                Button {
                    value.wrappedValue = min(
                        IOSAlgorithmConfiguration.maxPlannerAscentSpeedMetersPerMinute,
                        value.wrappedValue + 0.5
                    )
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 28, height: 24)
                }
                .disabled(
                    value.wrappedValue >= IOSAlgorithmConfiguration.maxPlannerAscentSpeedMetersPerMinute - 0.001
                )
            }
            .font(.caption.weight(.bold))
            .foregroundStyle(DIRTheme.cyan)
            .background(RoundedRectangle(cornerRadius: 5).fill(DIRTheme.surface2))
        }
        .padding(.vertical, 10)
    }
}
