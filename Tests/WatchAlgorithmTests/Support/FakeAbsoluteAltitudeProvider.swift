import Foundation

@MainActor
final class FakeAbsoluteAltitudeProvider: FullComputerAbsoluteAltitudeProviding {
    var isAvailable = true
    private(set) var startCount = 0
    private(set) var stopCount = 0
    private var handler: ((FullComputerAltitudeProviderEvent) -> Void)?

    func start(handler: @escaping (FullComputerAltitudeProviderEvent) -> Void) {
        startCount += 1
        self.handler = handler
    }

    func stop() {
        stopCount += 1
    }

    func emit(
        altitudeMeters: Double,
        accuracyMeters: Double,
        precisionMeters: Double,
        sensorMeasuredAt: Date = Date(),
        receivedAt: Date? = nil
    ) {
        let receipt = receivedAt ?? sensorMeasuredAt
        handler?(
            .sample(
                FullComputerAbsoluteAltitudeSample(
                    altitudeMeters: altitudeMeters,
                    accuracyMeters: accuracyMeters,
                    precisionMeters: precisionMeters,
                    sensorMeasuredAt: sensorMeasuredAt,
                    receivedAt: receipt
                )
            )
        )
    }

    func emitFailure(_ error: FullComputerEnvironmentSensorError) {
        handler?(.failure(error))
    }

    func emitNilDataNilError() {
        handler?(.nilDataNilError)
    }
}
