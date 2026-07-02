import Foundation

enum SnorkelingWatchReturnPrimaryActionPolicy {
    static func isReturnAvailable(returnNavigation: SnorkelingReturnNavigationSnapshot) -> Bool {
        returnNavigation.entryPoint != nil
    }

    static func returnButtonTitle(isAvailable: Bool) -> String {
        isAvailable
            ? DIRWatchLocalizer.string("snorkeling.return.primary")
            : DIRWatchLocalizer.string("snorkeling.return.entry_unavailable")
    }

    static func returnButtonAccessibilityLabel(isAvailable: Bool) -> String {
        returnButtonTitle(isAvailable: isAvailable)
    }

    static func returnIsPrimaryAction(isAvailable: Bool, isSessionStarted: Bool) -> Bool {
        isSessionStarted && isAvailable
    }
}
