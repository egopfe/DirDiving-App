import Foundation

/// UI-free snorkeling depth ingestion quality for later presentation.
enum SnorkelingDepthPresentationState: String, Codable, CaseIterable, Hashable, Sendable {
    case valid
    case degraded
    case unavailable
}

struct SnorkelingDepthFeedConfiguration: Codable, Hashable, Sendable {
    var depthFeed: DepthMeasurementFeedConfiguration
    /// Depth at or above which the diver is treated as underwater for cross-feed GPS policy.
    var underwaterDepthThresholdMeters: Double
    /// Depth above which accepted readings may be flagged degraded when the feed rejects spikes.
    var degradedDepthThresholdMeters: Double

    static let snorkelingDefault = SnorkelingDepthFeedConfiguration(
        depthFeed: .snorkelingDefault,
        underwaterDepthThresholdMeters: 0.35,
        degradedDepthThresholdMeters: 8
    )
}

struct SnorkelingDepthRawAuditEntry: Codable, Equatable, Hashable, Sendable {
    let raw: DepthMeasurementRaw
    let monotonicRelativeTimestampSeconds: TimeInterval
    let depthFeedQuality: DepthFeedQuality
    let snorkelingQuality: SnorkelingDepthQuality
    let presentationState: SnorkelingDepthPresentationState
}

struct SnorkelingDepthFeedState: Codable, Hashable, Sendable {
    var depthFeedState: DepthMeasurementFeedState
    var rawAuditTrail: [SnorkelingDepthRawAuditEntry]
    var isUnderwater: Bool
    var lastAcceptedDepthMeters: Double?
    var lastTemperatureCelsius: Double?

    static let initial = SnorkelingDepthFeedState(
        depthFeedState: .initial,
        rawAuditTrail: [],
        isUnderwater: false,
        lastAcceptedDepthMeters: nil,
        lastTemperatureCelsius: nil
    )
}

struct SnorkelingDepthIngestResult: Equatable, Hashable, Sendable {
    let raw: DepthMeasurementRaw
    let monotonicRelativeTimestampSeconds: TimeInterval
    let depthFeedQuality: DepthFeedQuality
    let snorkelingQuality: SnorkelingDepthQuality
    let presentationState: SnorkelingDepthPresentationState
    let acceptedDepthMeters: Double?
    let temperatureCelsius: Double?
    let verticalSpeedMetersPerSecond: Double?
    let isUnderwater: Bool
}

/// Snorkeling depth feed — reuses `DepthMeasurementFeed` without Dive lifecycle coupling.
enum SnorkelingDepthFeed {
    static let maximumRawAuditEntries = 2_048

    @discardableResult
    static func ingest(
        raw: DepthMeasurementRaw,
        monotonicRelativeTimestampSeconds: TimeInterval,
        state: inout SnorkelingDepthFeedState,
        configuration: SnorkelingDepthFeedConfiguration = .snorkelingDefault
    ) -> SnorkelingDepthIngestResult {
        let depthResult = DepthMeasurementFeed.ingest(
            raw: raw,
            state: &state.depthFeedState,
            configuration: configuration.depthFeed
        )

        let acceptedDepth = depthResult.accepted?.depthMeters
        let isUnderwater = acceptedDepth.map {
            $0 >= configuration.underwaterDepthThresholdMeters
        } ?? state.isUnderwater

        let snorkelingQuality = mapQuality(
            depthResult: depthResult,
            acceptedDepthMeters: acceptedDepth,
            configuration: configuration
        )
        let presentationState = mapPresentation(
            depthFeedQuality: depthResult.quality,
            snorkelingQuality: snorkelingQuality
        )

        if let accepted = depthResult.accepted {
            state.lastAcceptedDepthMeters = accepted.depthMeters
            state.lastTemperatureCelsius = accepted.temperatureCelsius
            state.isUnderwater = accepted.depthMeters >= configuration.underwaterDepthThresholdMeters
        } else if depthResult.quality == .missing {
            // Keep last underwater hint until a new accepted surface sample arrives.
        }

        appendAudit(
            raw: raw,
            monotonicRelativeTimestampSeconds: monotonicRelativeTimestampSeconds,
            depthFeedQuality: depthResult.quality,
            snorkelingQuality: snorkelingQuality,
            presentationState: presentationState,
            state: &state
        )

        return SnorkelingDepthIngestResult(
            raw: raw,
            monotonicRelativeTimestampSeconds: monotonicRelativeTimestampSeconds,
            depthFeedQuality: depthResult.quality,
            snorkelingQuality: snorkelingQuality,
            presentationState: presentationState,
            acceptedDepthMeters: acceptedDepth,
            temperatureCelsius: depthResult.accepted?.temperatureCelsius ?? state.lastTemperatureCelsius,
            verticalSpeedMetersPerSecond: depthResult.accepted?.verticalSpeedMetersPerSecond,
            isUnderwater: isUnderwater
        )
    }

    private static func mapQuality(
        depthResult: DepthFeedIngestResult,
        acceptedDepthMeters: Double?,
        configuration: SnorkelingDepthFeedConfiguration
    ) -> SnorkelingDepthQuality {
        switch depthResult.quality {
        case .accepted:
            guard let acceptedDepthMeters else { return .unavailable }
            if acceptedDepthMeters >= configuration.degradedDepthThresholdMeters {
                return .shallowEstimate
            }
            if acceptedDepthMeters >= configuration.underwaterDepthThresholdMeters {
                return .shallowEstimate
            }
            return .measured
        case .missing:
            return .unavailable
        case .nonFinite, .spikeRejected, .regressiveTimestamp, .stale, .outOfRange:
            return .invalid
        }
    }

    private static func mapPresentation(
        depthFeedQuality: DepthFeedQuality,
        snorkelingQuality: SnorkelingDepthQuality
    ) -> SnorkelingDepthPresentationState {
        switch depthFeedQuality {
        case .accepted:
            return snorkelingQuality == .measured ? .valid : .degraded
        case .missing:
            return .unavailable
        case .nonFinite, .spikeRejected, .regressiveTimestamp, .stale, .outOfRange:
            return snorkelingQuality == .invalid ? .degraded : .unavailable
        }
    }

    private static func appendAudit(
        raw: DepthMeasurementRaw,
        monotonicRelativeTimestampSeconds: TimeInterval,
        depthFeedQuality: DepthFeedQuality,
        snorkelingQuality: SnorkelingDepthQuality,
        presentationState: SnorkelingDepthPresentationState,
        state: inout SnorkelingDepthFeedState
    ) {
        state.rawAuditTrail.append(
            SnorkelingDepthRawAuditEntry(
                raw: raw,
                monotonicRelativeTimestampSeconds: monotonicRelativeTimestampSeconds,
                depthFeedQuality: depthFeedQuality,
                snorkelingQuality: snorkelingQuality,
                presentationState: presentationState
            )
        )
        if state.rawAuditTrail.count > maximumRawAuditEntries {
            state.rawAuditTrail.removeFirst(state.rawAuditTrail.count - maximumRawAuditEntries)
        }
    }
}
