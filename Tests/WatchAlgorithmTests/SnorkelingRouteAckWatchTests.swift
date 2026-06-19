import XCTest

@MainActor
final class SnorkelingRouteAckWatchTests: XCTestCase {
    override func setUp() {
        super.setUp()
        SnorkelingSyncTestSupport.installDeterministicSecrets()
        SnorkelingImportedRouteStore.shared.resetForTesting()
    }

    override func tearDown() {
        SnorkelingImportedRouteStore.shared.resetForTesting()
        SnorkelingSyncTestSupport.resetSecrets()
        super.tearDown()
    }

    func testWatchRouteImportProducesSignedACK() throws {
        SnorkelingSyncTestSupport.requirePeerSecret()
        var draft = SnorkelingRoutePlannerDraft(name: "Watch ACK")
        draft.entryPoint = SnorkelingRoutePlannerPoint(name: "E", role: .entry, latitude: 44.4, longitude: 8.94)
        draft.exitPoint = SnorkelingRoutePlannerPoint(name: "X", role: .exit, latitude: 44.41, longitude: 8.95)
        let package = try SnorkelingRoutePackageBuilder.build(draft: draft, profile: nil, packageID: UUID(), revision: 1)
        let data = try SnorkelingRouteSyncCodec.encode(package)
        let userInfo = SnorkelingRouteSyncTransferSupport.makeTransferUserInfo(packageData: data, package: package)
        let ackPayload = SnorkelingRouteWatchReceiver.importPayload(userInfo, store: .shared, sessionInProgress: false)
        guard let ackPayload else { return XCTFail("missing ack payload") }
        guard let ack = SnorkelingRouteSyncTransferSupport.parseAck(ackPayload) else {
            return XCTFail("invalid ack payload")
        }
        XCTAssertTrue(
            SnorkelingRouteSyncAckSigner.verify(
                ack.signature,
                packageID: package.body.packageID,
                revision: package.body.revision,
                checksum: package.payloadChecksumSHA256,
                issuedAt: ack.issuedAt
            )
        )
    }
}
