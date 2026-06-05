import SwiftUI

struct GasMixCard: View {
    @Binding var mix: GasMix
    let accent: Color
    var unitPreference: IOSUnitPreference = .metric
    var plannerEnvironment: PlannerEnvironment = .seaLevelSaltWater
    var allowedMixKinds: [GasMixKind] = GasMixKind.allCases
    var onMixChanged: (() -> Void)? = nil

    var body: some View {
        DIRCard(accent: accent) {
            VStack(alignment: .leading, spacing: 14) {
                Picker("", selection: mixKindBinding) {
                    ForEach(allowedMixKinds) { kind in
                        Text(kind.localizedTitle)
                            .tag(kind)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()

                if mix.mixKind == .trimix {
                    DIRWarningBox(text: String(localized: "planner.gas.trimix_buhlmann_disclaimer"))
                }

                if !mix.isValidMix {
                    Text(String(localized: "planner.gas.mix_invalid"))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(DIRTheme.red)
                }

                HStack(alignment: .top, spacing: 8) {
                    gasMetric(String(localized: "planner.gas.mix_label"), mix.label, alignLeading: true)
                    gasAdjuster(
                        String(localized: "planner.gas.oxygen"),
                        value: mix.oxygen,
                        suffix: "%",
                        step: 0.01,
                        enabled: mix.canEditOxygen
                    ) { mix.setOxygenFraction($0); notifyChange() }
                    gasAdjuster(
                        String(localized: "planner.gas.helium"),
                        value: mix.helium,
                        suffix: "%",
                        step: 0.01,
                        enabled: mix.canEditHelium
                    ) { mix.setHeliumFraction($0); notifyChange() }
                    gasMetric(String(localized: "planner.gas.nitrogen"), "\(Int(mix.nitrogen * 100))%")
                }

                HStack {
                    Text(String(localized: "planner.mod.calculated"))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                    Spacer()
                    Text(Formatters.depth(mix.modMeters(environment: plannerEnvironment), units: unitPreference).text)
                        .font(.caption.monospacedDigit().weight(.semibold))
                        .foregroundStyle(DIRTheme.cyan)
                }

                Divider().overlay(DIRTheme.hairline)

                VStack(spacing: 8) {
                    HStack(spacing: 16) {
                        gasLine(String(localized: "planner.gas.ppo2_max"), Formatters.one(mix.maxPPO2))
                        gasLine(String(localized: "planner.gas.surface_density"), "\(Formatters.one(mix.surfaceDensityGramsLiter)) g/L")
                    }
                    HStack {
                        Text(String(localized: "planner.gas.adjust_ppo2"))
                            .font(.caption)
                            .foregroundStyle(DIRTheme.muted)
                        Spacer()
                        gasStepper(value: mix.maxPPO2, step: 0.1, enabled: true) {
                            mix.setMaxPPO2($0)
                            notifyChange()
                        }
                    }
                }
            }
        }
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(accent)
                .frame(width: 3)
                .padding(.vertical, 8)
        }
    }

    private var mixKindBinding: Binding<GasMixKind> {
        Binding(
            get: { mix.mixKind },
            set: { newKind in
                mix.applyMixKind(newKind)
                notifyChange()
            }
        )
    }

    private func notifyChange() {
        mix.normalizeMixAndPPO2()
        onMixChanged?()
    }

    private func gasMetric(_ title: String, _ value: String, alignLeading: Bool = false) -> some View {
        VStack(alignment: alignLeading ? .leading : .trailing, spacing: 5) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
            Text(value)
                .font(.callout.monospacedDigit())
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: alignLeading ? .leading : .trailing)
    }

    private func gasLine(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(DIRTheme.muted)
            Spacer()
            Text(value)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.white)
        }
    }

    private func gasAdjuster(
        _ title: String,
        value: Double,
        suffix: String,
        step: Double,
        enabled: Bool,
        update: @escaping (Double) -> Void
    ) -> some View {
        VStack(alignment: .trailing, spacing: 5) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
            HStack(spacing: 3) {
                Button { update(value - step) } label: {
                    Image(systemName: "minus")
                        .font(.caption2.weight(.bold))
                        .frame(width: 18, height: 18)
                }
                .disabled(!enabled)
                .accessibilityLabel(String(format: String(localized: "planner.gas.stepper.decrease.a11y"), title))
                Text("\(Int(value * 100))\(suffix)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(enabled ? .white : DIRTheme.muted)
                    .frame(width: 42)
                    .accessibilityLabel(String(format: String(localized: "planner.gas.stepper.value.a11y"), title, String(Int(value * 100)), suffix))
                Button { update(value + step) } label: {
                    Image(systemName: "plus")
                        .font(.caption2.weight(.bold))
                        .frame(width: 18, height: 18)
                }
                .disabled(!enabled)
                .accessibilityLabel(String(format: String(localized: "planner.gas.stepper.increase.a11y"), title))
            }
            .foregroundStyle(enabled ? DIRTheme.cyan : DIRTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .opacity(enabled ? 1 : 0.55)
    }

    private func gasStepper(value: Double, step: Double, enabled: Bool, update: @escaping (Double) -> Void) -> some View {
        let label = String(localized: "planner.gas.adjust_ppo2")
        return HStack(spacing: 5) {
            Button { update(value - step) } label: {
                Image(systemName: "minus")
                    .frame(width: 24, height: 22)
            }
            .disabled(!enabled)
            .accessibilityLabel(String(format: String(localized: "planner.gas.stepper.decrease.a11y"), label))
            Text(Formatters.one(value))
                .font(.callout.monospacedDigit())
                .foregroundStyle(.white)
                .frame(width: 42)
                .accessibilityLabel(String(format: String(localized: "planner.gas.stepper.value.a11y"), label, Formatters.one(value), ""))
            Button { update(value + step) } label: {
                Image(systemName: "plus")
                    .frame(width: 24, height: 22)
            }
            .disabled(!enabled)
            .accessibilityLabel(String(format: String(localized: "planner.gas.stepper.increase.a11y"), label))
        }
        .foregroundStyle(DIRTheme.cyan)
    }
}
