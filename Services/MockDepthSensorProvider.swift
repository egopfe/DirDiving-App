import Foundation

/// Simulation depth source — no Submerged Depth and Pressure entitlement required.
@MainActor
final class MockDepthSensorProvider: DepthSensorProvider {
    var onDepthMeasurement: ((Double?, Date, Double?) -> Void)?
    var onSubmersionState: ((DepthSensorSubmersionState) -> Void)?
    var onTemperature: ((Double?, Date) -> Void)?
    var onError: ((String) -> Void)?

    private var timer: Timer?

    func start() {
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.onDepthMeasurement?(0, Date(), 20.0)
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
