import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var navigation: AppNavigationStore

    var body: some View {
        TabView(selection: $navigation.selectedPage) {
            ModeSelectionView()
                .tag(AppPage.modeSelection)
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
    }
}
