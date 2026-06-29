import CoreLocation
import Foundation

enum IOSFirstLaunchLocationPermissionPolicy {
    static let hasPresentedLocationPermissionPromptKey = "dirdiving.ios.firstLaunch.locationPermissionPrompt.presented"

    static func shouldPresentFirstLaunchPermissionFlow(
        authorizationStatus: CLAuthorizationStatus,
        userDefaults: UserDefaults = .standard
    ) -> Bool {
        guard userDefaults.bool(forKey: hasPresentedLocationPermissionPromptKey) == false else {
            return false
        }
        return authorizationStatus == .notDetermined
    }

    static func markPresented(userDefaults: UserDefaults = .standard) {
        userDefaults.set(true, forKey: hasPresentedLocationPermissionPromptKey)
    }
}
