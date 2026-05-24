import SwiftUI

/// Lightweight companion disclaimer shown on every cold launch after legal onboarding.
struct LaunchCompanionDisclaimerOverlay: ViewModifier {
    @Binding var isPresented: Bool

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                ZStack {
                    DiveScreenBackground()
                    VStack(spacing: 14) {
                        DiveOctopusLogo(accent: DiveUI.cyan)
                            .frame(width: 36, height: 32)
                        Text(String(localized: "launch.companion_disclaimer.title"))
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundStyle(DiveUI.yellow)
                            .multilineTextAlignment(.center)
                        Text(String(localized: "launch.companion_disclaimer.body"))
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.92))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 8)
                        DiveCommandButton(String(localized: "Continue"), systemImage: "checkmark", color: DiveUI.green) {
                            CompanionDisclaimerAcceptance.accept()
                            isPresented = false
                        }
                    }
                    .padding(16)
                }
            }
    }
}

extension View {
    func launchCompanionDisclaimer(isPresented: Binding<Bool>) -> some View {
        modifier(LaunchCompanionDisclaimerOverlay(isPresented: isPresented))
    }
}
