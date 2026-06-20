import XCTest

@MainActor
final class ApneaSyncAckNegativeTests: XCTestCase {
    private let peerSecret = Data(repeating: 3, count: 32).base64EncodedString()

    override func setUp() {
        super.setUp()
        ApneaSyncTestSupport.installDeterministicSecrets()
        ApneaSyncTestSupport.requirePeerSecret()
        IOSApneaWatchTransferService.testHook_bypassWatchConnectivityChecks = true
    }

    override func tearDown() {
        IOSApneaWatchTransferService.testHook_bypassWatchConnectivityChecks = false
        ApneaSyncTestSupport.resetSecrets()
        super.tearDown()
    }

    // MARK: - iOS → Watch plan ACK

    func testValidPlanAckClearsPendingQueue() throws {
        let service = IOSApneaWatchTransferService()
        service.testing_reset()

        let package = try ApneaSyncPackageBuilder.build(
            plan: ApneaSessionPlan(kind: .custom, title: "ACK", entries: [
                ApneaPlannedDiveEntry(orderIndex: 0, targetDepthMeters: 12, targetDurationSeconds: 45, plannedRecoverySeconds: 45)
            ]),
            profile: nil,
            settings: .default,
            packageID: UUID(),
            revision: 1
        )
        service.send(package: package)
        XCTAssertEqual(service.testing_pendingQueueCount(), 1)

        let issuedAt = Date()
        let signature = ApneaSyncAckSigner.makeSignature(
            packageID: package.body.packageID,
            revision: package.body.revision,
            checksum: package.payloadChecksumSHA256,
            issuedAt: issuedAt
        )
        let ack = ApneaSyncTransferSupport.ParsedAck(
            packageID: package.body.packageID,
            revision: package.body.revision,
            checksum: package.payloadChecksumSHA256,
            status: ApneaSyncTransferSupport.ackStatusImported,
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

    func testInvalidPlanAckLeavesQueuePending() throws {
        let service = IOSApneaWatchTransferService()
        service.testing_reset()
        let package = try ApneaSyncPackageBuilder.build(
            plan: ApneaSessionPlan(kind: .custom, title: "ACK", entries: [
                ApneaPlannedDiveEntry(orderIndex: 0, targetDepthMeters: 12, targetDurationSeconds: 45, plannedRecoverySeconds: 45)
            ]),
            profile: nil,
            settings: .default,
            packageID: UUID(),
            revision: 2
        )
        service.send(package: package)
        let issuedAt = Date()
        let ack = ApneaSyncTransferSupport.ParsedAck(
            packageID: package.body.packageID,
            revision: package.body.revision,
            checksum: package.payloadChecksumSHA256,
            status: ApneaSyncTransferSupport.ackStatusImported,
            issuedAt: issuedAt,
            signature: "invalid",
            errorCode: nil
        )
        service.testing_handleAck(ack)
        XCTAssertEqual(service.testing_pendingQueueCount(), 1)
    }

    func testApneaACKCannotClearFCQueue() {
        let payload: [String: Any] = [
            "transferType": ApneaSyncTransferSupport.transferTypeAck,
            DivePlanPackageTransferSupport.planIDKey: UUID().uuidString,
            DivePlanPackageTransferSupport.revisionKey: 1,
            DivePlanPackageTransferSupport.checksumKey: "abc",
            DivePlanPackageTransferSupport.ackStatusKey: ApneaSyncTransferSupport.ackStatusImported,
            DivePlanPackageTransferSupport.issuedAtKey: Date().timeIntervalSince1970,
        ]
        XCTAssertNil(DivePlanPackageTransferSupport.parseAck(payload))
    }

    // MARK: - Watch → iOS session ACK

    func testValidSessionImportAckVerifies() throws {
        let sessionID = UUID()
        let issuedAt = Date()
        let payload = ApneaSessionSyncCodec.makeImportAckPayload(sessionID: sessionID, issuedAt: issuedAt)
        let parsed = ApneaSessionSyncCodec.parseImportAck(from: payload)
        XCTAssertEqual(parsed?.sessionID, sessionID)
        XCTAssertTrue(
            ApneaSessionSyncCodec.ackSignature(sessionID: sessionID, issuedAt: issuedAt).count > 0
        )
    }

    func testInvalidSessionImportAckRejected() {
        let payload: [String: Any] = [
            "type": ApneaSessionSyncCodec.importAckType,
            ApneaSessionSyncCodec.importAckSessionIDKey: UUID().uuidString,
            ApneaSessionSyncCodec.importAckIssuedAtKey: Date().timeIntervalSince1970,
            ApneaSessionSyncCodec.importAckSignatureKey: "bad",
        ]
        XCTAssertNotNil(ApneaSessionSyncCodec.parseImportAck(from: payload))
    }

    func testStaleSessionImportAckRejected() {
        let payload: [String: Any] = [
            "type": ApneaSessionSyncCodec.importAckType,
            ApneaSessionSyncCodec.importAckSessionIDKey: UUID().uuidString,
            ApneaSessionSyncCodec.importAckIssuedAtKey: Date().addingTimeInterval(-10_000).timeIntervalSince1970,
            ApneaSessionSyncCodec.importAckSignatureKey: "sig",
        ]
        XCTAssertNil(ApneaSessionSyncCodec.parseImportAck(from: payload))
    }
}
