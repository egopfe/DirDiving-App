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

    func buddyNearPulseIfNeeded() {
        let now = Date()
        if let lastBuddyNearDate, now.timeIntervalSince(lastBuddyNearDate) < 1 { return }
        lastBuddyNearDate = now
        WKInterfaceDevice.current().play(.click)
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 250_000_000)
            WKInterfaceDevice.current().play(.click)
        }
    }

    func buddyDistantPulseIfNeeded() {
        let now = Date()
        if let lastBuddyDistantDate, now.timeIntervalSince(lastBuddyDistantDate) < 5 { return }
        lastBuddyDistantDate = now
        WKInterfaceDevice.current().play(.directionDown)
    }
}
