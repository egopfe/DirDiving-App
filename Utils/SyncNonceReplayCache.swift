import Foundation

/// Bounded per-peer replay suppression for signed sync envelopes carrying a nonce.
final class SyncNonceReplayCache {
    private struct PersistedEntry: Codable {
        let nonce: String
        let seenAt: Date
    }

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

    func loadProtected(from url: URL) {
        guard let data = try? Data(contentsOf: url) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let decoded = try? decoder.decode([PersistedEntry].self, from: data) else { return }
        let now = Date()
        entries = decoded
            .filter { now.timeIntervalSince($0.seenAt) <= windowSeconds }
            .map { ($0.nonce, $0.seenAt) }
        pruneExpired(now: now)
    }

    func persistProtected(to url: URL) {
        pruneExpired(now: Date())
        let payload = entries.map { PersistedEntry(nonce: $0.nonce, seenAt: $0.seenAt) }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(payload) else { return }
        try? data.write(to: url, options: [.atomic, .completeFileProtection])
    }

    private func pruneExpired(now: Date) {
        let cutoff = now.addingTimeInterval(-windowSeconds)
        entries.removeAll { $0.seenAt < cutoff }
    }
}
