import Foundation

enum IOSDiveLogbookPolicy {
    static let maxSessions = IOSAlgorithmConfiguration.maxLogSessions

    static func newestFirstCapped(_ sessions: [DiveSession]) -> [DiveSession] {
        Array(
            sessions
                .sorted { lhs, rhs in
                    if lhs.startDate == rhs.startDate {
                        return lhs.id.uuidString < rhs.id.uuidString
                    }
                    return lhs.startDate > rhs.startDate
                }
                .prefix(maxSessions)
        )
    }

    static func normalizeAndCap(_ sessions: [DiveSession], allowEmptySamples: Bool = true) -> [DiveSession] {
        newestFirstCapped(
            sessions.compactMap { session in
                try? DiveSessionAlgorithmValidator.normalizedForStorage(
                    session,
                    allowEmptySamples: allowEmptySamples
                )
            }
        )
    }
}
