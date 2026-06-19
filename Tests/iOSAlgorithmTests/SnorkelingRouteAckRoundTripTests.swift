import XCTest

@MainActor
final class SnorkelingRouteAckRoundTripTests: XCTestCase {
    override func setUp() {
        super.setUp()
        SnorkelingSyncTestSupport.installDeterministicSecrets()
    }

    override func tearDown() {
        SnorkelingSyncTestSupport.resetSecrets()
        super.tearDown()
    }

    func testValidRouteAckClearsPendingQueue() throws {
        SnorkelingSyncTestSupport.requirePeerSecret()
        let service = IOSSnorkelingWatchTransferService()
        service.testing_reset()

        var draft = SnorkelingRoutePlannerDraft(name: "ACK")
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "E", role: .entry, latitude: 44.4, longitude: 8.94)
        draft.exitPoint = SnorkelingRoutePlannerPoint(name: "X", role: .exit, latitude: 44.41, longitude: 8.95)
        let sent = service.send(
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
        XCTAssertTrue(sent)
        XCTAssertEqual(service.testing_pendingQueueCount(), 1)

        guard let package = service.currentPackage else { return XCTFail("missing package") }
        let issuedAt = Date()
        let signature = SnorkelingRouteSyncAckSigner.makeSignature(
            packageID: package.body.packageID,
            revision: package.body.revision,
            checksum: package.payloadChecksumSHA256,
            issuedAt: issuedAt
        )
        let ack = SnorkelingRouteSyncTransferSupport.ParsedAck(
            packageID: package.body.packageID,
            revision: package.body.revision,
            checksum: package.payloadChecksumSHA256,
            status: SnorkelingRouteSyncTransferSupport.ackStatusImported,
            issuedAt: issuedAt,
            signature: signature,
            errorCode: nil
        )
        service.testing_handleAck(ack)
        XCTAssertEqual(service.testing_pendingQueueCount(), 0)
        if case .acknowledged = service.state { } else {
            XCTFail("expected acknowledged state")
        }
    }

    func testInvalidRouteAckLeavesQueuePending() throws {
        SnorkelingSyncTestSupport.requirePeerSecret()
        let service = IOSSnorkelingWatchTransferService()
        service.testing_reset()
        var draft = SnorkelingRoutePlannerDraft(name: "ACK")
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
        guard let package = service.currentPackage else { return XCTFail("missing package") }
        let ack = SnorkelingRouteSyncTransferSupport.ParsedAck(
            packageID: package.body.packageID,
            revision: package.body.revision,
            checksum: package.payloadChecksumSHA256,
            status: SnorkelingRouteSyncTransferSupport.ackStatusImported,
            issuedAt: Date(),
            signature: "invalid",
            errorCode: nil
        )
        service.testing_handleAck(ack)
        XCTAssertEqual(service.testing_pendingQueueCount(), 1)
        if case .failed = service.state { } else {
            XCTFail("expected failed state")
        }
    }
}
