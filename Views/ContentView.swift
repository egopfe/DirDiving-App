import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DiveLiveView()
            CompassView()
            AscentRateSettingsView()
            BuddyAssistView()
            UserImagesView()
            DiveLogListView()
        }
        .tabViewStyle(.verticalPage)
    }
}
