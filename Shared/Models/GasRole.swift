import Foundation

enum GasRole: String, CaseIterable, Identifiable, Codable {
    case bottom = "Fondo"
    case travel = "Travel"
    case deco = "Deco"
    case bailout = "Bailout"
    case ccrDiluent = "CCR Diluent"
    case ccrBailout = "CCR Bailout"
    var id: String { rawValue }
}
