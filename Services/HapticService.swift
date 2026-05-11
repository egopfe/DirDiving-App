import Foundation
import WatchKit

@MainActor
final class HapticService {
    static let shared = HapticService()
    private var lastWarningDate: Date?
    private init() {}

    func warnIfNeeded() {
        let now = Date()
        if let lastWarningDate, now.timeIntervalSince(lastWarningDate) < 2 { return }
        lastWarningDate = now
        WKInterfaceDevice.current().play(.failure)
    }
}
