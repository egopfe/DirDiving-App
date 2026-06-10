import SwiftUI

struct PlannerCNSDescentBottomSettingsCard: View {
    @AppStorage(PlannerCNSDescentBottomCheckSettings.storageKey) private var cnsDescentBottomCheckEnabled = PlannerCNSDescentBottomCheckSettings.defaultEnabled
    @AppStorage(PlannerCNSDescentBottomCheckSettings.thresholdStorageKey) private var cnsThresholdPercent = PlannerCNSDescentBottomCheckSettings.defaultThresholdPercent

    private var cnsThresholdPercentBinding: Binding<Int> {
        Binding(
            get: { PlannerCNSDescentBottomCheckSettings.clamp(cnsThresholdPercent) },
            set: { cnsThresholdPercent = PlannerCNSDescentBottomCheckSettings.clamp($0) }
        )
    }

    var body: some View {
        DIRCard(DIRIOSLocalizer.string("planner.settings.cns_descent_bottom.title"), icon: "lungs.fill", accent: DIRTheme.cyan) {
            VStack(alignment: .leading, spacing: 10) {
                Toggle(isOn: $cnsDescentBottomCheckEnabled) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(DIRIOSLocalizer.string("planner.settings.cns_descent_bottom.toggle"))
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.white)
                        Text(DIRIOSLocalizer.string("planner.settings.cns_descent_bottom.toggle_hint"))
                            .font(.caption2)
                            .foregroundStyle(DIRTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .tint(DIRTheme.cyan)
                .accessibilityHint(DIRIOSLocalizer.string("planner.settings.cns_descent_bottom.toggle.a11y"))

                if cnsDescentBottomCheckEnabled {
                    Divider().overlay(DIRTheme.hairline)
                    cnsThresholdStepper
                }

                Text(DIRIOSLocalizer.string("planner.settings.cns_descent_bottom.reference_only"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.yellow)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var cnsThresholdStepper: some View {
        HStack {
            Text(DIRIOSLocalizer.string("planner.settings.cns_descent_bottom.threshold"))
                .font(.callout)
                .foregroundStyle(.white)
            Spacer()
            Text("\(cnsThresholdPercentBinding.wrappedValue) %")
                .font(.callout.monospacedDigit())
                .foregroundStyle(.white)
                .frame(width: 56, alignment: .trailing)
            HStack(spacing: 1) {
                Button {
                    cnsThresholdPercentBinding.wrappedValue -= 1
                } label: {
                    Image(systemName: "minus")
                        .frame(width: 28, height: 24)
                }
                .disabled(cnsThresholdPercentBinding.wrappedValue <= PlannerCNSDescentBottomCheckSettings.minimumThresholdPercent)
                Button {
                    cnsThresholdPercentBinding.wrappedValue += 1
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 28, height: 24)
                }
                .disabled(cnsThresholdPercentBinding.wrappedValue >= PlannerCNSDescentBottomCheckSettings.maximumThresholdPercent)
            }
            .font(.caption.weight(.bold))
            .foregroundStyle(DIRTheme.cyan)
            .background(RoundedRectangle(cornerRadius: 5).fill(DIRTheme.surface2))
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            String(
                format: DIRIOSLocalizer.string("planner.settings.cns_descent_bottom.threshold.a11y"),
                cnsThresholdPercentBinding.wrappedValue
            )
        )
    }
}
