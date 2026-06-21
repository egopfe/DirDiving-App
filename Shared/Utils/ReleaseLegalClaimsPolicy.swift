import Foundation

/// Canonical Command 13 release/legal/claims software gate registry (documentation + validation).
enum ReleaseLegalClaimsPolicy {
    static let validationScriptPath = "Scripts/validate_release_legal_claims_readiness.sh"
    static let prohibitedClaimsScannerPath = "Scripts/scan_prohibited_claims.py"
    static let claimsRegistryCSV = "Docs/CLAIMS_POLICY_REGISTRY_CURRENT.csv"
    static let claimsEvidenceMatrixCSV = "Docs/CLAIMS_EVIDENCE_MATRIX_CURRENT.csv"
    static let prohibitedAllowlistCSV = "Docs/PROHIBITED_CLAIMS_ALLOWLIST_CURRENT.csv"
    static let findingTraceabilityCSV = "Docs/RELEASE_LEGAL_FINDING_TRACEABILITY_CURRENT.csv"

    static let requiredGovernanceDocuments: [String] = [
        "Docs/RELEASE_LEGAL_CLAIMS_COMPLIANCE_AUDIT_CURRENT.md",
        "Docs/RELEASE_LEGAL_CLAIMS_COMPLIANCE_REMEDIATION_REPORT_CURRENT.md",
        "Docs/CLAIMS_POLICY_REGISTRY_CURRENT.md",
        "Docs/CLAIMS_POLICY_REGISTRY_CURRENT.csv",
        "Docs/LEGAL_VERSIONING_AND_RECONSENT_POLICY_CURRENT.md",
        "Docs/RELEASE_CLAIMS_GATE_POLICY_CURRENT.md",
        "Docs/RELEASE_GATE_MATRIX_CURRENT.csv",
        "Docs/INCIDENT_RESPONSE_RUNBOOK_CURRENT.md",
        "Docs/RELEASE_ROLLBACK_PROCEDURE_CURRENT.md",
        "Docs/SUPPORT_ESCALATION_AND_SLA_CURRENT.md",
        "Docs/EXPORT_DISCLAIMER_POLICY_CURRENT.md",
        "Docs/WATCH_ULTRA_ENTITLEMENT_RELEASE_GATE_CURRENT.md",
        "Docs/APP_STORE_TESTFLIGHT_BLOCKERS_CURRENT.md",
        "Docs/RELEASE_LEGAL_EXTERNAL_QA_PENDING_CURRENT.md",
        "Docs/LEGAL_COPY_OWNERSHIP_CURRENT.md",
        "Docs/RELEASE_LEGAL_REQUIREMENT_TEST_MATRIX_CURRENT.csv",
    ]

    static let requiredEvidencePackages: [(folder: String, statusFile: String, templateFile: String)] = [
        ("Docs/QA_EVIDENCE/LEGAL_REVIEW", "STATUS.md", "EVIDENCE_TEMPLATE.md"),
        ("Docs/QA_EVIDENCE/APP_STORE_MARKETING", "STATUS.md", "EVIDENCE_TEMPLATE.md"),
        ("Docs/QA_EVIDENCE/BUHLMANN_EXTERNAL", "STATUS.md", "EVIDENCE_TEMPLATE.md"),
        ("Docs/QA_EVIDENCE/CCR_EXTERNAL", "STATUS.md", "EVIDENCE_TEMPLATE.md"),
        ("Docs/QA_EVIDENCE/HARDWARE_ENTITLEMENT", "STATUS.md", "EVIDENCE_TEMPLATE.md"),
        ("Docs/QA_EVIDENCE/DYNAMIC_TYPE_VOICEOVER", "STATUS.md", "EVIDENCE_TEMPLATE.md"),
        ("Docs/QA_EVIDENCE/WATCH_IOS_SYNC", "STATUS.md", "EVIDENCE_TEMPLATE.md"),
        ("Docs/QA_EVIDENCE/ICLOUD_TWO_DEVICE", "STATUS.md", "EVIDENCE_TEMPLATE.md"),
    ]

    static let iosRemediationSuite = "ReleaseLegalClaimsRemediationTests"
    static let watchRemediationSuite = "ReleaseLegalClaimsRemediationWatchTests"

    static func documentExists(relativePath: String, repositoryRoot: URL) -> Bool {
        FileManager.default.fileExists(atPath: repositoryRoot.appendingPathComponent(relativePath).path)
    }

    static func registryCoversMinimumClaimIDs(in repositoryRoot: URL) -> Bool {
        let url = repositoryRoot.appendingPathComponent(claimsRegistryCSV)
        guard let text = try? String(contentsOf: url, encoding: .utf8) else { return false }
        let ids = Set(
            text.split(separator: "\n").dropFirst().compactMap { line -> String? in
                let field = line.split(separator: ",", maxSplits: 1).first.map(String.init)
                return field?.hasPrefix("CLM-") == true ? field : nil
            }
        )
        return minimumClaimIDs.isSubset(of: ids)
    }

    static let minimumClaimIDs: Set<String> = [
        "CLM-GLOBAL-01", "CLM-GLOBAL-02",
        "CLM-GAUGE-01", "CLM-FC-01", "CLM-FC-02",
        "CLM-PLN-01", "CLM-PLN-02", "CLM-PLN-03",
        "CLM-CCR-01",
        "CLM-APNEA-01", "CLM-SNORK-01",
        "CLM-GPS-01", "CLM-EXP-01", "CLM-PRIV-01", "CLM-ENT-01",
        "CLM-EQUIP-01", "CLM-STORE-01", "CLM-STORE-02",
        "CLM-SYNC-01", "CLM-CLOUD-01", "CLM-LEGAL-01",
        "CLM-BM-EXT-01", "CLM-CCR-EXT-01",
    ]
}
