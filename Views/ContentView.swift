import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DiveLiveView()
            CompassView()
            UserImagesView()
            DiveLogListView()
        }
        .tabViewStyle(.verticalPage)
    }
}
