import Foundation

/// Release-hard invariant checks for Snorkeling Commands 04–07.
enum SnorkelingReleaseSelfCheck {
    struct Issue: Equatable {
        let code: String
        let detail: String
    }

    static let checkpointNamespace = "dirdiving_snorkeling_session"
    static let logbookNamespace = "dirdiving_snorkeling_sessions"
    static let diveSessionPayloadKey = "dirdiving_dive_session"
    static let apneaSessionPayloadKey = "dirdiving_apnea_session"

    static func verifyNamespaceIsolation() -> [Issue] {
        var issues: [Issue] = []
        if checkpointNamespace == diveSessionPayloadKey || checkpointNamespace == apneaSessionPayloadKey {
            issues.append(.init(code: "checkpoint.namespace.collision", detail: "Snorkeling checkpoint namespace must be isolated"))
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
        let required = [
            "Shared/Utils/SnorkelingNavigationEngine.swift",
            "Shared/Utils/SnorkelingReturnAdvisor.swift",
            "Shared/Utils/SnorkelingOperationalEventEngine.swift",
            "Shared/Utils/SnorkelingSessionCheckpointPersistence.swift",
            "Services/SnorkelingWatchRuntimeStore.swift",
            "Services/SnorkelingLogbookStore.swift",
            "Utils/SnorkelingWatchPresentation.swift",
            "Views/SnorkelingView.swift",
        ]
        return required.compactMap { relative in
            FileManager.default.fileExists(atPath: root.appendingPathComponent(relative).path)
                ? nil
                : Issue(code: "file.missing", detail: relative)
        }
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
        repositoryRoot: URL
    ) -> [Issue] {
        verifyNamespaceIsolation()
            + verifyNoForbiddenSafetyClaims(in: snorkelingSourceText)
            + verifyRequiredProductionFilesExist(at: repositoryRoot)
            + verifyLocalizationParity(english: english, italian: italian)
    }
}
