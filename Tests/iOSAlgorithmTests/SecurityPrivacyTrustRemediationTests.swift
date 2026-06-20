import XCTest

final class SecurityPrivacyTrustRemediationTests: XCTestCase {
    func testPrivacyManifestIOSExistsAndDeclaresNoTracking() throws {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("iOSApp/Config/PrivacyInfo-iOS.xcprivacy")
        let data = try Data(contentsOf: url)
        let plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        XCTAssertEqual(plist?["NSPrivacyTracking"] as? Bool, false)
        let domains = plist?["NSPrivacyTrackingDomains"] as? [String]
        XCTAssertEqual(domains?.isEmpty, true)
    }

    func testPrivacyManifestWatchExistsAndDeclaresNoTracking() throws {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Config/PrivacyInfo-Watch.xcprivacy")
        let data = try Data(contentsOf: url)
        let plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        XCTAssertEqual(plist?["NSPrivacyTracking"] as? Bool, false)
    }

    func testDivingExportOmitsGPSByDefault() {
        let gps = GPSPoint(latitude: 45.123456, longitude: 9.654321, horizontalAccuracy: 5, timestamp: Date())
        let omitted = DivingExportPrivacyPolicy.exportCoordinateStrings(point: gps, precision: .omitted)
        XCTAssertEqual(omitted.latitude, "")
        XCTAssertEqual(omitted.longitude, "")
    }

    func testDivingExportApproximateGPSReducesPrecision() {
        let gps = GPSPoint(latitude: 45.123456, longitude: 9.654321, horizontalAccuracy: 5, timestamp: Date())
        let approx = DivingExportPrivacyPolicy.exportCoordinateStrings(point: gps, precision: .approximate)
        XCTAssertEqual(approx.latitude, "45.123")
        XCTAssertEqual(approx.longitude, "9.654")
    }

    func testDivingExportPreciseGPSPreservesSixDecimals() {
        let gps = GPSPoint(latitude: 45.123456, longitude: 9.654321, horizontalAccuracy: 5, timestamp: Date())
        let precise = DivingExportPrivacyPolicy.exportCoordinateStrings(point: gps, precision: .precise)
        XCTAssertEqual(precise.latitude, "45.123456")
        XCTAssertEqual(precise.longitude, "9.654321")
    }

    func testTrustBootstrapRejectsStaleContext() {
        let stale = WatchSyncTrustBootstrapPolicy.bootstrapMetadata(
            for: 1,
            issuedAt: Date().addingTimeInterval(-WatchSyncTrustBootstrapPolicy.bootstrapTTLSeconds - 10)
        )
        XCTAssertEqual(
            WatchSyncTrustBootstrapPolicy.validateBootstrapMetadata(stale, expectedEpoch: 1),
            .stale
        )
    }

    func testTrustBootstrapAcceptsFreshContext() {
        let fresh = WatchSyncTrustBootstrapPolicy.bootstrapMetadata(for: 2)
        XCTAssertEqual(
            WatchSyncTrustBootstrapPolicy.validateBootstrapMetadata(fresh, expectedEpoch: 2),
            .valid
        )
    }

    func testForgedReplyCannotDequeue() {
        let sessionID = UUID()
        let issuedAt = Date()
        let forged: [String: Any] = [
            WatchSyncReplyHandlerPolicy.ackSignatureKey: "forged",
            WatchSyncReplyHandlerPolicy.sessionIDKey: sessionID.uuidString
        ]
        XCTAssertTrue(
            WatchSyncReplyHandlerPolicy.forgedReplyCannotDequeue(
                reply: forged,
                expectedSessionID: sessionID,
                expectedIssuedAt: issuedAt,
                verifySignature: { _, _, _ in false }
            )
        )
    }

    func testTransportHintReplyDoesNotDequeue() {
        let reply: [String: Any] = [WatchSyncReplyHandlerPolicy.statusKey: "acknowledged"]
        XCTAssertEqual(WatchSyncReplyHandlerPolicy.disposition(for: reply), .transportHintOnly)
        XCTAssertFalse(
            WatchSyncReplyHandlerPolicy.mayDequeuePendingTransfer(
                reply: reply,
                expectedSessionID: UUID(),
                expectedIssuedAt: Date(),
                verifySignature: { _, _, _ in true }
            )
        )
    }

    func testCSVImportBoundsRejectOversizedPreflight() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("oversized.csv")
        let payload = String(repeating: "a", count: DiveCSVImportBounds.maxBytes + 1)
        try payload.write(to: url, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: url) }
        XCTAssertEqual(DiveCSVImportBounds.preflightFileSize(at: url), .fileTooLarge)
    }

    func testProtectedSensitiveFileStoreRoundTrip() throws {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let url = base.appendingPathComponent("SecurityTest-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let payload = Data("protected-queue".utf8)
        try ProtectedSensitiveFileStore.saveData(payload, to: url)
        XCTAssertEqual(ProtectedSensitiveFileStore.loadData(from: url), payload)
    }

    func testLegacySecurityIdentifierMigrationRegistry() {
        XCTAssertEqual(
            LegacySecurityIdentifierMigration.LegacyKeychainServices.canonicalWatchSync,
            "com.egopfe.dirdiving.watch-sync"
        )
        XCTAssertEqual(
            LegacySecurityIdentifierMigration.LegacyUserDefaultsKeys.canonicalAscentRateLimits,
            "dirdiving_ascent_rate_limits"
        )
    }

    func testSimulatedSessionTagDetection() {
        XCTAssertTrue(
            DivingRecordEligibilityPolicy.isSimulatedSession(
                depthSensorSourceTag: DivingRecordEligibilityPolicy.simulatedSourceTag
            )
        )
        XCTAssertFalse(DivingRecordEligibilityPolicy.isSimulatedSession(depthSensorSourceTag: nil))
    }
}
