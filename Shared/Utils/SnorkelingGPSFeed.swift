import Foundation

enum SnorkelingGPSSource: String, Codable, CaseIterable, Hashable, Sendable {
    case live
    case replay
    case imported
}

/// UI-free snorkeling GPS presentation states for later screens.
enum SnorkelingGPSPresentationState: String, Codable, CaseIterable, Hashable, Sendable {
    case tracking
    case degraded
    case stale
    case unavailable
    case underwaterUnavailable
}

enum SnorkelingGPSFeedRejectionReason: String, Codable, CaseIterable, Hashable, Sendable {
    case underwater
    case invalidCoordinates
    case regressiveTimestamp
    case lowAccuracy
    case fixTooOld
    case speedOutlier
    case gapExceeded
}

struct SnorkelingGPSRawFix: Codable, Equatable, Hashable, Sendable {
    let latitude: Double
    let longitude: Double
    let horizontalAccuracyMeters: Double
    let sensorTimestamp: Date
    let receivedAt: Date
    let reportedSpeedMetersPerSecond: Double?
    let source: SnorkelingGPSSource

    init(
        latitude: Double,
        longitude: Double,
        horizontalAccuracyMeters: Double,
        sensorTimestamp: Date,
        receivedAt: Date? = nil,
        reportedSpeedMetersPerSecond: Double? = nil,
        source: SnorkelingGPSSource = .live
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.horizontalAccuracyMeters = horizontalAccuracyMeters
        self.sensorTimestamp = sensorTimestamp
        self.receivedAt = receivedAt ?? sensorTimestamp
        self.reportedSpeedMetersPerSecond = reportedSpeedMetersPerSecond
        self.source = source
    }
}

struct SnorkelingGPSFeedConfiguration: Codable, Hashable, Sendable {
    var trackingMaximumHorizontalAccuracyMeters: Double
    var degradedMaximumHorizontalAccuracyMeters: Double
    var trackingMaximumFixAgeSeconds: TimeInterval
    var staleMaximumFixAgeSeconds: TimeInterval
    var gapUnavailableSeconds: TimeInterval
    var maximumPlausibleSpeedMetersPerSecond: Double
    var regressiveTimestampToleranceSeconds: TimeInterval
    var minimumSegmentDeltaSeconds: TimeInterval

    static let snorkelingDefault = SnorkelingGPSFeedConfiguration(
        trackingMaximumHorizontalAccuracyMeters: 20,
        degradedMaximumHorizontalAccuracyMeters: 45,
        trackingMaximumFixAgeSeconds: 12,
        staleMaximumFixAgeSeconds: 90,
        gapUnavailableSeconds: 45,
        maximumPlausibleSpeedMetersPerSecond: 3.5,
        regressiveTimestampToleranceSeconds: 0.001,
        minimumSegmentDeltaSeconds: 0.25
    )
}

struct SnorkelingGPSAcceptedFix: Codable, Equatable, Hashable, Sendable {
    let latitude: Double
    let longitude: Double
    let horizontalAccuracyMeters: Double
    let sensorTimestamp: Date
    let receivedAt: Date
    let monotonicRelativeTimestampSeconds: TimeInterval
    let fixAgeSeconds: TimeInterval
    let source: SnorkelingGPSSource
    let segmentDistanceMeters: Double
    let impliedSpeedMetersPerSecond: Double
    let gpsQuality: SnorkelingGPSQuality
    let presentationState: SnorkelingGPSPresentationState
}

struct SnorkelingGPSRawAuditEntry: Codable, Equatable, Hashable, Sendable {
    let raw: SnorkelingGPSRawFix
    let monotonicRelativeTimestampSeconds: TimeInterval
    let gpsQuality: SnorkelingGPSQuality
    let presentationState: SnorkelingGPSPresentationState
    let rejectionReason: SnorkelingGPSFeedRejectionReason?
    let accepted: SnorkelingGPSAcceptedFix?
}

struct SnorkelingGPSFeedState: Codable, Hashable, Sendable {
    var lastAcceptedFix: SnorkelingGPSAcceptedFix?
    var lastSensorTimestamp: Date?
    var lastMonotonicRelativeTimestampSeconds: TimeInterval?
    var accumulatedDistanceMeters: Double
    var rawAuditTrail: [SnorkelingGPSRawAuditEntry]

    static let initial = SnorkelingGPSFeedState(
        lastAcceptedFix: nil,
        lastSensorTimestamp: nil,
        lastMonotonicRelativeTimestampSeconds: nil,
        accumulatedDistanceMeters: 0,
        rawAuditTrail: []
    )
}

struct SnorkelingGPSIngestResult: Equatable, Hashable, Sendable {
    let raw: SnorkelingGPSRawFix
    let monotonicRelativeTimestampSeconds: TimeInterval
    let gpsQuality: SnorkelingGPSQuality
    let presentationState: SnorkelingGPSPresentationState
    let rejectionReason: SnorkelingGPSFeedRejectionReason?
    let accepted: SnorkelingGPSAcceptedFix?
    let accumulatedDistanceMeters: Double
}

/// Snorkeling GPS feed — surface-only measured fixes, geodetic segment distance, UI-free.
enum SnorkelingGPSFeed {
    static let maximumRawAuditEntries = 2_048

    @discardableResult
    static func ingest(
        raw: SnorkelingGPSRawFix,
        monotonicRelativeTimestampSeconds: TimeInterval,
        isUnderwater: Bool,
        state: inout SnorkelingGPSFeedState,
        configuration: SnorkelingGPSFeedConfiguration = .snorkelingDefault,
        now: Date = Date()
    ) -> SnorkelingGPSIngestResult {
        if isUnderwater {
            return reject(
                raw: raw,
                monotonicRelativeTimestampSeconds: monotonicRelativeTimestampSeconds,
                reason: .underwater,
                gpsQuality: .unavailable,
                presentationState: .underwaterUnavailable,
                state: &state
            )
        }

        guard SnorkelingDomainSupport.isValidCoordinate(latitude: raw.latitude, longitude: raw.longitude),
              raw.horizontalAccuracyMeters.isFinite,
              raw.horizontalAccuracyMeters >= 0 else {
            return reject(
                raw: raw,
                monotonicRelativeTimestampSeconds: monotonicRelativeTimestampSeconds,
                reason: .invalidCoordinates,
                gpsQuality: .invalid,
                presentationState: .unavailable,
                state: &state
            )
        }

        if let lastTimestamp = state.lastSensorTimestamp,
           raw.sensorTimestamp.timeIntervalSince(lastTimestamp) < -configuration.regressiveTimestampToleranceSeconds {
            return reject(
                raw: raw,
                monotonicRelativeTimestampSeconds: monotonicRelativeTimestampSeconds,
                reason: .regressiveTimestamp,
                gpsQuality: .invalid,
                presentationState: .unavailable,
                state: &state
            )
        }

        let fixAge = now.timeIntervalSince(raw.sensorTimestamp)
        guard fixAge.isFinite, fixAge >= 0 else {
            return reject(
                raw: raw,
                monotonicRelativeTimestampSeconds: monotonicRelativeTimestampSeconds,
                reason: .fixTooOld,
                gpsQuality: .invalid,
                presentationState: .unavailable,
                state: &state
            )
        }

        if fixAge > configuration.staleMaximumFixAgeSeconds {
            return reject(
                raw: raw,
                monotonicRelativeTimestampSeconds: monotonicRelativeTimestampSeconds,
                reason: .fixTooOld,
                gpsQuality: .stale,
                presentationState: .stale,
                state: &state
            )
        }

        if raw.horizontalAccuracyMeters > configuration.degradedMaximumHorizontalAccuracyMeters {
            return reject(
                raw: raw,
                monotonicRelativeTimestampSeconds: monotonicRelativeTimestampSeconds,
                reason: .lowAccuracy,
                gpsQuality: .unavailable,
                presentationState: .unavailable,
                state: &state
            )
        }

        if let previous = state.lastAcceptedFix {
            let gap = raw.sensorTimestamp.timeIntervalSince(previous.sensorTimestamp)
            if gap > configuration.gapUnavailableSeconds {
                return reject(
                    raw: raw,
                    monotonicRelativeTimestampSeconds: monotonicRelativeTimestampSeconds,
                    reason: .gapExceeded,
                    gpsQuality: .unavailable,
                    presentationState: .unavailable,
                    state: &state,
                    resetAcceptedBridge: true
                )
            }

            let delta = max(
                raw.receivedAt.timeIntervalSince(previous.receivedAt),
                raw.sensorTimestamp.timeIntervalSince(previous.sensorTimestamp),
                configuration.minimumSegmentDeltaSeconds
            )
            let segmentDistance = SnorkelingDomainSupport.distanceMeters(
                from: (previous.latitude, previous.longitude),
                to: (raw.latitude, raw.longitude)
            )
            let impliedSpeed = segmentDistance / delta
            if impliedSpeed > configuration.maximumPlausibleSpeedMetersPerSecond {
                return reject(
                    raw: raw,
                    monotonicRelativeTimestampSeconds: monotonicRelativeTimestampSeconds,
                    reason: .speedOutlier,
                    gpsQuality: .invalid,
                    presentationState: .degraded,
                    state: &state
                )
            }

            let presentation = presentationState(
                fixAge: fixAge,
                horizontalAccuracyMeters: raw.horizontalAccuracyMeters,
                configuration: configuration
            )
            let quality = gpsQuality(for: presentation)
            let accepted = SnorkelingGPSAcceptedFix(
                latitude: raw.latitude,
                longitude: raw.longitude,
                horizontalAccuracyMeters: raw.horizontalAccuracyMeters,
                sensorTimestamp: raw.sensorTimestamp,
                receivedAt: raw.receivedAt,
                monotonicRelativeTimestampSeconds: monotonicRelativeTimestampSeconds,
                fixAgeSeconds: fixAge,
                source: raw.source,
                segmentDistanceMeters: quality == .measured ? segmentDistance : 0,
                impliedSpeedMetersPerSecond: impliedSpeed,
                gpsQuality: quality,
                presentationState: presentation
            )
            if quality == .measured {
                state.accumulatedDistanceMeters += segmentDistance
            }
            state.lastAcceptedFix = accepted
            state.lastSensorTimestamp = raw.sensorTimestamp
            state.lastMonotonicRelativeTimestampSeconds = monotonicRelativeTimestampSeconds
            return finalize(
                raw: raw,
                monotonicRelativeTimestampSeconds: monotonicRelativeTimestampSeconds,
                gpsQuality: quality,
                presentationState: presentation,
                rejectionReason: nil,
                accepted: accepted,
                state: &state
            )
        }

        let presentation = presentationState(
            fixAge: fixAge,
            horizontalAccuracyMeters: raw.horizontalAccuracyMeters,
            configuration: configuration
        )
        let quality = gpsQuality(for: presentation)
        let accepted = SnorkelingGPSAcceptedFix(
            latitude: raw.latitude,
            longitude: raw.longitude,
            horizontalAccuracyMeters: raw.horizontalAccuracyMeters,
            sensorTimestamp: raw.sensorTimestamp,
            receivedAt: raw.receivedAt,
            monotonicRelativeTimestampSeconds: monotonicRelativeTimestampSeconds,
            fixAgeSeconds: fixAge,
            source: raw.source,
            segmentDistanceMeters: 0,
            impliedSpeedMetersPerSecond: 0,
            gpsQuality: quality,
            presentationState: presentation
        )
        state.lastAcceptedFix = accepted
        state.lastSensorTimestamp = raw.sensorTimestamp
        state.lastMonotonicRelativeTimestampSeconds = monotonicRelativeTimestampSeconds
        return finalize(
            raw: raw,
            monotonicRelativeTimestampSeconds: monotonicRelativeTimestampSeconds,
            gpsQuality: quality,
            presentationState: presentation,
            rejectionReason: nil,
            accepted: accepted,
            state: &state
        )
    }

    private static func presentationState(
        fixAge: TimeInterval,
        horizontalAccuracyMeters: Double,
        configuration: SnorkelingGPSFeedConfiguration
    ) -> SnorkelingGPSPresentationState {
        if fixAge > configuration.trackingMaximumFixAgeSeconds {
            return .stale
        }
        if horizontalAccuracyMeters > configuration.trackingMaximumHorizontalAccuracyMeters {
            return .degraded
        }
        return .tracking
    }

    private static func gpsQuality(for presentation: SnorkelingGPSPresentationState) -> SnorkelingGPSQuality {
        switch presentation {
        case .tracking:
            return .measured
        case .degraded:
            return .estimated
        case .stale:
            return .stale
        case .unavailable, .underwaterUnavailable:
            return .unavailable
        }
    }

    private static func reject(
        raw: SnorkelingGPSRawFix,
        monotonicRelativeTimestampSeconds: TimeInterval,
        reason: SnorkelingGPSFeedRejectionReason,
        gpsQuality: SnorkelingGPSQuality,
        presentationState: SnorkelingGPSPresentationState,
        state: inout SnorkelingGPSFeedState,
        resetAcceptedBridge: Bool = false
    ) -> SnorkelingGPSIngestResult {
        if resetAcceptedBridge {
            state.lastAcceptedFix = nil
        }
        state.lastSensorTimestamp = raw.sensorTimestamp
        state.lastMonotonicRelativeTimestampSeconds = monotonicRelativeTimestampSeconds
        return finalize(
            raw: raw,
            monotonicRelativeTimestampSeconds: monotonicRelativeTimestampSeconds,
            gpsQuality: gpsQuality,
            presentationState: presentationState,
            rejectionReason: reason,
            accepted: nil,
            state: &state
        )
    }

    private static func finalize(
        raw: SnorkelingGPSRawFix,
        monotonicRelativeTimestampSeconds: TimeInterval,
        gpsQuality: SnorkelingGPSQuality,
        presentationState: SnorkelingGPSPresentationState,
        rejectionReason: SnorkelingGPSFeedRejectionReason?,
        accepted: SnorkelingGPSAcceptedFix?,
        state: inout SnorkelingGPSFeedState
    ) -> SnorkelingGPSIngestResult {
        appendAudit(
            raw: raw,
            monotonicRelativeTimestampSeconds: monotonicRelativeTimestampSeconds,
            gpsQuality: gpsQuality,
            presentationState: presentationState,
            rejectionReason: rejectionReason,
            accepted: accepted,
            state: &state
        )
        return SnorkelingGPSIngestResult(
            raw: raw,
            monotonicRelativeTimestampSeconds: monotonicRelativeTimestampSeconds,
            gpsQuality: gpsQuality,
            presentationState: presentationState,
            rejectionReason: rejectionReason,
            accepted: accepted,
            accumulatedDistanceMeters: state.accumulatedDistanceMeters
        )
    }

    private static func appendAudit(
        raw: SnorkelingGPSRawFix,
        monotonicRelativeTimestampSeconds: TimeInterval,
        gpsQuality: SnorkelingGPSQuality,
        presentationState: SnorkelingGPSPresentationState,
        rejectionReason: SnorkelingGPSFeedRejectionReason?,
        accepted: SnorkelingGPSAcceptedFix?,
        state: inout SnorkelingGPSFeedState
    ) {
        state.rawAuditTrail.append(
            SnorkelingGPSRawAuditEntry(
                raw: raw,
                monotonicRelativeTimestampSeconds: monotonicRelativeTimestampSeconds,
                gpsQuality: gpsQuality,
                presentationState: presentationState,
                rejectionReason: rejectionReason,
                accepted: accepted
            )
        )
        if state.rawAuditTrail.count > maximumRawAuditEntries {
            state.rawAuditTrail.removeFirst(state.rawAuditTrail.count - maximumRawAuditEntries)
        }
    }
}
