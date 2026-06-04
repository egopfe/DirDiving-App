import SwiftUI

/// Inline ascent-speed alarm on the live dive screen (non-blocking).
/// Visual target: `Docs/ReferenceUI/ascent_alarm.png` and product mockup 2026-05-20.
struct AscentWarningBannerView: View {
    let rateMetersPerMinute: Double
    let isActive: Bool
    var units: DIRUnitPreference = .metric

    @State private var borderPulse = false

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.arrowtriangle.up.fill")
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(DiveUI.alarmRed)
                .symbolRenderingMode(.hierarchical)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 2) {
                Text("ascent_alarm_title", bundle: .main)
                    .font(DiveUI.Typography.bannerTitle)
                    .foregroundStyle(DiveUI.alarmRed)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)

                HStack(spacing: 0) {
                    if rateMetersPerMinute > 0.05 {
                        Text(speedLine)
                            .font(DiveUI.Typography.bannerSubtitle)
                            .foregroundStyle(DiveUI.alarmText)
                            .monospacedDigit()
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)

                        Rectangle()
                            .fill(DiveUI.alarmText.opacity(0.35))
                            .frame(width: 1, height: 10)
                            .padding(.horizontal, 5)
                    }

                    Text("ascent_alarm_instruction", bundle: .main)
                        .font(DiveUI.Typography.bannerSubtitle)
                        .foregroundStyle(DiveUI.alarmText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "bell.and.waves.left.and.right.fill")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(DiveUI.alarmRed.opacity(0.9))
                .symbolRenderingMode(.hierarchical)
                .frame(width: 18)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, minHeight: 44)
        .background(
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(DiveUI.alarmFill.opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(DiveUI.alarmRed.opacity(borderPulse ? 1.0 : 0.72), lineWidth: 1.2)
                )
                .shadow(color: DiveUI.alarmRed.opacity(borderPulse ? 0.22 : 0.12), radius: 4, x: 0, y: 0)
        )
        .opacity(isActive ? 1 : 0)
        .offset(y: isActive ? 0 : -6)
        .animation(.easeInOut(duration: 0.3), value: isActive)
        .onAppear {
            guard isActive else { return }
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                borderPulse = true
            }
        }
        .onChange(of: isActive) { _, active in
            if active {
                borderPulse = false
                withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                    borderPulse = true
                }
            } else {
                borderPulse = false
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
        .accessibilityHint(String(localized: "ascent_alarm_accessibility_hint", bundle: .main))
    }

    private var speedLine: String {
        let display = units.ascentRateDisplay(metersPerMinute: rateMetersPerMinute)
        return "+\(Formatters.one(display.value)) \(display.unit)"
    }

    private var accessibilitySummary: String {
        let title = String(localized: "ascent_alarm_title", bundle: .main)
        let instruction = String(localized: "ascent_alarm_instruction", bundle: .main)
        if rateMetersPerMinute > 0.05 {
            return "\(title). \(speedLine). \(instruction)"
        }
        return "\(title). \(instruction)"
    }
}
