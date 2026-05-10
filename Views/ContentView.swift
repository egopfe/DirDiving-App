import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DiveLiveView()
            CompassView()
            AscentRateSettingsView()
            UserImagesView()
            DiveLogListView()
        }
        .tabViewStyle(.verticalPage)
    }
}
