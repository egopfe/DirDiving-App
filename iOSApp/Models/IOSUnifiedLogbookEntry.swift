import Foundation

enum IOSUnifiedLogbookActivityKind: String, Codable, CaseIterable, Hashable, Identifiable, Sendable {
    case diving
    case snorkeling
    case apnea

    var id: String { rawValue }

    var dirActivityMode: DIRActivityMode {
        switch self {
        case .diving: return .diving
        case .snorkeling: return .snorkeling
        case .apnea: return .apnea
        }
    }
}

struct IOSUnifiedLogbookEntry: Identifiable, Hashable, Sendable {
    let id: String
    let sourceID: UUID
    let activity: IOSUnifiedLogbookActivityKind
    let date: Date
    let title: String
    let subtitle: String
    let primaryMetric: String
    let secondaryMetric: String?
    let tertiaryMetric: String?
    let isDemo: Bool
}

enum IOSUnifiedLogbookSelection: Identifiable, Hashable {
    case diving(UUID)
    case snorkeling(UUID)
    case apnea(UUID)

    var id: String {
        switch self {
        case .diving(let uuid): return "diving-\(uuid.uuidString)"
        case .snorkeling(let uuid): return "snorkeling-\(uuid.uuidString)"
        case .apnea(let uuid): return "apnea-\(uuid.uuidString)"
        }
    }
}
