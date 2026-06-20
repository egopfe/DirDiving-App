import CryptoKit
import XCTest

@MainActor
final class TestQaEvidenceRemediationTests: XCTestCase {
    func testCommand12AuditDocumentsExist() {
        let root = repositoryRoot()
        for relativePath in TestQaEvidenceSoftwareGatePolicy.command12AuditDocuments {
            XCTAssertTrue(
                TestQaEvidenceSoftwareGatePolicy.documentExists(relativePath: relativePath, repositoryRoot: root),
                "Missing Command 12 document: \(relativePath)"
            )
        }
        XCTAssertTrue(
            TestQaEvidenceSoftwareGatePolicy.documentExists(
                relativePath: TestQaEvidenceSoftwareGatePolicy.validationScriptPath,
                repositoryRoot: root
            )
        )
    }

    func testTraceabilityMatrixCoversAllRequirements() {
        XCTAssertTrue(TestQaEvidenceSoftwareGatePolicy.registryCoversAllTraceabilityRequirements(in: repositoryRoot()))
    }

    func testLogbookLargeDatasetSoftwareGate() throws {
        let sessions = IOSDiveLogbookScalabilitySupport.makeSyntheticSessions(count: 5_000)
        let data = try IOSDiveLogbookScalabilitySupport.encodeSessions(sessions)
        let budget = DIRPerformanceBudgets.entry(for: .logbookLoad)!
        let start = CFAbsoluteTimeGetCurrent()
        let decoded = try IOSDiveLogbookScalabilitySupport.decodeSessions(from: data)
        let elapsedMs = (CFAbsoluteTimeGetCurrent() - start) * 1_000
        XCTAssertEqual(decoded.count, 5_000)
        XCTAssertLessThan(elapsedMs, budget.hardTestLimit)
    }

    func testSubsurfaceCSVSoftwareRoundTripGate() throws {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let session = DiveSession(
            id: UUID(),
            startDate: start,
            endDate: start.addingTimeInterval(180),
            durationSeconds: 180,
            maxDepthMeters: 21,
            avgDepthMeters: 12,
            avgWaterTemperatureCelsius: 20,
            ttv: 21,
            entryGPS: nil,
            exitGPS: nil,
            samples: [
                DiveSample(timestamp: start, depthMeters: 0, temperatureCelsius: 21),
                DiveSample(timestamp: start.addingTimeInterval(180), depthMeters: 21, temperatureCelsius: 20),
            ],
            siteName: "Software gate reef",
            isManual: true
        )
        let csv = try XCTUnwrap(SubsurfaceExportService.makeCSV(for: session))
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("TestQaEvidence-\(UUID().uuidString).csv")
        try csv.write(to: url, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: url) }
        guard case .success(let summary) = DiveImportService.importCSV(from: url) else {
            return XCTFail("Expected successful Subsurface CSV import")
        }
        XCTAssertEqual(summary.session.siteName, "Software gate reef")
    }

    func testBuhlmannInternalReferenceFixturesAreFinite() {
        let air = BuhlmannPlanner.plan(
            depthMeters: 30,
            bottomGas: GasMix(name: "Air", role: .bottom, oxygen: 0.21, helium: 0, maxPPO2: 1.4)
        )
        XCTAssertEqual(air.modelState, .validReference)
        XCTAssertGreaterThan(air.ndlMinutes, 1)
    }

    func testSyncAckBurstSymmetryUnderLoad() {
        WatchSyncTestSupport.installDeterministicSecrets()
        defer { WatchSyncTestSupport.resetSecrets() }

        let sessionID = UUID()
        let issuedAt = Date()
        for index in 0..<100 {
            let diveAck = WatchDiveSyncCodec.ackSignature(
                sessionID: sessionID,
                issuedAt: issuedAt.addingTimeInterval(Double(index))
            )
            XCTAssertTrue(
                WatchDiveSyncCodec.verifyAckSignature(
                    diveAck,
                    sessionID: sessionID,
                    issuedAt: issuedAt.addingTimeInterval(Double(index))
                )
            )
            XCTAssertFalse(
                WatchDiveSyncCodec.verifyAckSignature(
                    diveAck,
                    sessionID: UUID(),
                    issuedAt: issuedAt.addingTimeInterval(Double(index))
                )
            )
        }
    }

    func testTombstoneSoftwareCodecGate() throws {
        WatchSyncTestSupport.installDeterministicSecrets()
        defer { WatchSyncTestSupport.resetSecrets() }
        let key = try WatchSyncAuth.deriveSyncKey(peerBundleID: "com.egopfe.dirdiving.ios")
        let sessionID = UUID()
        let record = ActivitySyncTombstoneRecord(sessionID: sessionID, activity: .snorkeling, revision: 3)
        let signed = try ActivitySyncSignedTombstone.sign(
            record: record,
            syncKey: key,
            bundleID: "com.egopfe.dirdiving.ios.watch"
        )
        XCTAssertTrue(signed.verify(syncKey: key, expectedBundleID: "com.egopfe.dirdiving.ios.watch"))
        let payload = ActivitySyncTombstoneCodec.encodeBroadcastPayload(
            tombstones: [signed],
            broadcastKey: ActivitySyncTombstoneBroadcast.broadcastKey(for: .snorkeling)
        )
        let decoded = ActivitySyncTombstoneCodec.decodeBroadcastPayload(
            from: payload,
            broadcastKey: ActivitySyncTombstoneBroadcast.broadcastKey(for: .snorkeling)
        )
        XCTAssertEqual(decoded.first?.record.sessionID, sessionID)
    }

    func testLegalAndAppStoreComplianceDocumentationExists() {
        let root = repositoryRoot()
        let required = [
            "Docs/IOS_APP_STORE_ALGORITHM_MARKETING_REVIEW_CHECKLIST.md",
            "Docs/RELEASE_CHECKLIST.md",
            "Docs/QA_EVIDENCE/APP_STORE_MARKETING/README.md",
        ]
        for path in required {
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }
    }

    func testPhysicalEvidenceFoldersDefaultPending() throws {
        let root = repositoryRoot()
        let pendingFolders = [
            "Docs/QA_EVIDENCE/WATCH_ULTRA/README.md",
            "Docs/QA_EVIDENCE/WATCH_IOS_SYNC/README.md",
            "Docs/QA_EVIDENCE/BUHLMANN_EXTERNAL/README.md",
            "Docs/QA_EVIDENCE/CCR_EXTERNAL/README.md",
            "Docs/QA_EVIDENCE/ICLOUD_TWO_DEVICE/README.md",
            "Docs/QA_EVIDENCE/DYNAMIC_TYPE_VOICEOVER/README.md",
        ]
        for path in pendingFolders {
            let url = root.appendingPathComponent(path)
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path), path)
            let text = try String(contentsOf: url, encoding: .utf8)
            XCTAssertTrue(text.localizedCaseInsensitiveContains("PENDING"), "\(path) must remain PENDING")
        }
    }

    func testSoftwareProxyRequirementsAreDeclared() {
        XCTAssertFalse(TestQaEvidenceSoftwareGatePolicy.softwareProxyRequirementIDs.isEmpty)
        XCTAssertTrue(TestQaEvidenceSoftwareGatePolicy.softwareProxyRequirementIDs.contains("REQ-LOG-02"))
        XCTAssertTrue(TestQaEvidenceSoftwareGatePolicy.softwareProxyRequirementIDs.contains("REQ-EXP-03"))
        XCTAssertTrue(
            TestQaEvidenceSoftwareGatePolicy.registryCoversAllTraceabilityRequirements(in: repositoryRoot())
        )
        XCTAssertEqual(
            TestQaEvidenceSoftwareGatePolicy.softwareVerifiableRequirementCount,
            TestQaEvidenceSoftwareGatePolicy.softwareClosedRequirementIDs
                .union(TestQaEvidenceSoftwareGatePolicy.softwareProxyRequirementIDs)
                .count
        )
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
