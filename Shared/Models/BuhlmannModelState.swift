import Foundation

enum BuhlmannModelState: String, Codable, Hashable {
    case validReference
    case simplifiedReferenceOnly
    case unsupportedTrimix
    case modelIncomplete
    case unavailable
    case invalidInput
}
