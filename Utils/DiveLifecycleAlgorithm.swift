import Foundation

enum DiveLifecycleAction: Equatable {
    case none
    case startDive
    case endDive
}

struct DiveLifecycleAlgorithm {
    private var startCandidateCount = 0
    private var startCandidateDate: Date?
    private(set) var surfaceCandidateDate: Date?

    mutating func reset() {
        startCandidateCount = 0
        startCandidateDate = nil
        surfaceCandidateDate = nil
    }

    mutating func clearSurfaceCandidate() {
        surfaceCandidateDate = nil
    }

    mutating func evaluate(
        validatedSample: ValidatedDepthSample,
        isDiveActive: Bool,
        isManualLifecycleActive: Bool,
        hasObservedSubmersion: Bool
    ) -> DiveLifecycleAction {
        guard let sample = validatedSample.sample, validatedSample.isValid else { return .none }

        if !isDiveActive {
            return evaluateStart(depthMeters: sample.depthMeters, timestamp: sample.timestamp)
        }

        guard !isManualLifecycleActive || hasObservedSubmersion else { return .none }
        return evaluateStop(depthMeters: sample.depthMeters, timestamp: sample.timestamp)
    }

    mutating func shouldEndAtSurface(currentDepthMeters: Double, timestamp: Date) -> Bool {
        guard let surfaceCandidateDate else { return false }
        guard currentDepthMeters <= DiveAlgorithmConfiguration.automaticStopDepthMeters else { return false }
        return timestamp.timeIntervalSince(surfaceCandidateDate) >= DiveAlgorithmConfiguration.automaticStopDwellSeconds
    }

    private mutating func evaluateStart(depthMeters: Double, timestamp: Date) -> DiveLifecycleAction {
        guard depthMeters > DiveAlgorithmConfiguration.automaticStartDepthMeters else {
            startCandidateCount = 0
            startCandidateDate = nil
            return .none
        }

        if let candidateDate = startCandidateDate,
           timestamp.timeIntervalSince(candidateDate) > DiveAlgorithmConfiguration.staleDepthSampleSeconds {
            startCandidateCount = 0
            startCandidateDate = nil
        }
        if startCandidateDate == nil {
            startCandidateDate = timestamp
        }
        startCandidateCount += 1
        return startCandidateCount >= DiveAlgorithmConfiguration.automaticStartRequiredSamples ? .startDive : .none
    }

    private mutating func evaluateStop(depthMeters: Double, timestamp: Date) -> DiveLifecycleAction {
        guard depthMeters <= DiveAlgorithmConfiguration.automaticStopDepthMeters else {
            surfaceCandidateDate = nil
            return .none
        }
        if surfaceCandidateDate == nil {
            surfaceCandidateDate = timestamp
        }
        return shouldEndAtSurface(currentDepthMeters: depthMeters, timestamp: timestamp) ? .endDive : .none
    }
}
