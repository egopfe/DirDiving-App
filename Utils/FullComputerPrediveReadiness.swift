import Foundation

enum FullComputerPrediveReadiness: Equatable {
    case ready
    case sensorUnavailable
    case invalidGasProfile(String)

    var isReady: Bool {
        if case .ready = self { return true }
        return false
    }

    var errorMessage: String? {
        switch self {
        case .ready: return nil
        case .sensorUnavailable:
            return String(localized: "startup.fc_confirm.error.sensor")
        case .invalidGasProfile(let message):
            return message
        }
    }

    static func evaluate(
        depthAutomationAvailable: Bool,
        validationIssues: [FullComputerGasValidationIssue]
    ) -> FullComputerPrediveReadiness {
        if !validationIssues.isEmpty {
            let issue = validationIssues[0]
            let key = issue.localizationKey
            let message: String
            if let arg = issue.argument {
                message = String(format: String(localized: String.LocalizationValue(key)), arg)
            } else {
                message = String(localized: String.LocalizationValue(key))
            }
            return .invalidGasProfile(message)
        }
        if !depthAutomationAvailable {
            return .sensorUnavailable
        }
        return .ready
    }
}
