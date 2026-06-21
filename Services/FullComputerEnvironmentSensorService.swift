import Foundation
import CoreMotion
import Combine

struct FullComputerAbsoluteAltitudeSample: Equatable, Sendable {
    let altitudeMeters: Double
    let accuracyMeters: Double
    let precisionMeters: Double
    let receivedAt: Date
}

enum FullComputerEnvironmentSensorError: String, Error, Equatable, Sendable {
    case unavailable
    case sensorFailure
    case timedOut
}

enum FullComputerEnvironmentSensorState: Equatable {
    case idle
    case sampling
    case proposalReady
    case unavailable
    case timedOut
    case failed
}

enum FullComputerAltitudeSamplingPolicy {
    static let requiredSampleCount = 5
    static let maximumAccuracyMeters = FullComputerEnvironmentRecord.maximumSensorAccuracyMeters
    static let maximumStableSpreadMeters = 12.0
    static let timeoutSeconds: TimeInterval = 8

    static func isUsable(_ sample: FullComputerAbsoluteAltitudeSample) -> Bool {
        sample.altitudeMeters.isFinite
            && sample.accuracyMeters.isFinite
            && sample.accuracyMeters >= 0
            && sample.accuracyMeters <= maximumAccuracyMeters
            && sample.precisionMeters.isFinite
            && sample.precisionMeters >= 0
    }

    static func stableProposal(
        from samples: [FullComputerAbsoluteAltitudeSample]
    ) -> FullComputerAbsoluteAltitudeSample? {
        let usable = samples.filter(isUsable)
        guard usable.count >= requiredSampleCount else { return nil }
        let window = Array(usable.suffix(requiredSampleCount))
        let altitudes = window.map(\.altitudeMeters).sorted()
        guard let minimum = altitudes.first,
              let maximum = altitudes.last,
              maximum - minimum <= maximumStableSpreadMeters else {
            return nil
        }
        return FullComputerAbsoluteAltitudeSample(
            altitudeMeters: altitudes[altitudes.count / 2],
            accuracyMeters: window.map(\.accuracyMeters).max() ?? maximumAccuracyMeters,
            precisionMeters: window.map(\.precisionMeters).max() ?? 0,
            receivedAt: window.map(\.receivedAt).max() ?? Date()
        )
    }
}

@MainActor
protocol FullComputerAbsoluteAltitudeProviding: AnyObject {
    var isAvailable: Bool { get }
    func start(
        handler: @escaping (Result<FullComputerAbsoluteAltitudeSample, FullComputerEnvironmentSensorError>) -> Void
    )
    func stop()
}

@MainActor
final class AppleWatchAbsoluteAltitudeProvider: FullComputerAbsoluteAltitudeProviding {
    private let altimeter = CMAltimeter()

    var isAvailable: Bool {
        CMAltimeter.isAbsoluteAltitudeAvailable()
    }

    func start(
        handler: @escaping (Result<FullComputerAbsoluteAltitudeSample, FullComputerEnvironmentSensorError>) -> Void
    ) {
        guard isAvailable else {
            handler(.failure(.unavailable))
            return
        }
        altimeter.stopAbsoluteAltitudeUpdates()
        altimeter.startAbsoluteAltitudeUpdates(to: .main) { data, error in
            Task { @MainActor in
                if error != nil {
                    handler(.failure(.sensorFailure))
                    return
                }
                guard let data else { return }
                handler(
                    .success(
                        FullComputerAbsoluteAltitudeSample(
                            altitudeMeters: data.altitude,
                            accuracyMeters: data.accuracy,
                            precisionMeters: data.precision,
                            receivedAt: Date()
                        )
                    )
                )
            }
        }
    }

    func stop() {
        altimeter.stopAbsoluteAltitudeUpdates()
    }
}

/// Captures a fresh absolute-altitude sample immediately before Full Computer start.
/// Sensor data is always a proposal; it never mutates the active draft until accepted.
@MainActor
final class FullComputerEnvironmentSensorService: ObservableObject {
    static let shared = FullComputerEnvironmentSensorService()

    @Published private(set) var state: FullComputerEnvironmentSensorState = .idle

    private let provider: FullComputerAbsoluteAltitudeProviding
    private var samples: [FullComputerAbsoluteAltitudeSample] = []
    private var timeoutTask: Task<Void, Never>?
    private weak var configuration: FullComputerPrediveConfigurationStore?

    init(provider: FullComputerAbsoluteAltitudeProviding = AppleWatchAbsoluteAltitudeProvider()) {
        self.provider = provider
    }

    func requestProposal(into configuration: FullComputerPrediveConfigurationStore) {
        cancel()
        guard configuration.canEdit else { return }
        configuration.dismissPendingSensorProposal()
        guard provider.isAvailable else {
            state = .unavailable
            return
        }

        self.configuration = configuration
        samples = []
        state = .sampling
        provider.start { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let error):
                self.finish(with: error == .unavailable ? .unavailable : .failed)
            case .success(let sample):
                self.consume(sample)
            }
        }

        guard state == .sampling else { return }
        timeoutTask = Task { @MainActor [weak self] in
            try? await Task.sleep(
                nanoseconds: UInt64(FullComputerAltitudeSamplingPolicy.timeoutSeconds * 1_000_000_000)
            )
            guard !Task.isCancelled else { return }
            self?.finish(with: .timedOut)
        }
    }

    func cancel() {
        provider.stop()
        timeoutTask?.cancel()
        timeoutTask = nil
        samples = []
        configuration = nil
        if state == .sampling {
            state = .idle
        }
    }

    private func consume(_ sample: FullComputerAbsoluteAltitudeSample) {
        guard state == .sampling else { return }
        guard FullComputerAltitudeSamplingPolicy.isUsable(sample) else { return }
        samples.append(sample)
        guard let stable = FullComputerAltitudeSamplingPolicy.stableProposal(from: samples),
              let configuration else {
            return
        }

        let salinity = configuration.draftEnvironment?.salinity ?? .salt
        guard case .success(var record) = FullComputerEnvironmentRecord.make(
            altitudeMeters: stable.altitudeMeters,
            salinity: salinity,
            source: .watchSensorMeasuredProposal,
            capturedAt: stable.receivedAt
        ) else {
            finish(with: .failed)
            return
        }
        record.sensorAccuracyMeters = stable.accuracyMeters
        record.sensorPrecisionMeters = stable.precisionMeters
        guard record.validateForLiveStart() == nil else {
            finish(with: .failed)
            return
        }
        configuration.proposeSensorEnvironment(record)
        finish(with: .proposalReady)
    }

    private func finish(with finalState: FullComputerEnvironmentSensorState) {
        provider.stop()
        timeoutTask?.cancel()
        timeoutTask = nil
        samples = []
        configuration = nil
        state = finalState
    }
}
