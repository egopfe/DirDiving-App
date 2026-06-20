import XCTest

final class ApneaSyncCodecTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: ApneaSessionSyncCodec.importedSessionIDsKey)
    }

    func testSealValidateAndChecksumRoundTrip() throws {
        let plan = ApneaSessionPlan(
            kind: .pyramid,
            title: "Morning",
            entries: [
                ApneaPlannedDiveEntry(orderIndex: 0, targetDepthMeters: 10, targetDurationSeconds: 60, plannedRecoverySeconds: 60),
                ApneaPlannedDiveEntry(orderIndex: 1, targetDepthMeters: 15, targetDurationSeconds: 75, plannedRecoverySeconds: 75),
                ApneaPlannedDiveEntry(orderIndex: 2, targetDepthMeters: 20, targetDurationSeconds: 90, plannedRecoverySeconds: 90),
            ]
        )
        let profile = ApneaCompanionProfile(displayName: "Test", discipline: .depthTraining, targetDepthMeters: 20)
        let package = try ApneaSyncPackageBuilder.build(
            plan: plan,
            profile: profile,
            settings: .default,
            packageID: UUID(),
            revision: 1
        )
        XCTAssertNoThrow(try ApneaSyncCodec.validate(package))
        let data = try ApneaSyncCodec.encode(package)
        let decoded = try ApneaSyncCodec.decode(data)
        XCTAssertEqual(decoded.payloadChecksumSHA256, package.payloadChecksumSHA256)
    }

    func testChecksumMismatchRejected() throws {
        var package = try ApneaSyncPackageBuilder.build(
            plan: ApneaSessionPlan(kind: .custom, title: "A", entries: [
                ApneaPlannedDiveEntry(orderIndex: 0, targetDepthMeters: 10, targetDurationSeconds: 60, plannedRecoverySeconds: 60)
            ]),
            profile: nil,
            settings: .default,
            packageID: UUID(),
            revision: 2
        )
        package.payloadChecksumSHA256 = "deadbeef"
        XCTAssertThrowsError(try ApneaSyncCodec.validate(package)) { error in
            XCTAssertEqual(error as? ApneaSyncValidationError, .checksumMismatch)
        }
    }

    func testTransferSupportAckRoundTrip() throws {
        WatchSyncTestSupport.installDeterministicSecrets()
        defer { WatchSyncTestSupport.resetSecrets() }
        WatchSyncTestSupport.requirePeerSecret()
        let package = try ApneaSyncPackageBuilder.build(
            plan: ApneaSessionPlan(kind: .custom, title: "Sync", entries: [
                ApneaPlannedDiveEntry(orderIndex: 0, targetDepthMeters: 12, targetDurationSeconds: 45, plannedRecoverySeconds: 45)
            ]),
            profile: nil,
            settings: .default,
            packageID: UUID(),
            revision: 3
        )
        let data = try ApneaSyncCodec.encode(package)
        let userInfo = ApneaSyncTransferSupport.makeTransferUserInfo(packageData: data, package: package)
        let decoded = try ApneaSyncTransferSupport.decodePackage(from: userInfo)
        XCTAssertEqual(decoded.body.revision, 3)

        let issuedAt = Date()
        let signature = ApneaSyncAckSigner.makeSignature(
            packageID: package.body.packageID,
            revision: package.body.revision,
            checksum: package.payloadChecksumSHA256,
            issuedAt: issuedAt
        )
        let ackPayload = ApneaSyncTransferSupport.makeAckPayload(
            packageID: package.body.packageID,
            revision: package.body.revision,
            checksum: package.payloadChecksumSHA256,
            status: ApneaSyncTransferSupport.ackStatusImported,
            issuedAt: issuedAt,
            signature: signature
        )
        let parsed = ApneaSyncTransferSupport.parseAck(ackPayload)
        XCTAssertEqual(parsed?.status, ApneaSyncTransferSupport.ackStatusImported)
        XCTAssertTrue(
            ApneaSyncAckSigner.verify(
                parsed?.signature,
                packageID: package.body.packageID,
                revision: package.body.revision,
                checksum: package.payloadChecksumSHA256,
                issuedAt: issuedAt
            )
        )
    }

    func testSessionImportPolicyMergesByCompleteness() {
        let id = UUID()
        let local = ApneaSession(
            id: id,
            startMode: .watch,
            state: .completed,
            dives: [ApneaDive(startedAtMonotonicSeconds: 0, durationSeconds: 60, maxDepthMeters: 10, averageDepthMeters: 8)]
        )
        var remote = local
        remote.dives = local.dives + [
            ApneaDive(startedAtMonotonicSeconds: 120, durationSeconds: 75, maxDepthMeters: 15, averageDepthMeters: 12)
        ]
        let outcome = ApneaSessionSyncImportPolicy.importSession(remote, existingSessions: [local], importedIDs: [])
        guard case .merged = outcome.result, let merged = outcome.session else {
            return XCTFail("Expected merged session")
        }
        XCTAssertEqual(merged.dives.count, 2)
    }

    @MainActor
    func testIOSLogbookAtomicImport() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        IOSApneaLogbookStore.testHook_storageDirectoryURL = directory
        defer {
            IOSApneaLogbookStore.testHook_storageDirectoryURL = nil
            try? FileManager.default.removeItem(at: directory)
        }

        let store = IOSApneaLogbookStore()
        store.resetImportedIDsForTesting()
        var session = ApneaSession(
            startMode: .watch,
            state: .completed,
            dives: [ApneaDive(startedAtMonotonicSeconds: 0, durationSeconds: 90, maxDepthMeters: 18, averageDepthMeters: 12)]
        )
        session.statistics = session.refreshedStatistics()
        let result = store.mergeImportedSession(session)
        guard result == .imported else {
            return XCTFail("Expected imported, got \(result) error=\(store.loadErrorMessage ?? "nil")")
        }
        XCTAssertEqual(store.sessions.count, 1)

        let duplicate = store.mergeImportedSession(session)
        XCTAssertEqual(duplicate, .merged)
    }
}
