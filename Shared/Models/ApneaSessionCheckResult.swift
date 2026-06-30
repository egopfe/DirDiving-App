import Foundation

enum ApneaSessionCheckStatus: String, Codable, CaseIterable, Hashable, Sendable {
    case ready
    case warning
    case incomplete
    case blocked
}

struct ApneaSessionCheckIssue: Codable, Hashable, Sendable, Identifiable {
    let id: UUID
    var localizationKey: String
    var severity: ApneaSessionCheckStatus

    init(id: UUID = UUID(), localizationKey: String, severity: ApneaSessionCheckStatus) {
        self.id = id
        self.localizationKey = localizationKey
        self.severity = severity
    }
}

struct ApneaSessionCheckResult: Codable, Hashable, Sendable {
    var status: ApneaSessionCheckStatus
    var profileKind: ApneaProfileKind
    var recoveryAlertsEnabled: Bool
    var buddyReminderShown: Bool
    var issues: [ApneaSessionCheckIssue]

    var isReadyForTraining: Bool {
        status == .ready || status == .warning
    }
}
