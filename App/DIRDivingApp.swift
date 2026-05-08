import SwiftUI

@main
struct DIRDivingApp: App {
    @StateObject private var logStore: DiveLogStore
    @StateObject private var gpsManager: GPSManager
    @StateObject private var compassManager: CompassManager
    @StateObject private var diveManager: DiveManager
    @StateObject private var imageStore: UserImageStore

    init() {
        let logStore = DiveLogStore()
        let gpsManager = GPSManager()
        _logStore = StateObject(wrappedValue: logStore)
        _gpsManager = StateObject(wrappedValue: gpsManager)
        _compassManager = StateObject(wrappedValue: CompassManager())
        _diveManager = StateObject(wrappedValue: DiveManager(logStore: logStore, gpsManager: gpsManager))
        _imageStore = StateObject(wrappedValue: UserImageStore())
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack { ContentView() }
                .environmentObject(logStore)
                .environmentObject(gpsManager)
                .environmentObject(compassManager)
                .environmentObject(diveManager)
                .environmentObject(imageStore)
        }
    }
}
