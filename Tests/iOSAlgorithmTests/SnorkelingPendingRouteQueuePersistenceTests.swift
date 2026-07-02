import XCTest

@MainActor
final class SnorkelingPendingRouteQueuePersistenceTests: XCTestCase {
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "SnorkelingPendingRouteQueuePersistenceTests")!
        SnorkelingRoutePendingSendQueuePersistence.clear(from: defaults)
    }

    override func tearDown() {
        SnorkelingRoutePendingSendQueuePersistence.clear(from: defaults)
        defaults.removePersistentDomain(forName: "SnorkelingPendingRouteQueuePersistenceTests")
        super.tearDown()
    }

    func testPendingRouteQueuePersistenceRoundTrip() {
        let entry = sampleEntry(revision: 2)
        SnorkelingRoutePendingSendQueuePersistence.save([entry], to: defaults)
        XCTAssertEqual(SnorkelingRoutePendingSendQueuePersistence.load(from: defaults), [entry])
    }

    func testCorruptPendingQueueIgnoredSafely() {
        defaults.set(Data([0x01, 0x02, 0x03]), forKey: SnorkelingRoutePendingSendQueuePersistence.userDefaultsKey)
        XCTAssertTrue(SnorkelingRoutePendingSendQueuePersistence.load(from: defaults).isEmpty)
    }

    func testNamespaceIsSnorkelingScoped() {
        XCTAssertTrue(SnorkelingRoutePendingSendQueuePersistence.userDefaultsKey.hasPrefix("dirdiving_snorkeling_"))
        XCTAssertFalse(SnorkelingRoutePendingSendQueuePersistence.userDefaultsKey.contains("apnea"))
    }

    func testPendingQueueRestoredAfterNewServiceInstance() {
        let entry = sampleEntry(revision: 5)
        SnorkelingRoutePendingSendQueuePersistence.save([entry], to: defaults)

        let service = IOSSnorkelingWatchTransferService(defaults: defaults)
        XCTAssertEqual(service.testing_pendingQueueCount(), 1)
        if case .queued = service.state {} else {
            XCTFail("Expected queued state after restore")
        }
    }

    func testPendingQueueClearedAfterAck() throws {
        SnorkelingSyncTestSupport.installDeterministicSecrets()
        defer { SnorkelingSyncTestSupport.resetSecrets() }

        let service = IOSSnorkelingWatchTransferService(defaults: defaults)
        service.testing_reset()

        var draft = SnorkelingRoutePlannerDraft(name: "Persist")
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "E", role: .entry, latitude: 44.4, longitude: 8.94)
        draft.exitPoint = SnorkelingRoutePlannerPoint(name: "X", role: .exit, latitude: 44.41, longitude: 8.95)
        _ = service.send(
            draft: draft,
            profile: nil,
            connectivity: SnorkelingWatchTransferConnectivityContext(
                isSupported: true,
                activationState: .activated,
                isPaired: true,
                isWatchAppInstalled: true,
                isReachable: true
            )
        )
        XCTAssertEqual(SnorkelingRoutePendingSendQueuePersistence.load(from: defaults).count, 1)

        guard let package = service.currentPackage else { return XCTFail("missing package") }
        let issuedAt = Date()
        let signature = SnorkelingRouteSyncAckSigner.makeSignature(
            packageID: package.body.packageID,
            revision: package.body.revision,
            checksum: package.payloadChecksumSHA256,
            issuedAt: issuedAt
        )
        service.testing_handleAck(
            SnorkelingRouteSyncTransferSupport.ParsedAck(
                packageID: package.body.packageID,
                revision: package.body.revision,
                checksum: package.payloadChecksumSHA256,
                status: SnorkelingRouteSyncTransferSupport.ackStatusImported,
                issuedAt: issuedAt,
                signature: signature,
                errorCode: nil
            )
        )
        XCTAssertTrue(SnorkelingRoutePendingSendQueuePersistence.load(from: defaults).isEmpty)
    }

    private func sampleEntry(revision: Int) -> SnorkelingRoutePendingSendEntry {
        SnorkelingRoutePendingSendEntry(
            packageID: UUID(uuidString: "AABBCCDD-EEFF-0011-2233-445566778899")!,
            revision: revision,
            checksum: "checksum-\(revision)",
            packageData: Data("package-\(revision)".utf8),
            enqueuedAt: Date(timeIntervalSince1970: 1_700_000_000)
        )
    }
}
