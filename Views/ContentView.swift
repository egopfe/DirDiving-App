import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var navigation: AppNavigationStore
    @EnvironmentObject private var dive: DiveManager
    @EnvironmentObject private var apneaRuntime: ApneaWatchRuntimeStore
    @EnvironmentObject private var snorkelingRuntime: SnorkelingWatchRuntimeStore
    @EnvironmentObject private var snorkelingLogbook: SnorkelingLogbookStore
    @EnvironmentObject private var imageStore: UserImageStore
    @EnvironmentObject private var activitySelection: DIRActivitySelectionStore
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
            CompassView()
                .tag(AppPage.compass)
            SettingsView()
                .tag(AppPage.settings)
            UserImagesView()
                .tag(AppPage.userImages)
            if activitySelection.selectedActivity == .diving {
                DiveLogListView()
                    .tag(AppPage.diveLog)
            }
        }
        .tabViewStyle(.verticalPage)
        .onAppear {
            navigation.clampSelectedPage(
                for: activitySelection.selectedActivity,
                includeModeSelection: WatchModeSelectionPreferences.hasMultipleStableModes
            )
        }
        .onChange(of: activitySelection.selectedActivity) { _, activity in
            navigation.clampSelectedPage(
                for: activity,
                includeModeSelection: WatchModeSelectionPreferences.hasMultipleStableModes
            )
        }
        .onChange(of: imageStore.imageNames) { _, _ in
            navigation.clampSelectedPage(
                for: activitySelection.selectedActivity,
                includeModeSelection: WatchModeSelectionPreferences.hasMultipleStableModes
            )
        }
        .onChange(of: dive.isDiveActive) { _, isActive in
            if isActive {
                navigation.selectedPage = .live
            }
        }
        .onChange(of: apneaRuntime.isSessionActive) { _, isActive in
            if isActive {
                navigation.selectedPage = .live
            }
        }
        .onChange(of: snorkelingRuntime.isSessionActive) { _, isActive in
            if isActive {
                navigation.selectedPage = .live
            }
        }
        .onChange(of: navigation.selectedPage) { _, page in
            guard isAnySessionActive else { return }
            let result = WatchUnderwaterNavigationClampPolicy.clampIfNeeded(
                selectedPage: page,
                activity: activitySelection.selectedActivity,
                divingMode: activitySelection.selectedDivingMode,
                isSessionActive: true,
                hasUserImages: !imageStore.imageNames.isEmpty,
                includeModeSelection: WatchModeSelectionPreferences.hasMultipleStableModes
            )
            if result.wasBlocked {
                navigation.reportUnderwaterNavigationBlocked(activity: activitySelection.selectedActivity)
                navigation.selectedPage = result.page
            }
        }
        .overlay(alignment: .topTrailing) {
            if isAnySessionActive {
                WatchUnderwaterPrimaryActionHintView()
                    .padding(.top, 4)
                    .padding(.trailing, 6)
            }
        }
        .overlay(alignment: .bottom) {
            if let toast = navigation.hardwareActionToast {
                navigationToast(toast)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .overlay(alignment: .bottom) {
            if let toast = navigation.underwaterNavigationToast {
                navigationToast(
                    toast,
                    accessibilityLabel: navigation.blockedNavigationAccessibilityLabel(
                        activity: activitySelection.selectedActivity
                    )
                )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .overlay(alignment: .bottom) {
            if !crownHintDismissed, navigation.selectedPage == .live, !dive.isDiveActive, !apneaRuntime.isSessionActive, !snorkelingRuntime.isSessionActive {
                crownNavigationHint
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.22), value: navigation.underwaterNavigationToast)
        .animation(.easeInOut(duration: 0.22), value: navigation.hardwareActionToast)
        .animation(.easeInOut(duration: 0.22), value: crownHintDismissed)
        .launchCompanionDisclaimer(isPresented: $showLaunchDisclaimer)
        .onAppear {
            if !activitySelection.sessionConfigured, !activitySelection.isStartupFlowActive {
                activitySelection.beginInitialLaunch(entry: .userColdLaunch)
            }
        }
        .fullScreenCover(isPresented: startupFlowPresented) {
            StartupFlowView()
                .environmentObject(navigation)
                .environmentObject(dive)
                .environmentObject(activitySelection)
                .environmentObject(apneaRuntime)
                .environmentObject(snorkelingRuntime)
                .environmentObject(snorkelingLogbook)
        }
        .overlay(alignment: .bottom) {
            if let toast = activitySelection.modeChangeBlockedToast {
                navigationToast(toast)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.22), value: activitySelection.modeChangeBlockedToast)
    }

    private var isAnySessionActive: Bool {
        dive.isDiveActive || apneaRuntime.isSessionActive || snorkelingRuntime.isSessionActive
    }

    private var startupFlowPresented: Binding<Bool> {
        Binding(
            get: { activitySelection.isStartupFlowActive },
            set: { isPresented in
                if !isPresented, activitySelection.isStartupFlowActive {
                    // Startup flow dismisses only through explicit completion paths.
                    return
                }
            }
        )
    }

    private func navigationToast(_ message: String, accessibilityLabel: String? = nil) -> some View {
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
            .accessibilityLabel(accessibilityLabel ?? String(localized: "nav.toast.a11y.generic"))
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
