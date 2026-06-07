import Foundation

/// Bounded per-peer replay suppression for signed sync envelopes carrying a nonce.
final class SyncNonceReplayCache {
    private var entries: [(nonce: String, seenAt: Date)] = []
    private let maxEntries: Int
    private let windowSeconds: TimeInterval

    init(maxEntries: Int = 512, windowSeconds: TimeInterval = 3_600) {
        self.maxEntries = max(1, maxEntries)
        self.windowSeconds = max(1, windowSeconds)
    }

    /// Returns `true` when the nonce was already seen inside the replay window.
    func isReplay(_ nonce: String, now: Date = Date()) -> Bool {
        pruneExpired(now: now)
        return entries.contains { $0.nonce == nonce }
    }

    /// Records a nonce after successful verification. Returns `false` if it was a replay.
    @discardableResult
    func register(_ nonce: String, now: Date = Date()) -> Bool {
        pruneExpired(now: now)
        guard !entries.contains(where: { $0.nonce == nonce }) else { return false }
        entries.append((nonce: nonce, seenAt: now))
        if entries.count > maxEntries {
            entries.removeFirst(entries.count - maxEntries)
        }
        return true
    }

    func reset() {
        entries.removeAll()
    }

    var count: Int { entries.count }

    private func pruneExpired(now: Date) {
        let cutoff = now.addingTimeInterval(-windowSeconds)
        entries.removeAll { $0.seenAt < cutoff }
    }
}
