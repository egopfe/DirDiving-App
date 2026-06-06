import Foundation

enum DepthSampleValidity: String, Codable, Equatable {
    case valid
    case missing
    case stale
    case frozen
    case spikeRejected
    case nonFinite
    case outOfRange
}

struct ValidatedDepthSample: Equatable {
    let validity: DepthSampleValidity
    let rawDepthMeters: Double?
    let sample: DiveSample?

    var isValid: Bool { validity == .valid && sample != nil }
}

struct DepthSampleValidationState {
    private(set) var lastValidSample: DiveSample?
    private var frozenReferenceSample: DiveSample?

    mutating func reset() {
        lastValidSample = nil
        frozenReferenceSample = nil
    }

    mutating func restore(lastValidSample: DiveSample?) {
        self.lastValidSample = lastValidSample
        frozenReferenceSample = lastValidSample
    }

    mutating func validate(
        rawDepthMeters: Double?,
        timestamp: Date,
        receivedAt: Date = Date(),
        temperatureCelsius: Double?,
        isDiveActive: Bool = false,
        exemptMockSurfaceFrozenSamples: Bool = false
    ) -> ValidatedDepthSample {
        guard let rawDepthMeters else {
            return ValidatedDepthSample(validity: .missing, rawDepthMeters: nil, sample: nil)
        }
        guard rawDepthMeters.isFinite else {
            return ValidatedDepthSample(validity: .nonFinite, rawDepthMeters: rawDepthMeters, sample: nil)
        }
        guard rawDepthMeters <= DiveAlgorithmConfiguration.maximumPlausibleDepthMeters else {
            return ValidatedDepthSample(validity: .outOfRange, rawDepthMeters: rawDepthMeters, sample: nil)
        }
        guard timestamp.timeIntervalSince(receivedAt) <= DiveAlgorithmConfiguration.maximumFutureDepthSampleSkewSeconds else {
            return ValidatedDepthSample(validity: .stale, rawDepthMeters: rawDepthMeters, sample: nil)
        }
        guard receivedAt.timeIntervalSince(timestamp) <= DiveAlgorithmConfiguration.staleDepthSampleSeconds else {
            return ValidatedDepthSample(validity: .stale, rawDepthMeters: rawDepthMeters, sample: nil)
        }

        let depthMeters = max(0, rawDepthMeters)
        let sample = DiveSample(
            timestamp: timestamp,
            depthMeters: depthMeters,
            temperatureCelsius: DiveAlgorithm.sanitizedTemperatureCelsius(temperatureCelsius)
        )

        guard DiveAlgorithm.isPlausibleDepthTransition(from: lastValidSample, to: sample) else {
            return ValidatedDepthSample(validity: .spikeRejected, rawDepthMeters: rawDepthMeters, sample: nil)
        }

        if let reference = frozenReferenceSample,
           abs(reference.depthMeters - sample.depthMeters) <= DiveAlgorithmConfiguration.frozenDepthToleranceMeters {
            if sample.timestamp.timeIntervalSince(reference.timestamp) >= DiveAlgorithmConfiguration.frozenDepthSampleSeconds {
                let isMockSurfaceBand = exemptMockSurfaceFrozenSamples
                    && depthMeters <= DiveAlgorithmConfiguration.automaticStopDepthMeters
                if isDiveActive, !isMockSurfaceBand {
                    return ValidatedDepthSample(validity: .frozen, rawDepthMeters: rawDepthMeters, sample: nil)
                }
                frozenReferenceSample = sample
                lastValidSample = sample
                return ValidatedDepthSample(validity: .valid, rawDepthMeters: rawDepthMeters, sample: sample)
            }
        } else {
            frozenReferenceSample = sample
        }

        lastValidSample = sample
        return ValidatedDepthSample(validity: .valid, rawDepthMeters: rawDepthMeters, sample: sample)
    }
}
