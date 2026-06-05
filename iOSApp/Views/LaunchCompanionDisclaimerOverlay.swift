import SwiftUI

struct LaunchCompanionDisclaimerOverlay: ViewModifier {
    @Binding var isPresented: Bool

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                DIRScreenContainer {
                    VStack(spacing: 18) {
                        DIRBrandMark()
                            .frame(width: 44, height: 44)
                        Text(String(localized: "launch.companion_disclaimer.title"))
                            .font(.title3.weight(.bold))
                            .foregroundStyle(DIRTheme.yellow)
                            .multilineTextAlignment(.center)
                        Text(String(localized: "launch.companion_disclaimer.body"))
                            .font(.body.weight(.medium))
                            .foregroundStyle(.white.opacity(0.92))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 8)
                        Button {
                            CompanionDisclaimerAcceptance.accept()
                            isPresented = false
                        } label: {
                            Label(String(localized: "Continue"), systemImage: "checkmark")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(RoundedRectangle(cornerRadius: 12).fill(DIRTheme.green))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(24)
                }
            }
    }
}

extension View {
    func launchCompanionDisclaimer(isPresented: Binding<Bool>) -> some View {
        modifier(LaunchCompanionDisclaimerOverlay(isPresented: isPresented))
    }
}
