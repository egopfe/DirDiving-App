import Foundation

enum DepthSensorSubmersionState {
    case submerged
    case notSubmerged
    case unknown
}

@MainActor
protocol DepthSensorProvider: AnyObject {
    var onDepthMeasurement: ((Double?, Date, Double?) -> Void)? { get set }
    var onSubmersionState: ((DepthSensorSubmersionState) -> Void)? { get set }
    var onTemperature: ((Double?, Date) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    func start()
    func stop()
}
