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
            if !imageStore.imageNames.isEmpty {
                UserImagesView()
                    .tag(AppPage.userImages)
            }
            DiveLogListView()
                .tag(AppPage.diveLog)
        }
        .tabViewStyle(.verticalPage)
        .onAppear {
            navigation.clampSelectedPage(userImagesAvailable: !imageStore.imageNames.isEmpty)
        }
        .onChange(of: imageStore.imageNames) { _, names in
            navigation.clampSelectedPage(userImagesAvailable: !names.isEmpty)
        }
        .onChange(of: dive.isDiveActive) { _, isActive in
            if isActive {
                navigation.selectedPage = .live
            }
        }
        .onChange(of: navigation.selectedPage) { _, page in
            guard dive.isDiveActive else { return }
            if page != .live && page != .compass && page != .diveLog {
                navigation.selectedPage = .live
            }
        }
        .launchCompanionDisclaimer(isPresented: $showLaunchDisclaimer)
    }
}
