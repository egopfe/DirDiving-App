import Foundation

/// iOS companion session configuration sent toward Watch runtime.
struct ApneaSessionConfiguration: Codable, Hashable, Sendable {
    var profile: ApneaSessionProfile
    var recoveryPolicy: ApneaRecoveryPolicy
    var recoveryAlertsEnabled: Bool
    var buddyReminderShown: Bool
    var checklistAcknowledged: Bool
    var trainingTable: ApneaTrainingTable?

    init(
        profile: ApneaSessionProfile,
        recoveryPolicy: ApneaRecoveryPolicy? = nil,
        recoveryAlertsEnabled: Bool = true,
        buddyReminderShown: Bool = false,
        checklistAcknowledged: Bool = false,
        trainingTable: ApneaTrainingTable? = nil
    ) {
        self.profile = profile
        self.recoveryPolicy = recoveryPolicy ?? profile.minimumRecoveryPolicy
        self.recoveryAlertsEnabled = recoveryAlertsEnabled
        self.buddyReminderShown = buddyReminderShown
        self.checklistAcknowledged = checklistAcknowledged
        self.trainingTable = trainingTable
    }
}
