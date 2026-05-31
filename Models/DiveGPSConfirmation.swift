import Foundation

enum DiveGPSConfirmation: Equatable {
    case start(point: GPSPoint?, fallback: Bool)
    case end(point: GPSPoint?, fallback: Bool)
}
