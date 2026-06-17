import Foundation

/// Lightweight release-hard invariant checks for Apnea (Command 12).
enum ApneaReleaseSelfCheck {
    struct Issue: Equatable {
        let code: String
        let detail: String
    }

    static let apneaSessionPayloadKey = "dirdiving_apnea_session"
    static let diveSessionPayloadKey = "dirdiving_dive_session"
    static let apneaPlanTransferType = "apneaSyncPlanPackage"
    static let fullComputerPlanTransferType = "fullComputerPlanPackage"

    static func verifySyncNamespaceIsolation() -> [Issue] {
        var issues: [Issue] = []
        if apneaSessionPayloadKey == diveSessionPayloadKey {
            issues.append(.init(code: "sync.namespace.collision", detail: "Apnea session key must differ from dive session key"))
        }
        if apneaPlanTransferType == fullComputerPlanTransferType {
            issues.append(.init(code: "sync.plan.collision", detail: "Apnea plan transfer type must differ from Full Computer plan package"))
        }
        return issues
    }

    static func verifyNoBlackoutOrNoMovementClaims(in repositoryText: String) -> [Issue] {
        let forbidden = [
            "blackout detection",
            "blackout monitor",
            "no-movement detection",
            "no movement detection",
            "sam detection",
        ]
        let lower = repositoryText.lowercased()
        return forbidden.compactMap { phrase in
            lower.contains(phrase)
                ? Issue(code: "safety.unvalidated_claim", detail: "Forbidden claim phrase: \(phrase)")
                : nil
        }
    }

    static func verifyMockupMatrix() -> [Issue] {
        var issues: [Issue] = []
        if ApneaMockupReferenceMatrix.count != 23 {
            issues.append(.init(code: "mockup.count", detail: "Expected 23 mockup entries, got \(ApneaMockupReferenceMatrix.count)"))
        }
        let ids = ApneaMockupReferenceMatrix.all.map(\.id)
        if Set(ids).count != ids.count {
            issues.append(.init(code: "mockup.duplicate", detail: "Duplicate mockup IDs in matrix"))
        }
        if ApneaMockupReferenceMatrix.watchCount != 8 {
            issues.append(.init(code: "mockup.watch_count", detail: "Expected 8 watch mockups"))
        }
        if ApneaMockupReferenceMatrix.iosCount != 15 {
            issues.append(.init(code: "mockup.ios_count", detail: "Expected 15 iOS mockups"))
        }
        return issues
    }

    static func runAll(apneaSourceText: String) -> [Issue] {
        verifySyncNamespaceIsolation()
            + verifyNoBlackoutOrNoMovementClaims(in: apneaSourceText)
            + verifyMockupMatrix()
    }
}
