import SwiftUI

@main
struct DIRDivingApp: App {
    @StateObject private var logStore: DiveLogStore
    @StateObject private var gpsManager: GPSManager
    @StateObject private var compassManager: CompassManager
    @StateObject private var diveManager: DiveManager
    @StateObject private var imageStore: UserImageStore
    @StateObject private var ascentSettings: AscentRateSettingsStore
    @StateObject private var buddyAssist: BuddyAssistService

    init() {
        let logStore = DiveLogStore()
        let gpsManager = GPSManager()
        let ascentSettings = AscentRateSettingsStore()
        let buddyAssist = BuddyAssistService()
        _logStore = StateObject(wrappedValue: logStore)
        _gpsManager = StateObject(wrappedValue: gpsManager)
        _compassManager = StateObject(wrappedValue: CompassManager())
        _diveManager = StateObject(wrappedValue: DiveManager(logStore: logStore, gpsManager: gpsManager, ascentSettings: ascentSettings))
        _imageStore = StateObject(wrappedValue: UserImageStore())
        _ascentSettings = StateObject(wrappedValue: ascentSettings)
        _buddyAssist = StateObject(wrappedValue: buddyAssist)
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack { ContentView() }
                .environmentObject(logStore)
                .environmentObject(gpsManager)
                .environmentObject(compassManager)
                .environmentObject(diveManager)
                .environmentObject(imageStore)
                .environmentObject(ascentSettings)
                .environmentObject(buddyAssist)
        }
    }
}
