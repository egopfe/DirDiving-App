import Foundation

struct SnorkelingRecordEligibilityOptions: Equatable, Hashable, Sendable {
    var includeSimulatedSessions: Bool
    var includeDegradedData: Bool

    static let `default` = SnorkelingRecordEligibilityOptions(
        includeSimulatedSessions: false,
        includeDegradedData: false
    )
}

enum SnorkelingRecordEligibilityPolicy {
    static func isSimulatedSession(_ session: SnorkelingSession) -> Bool {
        session.startMode == .manual
            && session.dips.allSatisfy { $0.samples.isEmpty && $0.events.isEmpty }
    }

    static func hasInsufficientDataQuality(_ session: SnorkelingSession) -> Bool {
        if session.warnings.contains(.dataQualityDegraded)
            || session.warnings.contains(.sparseTrack)
            || session.warnings.contains(.depthUnavailable) {
            return true
        }
        let samples = session.dips.flatMap(\.samples)
        guard !samples.isEmpty else {
            return session.dips.contains { $0.durationSeconds > 0 && $0.samples.isEmpty }
        }
        let weakSamples = samples.filter { $0.depthQuality != .measured }
        return Double(weakSamples.count) / Double(samples.count) > 0.5
    }

    static func isEligibleForStatistics(_ session: SnorkelingSession) -> Bool {
        switch SnorkelingLogbookPolicy.classify(session) {
        case .invalid:
            return false
        case .exportable:
            return session.statistics.sessionMaxDepthMeters.isFinite
                && session.statistics.sessionMaxDepthMeters >= 0
                && (session.dips.contains { $0.durationSeconds > 0 || !$0.samples.isEmpty }
                    || session.statistics.totalDistanceMeters > 0)
        }
    }

    static func isEligibleForRecords(
        _ session: SnorkelingSession,
        options: SnorkelingRecordEligibilityOptions = .default
    ) -> Bool {
        guard isEligibleForStatistics(session) else { return false }
        if isSimulatedSession(session), !options.includeSimulatedSessions { return false }
        if hasInsufficientDataQuality(session), !options.includeDegradedData { return false }
        return true
    }

    static func eligibleSessions(
        from source: [SnorkelingSession],
        options: SnorkelingRecordEligibilityOptions = .default
    ) -> [SnorkelingSession] {
        source.filter { isEligibleForRecords($0, options: options) }
    }
}
