import Foundation

enum SnorkelingDomainValidationIssue: Equatable, Hashable {
    case nonFinite(field: String)
    case negativeValue(field: String)
    case invalidCoordinate(field: String)
    case nonMonotonicTrackPoints
    case nonMonotonicDipSamples
    case duplicateTrackPointID(UUID)
    case duplicateDipSampleID(UUID)
    case duplicateDipID(UUID)
    case invalidDuration(field: String)
    case underwaterMeasuredGPS
    case unknownSchemaVersion(Int)
    case unsupportedFutureSchema(Int)
}

enum SnorkelingDomainValidator {
    static func validate(trackPoint: SnorkelingTrackPoint) -> [SnorkelingDomainValidationIssue] {
        var issues: [SnorkelingDomainValidationIssue] = []
        if !trackPoint.monotonicRelativeTimestampSeconds.isFinite || trackPoint.monotonicRelativeTimestampSeconds < 0 {
            issues.append(.negativeValue(field: "trackPoint.monotonicRelativeTimestampSeconds"))
        }
        if let latitude = trackPoint.latitude, let longitude = trackPoint.longitude {
            if !SnorkelingDomainSupport.isValidCoordinate(latitude: latitude, longitude: longitude) {
                issues.append(.invalidCoordinate(field: "trackPoint.coordinate"))
            }
            if trackPoint.isUnderwater && trackPoint.gpsQuality.isMeasuredSurfaceFix {
                issues.append(.underwaterMeasuredGPS)
            }
        } else if trackPoint.gpsQuality.isMeasuredSurfaceFix {
            issues.append(.invalidCoordinate(field: "trackPoint.missingCoordinateForMeasuredGPS"))
        }
        if let depth = trackPoint.depthMeters {
            if !depth.isFinite {
                issues.append(.nonFinite(field: "trackPoint.depthMeters"))
            } else if depth < 0 {
                issues.append(.negativeValue(field: "trackPoint.depthMeters"))
            }
        }
        if !SnorkelingDomainSupport.isFiniteOptional(trackPoint.horizontalAccuracyMeters) {
            issues.append(.nonFinite(field: "trackPoint.horizontalAccuracyMeters"))
        }
        if !SnorkelingDomainSupport.isFiniteOptional(trackPoint.speedMetersPerSecond) {
            issues.append(.nonFinite(field: "trackPoint.speedMetersPerSecond"))
        }
        return issues
    }

    static func validate(dipSample: SnorkelingDipSample) -> [SnorkelingDomainValidationIssue] {
        var issues: [SnorkelingDomainValidationIssue] = []
        if !dipSample.depthMeters.isFinite {
            issues.append(.nonFinite(field: "dipSample.depthMeters"))
        } else if dipSample.depthMeters < 0 {
            issues.append(.negativeValue(field: "dipSample.depthMeters"))
        }
        if !dipSample.verticalSpeedMetersPerSecond.isFinite {
            issues.append(.nonFinite(field: "dipSample.verticalSpeedMetersPerSecond"))
        }
        if !SnorkelingDomainSupport.isFiniteOptional(dipSample.temperatureCelsius) {
            issues.append(.nonFinite(field: "dipSample.temperatureCelsius"))
        }
        if dipSample.monotonicRelativeTimestampSeconds < 0 || !dipSample.monotonicRelativeTimestampSeconds.isFinite {
            issues.append(.negativeValue(field: "dipSample.monotonicRelativeTimestampSeconds"))
        }
        return issues
    }

    static func validate(dip: SnorkelingDip) -> [SnorkelingDomainValidationIssue] {
        var issues: [SnorkelingDomainValidationIssue] = []
        if !dip.maxDepthMeters.isFinite {
            issues.append(.nonFinite(field: "dip.maxDepthMeters"))
        } else if dip.maxDepthMeters < 0 {
            issues.append(.negativeValue(field: "dip.maxDepthMeters"))
        }
        if !dip.averageDepthMeters.isFinite || dip.averageDepthMeters < 0 {
            issues.append(.negativeValue(field: "dip.averageDepthMeters"))
        }
        if !dip.durationSeconds.isFinite || dip.durationSeconds < 0 {
            issues.append(.invalidDuration(field: "dip.durationSeconds"))
        }
        issues.append(contentsOf: validateDipSampleSeries(dip.samples))
        return issues
    }

    static func validate(marker: SnorkelingMarker) -> [SnorkelingDomainValidationIssue] {
        var issues: [SnorkelingDomainValidationIssue] = []
        if !SnorkelingDomainSupport.isValidCoordinate(latitude: marker.latitude, longitude: marker.longitude) {
            issues.append(.invalidCoordinate(field: "marker.coordinate"))
        }
        if let depth = marker.depthMeters, (!depth.isFinite || depth < 0) {
            issues.append(.negativeValue(field: "marker.depthMeters"))
        }
        return issues
    }

    static func validate(waypoint: SnorkelingWaypoint) -> [SnorkelingDomainValidationIssue] {
        SnorkelingDomainSupport.isValidCoordinate(latitude: waypoint.latitude, longitude: waypoint.longitude)
            ? []
            : [.invalidCoordinate(field: "waypoint.coordinate")]
    }

    static func validate(session: SnorkelingSession) -> [SnorkelingDomainValidationIssue] {
        var issues: [SnorkelingDomainValidationIssue] = []
        if session.schemaVersion < 0 {
            issues.append(.unknownSchemaVersion(session.schemaVersion))
        }
        if session.schemaVersion > SnorkelingSession.currentSchemaVersion {
            issues.append(.unsupportedFutureSchema(session.schemaVersion))
        }
        if !session.statistics.sessionMaxDepthMeters.isFinite {
            issues.append(.nonFinite(field: "statistics.sessionMaxDepthMeters"))
        }
        if !session.statistics.totalDistanceMeters.isFinite || session.statistics.totalDistanceMeters < 0 {
            issues.append(.negativeValue(field: "statistics.totalDistanceMeters"))
        }

        issues.append(contentsOf: validateTrackPointSeries(session.trackPoints))
        if let entry = session.entryPoint {
            issues.append(contentsOf: validate(trackPoint: entry))
        }

        var dipIDs = Set<UUID>()
        for dip in session.dips {
            if !dipIDs.insert(dip.id).inserted {
                issues.append(.duplicateDipID(dip.id))
            }
            issues.append(contentsOf: validate(dip: dip))
        }

        for marker in session.markers {
            issues.append(contentsOf: validate(marker: marker))
        }

        for plan in session.routePlans {
            for waypoint in plan.waypoints {
                issues.append(contentsOf: validate(waypoint: waypoint))
            }
        }

        return issues
    }

    private static func validateTrackPointSeries(_ points: [SnorkelingTrackPoint]) -> [SnorkelingDomainValidationIssue] {
        var issues: [SnorkelingDomainValidationIssue] = []
        var seen = Set<UUID>()
        var lastTimestamp: TimeInterval?
        for point in points {
            if !seen.insert(point.id).inserted {
                issues.append(.duplicateTrackPointID(point.id))
            }
            issues.append(contentsOf: validate(trackPoint: point))
            if let last = lastTimestamp, point.monotonicRelativeTimestampSeconds < last {
                issues.append(.nonMonotonicTrackPoints)
            }
            lastTimestamp = point.monotonicRelativeTimestampSeconds
        }
        return issues
    }

    private static func validateDipSampleSeries(_ samples: [SnorkelingDipSample]) -> [SnorkelingDomainValidationIssue] {
        var issues: [SnorkelingDomainValidationIssue] = []
        var seen = Set<UUID>()
        var lastTimestamp: TimeInterval?
        for sample in samples {
            if !seen.insert(sample.id).inserted {
                issues.append(.duplicateDipSampleID(sample.id))
            }
            issues.append(contentsOf: validate(dipSample: sample))
            if let last = lastTimestamp, sample.monotonicRelativeTimestampSeconds < last {
                issues.append(.nonMonotonicDipSamples)
            }
            lastTimestamp = sample.monotonicRelativeTimestampSeconds
        }
        return issues
    }
}
