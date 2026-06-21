import CryptoKit
import Foundation

/// Structural snapshot contracts for iOS mockups (Command 14).
enum IOSMockupSnapshotContracts {
    static func expectedDimensions(mockupID: String, path: String) -> (width: Int, height: Int) {
        if path.contains("SNORKELING_IOS") || path.contains("SNORKELING_IOS") {
            return (1086, 1448)
        }
        if path.contains("IOS_COMPANION") {
            return (853, 1844)
        }
        if mockupID == "FC_UI_07" {
            return (1254, 1254)
        }
        return (768, 1024)
    }

    static func resolvedImplementationPath(mockupID: String, implementationView: String) -> String {
        switch mockupID {
        case "APNEA_IOS_06":
            return "iOSApp/Views/Apnea/IOSApneaSessionsListView.swift"
        case "APNEA_IOS_13":
            return "iOSApp/Views/Apnea/IOSApneaSessionDetailView.swift"
        default:
            let base = implementationView.components(separatedBy: " ").first ?? implementationView
            return base.replacingOccurrences(of: "(", with: "")
        }
    }

    static func localizationKeys(for mockupID: String) -> [String] {
        switch mockupID {
        case "APNEA_IOS_01":
            return ["apnea.ios.dashboard.title", "apnea.ios.dashboard.duration"]
        case "SNORKELING_IOS_01":
            return ["snorkeling.ios.dashboard.title", "snorkeling.ios.dashboard.duration"]
        case "IOS_COMPANION_ACTIVITY_SELECTION":
            return ["brand.name", "companion.activity.diving.title"]
        case "FC_UI_07":
            return ["fc.plan.transfer.title", "fc.plan.transfer.send"]
        default:
            return []
        }
    }

    static func accessibilityIdentifiers(for mockupID: String) -> [String] {
        switch mockupID {
        case "APNEA_IOS_01": return ["apnea.ios.dashboard"]
        case "SNORKELING_IOS_01": return ["snorkeling.ios.dashboard"]
        default: return []
        }
    }

    static func deterministicFingerprint(_ payload: String) -> String {
        let digest = SHA256.hash(data: Data(payload.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
