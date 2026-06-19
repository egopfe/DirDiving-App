import Foundation

enum SnorkelingReleaseHardTolerances {
    static let checkpointRoundTripBudgetSeconds: TimeInterval = 0.25
    static let logbookRetentionCap = SnorkelingLogbookPolicy.maxSessions
    static let checkpointDebounceNanoseconds: UInt64 = 250_000_000

    /// Maximum accepted age for signed session/route transport payloads (seconds).
    static let syncPayloadMaxAgeSeconds: TimeInterval = 300

    /// Canonical map gap threshold — must match `SnorkelingSessionMapPresentation`.
    static let mapGapSegmentationThresholdSeconds: TimeInterval = SnorkelingSessionMapPresentation.maxGapSecondsForContinuousSegment

    /// Minimum measured surface fixes required for GPX export.
    static let minimumMeasuredSurfaceFixesForGPX = 2

    /// Imported session ID store cap (Watch → iOS).
    static let importedSessionIDStoreCap = 512

    /// Sensor/depth unavailable blocks ready start — no silent fallback to manual session.
    static let sensorLossBlocksReadyStart = true
}
