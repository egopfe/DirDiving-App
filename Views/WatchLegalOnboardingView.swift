import SwiftUI

private enum WatchLegalLinks {
    static let termsURL = "https://github.com/egopfe/DirDiving-App/blob/main/Docs/TERMS_OF_USE.md"
    static let privacyURL = "https://github.com/egopfe/DirDiving-App/blob/main/Docs/PRIVACY_AND_DATA_USE.md"
}

struct WatchLegalOnboardingView: View {
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
            DiveScreenBackground()

            ScrollView {
                VStack(spacing: 10) {
                    header

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
                .padding(.horizontal, DiveUI.screenPadding)
                .padding(.top, 9)
                .padding(.bottom, 12)
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert(String(localized: "legal.exit.title"), isPresented: $showExitGuidance) {
            Button(String(localized: "I Understand"), role: .cancel) {}
        } message: {
            Text(String(localized: "Close DIR Diving from the system app switcher if you do not accept the safety terms."))
        }
    }

    private var header: some View {
        HStack(spacing: 7) {
            DiveOctopusLogo(accent: DiveUI.blue)
                .frame(width: 28, height: 25)
                .scaleEffect(0.78)
            Text("DIR DIVING")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(DiveUI.yellow)
                .lineLimit(1)
            Spacer()
            DiveClockText(size: 14)
        }
    }

    private var welcomeScreen: some View {
        VStack(spacing: 10) {
            DivePanel(stroke: DiveUI.cyan) {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 25, weight: .black))
                        .foregroundStyle(DiveUI.cyan)
                    Text(String(localized: "Welcome to DIR Diving"))
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text(String(localized: "Before using the app, review and accept the safety disclaimer."))
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(DiveUI.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    DiveStatusPill(String(localized: "NOT A DIVE COMPUTER"), color: DiveUI.red, systemImage: "exclamationmark.triangle.fill")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            DiveCommandButton(String(localized: "Continue"), systemImage: "chevron.right", color: DiveUI.cyan) {
                withAnimation(.easeInOut(duration: 0.2)) { step = 1 }
            }
        }
    }

    private var safetyScreen: some View {
        VStack(spacing: 9) {
            DivePanel(stroke: DiveUI.red) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "DIR Diving is NOT a dive computer."))
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(DiveUI.red)
                        .fixedSize(horizontal: false, vertical: true)
                    warningRow(String(localized: "Not for decompression management"))
                    warningRow(String(localized: "Not for life-support use"))
                    warningRow(String(localized: "Always use certified redundant instruments"))
                    warningRow(String(localized: "Diving involves risk of serious injury or death"))
                }
            }

            HStack(spacing: 8) {
                DiveCommandButton(String(localized: "Exit App"), systemImage: "xmark", color: DiveUI.red) {
                    showExitGuidance = true
                }
                DiveCommandButton(String(localized: "I Understand"), systemImage: "checkmark", color: DiveUI.green) {
                    withAnimation(.easeInOut(duration: 0.2)) { step = 2 }
                }
            }
        }
    }

    private var disclaimerScreen: some View {
        VStack(spacing: 9) {
            DivePanel(stroke: DiveUI.yellow) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "Legal Disclaimer"))
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundStyle(DiveUI.yellow)

                    LegalDisclaimerScrollGate(reachedBottom: $disclaimerReachedBottom, maxHeight: 118) {
                        Text(legalAcceptance.disclaimerText(languageCode: languageCode))
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if !disclaimerReachedBottom {
                        Text(String(localized: "legal.scroll.prompt"))
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(DiveUI.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if disclaimerReachedBottom {
                        DiveCommandButton(String(localized: "Continue"), systemImage: "chevron.right", color: DiveUI.yellow) {
                            withAnimation(.easeInOut(duration: 0.2)) { step = 3 }
                        }
                    }
                }
            }
        }
    }

    private var acceptanceScreen: some View {
        VStack(spacing: 9) {
            DivePanel(stroke: DiveUI.green) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "Acceptance"))
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundStyle(DiveUI.green)
                    acceptanceToggle(String(localized: "I am a certified diver"), isOn: $certifiedDiver)
                    acceptanceToggle(String(localized: "I understand this is NOT a dive computer"), isOn: $understandsNotDiveComputer)
                    acceptanceToggle(String(localized: "I will not use this app as a primary life-support instrument"), isOn: $notPrimaryLifeSupport)
                    acceptanceToggle(String(localized: "I accept the Terms and Disclaimer"), isOn: $acceptedTerms)
                    acceptanceToggle(
                        String(localized: "I understand that DIR Diving is intended to operate only within Apple’s documented underwater API operating limits and that readings outside this range may be unreliable."),
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
                HStack {
                    Text(String(localized: "Continue"))
                    Image(systemName: "checkmark.seal.fill")
                }
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(canAccept ? DiveUI.green : DiveUI.mutedText)
                .frame(maxWidth: .infinity, minHeight: 38)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill((canAccept ? DiveUI.green : Color.white).opacity(canAccept ? 0.14 : 0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(canAccept ? DiveUI.green : DiveUI.hairline, lineWidth: 1)
                        )
                )
            }
            .disabled(!canAccept || !disclaimerReachedBottom)
            .buttonStyle(.plain)
        }
    }

    private func warningRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(DiveUI.yellow)
            Text(text)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func acceptanceToggle(_ title: String, isOn: Binding<Bool>) -> some View {
        Button {
            isOn.wrappedValue.toggle()
        } label: {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: isOn.wrappedValue ? "checkmark.square.fill" : "square")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(isOn.wrappedValue ? DiveUI.green : DiveUI.secondaryText)
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct WatchLegalSafetyView: View {
    @EnvironmentObject private var legalAcceptance: LegalAcceptanceStore
    @Environment(\.openURL) private var openURL
    @AppStorage(DIRAppLanguage.storageKey) private var appLanguage = DIRAppLanguage.system.rawValue

    private var languageCode: String {
        DIRAppLanguage.fromStorage(appLanguage).resolvedLanguageCode
    }

    var body: some View {
        ZStack {
            DiveScreenBackground()

            ScrollView {
                VStack(spacing: 9) {
                    HStack {
                        WatchDetailBackButton()
                        Spacer()
                    }
                    DiveScreenHeader(
                        String(localized: "Legal & Safety"),
                        subtitle: String(localized: "NOT A DIVE COMPUTER"),
                        accent: DiveUI.red,
                        systemImage: "checkmark.shield.fill"
                    )

                    DivePanel(stroke: DiveUI.red) {
                        VStack(alignment: .leading, spacing: 7) {
                            Text(String(localized: "DIR Diving is NOT a dive computer."))
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundStyle(DiveUI.red)
                            infoRow(String(localized: "Version accepted"), legalAcceptance.acceptedVersionText)
                            infoRow(String(localized: "Acceptance timestamp"), legalAcceptance.acceptedTimestampText)
                            infoRow(String(localized: "Language"), legalAcceptance.acceptedLanguageText)
                        }
                    }

                    DivePanel(stroke: DiveUI.yellow) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(localized: "Full disclaimer"))
                                .font(.system(size: 14, weight: .black, design: .rounded))
                                .foregroundStyle(DiveUI.yellow)
                            Text(legalAcceptance.disclaimerText(languageCode: languageCode))
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.9))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    HStack(spacing: 8) {
                        legalLink(String(localized: "Terms"), url: WatchLegalLinks.termsURL)
                        legalLink(String(localized: "Privacy"), url: WatchLegalLinks.privacyURL)
                    }
                }
                .padding(.horizontal, DiveUI.screenPadding)
                .padding(.top, 9)
                .padding(.bottom, 12)
            }
        }
    }

    private func infoRow(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(DiveUI.secondaryText)
            Text(value)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func legalLink(_ title: String, url: String) -> some View {
        Button {
            if let destination = URL(string: url) {
                openURL(destination)
            }
        } label: {
            Text(title)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(DiveUI.cyan)
                .frame(maxWidth: .infinity, minHeight: 34)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(DiveUI.cyan.opacity(0.1))
                        .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(DiveUI.cyan.opacity(0.8), lineWidth: 1))
                )
        }
        .buttonStyle(.plain)
    }
}
