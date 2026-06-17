import XCTest

final class ApneaReleaseHardValidationTests: XCTestCase {
    // MARK: - Mockup / bundle safety

    func testNoRasterMockupEmbeddedInIOSBundle() {
        let bundle = Bundle(for: ApneaReleaseHardValidationTests.self)
        let resourcePaths = bundle.paths(forResourcesOfType: "png", inDirectory: nil)
        let embeddedMockups = resourcePaths.filter { $0.contains("APNEA_") }
        XCTAssertTrue(embeddedMockups.isEmpty, "APNEA mockups must not ship in the iOS test bundle: \(embeddedMockups)")
    }

    func testSyncNamespaceIsolationConstants() {
        XCTAssertEqual(ApneaReleaseSelfCheck.apneaSessionPayloadKey, "dirdiving_apnea_session")
        XCTAssertEqual(ApneaReleaseSelfCheck.diveSessionPayloadKey, "dirdiving_dive_session")
        XCTAssertNotEqual(
            ApneaReleaseSelfCheck.apneaSessionPayloadKey,
            ApneaReleaseSelfCheck.diveSessionPayloadKey
        )
        XCTAssertNotEqual(
            ApneaReleaseSelfCheck.apneaPlanTransferType,
            ApneaReleaseSelfCheck.fullComputerPlanTransferType
        )
        XCTAssertTrue(ApneaReleaseSelfCheck.verifySyncNamespaceIsolation().isEmpty)
    }

    func testApneaSessionCodecUsesDedicatedPayloadKey() {
        XCTAssertEqual(ApneaSessionSyncCodec.payloadKey, ApneaReleaseSelfCheck.apneaSessionPayloadKey)
        XCTAssertNotEqual(ApneaSessionSyncCodec.payloadKey, WatchDiveSyncCodec.payloadKey)
    }

    func testApneaPlanTransferUsesDedicatedNamespace() {
        XCTAssertEqual(ApneaSyncTransferSupport.transferTypePackage, ApneaReleaseSelfCheck.apneaPlanTransferType)
        XCTAssertNotEqual(
            ApneaSyncTransferSupport.transferTypePackage,
            DivePlanPackageTransferSupport.transferTypePackage
        )
    }

    func testDegradedSessionsExcludedFromPersonalRecordsByDefault() {
        let degraded = makeSession(diveCount: 1, maxDepth: 18, warnings: [.dataQualityDegraded], includeSamples: true)
        let valid = makeSession(diveCount: 2, maxDepth: 24.7, includeSamples: true)
        XCTAssertFalse(ApneaRecordEligibilityPolicy.isEligibleForRecords(degraded))
        XCTAssertTrue(ApneaRecordEligibilityPolicy.isEligibleForRecords(valid))
        let summary = ApneaPersonalRecordsEngine.compute(from: [degraded, valid])
        XCTAssertEqual(summary.eligibleSessionCount, 1)
    }

    func testIOSBuddyDisclaimerLocalizationKeysExist() throws {
        let keys = [
            "apnea.ios.buddy.disclaimer",
            "apnea.ios.buddy.nav_title",
            "apnea.ios.watch.state.awaiting_ack",
            "apnea.ios.watch.state.delivered",
        ]
        let en = try loadIOSStrings(named: "en")
        let it = try loadIOSStrings(named: "it")
        for key in keys {
            XCTAssertFalse(en[key, default: ""].isEmpty, "Missing EN key: \(key)")
            XCTAssertFalse(it[key, default: ""].isEmpty, "Missing IT key: \(key)")
        }
    }

    // MARK: - Helpers

    private func makeSession(
        diveCount: Int,
        maxDepth: Double,
        duration: TimeInterval = 84,
        warnings: [ApneaSessionWarning] = [],
        includeSamples: Bool = false
    ) -> ApneaSession {
        let dives = (0..<diveCount).map { index in
            let samples: [ApneaSample]
            if includeSamples {
                samples = [
                    ApneaSample(monotonicRelativeTimestampSeconds: 0, depthMeters: 0),
                    ApneaSample(monotonicRelativeTimestampSeconds: duration / 2, depthMeters: maxDepth, temperatureCelsius: 24),
                    ApneaSample(monotonicRelativeTimestampSeconds: duration, depthMeters: 0),
                ]
            } else {
                samples = []
            }
            return ApneaDive(
                startedAtMonotonicSeconds: TimeInterval(index * 120),
                durationSeconds: duration,
                maxDepthMeters: maxDepth,
                averageDepthMeters: maxDepth * 0.6,
                samples: samples,
                events: [],
                markers: [],
                reachedMarkerIDs: [],
                recoveryAfter: ApneaRecoveryInterval(plannedSeconds: duration, completedSeconds: duration)
            )
        }
        return ApneaSession(
            startMode: .watch,
            state: .completed,
            dives: dives,
            warnings: warnings
        )
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func loadIOSStrings(named locale: String) throws -> [String: String] {
        let url = repositoryRoot().appendingPathComponent("iOSApp/Resources/\(locale).lproj/Localizable.strings")
        return parseStringsFile(try String(contentsOf: url, encoding: .utf8))
    }

    private func parseStringsFile(_ raw: String) -> [String: String] {
        var result: [String: String] = [:]
        let pattern = #"\"([^\"]+)\"\s*=\s*\"([^\"]*)\";"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return result }
        let range = NSRange(raw.startIndex..<raw.endIndex, in: raw)
        regex.enumerateMatches(in: raw, range: range) { match, _, _ in
            guard let match,
                  let keyRange = Range(match.range(at: 1), in: raw),
                  let valueRange = Range(match.range(at: 2), in: raw) else { return }
            result[String(raw[keyRange])] = String(raw[valueRange])
        }
        return result
    }
}
