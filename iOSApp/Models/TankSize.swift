import Foundation

/// Shared tank size menu for Equipment checklist and Planner (iOS MAIN).
enum TankSize: String, CaseIterable, Identifiable, Codable, Hashable {
    case s80 = "S80"
    case s40 = "S40"
    case bibo12 = "Bibo 12+12"
    case liters12 = "12L"
    case liters15 = "15L"
    case liters18 = "18L"

    var id: String { rawValue }

    /// Approximate water volume in liters for planner cylinder capacity display.
    var volumeLiters: Double {
        switch self {
        case .s80: return 11.1
        case .s40: return 5.7
        case .bibo12: return 24
        case .liters12: return 12
        case .liters15: return 15
        case .liters18: return 18
        }
    }

    static func nearest(toVolumeLiters volume: Double) -> TankSize {
        allCases.min { abs($0.volumeLiters - volume) < abs($1.volumeLiters - volume) } ?? .liters12
    }
}
