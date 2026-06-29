import CoreLocation
import Foundation

enum WatchFirstLaunchLocationPermissionPolicy {
    static let hasPresentedLocationPermissionPromptKey =
        "dirdiving.watch.firstLaunch.locationPermissionPrompt.presented"

    static func shouldPresentFirstLaunchPermissionFlow(
        authorizationStatus: CLAuthorizationStatus,
        legalAccepted: Bool,
        userDefaults: UserDefaults = .standard
    ) -> Bool {
        guard legalAccepted else { return false }
        guard userDefaults.bool(forKey: hasPresentedLocationPermissionPromptKey) == false else {
            return false
        }
        return authorizationStatus == .notDetermined
    }

    static func markPresented(userDefaults: UserDefaults = .standard) {
        userDefaults.set(true, forKey: hasPresentedLocationPermissionPromptKey)
    }
}
