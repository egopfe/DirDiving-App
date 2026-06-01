import SwiftUI

private enum IOSLegalLinks {
    static let termsURL = URL(string: "https://github.com/egopfe/DirDiving-App/blob/main/Docs/TERMS_OF_USE.md")!
    static let privacyURL = URL(string: "https://github.com/egopfe/DirDiving-App/blob/main/Docs/PRIVACY_AND_DATA_USE.md")!
}

struct IOSLegalOnboardingView: View {
    @EnvironmentObject private var legalAcceptance: LegalAcceptanceStore
    let languageCode: String

    @State private var step = 0
    @State private var disclaimerReachedBottom = false
    @State private var certifiedDiver = false
    @State private var understandsNotDiveComputer = false
    @State private var notPrimaryLifeSupport = false
    @State private var acceptedTerms = false
    @State private var acknowledgedDepthOperatingLimits = false
    @State private var showExitGuidance = false

    private var canAccept: Bool {
        certifiedDiver && understandsNotDiveComputer && notPrimaryLifeSupport && acceptedTerms
            && acknowledgedDepthOperatingLimits
    }

    var body: some View {
        ZStack {
            DIRBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    hero

                    Group {
                        switch step {
                        case 0:
                            welcomeScreen
                        case 1:
                            safetyScreen
                        case 2:
                            disclaimerScreen
                        default:
                            acceptanceScreen
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
                .padding(20)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
        }
        .alert("Exit App", isPresented: $showExitGuidance) {
            Button("I Understand", role: .cancel) {}
        } message: {
            Text("Close DIR Diving from the system app switcher if you do not accept the safety terms.")
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 10) {
                Image(systemName: "drop.fill")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(DIRTheme.cyan)
                Text("DIR DIVING")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
            }
            Text("iOS Companion")
                .font(.title3.weight(.semibold))
                .foregroundStyle(DIRTheme.muted)
            Text("Legal and safety onboarding")
                .font(.caption.weight(.bold))
                .foregroundStyle(DIRTheme.cyan)
                .textCase(.uppercase)
        }
    }

    private var welcomeScreen: some View {
        VStack(spacing: 16) {
            DIRCard("Welcome", icon: "checkmark.shield.fill", accent: DIRTheme.cyan) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Welcome to DIR Diving")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Before using the app, review and accept the safety disclaimer.")
                        .font(DIRTypography.body)
                        .foregroundStyle(DIRTheme.muted)
                        .lineSpacing(DIRTypography.bodyLineSpacing)
                    safetyBadge
                }
            }
            primaryButton("Continue", systemImage: "chevron.right", color: DIRTheme.cyan) {
                advance(to: 1)
            }
        }
    }

    private var safetyScreen: some View {
        VStack(spacing: 16) {
            DIRCard("Safety Warning", icon: "exclamationmark.triangle.fill", accent: DIRTheme.red) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("DIR Diving is NOT a dive computer.")
                        .font(.system(size: 25, weight: .black, design: .rounded))
                        .foregroundStyle(DIRTheme.red)
                    warningRow("Not for decompression management")
                    warningRow("Not for life-support use")
                    warningRow("Always use certified redundant instruments")
                    warningRow("Diving involves risk of serious injury or death")
                }
            }
            HStack(spacing: 12) {
                primaryButton("Exit App", systemImage: "xmark", color: DIRTheme.red) {
                    showExitGuidance = true
                }
                primaryButton("I Understand", systemImage: "checkmark", color: DIRTheme.green) {
                    advance(to: 2)
                }
            }
        }
    }

    private var disclaimerScreen: some View {
        VStack(spacing: 16) {
            DIRCard(String(localized: "Legal Disclaimer"), icon: "doc.text.magnifyingglass", accent: DIRTheme.yellow) {
                VStack(alignment: .leading, spacing: 14) {
                    LegalDisclaimerScrollGate(reachedBottom: $disclaimerReachedBottom, maxHeight: 280) {
                        Text(legalAcceptance.disclaimerText(languageCode: languageCode))
                            .dirLegalBodyStyle()
                    }

                    if !disclaimerReachedBottom {
                        Text(String(localized: "legal.scroll.prompt"))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(DIRTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if disclaimerReachedBottom {
                        primaryButton(String(localized: "Continue"), systemImage: "chevron.right", color: DIRTheme.yellow) {
                            advance(to: 3)
                        }
                    }
                }
            }
        }
    }

    private var acceptanceScreen: some View {
        VStack(spacing: 16) {
            DIRCard("Acceptance", icon: "signature", accent: DIRTheme.green) {
                VStack(alignment: .leading, spacing: 10) {
                    acceptanceToggle("I am a certified diver", isOn: $certifiedDiver)
                    acceptanceToggle("I understand this is NOT a dive computer", isOn: $understandsNotDiveComputer)
                    acceptanceToggle("I will not use this app as a primary life-support instrument", isOn: $notPrimaryLifeSupport)
                    acceptanceToggle("I accept the Terms and Disclaimer", isOn: $acceptedTerms)
                    acceptanceToggle(
                        "I understand that DIR Diving is intended to operate only within Apple’s documented underwater API operating limits and that readings outside this range may be unreliable.",
                        isOn: $acknowledgedDepthOperatingLimits
                    )
                }
            }

            Button {
                guard disclaimerReachedBottom, canAccept else { return }
                legalAcceptance.accept(
                    languageCode: languageCode,
                    acknowledgedDepthOperatingLimits: acknowledgedDepthOperatingLimits
                )
            } label: {
                Label("Continue", systemImage: "checkmark.seal.fill")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(canAccept ? .black : DIRTheme.muted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(canAccept ? DIRTheme.green : DIRTheme.faint)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(canAccept ? DIRTheme.green : DIRTheme.hairline, lineWidth: 1))
                    )
            }
            .disabled(!canAccept || !disclaimerReachedBottom)
            .buttonStyle(.plain)
        }
    }

    private var safetyBadge: some View {
        Label("NOT A DIVE COMPUTER", systemImage: "exclamationmark.triangle.fill")
            .font(.caption.weight(.black))
            .foregroundStyle(DIRTheme.red)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(DIRTheme.red.opacity(0.12))
                    .overlay(Capsule().stroke(DIRTheme.red.opacity(0.8), lineWidth: 1))
            )
    }

    private func warningRow(_ title: String) -> some View {
        Label {
            Text(LocalizedStringKey(title))
                .font(.body.weight(.medium))
                .foregroundStyle(.white)
        } icon: {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(DIRTheme.yellow)
        }
    }

    private func acceptanceToggle(_ title: String, isOn: Binding<Bool>) -> some View {
        Button {
            isOn.wrappedValue.toggle()
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isOn.wrappedValue ? "checkmark.square.fill" : "square")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(isOn.wrappedValue ? DIRTheme.green : DIRTheme.muted)
                Text(LocalizedStringKey(title))
                    .font(.body.weight(.medium))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .padding(.vertical, 7)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func primaryButton(_ title: String, systemImage: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(LocalizedStringKey(title), systemImage: systemImage)
                .font(.headline.weight(.bold))
                .foregroundStyle(color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(color, lineWidth: 1))
                )
        }
        .buttonStyle(.plain)
    }

    private func advance(to nextStep: Int) {
        withAnimation(.easeInOut(duration: 0.22)) {
            step = nextStep
        }
    }
}

struct IOSLegalSafetyView: View {
    @EnvironmentObject private var legalAcceptance: LegalAcceptanceStore
    @AppStorage(DIRIOSAppLanguage.storageKey) private var appLanguage = DIRIOSAppLanguage.system.rawValue

    private var languageCode: String {
        DIRIOSAppLanguage.fromStorage(appLanguage).resolvedLanguageCode
    }

    var body: some View {
        ZStack {
            DIRBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(String(localized: "Legal & Safety"))
                            .dirScreenTitleStyle()
                        Text("DIR Diving is NOT a dive computer.")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(DIRTheme.red)
                    }

                    DIRCard(String(localized: "Acceptance Log"), icon: "checkmark.seal.fill", accent: DIRTheme.green) {
                        row(String(localized: "Version accepted"), legalAcceptance.acceptedVersionText)
                        row(String(localized: "Acceptance timestamp"), legalAcceptance.acceptedTimestampText)
                        row(String(localized: "Language"), legalAcceptance.acceptedLanguageText)
                    }

                    DIRCard(String(localized: "Full disclaimer"), icon: "doc.text.magnifyingglass", accent: DIRTheme.yellow) {
                        Text(legalAcceptance.disclaimerText(languageCode: languageCode))
                            .dirLegalBodyStyle()
                    }

                    DIRCard(String(localized: "Terms & Privacy"), icon: "link", accent: DIRTheme.cyan) {
                        Link(destination: IOSLegalLinks.termsURL) {
                            Label(String(localized: "Terms"), systemImage: "doc.plaintext")
                                .foregroundStyle(DIRTheme.cyan)
                        }
                        Link(destination: IOSLegalLinks.privacyURL) {
                            Label(String(localized: "Privacy"), systemImage: "hand.raised")
                                .foregroundStyle(DIRTheme.cyan)
                        }
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle(Text(String(localized: "Legal & Safety")))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(LocalizedStringKey(title))
                .foregroundStyle(DIRTheme.muted)
            Spacer()
            Text(value)
                .foregroundStyle(.white)
                .multilineTextAlignment(.trailing)
        }
        .font(.callout)
        .padding(.vertical, 4)
    }
}
