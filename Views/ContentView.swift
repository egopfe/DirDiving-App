import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var navigation: AppNavigationStore

    var body: some View {
        TabView(selection: $navigation.selectedPage) {
            ModeSelectionView()
                .tag(AppPage.modeSelection)
            DiveLiveView()
                .tag(AppPage.live)
            SnorkelingView()
                .tag(AppPage.snorkeling)
            ApneaView()
                .tag(AppPage.apnea)
            CompassView()
                .tag(AppPage.compass)
            AscentRateSettingsView()
                .tag(AppPage.ascentSettings)
            UserImagesView()
                .tag(AppPage.userImages)
            DiveLogListView()
                .tag(AppPage.diveLog)
            BuddyAssistView()
                .tag(AppPage.buddyAssist)
        }
        .tabViewStyle(.verticalPage)
    }
}
