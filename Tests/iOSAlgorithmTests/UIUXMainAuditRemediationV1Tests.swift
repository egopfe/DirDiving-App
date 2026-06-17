import XCTest

final class UIUXMainAuditRemediationV1Tests: XCTestCase {
    func testGPSAndCompassUseSemanticKeysNotItalianPhrases() throws {
        let compass = try String(contentsOf: repositoryRoot().appendingPathComponent("Services/CompassManager.swift"))
        let settings = try String(contentsOf: repositoryRoot().appendingPathComponent("Views/SettingsView.swift"))
        let forbidden = ["Fix disponibile", "Bussola pronta", "Bussola attiva", "Bussola non disponibile"]
        for phrase in forbidden {
            XCTAssertFalse(compass.contains("String(localized: \"\(phrase)\""), "Italian-as-key in CompassManager: \(phrase)")
            XCTAssertFalse(settings.contains("String(localized: \"\(phrase)\""), "Italian-as-key in SettingsView: \(phrase)")
        }
        XCTAssertTrue(compass.contains("watch.compass.status."))
        XCTAssertTrue(settings.contains("watch.gps.status."))
    }

    func testCCRPlanResultUsesLocalizedChartAxesAndDensityUnavailableState() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/CCR/CCRPlanResultView.swift"))
        XCTAssertTrue(source.contains("ccr.chart.axis.time"))
        XCTAssertTrue(source.contains("CCRGasDensityPresentation.timelineSamples"))
        XCTAssertTrue(source.contains("ccr.gas_density.unavailable.description"))
        XCTAssertFalse(source.contains(".value(\"Time\""))
        XCTAssertFalse(source.contains(".value(\"Density\""))
    }

    func testPDFExportGateReasonKeysExistInBothCatalogs() throws {
        let en = try loadIOSStrings(named: "en")
        let it = try loadIOSStrings(named: "it")
        for reason in PDFExportBlockReason.allCases {
            let key = "pdf.export.error.\(reason.rawValue)"
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT \(key)")
        }
    }

    func testPDFExportGatePrimaryMessageUsesFirstReason() {
        let message = PDFExportGate.primaryMessage(for: [.modViolation, .invalidValidation])
        XCTAssertEqual(message, DIRIOSLocalizer.string("pdf.export.error.modViolation"))
    }

    func testCCRGasDensityUnavailableDoesNotReportZeroTimeline() {
        let base = CCRPlannerService.makePlan(input: CCRPlanInput.default)
        let unavailableSample = CCRTimelineSample(
            runtimeMinutes: 0,
            depthMeters: 20,
            ppO2Bar: 1.2,
            ppN2Bar: 0.6,
            endMeters: 10,
            gasDensityResult: .unavailable(reason: .invalidSetpoint)
        )
        let plan = CCRPlanResult(
            schedule: base.schedule,
            bailoutScenarios: base.bailoutScenarios,
            tissueTrace: base.tissueTrace,
            oxygenExposure: base.oxygenExposure,
            ppO2Timeline: base.ppO2Timeline,
            ppN2Timeline: base.ppN2Timeline,
            endTimeline: base.endTimeline,
            gasDensityTimeline: [unavailableSample],
            cnsTimeline: base.cnsTimeline,
            warnings: base.warnings,
            validationResult: base.validationResult,
            engineSegments: base.engineSegments,
            ttsMinutes: base.ttsMinutes,
            totalRuntimeMinutes: base.totalRuntimeMinutes,
            decoStops: base.decoStops,
            depthProfilePoints: base.depthProfilePoints,
            buhlmannState: base.buhlmannState
        )
        XCTAssertFalse(CCRGasDensityPresentation.hasAvailableTimeline(plan))
        XCTAssertEqual(
            CCRGasDensityPresentation.unavailableReason(for: plan),
            .invalidSetpoint
        )
        XCTAssertTrue(
            CCRGasDensityPresentation.accessibilitySummary(for: plan)
                .localizedCaseInsensitiveContains("unavailable")
                || CCRGasDensityPresentation.accessibilitySummary(for: plan)
                    .localizedCaseInsensitiveContains("non disponibile")
        )
    }

    func testBriefingReferenceFooterLocalizedInBothCatalogs() throws {
        let en = try loadIOSStrings(named: "en")
        let it = try loadIOSStrings(named: "it")
        XCTAssertEqual(en["briefing.reference_only.footer"], "DIR DIVING — REFERENCE ONLY")
        XCTAssertEqual(it["briefing.reference_only.footer"], "DIR DIVING — SOLO RIFERIMENTO")
        XCTAssertEqual(
            PlannerBriefingTransferSupport.referenceOnlyFooter,
            String(localized: "briefing.reference_only.footer")
        )
    }

    func testSettingsTabBadgeDerivesFromCanonicalSyncState() throws {
        let source = try String(contentsOf: repositoryRoot().appendingPathComponent("iOSApp/Views/ContentView.swift"))
        XCTAssertTrue(source.contains("watchSync.conflicts.count"))
        XCTAssertTrue(source.contains("logStore.sessionMergeConflicts.count"))
        XCTAssertTrue(source.contains("cloudSync.lastDecodeError"))
    }

    func testSyncBadgeLocalizationKeysExist() throws {
        let en = try loadIOSStrings(named: "en")
        let it = try loadIOSStrings(named: "it")
        for key in ["sync.badge.conflict.singular", "sync.badge.conflict.plural", "sync.badge.pending", "sync.badge.warning"] {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT \(key)")
        }
    }

    func testCCRGasDensityLocalizationKeysExistForAllReasons() throws {
        let en = try loadIOSStrings(named: "en")
        let it = try loadIOSStrings(named: "it")
        for reason in CCRGasDensityUnavailableReason.allCases {
            let key = "ccr.gas_density.unavailable.\(reason.rawValue)"
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT \(key)")
        }
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func loadIOSStrings(named language: String) throws -> [String: String] {
        let url = repositoryRoot()
            .appendingPathComponent("iOSApp/Resources/\(language).lproj/Localizable.strings")
        let raw = try String(contentsOf: url, encoding: .utf8)
        var result: [String: String] = [:]
        let pattern = #"^\s*"(.+?)"\s*=\s*"(.*)";\s*$"#
        let regex = try NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        let range = NSRange(raw.startIndex..<raw.endIndex, in: raw)
        regex.enumerateMatches(in: raw, options: [], range: range) { match, _, _ in
            guard let match, match.numberOfRanges == 3,
                  let keyRange = Range(match.range(at: 1), in: raw),
                  let valueRange = Range(match.range(at: 2), in: raw) else { return }
            result[String(raw[keyRange])] = String(raw[valueRange])
        }
        return result
    }
}
