import Foundation

enum SnorkelingReleaseHardTolerances {
    static let checkpointRoundTripBudgetSeconds: TimeInterval = 0.25
    static let logbookRetentionCap = SnorkelingLogbookPolicy.maxSessions
    static let checkpointDebounceNanoseconds: UInt64 = 250_000_000
}
