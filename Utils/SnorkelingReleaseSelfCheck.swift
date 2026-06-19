import Foundation

/// Release-hard invariant checks for Snorkeling Commands 04–12 (Watch runtime + iOS companion).
enum SnorkelingReleaseSelfCheck {
    struct Issue: Equatable {
        let code: String
        let detail: String
    }

    static let checkpointNamespace = "dirdiving_snorkeling_session"
    static let sessionSyncPayloadKey = "dirdiving_snorkeling_session_sync"
    static let routeSyncTransferType = "snorkelingRoutePackage"
    static let logbookNamespace = "dirdiving_snorkeling_sessions"
    static let diveSessionPayloadKey = "dirdiving_dive_session"
    static let apneaSessionPayloadKey = "dirdiving_apnea_session"
    static let apneaPlanTransferType = "apneaSyncPlanPackage"
    static let fullComputerPlanTransferType = "fullComputerPlanPackage"

    static let iosCommand08Files = [
        "iOSApp/Views/Snorkeling/IOSSnorkelingDashboardView.swift",
        "iOSApp/Views/Snorkeling/IOSSnorkelingProfilesView.swift",
        "iOSApp/Views/Snorkeling/IOSSnorkelingRoutePlannerView.swift",
        "iOSApp/Views/Snorkeling/IOSSnorkelingRootView.swift",
        "Shared/Utils/SnorkelingRouteSyncCodec.swift",
        "iOSApp/Services/IOSSnorkelingWatchTransferService.swift",
        "Shared/Utils/SnorkelingRoutePlanValidator.swift",
        "iOSApp/Utils/IOSSnorkelingLocationPermission.swift",
    ]

    static let iosCommand09Files = [
        "iOSApp/Views/Snorkeling/IOSSnorkelingSessionsListView.swift",
        "iOSApp/Views/Snorkeling/IOSSnorkelingSessionDetailView.swift",
        "iOSApp/Services/IOSSnorkelingLogbookStore.swift",
        "Shared/Utils/SnorkelingLogbookAnalytics.swift",
        "Shared/Utils/SnorkelingSessionChartData.swift",
        "Shared/Utils/SnorkelingPersonalRecordsEngine.swift",
        "Shared/Utils/SnorkelingSessionMapPresentation.swift",
    ]

    static let iosCommand10Files = [
        "iOSApp/Views/Snorkeling/IOSSnorkelingSessionExportView.swift",
        "iOSApp/Views/Snorkeling/IOSSnorkelingEquipmentView.swift",
        "iOSApp/Views/Snorkeling/IOSSnorkelingBuddySafetyView.swift",
        "iOSApp/Views/Snorkeling/IOSSnorkelingSettingsView.swift",
        "Shared/Utils/SnorkelingExportPrivacyPolicy.swift",
        "Shared/Utils/SnorkelingSessionExportEngine.swift",
        "Shared/Models/SnorkelingEquipmentCatalog.swift",
        "Shared/Models/SnorkelingBuddySafety.swift",
        "Shared/Utils/SnorkelingPhotoMetadataSanitizer.swift",
        "iOSApp/Services/IOSSnorkelingSessionPhotoStore.swift",
        "iOSApp/Services/IOSSnorkelingSessionExportService.swift",
    ]

    static let iosCommand11Files = [
        "Services/SnorkelingSessionSyncCodec.swift",
        "iOSApp/Services/SnorkelingSessionSyncCodec.swift",
        "Shared/Utils/SnorkelingSessionMerge.swift",
        "Services/SnorkelingSyncPendingTransfer.swift",
        "iOSApp/Services/IOSSnorkelingSessionSyncService.swift",
    ]

    static let watchCommand04to07Files = [
        "Shared/Utils/SnorkelingNavigationEngine.swift",
        "Shared/Utils/SnorkelingReturnAdvisor.swift",
        "Shared/Utils/SnorkelingOperationalEventEngine.swift",
        "Shared/Utils/SnorkelingSessionCheckpointPersistence.swift",
        "Services/SnorkelingWatchRuntimeStore.swift",
        "Services/SnorkelingLogbookStore.swift",
        "Utils/SnorkelingWatchPresentation.swift",
        "Views/SnorkelingView.swift",
    ]

    static func verifyNamespaceIsolation() -> [Issue] {
        var issues: [Issue] = []
        if checkpointNamespace == diveSessionPayloadKey || checkpointNamespace == apneaSessionPayloadKey {
            issues.append(.init(code: "checkpoint.namespace.collision", detail: "Snorkeling checkpoint namespace must be isolated"))
        }
        if sessionSyncPayloadKey == diveSessionPayloadKey || sessionSyncPayloadKey == apneaSessionPayloadKey {
            issues.append(.init(code: "session_sync.namespace.collision", detail: "Snorkeling session sync namespace must be isolated"))
        }
        if sessionSyncPayloadKey == checkpointNamespace {
            issues.append(.init(code: "session_sync.checkpoint.collision", detail: "Snorkeling session sync must not reuse checkpoint namespace"))
        }
        if sessionSyncPayloadKey == routeSyncTransferType {
            issues.append(.init(code: "session_sync.route.collision", detail: "Session sync must not reuse route sync key"))
        }
        if logbookNamespace == "dirdiving_apnea_sessions" || logbookNamespace == "dirdiving_dive_sessions" {
            issues.append(.init(code: "logbook.namespace.collision", detail: "Snorkeling logbook namespace must be isolated"))
        }
        return issues
    }

    static func verifyNoForbiddenSafetyClaims(in repositoryText: String) -> [Issue] {
        let forbidden = [
            "guaranteed return",
            "safe route",
            "rescue route",
            "exact underwater gps",
            "emergency navigation",
            "certified snorkeling computer",
            "medically safe",
            "zero risk",
        ]
        let lower = repositoryText.lowercased()
        return forbidden.compactMap { phrase in
            lower.contains(phrase)
                ? Issue(code: "safety.unvalidated_claim", detail: "Forbidden claim phrase: \(phrase)")
                : nil
        }
    }

    static func verifyRequiredProductionFilesExist(at root: URL) -> [Issue] {
        let required = watchCommand04to07Files
            + iosCommand08Files
            + iosCommand09Files
            + iosCommand10Files
            + iosCommand11Files
        return required.compactMap { relative in
            FileManager.default.fileExists(atPath: root.appendingPathComponent(relative).path)
                ? nil
                : Issue(code: "file.missing", detail: relative)
        }
    }

    static func verifyNoRasterMockupInProductionBundles(in sources: String) -> [Issue] {
        var issues: [Issue] = []
        if sources.contains("Image(\"SNORKELING_WATCH_") || sources.contains("Image(\"SNORKELING_IOS_") {
            issues.append(.init(code: "mockup.raster.embedded", detail: "SNORKELING raster mockups must not ship in production UI"))
        }
        if sources.contains("SNORKELING_WATCH_01_READY.png") && sources.contains("Bundle.main") {
            issues.append(.init(code: "mockup.bundle.load", detail: "Reference mockup PNG must not load from app bundle"))
        }
        return issues
    }

    static func verifyMockupReferenceIndex(at root: URL) -> [Issue] {
        let missing = SnorkelingMockupReferenceMatrix.referencePNGExists(at: root)
        return missing.map { .init(code: "mockup.reference.missing", detail: $0) }
    }

    static func verifySensorStartGate(in sources: String) -> [Issue] {
        guard sources.contains("SnorkelingWatchPresentation") else { return [] }
        if !sources.contains("startDisabledReason") || !sources.contains("snorkeling.ready.sensor_unavailable") {
            return [.init(code: "watch.sensor_gate.missing", detail: "Ready start must fail closed when depth sensor unavailable")]
        }
        return []
    }

    static func verifyIOSProductionPolicies(in sources: String) -> [Issue] {
        var issues: [Issue] = []
        if sources.contains("ExplorationCenterView") && sources.contains("IOSSnorkelingRootView") {
            issues.append(.init(code: "ios.exploration.in_production", detail: "ExplorationCenterView must not ship in snorkeling shell"))
        }
        if sources.range(of: #"offlineCacheReady:\s*true"#, options: .regularExpression) != nil,
           sources.contains("SnorkelingRoutePlannerDraft") {
            // Route planner draft must not default offline cache to true in production builder.
            if sources.contains("offlineCacheReady: true") && sources.contains("buildRoutePlan") {
                issues.append(.init(code: "ios.offline_map.fake", detail: "Route planner must not claim offline cache ready"))
            }
        }
        let fakeMetrics = ["heatmap", "readinessScore", "fatigueScore", "predictiveWellness"]
        for metric in fakeMetrics where sources.contains(metric) {
            issues.append(.init(code: "ios.fake_metric", detail: metric))
        }
        return issues
    }

    static func verifyProjectMembership(projectText: String) -> [Issue] {
        var issues: [Issue] = []
        let mustAppear = iosCommand11Files + [
            "Utils/SnorkelingMockupReferenceMatrix.swift",
            "Shared/Utils/SnorkelingSyncTestSupport.swift",
            "Shared/Utils/SnorkelingPhotoMetadataSanitizer.swift",
            "Tests/iOSAlgorithmTests/SnorkelingSessionSyncTransportNegativeTests.swift",
            "Tests/iOSAlgorithmTests/SnorkelingRouteAckRoundTripTests.swift",
            "Tests/iOSAlgorithmTests/SnorkelingSessionSyncInterruptedTransferTests.swift",
            "Tests/iOSAlgorithmTests/SnorkelingLegacyV1TransportTests.swift",
            "Tests/iOSAlgorithmTests/SnorkelingDuplicateIgnoredImportTests.swift",
            "Tests/iOSAlgorithmTests/IOSSnorkelingDashboardMapGapTests.swift",
            "Tests/iOSAlgorithmTests/IOSSnorkelingNoGPSPresentationTests.swift",
            "Tests/iOSAlgorithmTests/IOSSnorkelingExportServiceE2ETests.swift",
            "Tests/iOSAlgorithmTests/SnorkelingPhotoMetadataSanitizationTests.swift",
            "Tests/iOSAlgorithmTests/IOSSnorkelingReleaseHardValidationTests.swift",
            "Tests/iOSAlgorithmTests/IOSSnorkelingUIViewContractTests.swift",
            "Tests/WatchAlgorithmTests/SnorkelingMockupReferenceMatrixTests.swift",
        ]
        for path in mustAppear where !projectText.contains(path) {
            if path.hasPrefix("Shared/"), projectText.contains("path: Shared") {
                continue
            }
            issues.append(.init(code: "project.membership.missing", detail: path))
        }
        return issues
    }

    static func verifyLocalizationParity(
        english: [String: String],
        italian: [String: String]
    ) -> [Issue] {
        var issues: [Issue] = []
        let enKeys = Set(english.keys.filter { $0.hasPrefix("snorkeling.") })
        let itKeys = Set(italian.keys.filter { $0.hasPrefix("snorkeling.") })
        if enKeys != itKeys {
            issues.append(.init(code: "localization.parity", detail: "EN/IT snorkeling key sets differ"))
        }
        for key in SnorkelingLocalizationCatalog.productionKeys {
            if english[key, default: ""].isEmpty {
                issues.append(.init(code: "localization.en.missing", detail: key))
            }
            if italian[key, default: ""].isEmpty {
                issues.append(.init(code: "localization.it.missing", detail: key))
            }
        }
        return issues
    }

    static func runAll(
        snorkelingSourceText: String,
        english: [String: String],
        italian: [String: String],
        repositoryRoot: URL,
        projectText: String = "",
        verifyWatchLocalization: Bool = true
    ) -> [Issue] {
        verifyNamespaceIsolation()
            + verifyNoForbiddenSafetyClaims(in: snorkelingSourceText)
            + verifyRequiredProductionFilesExist(at: repositoryRoot)
            + verifyNoRasterMockupInProductionBundles(in: snorkelingSourceText)
            + verifyMockupReferenceIndex(at: repositoryRoot)
            + verifySensorStartGate(in: snorkelingSourceText)
            + verifyIOSProductionPolicies(in: snorkelingSourceText)
            + (projectText.isEmpty ? [] : verifyProjectMembership(projectText: projectText))
            + (verifyWatchLocalization ? verifyLocalizationParity(english: english, italian: italian) : [])
    }
}
