import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var navigation: AppNavigationStore
    @EnvironmentObject private var imageStore: UserImageStore
    @State private var showLaunchDisclaimer = true

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
        .launchCompanionDisclaimer(isPresented: $showLaunchDisclaimer)
    }
}
