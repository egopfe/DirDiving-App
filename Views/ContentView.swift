import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var navigation: AppNavigationStore
    @EnvironmentObject private var dive: DiveManager
    @EnvironmentObject private var imageStore: UserImageStore
    @AppStorage(WatchNavigationHints.crownHintDismissedKey) private var crownHintDismissed = false
    @State private var showLaunchDisclaimer = CompanionDisclaimerAcceptance.requiresDisplay

    var body: some View {
        TabView(selection: $navigation.selectedPage) {
            // MAIN stable runtime is single-mode Diving. Keep this scaffold hidden unless
            // multiple stable modes are explicitly enabled in a future non-experimental release.
            if WatchModeSelectionPreferences.hasMultipleStableModes {
                ModeSelectionView()
                    .tag(AppPage.modeSelection)
            }
            DiveLiveView()
                .tag(AppPage.live)
            SnorkelingView()
                .tag(AppPage.snorkeling)
            ApneaView()
                .tag(AppPage.apnea)
            CompassView()
                .tag(AppPage.compass)
            SettingsView()
                .tag(AppPage.settings)
            AlarmSettingsView()
                .tag(AppPage.alarmSettings)
            AscentRateSettingsView()
                .tag(AppPage.ascentSettings)
            InfoView()
                .tag(AppPage.info)
            UserImagesView()
                .tag(AppPage.userImages)
            DiveLogListView()
                .tag(AppPage.diveLog)
            BuddyAssistView()
                .tag(AppPage.buddyAssist)
        }
        .tabViewStyle(.verticalPage)
        .onAppear {
            navigation.clampSelectedPage()
        }
        .onChange(of: imageStore.imageNames) { _, _ in
            navigation.clampSelectedPage()
        }
        .onChange(of: dive.isDiveActive) { _, isActive in
            if isActive {
                navigation.selectedPage = .live
            }
        }
        .onChange(of: navigation.selectedPage) { _, page in
            guard dive.isDiveActive else { return }
            // During an active dive, only Live and Compass remain reachable (v9: images/menus available on surface).
            if page != .live && page != .compass {
                navigation.reportUnderwaterNavigationBlocked()
                navigation.selectedPage = .live
            }
        }
        .overlay(alignment: .bottom) {
            if let toast = navigation.underwaterNavigationToast {
                navigationToast(toast)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .overlay(alignment: .bottom) {
            if !crownHintDismissed, navigation.selectedPage == .live, !dive.isDiveActive {
                crownNavigationHint
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.22), value: navigation.underwaterNavigationToast)
        .animation(.easeInOut(duration: 0.22), value: crownHintDismissed)
        .launchCompanionDisclaimer(isPresented: $showLaunchDisclaimer)
    }

    private func navigationToast(_ message: String) -> some View {
        Text(message)
            .font(DiveUI.Typography.hintCaptionBold)
            .foregroundStyle(DiveUI.yellow)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(DiveUI.yellow.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(DiveUI.yellow.opacity(0.72), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 10)
            .padding(.bottom, 6)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isStaticText)
            .accessibilityLabel(String(localized: "nav.underwater.blocked.a11y.label"))
            .accessibilityValue(message)
    }

    private var crownNavigationHint: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "digitalcrown.arrow.clockwise")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(DiveUI.cyan)
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "nav.crown.hint.title"))
                        .font(DiveUI.Typography.hintCaptionBold)
                        .foregroundStyle(.white)
                    Text(String(localized: "nav.crown.hint.body"))
                        .font(DiveUI.Typography.hintCaption)
                        .foregroundStyle(DiveUI.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            Button {
                crownHintDismissed = true
                WatchNavigationHints.dismissCrownHint()
                HapticService.shared.confirm()
            } label: {
                Text(String(localized: "nav.crown.hint.dismiss"))
                    .font(DiveUI.Typography.hintCaptionBold)
                    .foregroundStyle(DiveUI.cyan)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .stroke(DiveUI.cyan.opacity(0.75), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.black.opacity(0.88))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(DiveUI.cyan.opacity(0.55), lineWidth: 1)
                )
        )
        .padding(.horizontal, 10)
        .padding(.bottom, 6)
    }
}
