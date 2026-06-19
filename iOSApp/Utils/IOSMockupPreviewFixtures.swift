import Foundation

/// Deterministic presentation inputs for iOS mockup fixture and snapshot contract tests.
enum IOSMockupPreviewFixtures {
    static let fixedDate = Date(timeIntervalSince1970: 1_735_689_600) // 2025-01-01 00:00:00 UTC
    static let fixedSessionID = UUID(uuidString: "00000000-0000-4000-8000-000000000001")!
    static let fixedLocaleEN = Locale(identifier: "en_US")
    static let fixedLocaleIT = Locale(identifier: "it_IT")

    static let allIOSApneaMockupIDs: [String] = (1...15).map { String(format: "APNEA_IOS_%02d", $0) }

    static let allIOSSnorkelingMockupIDs: [String] = (1...3).map { String(format: "SNORKELING_IOS_%02d", $0) }

    static let companionSelectionMockupPath = "mockups/IOS_COMPANION_ACTIVITY_SELECTION_POST_ONBOARDING.png"
}
