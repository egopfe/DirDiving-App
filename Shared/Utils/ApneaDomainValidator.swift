import Foundation

enum ApneaDomainValidationIssue: Equatable, Hashable {
    case nonFinite(field: String)
    case negativeValue(field: String)
    case nonMonotonicSamples
    case duplicateSampleID(UUID)
    case duplicateDiveID(UUID)
    case invalidDuration(field: String)
    case unknownSchemaVersion(Int)
    case unsupportedFutureSchema(Int)
}

enum ApneaDomainValidator {
    static func validate(sample: ApneaSample) -> [ApneaDomainValidationIssue] {
        var issues: [ApneaDomainValidationIssue] = []
        if !sample.depthMeters.isFinite {
            issues.append(.nonFinite(field: "sample.depthMeters"))
        } else if sample.depthMeters < 0 {
            issues.append(.negativeValue(field: "sample.depthMeters"))
        }
        if !sample.verticalSpeedMetersPerSecond.isFinite {
            issues.append(.nonFinite(field: "sample.verticalSpeedMetersPerSecond"))
        }
        if !ApneaDomainSupport.isFiniteOptional(sample.temperatureCelsius) {
            issues.append(.nonFinite(field: "sample.temperatureCelsius"))
        }
        if sample.monotonicRelativeTimestampSeconds < 0 || !sample.monotonicRelativeTimestampSeconds.isFinite {
            issues.append(.negativeValue(field: "sample.monotonicRelativeTimestampSeconds"))
        }
        return issues
    }

    static func validate(dive: ApneaDive) -> [ApneaDomainValidationIssue] {
        var issues: [ApneaDomainValidationIssue] = []
        if !dive.maxDepthMeters.isFinite {
            issues.append(.nonFinite(field: "dive.maxDepthMeters"))
        } else if dive.maxDepthMeters < 0 {
            issues.append(.negativeValue(field: "dive.maxDepthMeters"))
        }
        if !dive.averageDepthMeters.isFinite {
            issues.append(.nonFinite(field: "dive.averageDepthMeters"))
        } else if dive.averageDepthMeters < 0 {
            issues.append(.negativeValue(field: "dive.averageDepthMeters"))
        }
        if !dive.durationSeconds.isFinite || dive.durationSeconds < 0 {
            issues.append(.invalidDuration(field: "dive.durationSeconds"))
        }

        issues.append(contentsOf: validateSampleSeries(dive.samples))

        for target in dive.targets {
            if let depth = target.targetDepthMeters, !depth.isFinite {
                issues.append(.nonFinite(field: "target.targetDepthMeters"))
            }
            if let duration = target.targetDurationSeconds, !duration.isFinite || duration < 0 {
                issues.append(.invalidDuration(field: "target.targetDurationSeconds"))
            }
        }

        for marker in dive.markers {
            if !marker.depthMeters.isFinite || marker.depthMeters < 0 {
                issues.append(.negativeValue(field: "marker.depthMeters"))
            }
        }

        return issues
    }

    static func validate(session: ApneaSession) -> [ApneaDomainValidationIssue] {
        var issues: [ApneaDomainValidationIssue] = []
        if session.schemaVersion < 0 {
            issues.append(.unknownSchemaVersion(session.schemaVersion))
        }
        if session.schemaVersion > ApneaSession.currentSchemaVersion {
            issues.append(.unsupportedFutureSchema(session.schemaVersion))
        }
        if !session.statistics.sessionMaxDepthMeters.isFinite {
            issues.append(.nonFinite(field: "statistics.sessionMaxDepthMeters"))
        }
        if !session.statistics.totalUnderwaterSeconds.isFinite || session.statistics.totalUnderwaterSeconds < 0 {
            issues.append(.invalidDuration(field: "statistics.totalUnderwaterSeconds"))
        }

        var seenDiveIDs = Set<UUID>()
        for dive in session.dives {
            if !seenDiveIDs.insert(dive.id).inserted {
                issues.append(.duplicateDiveID(dive.id))
            }
            issues.append(contentsOf: validate(dive: dive))
        }

        if let personalBest = session.profile?.personalBestMaxDepthMeters, !personalBest.isFinite {
            issues.append(.nonFinite(field: "profile.personalBestMaxDepthMeters"))
        }

        for point in session.surfaceGPSPoints {
            if !point.latitude.isFinite || !point.longitude.isFinite {
                issues.append(.nonFinite(field: "surfaceGPS.latitude/longitude"))
            }
        }

        return issues
    }

    static func isValid(session: ApneaSession) -> Bool {
        validate(session: session).isEmpty
    }

    private static func validateSampleSeries(_ samples: [ApneaSample]) -> [ApneaDomainValidationIssue] {
        var issues: [ApneaDomainValidationIssue] = []
        var seenIDs = Set<UUID>()
        var lastTimestamp: TimeInterval?

        for sample in samples {
            issues.append(contentsOf: validate(sample: sample))
            if !seenIDs.insert(sample.id).inserted {
                issues.append(.duplicateSampleID(sample.id))
            }
            if let lastTimestamp, sample.monotonicRelativeTimestampSeconds < lastTimestamp {
                issues.append(.nonMonotonicSamples)
            }
            lastTimestamp = sample.monotonicRelativeTimestampSeconds
        }

        return issues
    }
}
