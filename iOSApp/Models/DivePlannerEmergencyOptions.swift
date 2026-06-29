import Foundation

struct DivePlannerEmergencyOptions: Codable, Equatable, Sendable {
    var includeBuddyDecoGas: Bool

    static let `default` = DivePlannerEmergencyOptions(includeBuddyDecoGas: false)
}

extension GasPlanInput {
    var emergencyOptions: DivePlannerEmergencyOptions {
        get { DivePlannerEmergencyOptions(includeBuddyDecoGas: includeBuddyDecoGas) }
        set { includeBuddyDecoGas = newValue.includeBuddyDecoGas }
    }
}
