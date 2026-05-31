import Foundation

enum DiveSessionValidationError: Error, Equatable {
    case invalidDates
    case invalidDuration
    case emptyProfile
    case tooManySamples
    case invalidSample
    case sampleOutsideSession
    case invalidGPS
    case inconsistentDerivedValues
}

enum DiveSessionAlgorithmValidator {
    static func validate(
        _ session: DiveSession,
        allowEmptySamples: Bool = false,
        maxDepthMeters: Double = IOSAlgorithmConfiguration.maxSyncDepthMeters
    ) throws -> DiveSession {
        guard session.endDate >= session.startDate else { throw DiveSessionValidationError.invalidDates }
        let sessionDuration = session.endDate.timeIntervalSince(session.startDate)
        guard sessionDuration.isFinite,
              sessionDuration >= 0,
              sessionDuration <= IOSAlgorithmConfiguration.maxDiveDurationSeconds,
              session.durationSeconds.isFinite,
              session.durationSeconds >= 0,
              session.durationSeconds <= IOSAlgorithmConfiguration.maxDiveDurationSeconds else {
            throw DiveSessionValidationError.invalidDuration
        }
        guard session.samples.count <= IOSAlgorithmConfiguration.maxProfileSampleCount else {
            throw DiveSessionValidationError.tooManySamples
        }

        let clean = DiveProfileMath.sanitizedSamples(session.samples, maxDepthMeters: maxDepthMeters)
        if !allowEmptySamples, clean.isEmpty {
            throw DiveSessionValidationError.emptyProfile
        }
        if clean.count != session.samples.count {
            throw DiveSessionValidationError.invalidSample
        }
        if clean.contains(where: { $0.timestamp < session.startDate || $0.timestamp > session.endDate }) {
            throw DiveSessionValidationError.sampleOutsideSession
        }
        if session.entryGPS != nil, !DiveProfileMath.isValidGPS(session.entryGPS) {
            throw DiveSessionValidationError.invalidGPS
        }
        if session.exitGPS != nil, !DiveProfileMath.isValidGPS(session.exitGPS) {
            throw DiveSessionValidationError.invalidGPS
        }

        let normalized = DiveProfileMath.normalizedSession(session, maxDepthLimit: maxDepthMeters)
        guard abs(normalized.durationSeconds - sessionDuration) <= 1.0 else {
            throw DiveSessionValidationError.invalidDuration
        }
        if !clean.isEmpty {
            guard abs(normalized.maxDepthMeters - session.maxDepthMeters) <= 0.25,
                  abs(normalized.avgDepthMeters - session.avgDepthMeters) <= 0.25,
                  abs(normalized.ttv - session.ttv) <= 0.5 else {
                throw DiveSessionValidationError.inconsistentDerivedValues
            }
        }
        return normalized
    }

    static func normalizedForStorage(
        _ session: DiveSession,
        allowEmptySamples: Bool = false,
        maxDepthMeters: Double = IOSAlgorithmConfiguration.maxSyncDepthMeters
    ) throws -> DiveSession {
        let normalized = DiveProfileMath.normalizedSession(session, maxDepthLimit: maxDepthMeters)
        return try validate(normalized, allowEmptySamples: allowEmptySamples, maxDepthMeters: maxDepthMeters)
    }
}
