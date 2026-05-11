import SwiftUI

@main
struct DIRDivingiOSApp: App {
    @StateObject private var logStore = DiveLogStore()
    @StateObject private var watchSync = WatchSyncService()
    @StateObject private var plannerStore = PlannerStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(logStore)
                .environmentObject(watchSync)
                .environmentObject(plannerStore)
                .preferredColorScheme(.dark)
                .onAppear { watchSync.activate(logStore: logStore) }
        }
    }
}
