import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var navigation: AppNavigationStore

    var body: some View {
        TabView(selection: $navigation.selectedPage) {
            DiveLiveView()
                .tag(AppPage.live)
            CompassView()
                .tag(AppPage.compass)
            AscentRateSettingsView()
                .tag(AppPage.ascentSettings)
            UserImagesView()
                .tag(AppPage.userImages)
            DiveLogListView()
                .tag(AppPage.diveLog)
        }
        .tabViewStyle(.verticalPage)
    }
}
