import Foundation

enum SalinityMode: String, CaseIterable, Identifiable, Codable {
    case fresh = "Dolce"
    case salt = "Salata"
    var id: String { rawValue }
}
