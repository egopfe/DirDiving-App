import Foundation

/// Shows the lightweight companion disclaimer once per app launch.
enum CompanionDisclaimerAcceptance {
    private static var dismissedThisLaunch = false

    static var requiresDisplay: Bool {
        !dismissedThisLaunch
    }

    static func accept() {
        dismissedThisLaunch = true
    }
}
