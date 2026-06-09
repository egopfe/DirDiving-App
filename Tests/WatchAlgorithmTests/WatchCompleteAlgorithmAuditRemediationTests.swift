import XCTest

/// Regression guards from `Docs/WATCH_COMPLETE_ALGORITHM_AUDIT_CURRENT.md` remediation (2026-06-02).
final class WatchCompleteAlgorithmAuditRemediationTests: XCTestCase {
    private static let watchCompileRoots = ["App", "Models", "Services", "Views", "Utils"]
    private static let forbiddenRuntimeTokens = [
        "dirdiving_ccr",
        "buhlmann",
        "bühlmann",
        "ratio_deco",
        "ratiodeco",
        "setpoint",
        "diluent",
        "bailout"
    ]

    func testWatchCSVExportExcludesDecompressionAndCCRMetadata() {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let session = DiveSession(
            startDate: start,
            endDate: start.addingTimeInterval(120),
            durationSeconds: 120,
            maxDepthMeters: 18,
            avgDepthMeters: 15,
            avgWaterTemperatureCelsius: 21.5,
            minWaterTemperatureCelsius: 21,
            maxWaterTemperatureCelsius: 22,
            ttv: 30,
            entryGPS: nil,
            exitGPS: nil,
            samples: [
                DiveSample(timestamp: start, depthMeters: 12, temperatureCelsius: 22),
                DiveSample(timestamp: start.addingTimeInterval(60), depthMeters: 18, temperatureCelsius: 21)
            ]
        )
        let csv = SubsurfaceExportService.makeCSV(for: session)!
        let lower = csv.lowercased()
        XCTAssertTrue(lower.contains("dirdiving_watch_export"))
        for token in Self.forbiddenRuntimeTokens {
            XCTAssertFalse(
                lower.contains(token),
                "Watch CSV must not contain decompression/CCR token: \(token)"
            )
        }
    }

    func testWatchCompileRootsExcludeDecompressionAndCCRRuntimeKeywords() throws {
        let repoRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let fileManager = FileManager.default
        var scannedFiles: [URL] = []
        for root in Self.watchCompileRoots {
            let directory = repoRoot.appendingPathComponent(root, isDirectory: true)
            guard let enumerator = fileManager.enumerator(
                at: directory,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles]
            ) else { continue }
            for case let url as URL in enumerator {
                guard url.pathExtension == "swift" else { continue }
                if url.path.contains("/iOSApp/") { continue }
                scannedFiles.append(url)
            }
        }
        XCTAssertFalse(scannedFiles.isEmpty, "Expected Watch compile-root Swift files")
        for file in scannedFiles {
            let source = try String(contentsOf: file, encoding: .utf8)
            let codeWithoutLineComments = source
                .split(separator: "\n", omittingEmptySubsequences: false)
                .map { line -> String in
                    guard let range = line.range(of: "//") else { return String(line) }
                    return String(line[..<range.lowerBound])
                }
                .joined(separator: "\n")
                .lowercased()
            for token in Self.forbiddenRuntimeTokens {
                XCTAssertFalse(
                    codeWithoutLineComments.contains(token),
                    "\(file.lastPathComponent) must not reference decompression/CCR runtime token in code: \(token)"
                )
            }
        }
    }

    func testActionButtonIntentsSourceRequiresLegalAcceptanceForAllSafetyIntents() throws {
        let repoRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let source = try String(
            contentsOf: repoRoot.appendingPathComponent("Services/ActionButtonIntents.swift"),
            encoding: .utf8
        )
        let intentStructs = [
            "ToggleStopwatchIntent",
            "ResetStopwatchIntent",
            "StartManualDiveIntent",
            "EndManualDiveIntent",
            "SetBearingIntent",
            "ClearBearingIntent",
            "AcknowledgeAlarmIntent"
        ]
        for name in intentStructs {
            let pattern = "struct \(name)[\\s\\S]*?func perform\\(\\)[\\s\\S]*?requireLegalAcceptanceForSafetyIntent\\(\\)"
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(source.startIndex..<source.endIndex, in: source)
            XCTAssertNotNil(
                regex.firstMatch(in: source, range: range),
                "\(name) must call requireLegalAcceptanceForSafetyIntent before dive/safety actions"
            )
        }
    }
}

@MainActor
final class WatchCompleteAlgorithmAuditRemediationDraftTests: XCTestCase {
    private var tempDirectory: URL!

    override func setUp() async throws {
        try await super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("WatchAuditRemediation-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        DiveManager.testHook_draftDirectoryURL = tempDirectory
        DiveLogStore.testHook_storageDirectoryURL = tempDirectory.appendingPathComponent("logs", isDirectory: true)
        DiveManager.testHook_suppressDepthSensorProvider = true
    }

    override func tearDown() async throws {
        DiveManager.testHook_suppressDepthSensorProvider = false
        DiveManager.testHook_draftDirectoryURL = nil
        DiveLogStore.testHook_storageDirectoryURL = nil
        try? FileManager.default.removeItem(at: tempDirectory)
        try await super.tearDown()
    }

    func testCorruptDraftPayloadIsDiscardedWithoutCrash() {
        let url = tempDirectory.appendingPathComponent("dirdiving_active_dive_draft.json")
        try! Data("{ not valid json <<<".utf8).write(to: url)

        let manager = DiveManager(
            logStore: DiveLogStore(),
            gpsManager: GPSManager(),
            ascentSettings: AscentRateSettingsStore(defaults: UserDefaults(suiteName: "WatchAuditDraft-\(UUID().uuidString)")!)
        )
        XCTAssertFalse(manager.isDiveActive)
        XCTAssertFalse(manager.testHook_hasActiveDiveDraftOnDisk)
    }

    func testMalformedDraftSamplesFieldIsQuarantined() {
        let url = tempDirectory.appendingPathComponent("dirdiving_active_dive_draft.json")
        let json = """
        {"schemaVersion":1,"phase":"active","sessionID":"\(UUID().uuidString)","startDate":"2026-01-01T00:00:00Z","samples":"not-an-array","entryGPSFixSource":"noFix","isManualLifecycleActive":true,"sessionStartedManually":true,"activeDiveExceededSupportedDepth":false,"hasObservedSubmersionDuringCurrentDive":false,"createdAt":"2026-01-01T00:00:00Z","updatedAt":"2026-01-01T00:00:00Z"}
        """
        try! Data(json.utf8).write(to: url)

        let manager = DiveManager(
            logStore: DiveLogStore(),
            gpsManager: GPSManager(),
            ascentSettings: AscentRateSettingsStore(defaults: UserDefaults(suiteName: "WatchAuditDraft-\(UUID().uuidString)")!)
        )
        XCTAssertFalse(manager.isDiveActive)
        XCTAssertFalse(manager.testHook_hasActiveDiveDraftOnDisk)
    }
}
