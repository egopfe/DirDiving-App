import Foundation
import WatchKit

@MainActor
final class HapticService {
    static let shared = HapticService()
    private var lastWarningDate: Date?
    private var lastBuddyNearDate: Date?
    private var lastBuddyDistantDate: Date?
    private init() {}

    func warnIfNeeded() {
        let now = Date()
        if let lastWarningDate, now.timeIntervalSince(lastWarningDate) < 2 { return }
        lastWarningDate = now
        WKInterfaceDevice.current().play(.failure)
    }

    func buddyMessageReceived(isCritical: Bool) {
        WKInterfaceDevice.current().play(isCritical ? .failure : .notification)
    }

    func buddyNearPulseIfNeeded() {
        let now = Date()
        if let lastBuddyNearDate, now.timeIntervalSince(lastBuddyNearDate) < 8 { return }
        lastBuddyNearDate = now
        WKInterfaceDevice.current().play(.directionUp)
    }

    func buddyDistantPulseIfNeeded() {
        let now = Date()
        if let lastBuddyDistantDate, now.timeIntervalSince(lastBuddyDistantDate) < 12 { return }
        lastBuddyDistantDate = now
        WKInterfaceDevice.current().play(.retry)
    }
}
