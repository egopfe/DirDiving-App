import Foundation

/// Software-verifiable Command 12 test/QA evidence gates.
/// Physical-device, paired-device field, underwater entitlement, and external-reference
/// campaigns remain PENDING until `Docs/QA_EVIDENCE/` folders contain signed artifacts.
enum TestQaEvidenceSoftwareGatePolicy {
    static let command12AuditDocuments: [String] = [
        "Docs/TEST_QA_EVIDENCE_AUDIT_CURRENT.md",
        "Docs/REQUIREMENT_TEST_TRACEABILITY_MATRIX_CURRENT.csv",
        "Docs/PHYSICAL_DEVICE_QA_MATRIX_CURRENT.csv",
        "Docs/EXTERNAL_VALIDATION_GAPS_CURRENT.md",
        "Docs/READINESS_TO_100_PLAN_CURRENT.md",
        "Docs/TEST_QA_EVIDENCE_REMEDIATION_REPORT_CURRENT.md",
        "Docs/TEST_QA_FINDING_TRACEABILITY_CURRENT.csv",
        "Docs/TEST_QA_EXTERNAL_QA_PENDING_CURRENT.md",
    ]

    static let validationScriptPath = "Scripts/validate_test_qa_evidence_readiness.sh"

    static let iosRemediationSuite = "TestQaEvidenceRemediationTests"
    static let watchRemediationSuite = "TestQaEvidenceRemediationWatchTests"
    static let plannerVisualContractSuite = "PlannerVisualContractTests"

    static let regressionValidationScripts: [String] = [
        "Scripts/validate_activity_architecture_settings_logbook_readiness.sh",
        "Scripts/validate_multi_activity_sync_persistence_schema_readiness.sh",
        "Scripts/validate_security_privacy_trust_readiness.sh",
        "Scripts/validate_performance_concurrency_battery_readiness.sh",
    ]

    /// Requirement IDs closed by automated/simulator evidence (physical/external still PENDING).
    static let softwareClosedRequirementIDs: Set<String> = [
        "REQ-START-01", "REQ-START-02", "REQ-START-03",
        "REQ-GAUGE-01", "REQ-GAUGE-02", "REQ-GAUGE-03",
        "REQ-FC-01", "REQ-FC-02", "REQ-FC-03", "REQ-FC-04", "REQ-FC-05",
        "REQ-BM-01", "REQ-BM-02",
        "REQ-GAS-01", "REQ-GAS-02",
        "REQ-DECO-01",
        "REQ-APNEA-01", "REQ-APNEA-02", "REQ-APNEA-03",
        "REQ-SNORK-01", "REQ-SNORK-02", "REQ-SNORK-03",
        "REQ-SET-01", "REQ-SET-02",
        "REQ-LOG-01",
        "REQ-SYNC-01", "REQ-SYNC-02", "REQ-SYNC-03",
        "REQ-MIG-01", "REQ-MIG-02",
        "REQ-BKP-01",
        "REQ-L10N-01", "REQ-L10N-02",
        "REQ-A11Y-01",
        "REQ-SEC-01", "REQ-SEC-02",
        "REQ-PERF-01", "REQ-PERF-02",
        "REQ-EXP-01", "REQ-EXP-02",
        "REQ-CCR-01",
        "REQ-ARCH-01",
        "REQ-LEGAL-01",
    ]

    /// Requirement IDs with software proxy coverage; field/external evidence still PENDING.
    static let softwareProxyRequirementIDs: Set<String> = [
        "REQ-FC-06",
        "REQ-BM-03",
        "REQ-APNEA-04",
        "REQ-SNORK-04",
        "REQ-LOG-02",
        "REQ-SYNC-04",
        "REQ-BKP-02",
        "REQ-A11Y-02",
        "REQ-EXP-03",
        "REQ-CCR-02",
        "REQ-LEGAL-02",
        "REQ-UND-01",
    ]

    static let physicalOnlyRequirementIDs: Set<String> = softwareProxyRequirementIDs

    static var softwareVerifiableRequirementCount: Int {
        softwareClosedRequirementIDs.count + softwareProxyRequirementIDs.count
    }

    static func documentExists(relativePath: String, repositoryRoot: URL) -> Bool {
        FileManager.default.fileExists(atPath: repositoryRoot.appendingPathComponent(relativePath).path)
    }

    static func registryCoversAllTraceabilityRequirements(in repositoryRoot: URL) -> Bool {
        let matrixURL = repositoryRoot.appendingPathComponent("Docs/REQUIREMENT_TEST_TRACEABILITY_MATRIX_CURRENT.csv")
        guard let text = try? String(contentsOf: matrixURL, encoding: .utf8) else { return false }
        let ids = text
            .split(separator: "\n")
            .dropFirst()
            .compactMap { line -> String? in
                let field = line.split(separator: ",", maxSplits: 1).first.map(String.init)
                return field?.hasPrefix("REQ-") == true ? field : nil
            }
        let all = Set(ids)
        return all == softwareClosedRequirementIDs.union(softwareProxyRequirementIDs)
    }
}
