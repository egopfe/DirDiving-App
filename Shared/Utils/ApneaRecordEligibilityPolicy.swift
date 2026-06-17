import Foundation

struct ApneaRecordEligibilityOptions: Equatable, Hashable, Sendable {
    var includeSimulatedSessions: Bool
    var includeDegradedData: Bool

    static let `default` = ApneaRecordEligibilityOptions(
        includeSimulatedSessions: false,
        includeDegradedData: false
    )
}

enum ApneaRecordEligibilityPolicy {
    static func isSimulatedSession(_ session: ApneaSession) -> Bool {
        session.startMode == .manual
            && session.dives.allSatisfy { $0.samples.isEmpty && $0.events.isEmpty }
    }

    static func hasInsufficientDataQuality(_ session: ApneaSession) -> Bool {
        if session.warnings.contains(.dataQualityDegraded) || session.warnings.contains(.sparseSamples) {
            return true
        }
        let samples = session.dives.flatMap(\.samples)
        guard !samples.isEmpty else {
            return session.dives.contains { $0.durationSeconds > 0 && $0.samples.isEmpty }
        }
        let weakSamples = samples.filter {
            $0.quality == .missing || $0.quality == .rejected || $0.quality == .estimated
        }
        return Double(weakSamples.count) / Double(samples.count) > 0.5
    }

    static func isEligibleForRecords(
        _ session: ApneaSession,
        options: ApneaRecordEligibilityOptions = .default
    ) -> Bool {
        guard ApneaLogbookStatistics.isEligibleForStatistics(session) else { return false }
        if isSimulatedSession(session), !options.includeSimulatedSessions { return false }
        if hasInsufficientDataQuality(session), !options.includeDegradedData { return false }
        return true
    }

    static func eligibleSessions(
        from source: [ApneaSession],
        options: ApneaRecordEligibilityOptions = .default
    ) -> [ApneaSession] {
        source.filter { isEligibleForRecords($0, options: options) }
    }
}
