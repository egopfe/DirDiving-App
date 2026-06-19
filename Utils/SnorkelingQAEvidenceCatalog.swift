import Foundation

/// Canonical physical QA evidence folders for Snorkeling release gate (Audit 12 remediation).
enum SnorkelingQAEvidenceCatalog {
    struct Entry: Equatable, Sendable {
        let qaID: String
        let folderName: String
        let commandCategory: String
        let purpose: String
        let requiredDevice: String
        let prerequisites: String
        let rollbackRequired: Bool
    }

    static let evidenceRoot = "Docs/QA_EVIDENCE"
    static let requiredMetadataFields = [
        "QA ID",
        "Status",
        "Branch",
        "Commit",
        "Tester",
        "Reviewer",
        "Execution date",
        "iPhone model",
        "iOS version",
        "Watch model",
        "watchOS version",
        "App build",
        "Test environment",
        "Preconditions",
        "Test steps",
        "Expected results",
        "Observed results",
        "Evidence artifacts",
        "Tester signature",
        "Reviewer signature",
    ]

    static let entries: [Entry] = [
        .init(qaID: "SNK-QA-001", folderName: "SNORKELING_IOS_WATCH_SYNC", commandCategory: "SNORKELING_IOS_WATCH_SYNC", purpose: "End-to-end iPhone ↔ Watch Snorkeling sync", requiredDevice: "Paired iPhone + Apple Watch", prerequisites: "Snorkeling profile on both devices; signed dev or TestFlight build", rollbackRequired: true),
        .init(qaID: "SNK-QA-002", folderName: "SNORKELING_ROUTE_PUSH", commandCategory: "SNORKELING_ROUTE_PUSH", purpose: "Route plan push from iOS to Watch", requiredDevice: "Paired iPhone + Apple Watch", prerequisites: "Route drafted on iOS; Watch reachable", rollbackRequired: true),
        .init(qaID: "SNK-QA-003", folderName: "SNORKELING_SESSION_PULL", commandCategory: "SNORKELING_SESSION_PULL", purpose: "Completed Watch session import to iOS Logbook", requiredDevice: "Paired iPhone + Apple Watch", prerequisites: "Completed Snorkeling session on Watch", rollbackRequired: true),
        .init(qaID: "SNK-QA-004", folderName: "SNORKELING_WATER_LOCK", commandCategory: "SNORKELING_WATER_LOCK", purpose: "Water Lock during Snorkeling session", requiredDevice: "Physical Apple Watch", prerequisites: "Active or pre-session Snorkeling UI", rollbackRequired: true),
        .init(qaID: "SNK-QA-005", folderName: "SNORKELING_WATCH_UI", commandCategory: "SNORKELING_WATCH_UI", purpose: "Watch UI stages: ready, surface, dip, nav, return, marker, summary", requiredDevice: "Physical Apple Watch", prerequisites: "Snorkeling session plan or manual session", rollbackRequired: false),
        .init(qaID: "SNK-QA-006", folderName: "SNORKELING_IOS_MAPS", commandCategory: "SNORKELING_IOS_MAPS", purpose: "iOS map preview, route overlay, gap handling", requiredDevice: "Physical iPhone", prerequisites: "Imported session with GPS track or route plan", rollbackRequired: false),
        .init(qaID: "SNK-QA-007", folderName: "SNORKELING_SAFETY_REVIEW", commandCategory: "SNORKELING_SAFETY_REVIEW", purpose: "Safety copy, disclaimers, non-certified navigation truthfulness", requiredDevice: "iPhone + Watch", prerequisites: "Release candidate build", rollbackRequired: true),
        .init(qaID: "SNK-QA-008", folderName: "SNORKELING_VOICEOVER", commandCategory: "SNORKELING_VOICEOVER", purpose: "VoiceOver on Watch and iOS Snorkeling surfaces", requiredDevice: "Physical iPhone + Watch", prerequisites: "VoiceOver enabled; EN and IT spot checks", rollbackRequired: false),
        .init(qaID: "SNK-QA-009", folderName: "SNORKELING_BATTERY_THERMAL", commandCategory: "SNORKELING_BATTERY,SNORKELING_THERMAL", purpose: "Battery drain and thermal behavior during surface sessions", requiredDevice: "Physical Apple Watch (Ultra + smallest supported)", prerequisites: "30–60 min surface session script", rollbackRequired: false),
        .init(qaID: "SNK-QA-010", folderName: "SNORKELING_GPS", commandCategory: "SNORKELING_GPS_ACCURACY", purpose: "GPS accuracy, degraded/unavailable presentation", requiredDevice: "Physical iPhone + Watch", prerequisites: "Outdoor or recorded GPS fixture", rollbackRequired: false),
        .init(qaID: "SNK-QA-011", folderName: "SNORKELING_RECOVERY", commandCategory: "SNORKELING_RECOVERY_RELAUNCH", purpose: "Session recovery after crash or force-quit", requiredDevice: "Physical Apple Watch", prerequisites: "Active Snorkeling checkpoint on disk", rollbackRequired: true),
        .init(qaID: "SNK-QA-012", folderName: "SNORKELING_RELAUNCH", commandCategory: "SNORKELING_RECOVERY_RELAUNCH", purpose: "App relaunch during/after Snorkeling session", requiredDevice: "Physical Apple Watch", prerequisites: "Session in progress or recently ended", rollbackRequired: true),
        .init(qaID: "SNK-QA-013", folderName: "SNORKELING_OFFLINE_ONLINE", commandCategory: "SNORKELING_OFFLINE", purpose: "Offline route/session behavior and reconnect sync", requiredDevice: "Paired iPhone + Watch", prerequisites: "Airplane mode or unreachable peer", rollbackRequired: true),
        .init(qaID: "SNK-QA-014", folderName: "SNORKELING_AIRPLANE_MODE", commandCategory: "SNORKELING_OFFLINE", purpose: "Airplane mode sync deferral and recovery", requiredDevice: "Paired iPhone + Watch", prerequisites: "Pending transfer queue", rollbackRequired: true),
        .init(qaID: "SNK-QA-015", folderName: "SNORKELING_PHOTO_PRIVACY", commandCategory: "SNORKELING_PRIVACY_REDACTION", purpose: "Photo EXIF redaction and export privacy", requiredDevice: "Physical iPhone", prerequisites: "Session photos with location metadata", rollbackRequired: true),
        .init(qaID: "SNK-QA-016", folderName: "SNORKELING_EXPORT", commandCategory: "SNORKELING_EXPORT", purpose: "Session export formats and share sheet", requiredDevice: "Physical iPhone", prerequisites: "Completed Snorkeling session in Logbook", rollbackRequired: false),
        .init(qaID: "SNK-QA-017", folderName: "SNORKELING_WATCH_LAYOUTS", commandCategory: "SNORKELING_SMALL_WATCH_LAYOUT,SNORKELING_WATCH_ULTRA", purpose: "Layout on smallest Watch and Watch Ultra", requiredDevice: "41 mm and 49 mm Apple Watch", prerequisites: "Same session script on both sizes", rollbackRequired: false),
        .init(qaID: "SNK-QA-018", folderName: "SNORKELING_PAIR_UNPAIR", commandCategory: "SNORKELING_PAIRED_DEVICE_MATRIX", purpose: "Pair/unpair and multi-device matrix", requiredDevice: "Multiple paired iPhone/Watch combinations", prerequisites: "Test matrix documented before execution", rollbackRequired: true),
        .init(qaID: "SNK-QA-019", folderName: "SNORKELING_HAPTICS", commandCategory: "SNORKELING_WATCH_UI", purpose: "Haptic alarms and marker confirmation on Watch", requiredDevice: "Physical Apple Watch", prerequisites: "Haptics enabled in settings", rollbackRequired: false),
        .init(qaID: "SNK-QA-020", folderName: "SNORKELING_WET_GLOVE", commandCategory: "SNORKELING_WATER_LOCK", purpose: "Wet glove / crown interaction limits", requiredDevice: "Physical Apple Watch", prerequisites: "Water Lock optional per scenario", rollbackRequired: false),
        .init(qaID: "SNK-QA-021", folderName: "SNORKELING_KEYCHAIN", commandCategory: "SNORKELING_IOS_WATCH_SYNC", purpose: "Sync crypto keychain trust and rotation", requiredDevice: "Paired iPhone + Watch", prerequisites: "Fresh install or key rotation scenario", rollbackRequired: true),
    ]

    static var folderCount: Int { entries.count }

    static func readmePath(for entry: Entry, repositoryRoot: URL) -> URL {
        repositoryRoot
            .appendingPathComponent(evidenceRoot)
            .appendingPathComponent(entry.folderName)
            .appendingPathComponent("README.md")
    }

    static func renderREADME(for entry: Entry, commit: String = "(record at execution)") -> String {
        """
        # Physical QA — \(entry.folderName)

        | Field | Value |
        |-------|-------|
        | **QA ID** | \(entry.qaID) |
        | **Command category** | \(entry.commandCategory) |
        | **Status** | **PENDING** |
        | **Branch** | \(commit == "(record at execution)" ? "(record at execution)" : "main") |
        | **Commit** | \(commit) |
        | **Purpose** | \(entry.purpose) |
        | **Required device** | \(entry.requiredDevice) |
        | **Tester** | |
        | **Reviewer** | |
        | **Execution date** | |
        | **iPhone model** | |
        | **iOS version** | |
        | **Watch model** | |
        | **watchOS version** | |
        | **App build** | |
        | **Test environment** | |
        | **Rollback required** | \(entry.rollbackRequired ? "YES" : "NO") |

        ## Preconditions

        \(entry.prerequisites)

        ## Test steps

        1. Install the build at the recorded commit SHA.
        2. Execute the scenario for **\(entry.folderName)** per `PROCEDURE.md` when present.
        3. Capture screenshot, video, or log artifacts under this folder (do not commit until reviewed).
        4. Record observed results and compare to expected results.
        5. Obtain tester and reviewer signatures before marking PASS.

        ## Expected results

        (Document per scenario before execution. Do not mark PASS without matching observed behavior.)

        ## Observed results

        **PENDING** — no physical evidence recorded yet.

        ## Evidence artifacts

        - (none — add `evidence-YYYYMMDD.ext` paths after capture)

        ## Battery / thermal notes

        (Required for battery/thermal scenarios; optional otherwise.)

        ## Linked issues

        - (none)

        ## Signatures

        | Role | Name | Date |
        |------|------|------|
        | Tester | | |
        | Reviewer | | |

        ## Verdict

        **PENDING** — PASS requires completed steps, attached artifacts, tester signature, and reviewer signature.
        Do not mark PASS without real device execution.
        """
    }
}
