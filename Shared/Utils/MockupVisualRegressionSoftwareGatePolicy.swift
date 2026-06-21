import Foundation

/// Software-verifiable Command 14 mockup visual regression gates.
enum MockupVisualRegressionSoftwareGatePolicy {
    static let canonicalMockupCount = 59
    static let iosRasterSnapshotMockupCount = 20

    static let validationScriptPath = "Scripts/validate_mockup_visual_regression_readiness.sh"
    static let csvGeneratorScriptPath = "Scripts/generate_mockup_validation_csvs.py"

    static let command14AuditDocuments: [String] = [
        "Docs/MOCKUP_VISUAL_REGRESSION_AUDIT_CURRENT.md",
        "Docs/MOCKUP_VISUAL_REGRESSION_REMEDIATION_REPORT_CURRENT.md",
        "Docs/MOCKUP_PATH_VALIDATION_CURRENT.csv",
        "Docs/MOCKUP_IMPLEMENTATION_MATRIX_CURRENT.csv",
        "Docs/VISUAL_REGRESSION_COVERAGE_MATRIX_CURRENT.csv",
        "Docs/UI_UX_MOCKUP_INVENTORY_CURRENT.csv",
        "Docs/IOS_RASTER_SNAPSHOT_REGRESSION_POLICY_CURRENT.md",
        "Docs/REFERENCE_UI_LEGACY_ASSET_REGISTER_CURRENT.csv",
        "Docs/SMALLEST_WATCH_LAYOUT_SOFTWARE_COVERAGE_CURRENT.md",
        "Docs/MANUAL_VISUAL_FIDELITY_SCORING_POLICY_CURRENT.md",
        "Docs/MOCKUP_VISUAL_REGRESSION_FINDING_TRACEABILITY_CURRENT.csv",
        "Docs/MOCKUP_VISUAL_REGRESSION_REQUIREMENT_TEST_MATRIX_CURRENT.csv",
        "Docs/MOCKUP_VISUAL_REGRESSION_EXTERNAL_QA_PENDING_CURRENT.md",
    ]

    static let qaEvidenceScaffoldingFolders: [String] = [
        "Docs/QA_EVIDENCE/PHYSICAL_PIXEL_DIFF",
        "Docs/QA_EVIDENCE/IOS_ACCESSIBILITY",
        "Docs/QA_EVIDENCE/SNORKELING_WATCH_LAYOUTS",
        "Docs/QA_EVIDENCE/WATCH_MOCKUP_PIXEL_BASELINES",
        "Docs/QA_EVIDENCE/MANUAL_VISUAL_FIDELITY",
    ]

    static let iosRemediationSuites: [String] = [
        "MockupVisualRegressionRemediationTests",
        "MockupAntiEmbeddingTests",
        "IOSDashboardMockupFidelityTests",
        "IOSMockupRasterSnapshotTests",
        "IOSPlannerDynamicTypeContractTests",
    ]

    static let watchRemediationSuites: [String] = [
        "MockupVisualRegressionRemediationWatchTests",
        "SmallestWatchLayoutContractTests",
    ]

    static let softwareVerifiableFindingIDs: Set<String> = [
        "MVR-P1-001",
        "MVR-P2-001",
        "MVR-P2-003",
        "MVR-P3-001",
        "MVR-P3-002",
        "MVR-P3-003",
    ]

    static let externalPendingFindingIDs: Set<String> = [
        "MVR-P1-002",
        "MVR-P2-002",
        "MVR-P2-004",
    ]

    static let productionSourceScanRoots: [String] = [
        "Views",
        "iOSApp/Views",
        "App",
    ]

    static let mockupEmbeddingForbiddenPatterns: [String] = [
        "Image(\"FC_UI_",
        "Image(\"APNEA_",
        "Image(\"SNORKELING_",
        "Image(\"IOS_COMPANION_",
        "mockups/FC_UI_",
        "mockups/iOS/APNEA_",
        "mockups/iOS/SNORKELING_",
    ]

    static let mockupReferenceAllowlistPathFragments: [String] = [
        "Tests/",
        "Docs/",
        "Utils/Mockup",
        "Utils/ApneaMockup",
        "Utils/SnorkelingMockup",
        "Utils/FullComputerMockup",
        "mockups/README",
        "Scripts/generate_mockup",
        "Scripts/validate_mockup",
    ]

    static func documentExists(relativePath: String, repositoryRoot: URL) -> Bool {
        FileManager.default.fileExists(atPath: repositoryRoot.appendingPathComponent(relativePath).path)
    }

    static func folderHasScaffolding(relativePath: String, repositoryRoot: URL) -> Bool {
        let base = repositoryRoot.appendingPathComponent(relativePath)
        let required = ["README.md", "STATUS.md", "EVIDENCE_TEMPLATE.md"]
        return required.allSatisfy { FileManager.default.fileExists(atPath: base.appendingPathComponent($0).path) }
    }
}
