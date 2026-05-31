import Foundation

enum GPSConfirmationPresentation: Equatable {
    case fix
    case fallback
    case noFix

    static func from(point: GPSPoint?, fallback: Bool) -> GPSConfirmationPresentation {
        if point != nil, !fallback { return .fix }
        if point != nil, fallback { return .fallback }
        return .noFix
    }
}

extension DiveGPSConfirmation {
    var presentation: GPSConfirmationPresentation {
        switch self {
        case .start(let point, let fallback), .end(let point, let fallback):
            return GPSConfirmationPresentation.from(point: point, fallback: fallback)
        }
    }

    var isStart: Bool {
        if case .start = self { return true }
        return false
    }
}
