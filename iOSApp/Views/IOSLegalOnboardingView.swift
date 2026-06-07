import SwiftUI

private enum IOSLegalLinks {
    static let termsURL = URL(string: "https://github.com/egopfe/DirDiving-App/blob/main/Docs/TERMS_OF_USE.md")
        ?? URL(fileURLWithPath: "")
    static let privacyURL = URL(string: "https://github.com/egopfe/DirDiving-App/blob/main/Docs/PRIVACY_AND_DATA_USE.md")
        ?? URL(fileURLWithPath: "")
}

struct IOSLegalOnboardingView: View {
    @EnvironmentObject private var legalAcceptance: LegalAcceptanceStore
    @Environment(\.iosCompanionViewportMetrics) private var viewportMetrics
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
        DIRDisclaimerScreen(verticalLayout: .top) {
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
                .accessibilityLabel(String(format: String(localized: "ios.legal.step.format"), step + 1, 4))
            }
        }
        .alert(String(localized: "ios.legal.exit_alert.title"), isPresented: $showExitGuidance) {
            Button(String(localized: "ios.legal.exit_alert.confirm"), role: .cancel) {}
        } message: {
            Text(String(localized: "ios.legal.exit_guidance.body"))
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
            Text(String(localized: "ios.legal.hero.subtitle"))
                .font(.title3.weight(.semibold))
                .foregroundStyle(DIRTheme.muted)
            Text(String(localized: "ios.legal.hero.onboarding_caption"))
                .font(.caption.weight(.bold))
                .foregroundStyle(DIRTheme.cyan)
                .textCase(.uppercase)
        }
    }

    private var welcomeScreen: some View {
        VStack(spacing: 16) {
            DIRCard(String(localized: "ios.legal.welcome.card"), icon: "checkmark.shield.fill", accent: DIRTheme.cyan) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(String(localized: "ios.legal.welcome.title"))
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(String(localized: "ios.legal.welcome.body"))
                        .font(DIRTypography.body)
                        .foregroundStyle(DIRTheme.muted)
                        .lineSpacing(DIRTypography.bodyLineSpacing)
                    safetyBadge
                }
            }
            primaryButton(String(localized: "ios.legal.welcome.continue"), systemImage: "chevron.right", color: DIRTheme.cyan) {
                advance(to: 1)
            }
        }
    }

    private var safetyScreen: some View {
        VStack(spacing: 16) {
            DIRCard(String(localized: "ios.legal.safety.card"), icon: "exclamationmark.triangle.fill", accent: DIRTheme.red) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(String(localized: "ios.legal.safety.not_dive_computer"))
                        .font(.system(size: 25, weight: .black, design: .rounded))
                        .foregroundStyle(DIRTheme.red)
                    warningRow(String(localized: "ios.legal.safety.warning.deco"))
                    warningRow(String(localized: "ios.legal.safety.warning.life_support"))
                    warningRow(String(localized: "ios.legal.safety.warning.redundant"))
                    warningRow(String(localized: "ios.legal.safety.warning.risk"))
                }
            }
            HStack(spacing: 12) {
                primaryButton(String(localized: "ios.legal.safety.exit"), systemImage: "xmark", color: DIRTheme.red) {
                    showExitGuidance = true
                }
                primaryButton(String(localized: "ios.legal.safety.understand"), systemImage: "checkmark", color: DIRTheme.green) {
                    advance(to: 2)
                }
            }
        }
    }

    private var disclaimerScreen: some View {
        VStack(spacing: 16) {
            DIRCard(String(localized: "ios.legal.disclaimer.card"), icon: "doc.text.magnifyingglass", accent: DIRTheme.yellow) {
                VStack(alignment: .leading, spacing: 14) {
                    LegalDisclaimerScrollGate(
                        reachedBottom: $disclaimerReachedBottom,
                        maxHeight: viewportMetrics.disclaimerScrollHeight()
                    ) {
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
                        primaryButton(String(localized: "ios.legal.disclaimer.continue"), systemImage: "chevron.right", color: DIRTheme.yellow) {
                            advance(to: 3)
                        }
                    }
                }
            }
        }
    }

    private var acceptanceScreen: some View {
        VStack(spacing: 16) {
            DIRCard(String(localized: "ios.legal.acceptance.card"), icon: "signature", accent: DIRTheme.green) {
                VStack(alignment: .leading, spacing: 10) {
                    acceptanceToggle(String(localized: "ios.legal.acceptance.certified"), isOn: $certifiedDiver)
                    acceptanceToggle(String(localized: "ios.legal.acceptance.not_dive_computer"), isOn: $understandsNotDiveComputer)
                    acceptanceToggle(String(localized: "ios.legal.acceptance.not_life_support"), isOn: $notPrimaryLifeSupport)
                    acceptanceToggle(String(localized: "ios.legal.acceptance.terms"), isOn: $acceptedTerms)
                    acceptanceToggle(
                        String(localized: "ios.legal.acceptance.depth_limits"),
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
                Label(String(localized: "ios.legal.acceptance.continue"), systemImage: "checkmark.seal.fill")
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
        Label(String(localized: "ios.legal.badge.not_dive_computer"), systemImage: "exclamationmark.triangle.fill")
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
            Text(title)
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
                Text(title)
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
            Label(title, systemImage: systemImage)
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
        DIRScreenContainer {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(String(localized: "ios.legal.settings.title"))
                            .dirScreenTitleStyle()
                        Text(String(localized: "ios.legal.safety_view.not_dive_computer"))
                            .font(.headline.weight(.bold))
                            .foregroundStyle(DIRTheme.red)
                    }

                    DIRCard(String(localized: "ios.legal.settings.acceptance_log"), icon: "checkmark.seal.fill", accent: DIRTheme.green) {
                        row(String(localized: "ios.legal.settings.version_accepted"), legalAcceptance.acceptedVersionText)
                        row(String(localized: "ios.legal.settings.acceptance_timestamp"), legalAcceptance.acceptedTimestampText)
                        row(String(localized: "ios.legal.settings.language"), legalAcceptance.acceptedLanguageText)
                    }

                    DIRCard(String(localized: "ios.legal.settings.full_disclaimer"), icon: "doc.text.magnifyingglass", accent: DIRTheme.yellow) {
                        Text(legalAcceptance.disclaimerText(languageCode: languageCode))
                            .dirLegalBodyStyle()
                    }

                    DIRCard(String(localized: "ios.legal.settings.terms_privacy"), icon: "link", accent: DIRTheme.cyan) {
                        Link(destination: IOSLegalLinks.termsURL) {
                            Label(String(localized: "ios.legal.settings.terms"), systemImage: "doc.plaintext")
                                .foregroundStyle(DIRTheme.cyan)
                        }
                        Link(destination: IOSLegalLinks.privacyURL) {
                            Label(String(localized: "ios.legal.settings.privacy"), systemImage: "hand.raised")
                                .foregroundStyle(DIRTheme.cyan)
                        }
                    }
                }
                .padding(16)
            }
            .dirCompanionScrollSurface()
        }
        .navigationTitle(Text(String(localized: "ios.legal.settings.title")))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
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
