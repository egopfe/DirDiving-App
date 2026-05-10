import Foundation

enum BuddyAssistMessage: String, CaseIterable, Codable, Identifiable {
    case ok
    case ascend
    case problem
    case whereAreYou
    case turnBack
    case lowGas

    var id: String { rawValue }

    var title: String {
        switch self {
        case .ok: return "OK"
        case .ascend: return "RISALI"
        case .problem: return "HO UN PROBLEMA"
        case .whereAreYou: return "DOVE SEI?"
        case .turnBack: return "TORNA INDIETRO"
        case .lowGas: return "LOW GAS"
        }
    }

    var payload: String { title }
}

struct BuddyAssistEvent: Identifiable, Hashable {
    enum Direction: String, Hashable {
        case sent
        case received
    }

    let id = UUID()
    let message: BuddyAssistMessage
    let direction: Direction
    let timestamp: Date
}
