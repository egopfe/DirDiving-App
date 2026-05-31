import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var navigation: AppNavigationStore
    @EnvironmentObject private var dive: DiveManager
    @EnvironmentObject private var imageStore: UserImageStore
    @State private var showLaunchDisclaimer = CompanionDisclaimerAcceptance.requiresDisplay

    var body: some View {
        TabView(selection: $navigation.selectedPage) {
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
            DiveLogListView()
                .tag(AppPage.diveLog)
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
                navigation.selectedPage = .live
            }
        }
        .launchCompanionDisclaimer(isPresented: $showLaunchDisclaimer)
    }
}
