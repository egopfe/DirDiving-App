import SwiftUI

/// Current GF value confirmation states (mockup screens 6–8).
struct FullComputerGradientFactorCurrentValueView: View {
    let resolved: FullComputerResolvedGradientFactors

    var body: some View {
        ScrollView {
            VStack(spacing: DiveUI.spaceL) {
                ZStack {
                    Circle()
                        .fill(statusBackground)
                        .frame(width: 72, height: 72)
                    Image(systemName: statusSymbol)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(statusForeground)
                }

                Text(resolved.valueText)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()

                Text(resolved.source.localizedLabel)
                    .font(DiveUI.Typography.hintCaptionBold)
                    .foregroundStyle(statusForeground)

                Text(bodyCopy)
                    .font(DiveUI.Typography.hintCaption)
                    .foregroundStyle(DiveUI.secondaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, DiveUI.screenPadding)
            .padding(.vertical, 16)
        }
        .navigationTitle(String(localized: "full_computer.gradient_factors.title"))
    }

    private var statusSymbol: String {
        if resolved.lockReason == .activeDive {
            return "lock.fill"
        }
        if resolved.source == .iosPlan || resolved.isLocked {
            return "lock.fill"
        }
        return "checkmark"
    }

    private var statusBackground: Color {
        if resolved.lockReason == .activeDive {
            return DiveUI.red.opacity(0.22)
        }
        if resolved.source == .iosPlan {
            return DiveUI.orange.opacity(0.22)
        }
        return DiveUI.green.opacity(0.22)
    }

    private var statusForeground: Color {
        if resolved.lockReason == .activeDive {
            return DiveUI.red
        }
        if resolved.source == .iosPlan {
            return DiveUI.orange
        }
        return DiveUI.green
    }

    private var bodyCopy: String {
        if resolved.lockReason == .activeDive {
            return String(localized: "full_computer.gradient_factors.locked.active_dive")
        }
        if resolved.source == .iosPlan {
            return String(localized: "full_computer.gradient_factors.ios_plan.body")
        }
        return String(localized: "full_computer.gradient_factors.watch_settings.body")
    }
}
