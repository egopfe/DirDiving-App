import XCTest

final class CompanionPhotoManagementTests: XCTestCase {
    override func setUp() {
        super.setUp()
        WatchSyncTestSupport.installDeterministicSecrets()
    }

    override func tearDown() {
        WatchSyncTestSupport.resetSecrets()
        super.tearDown()
    }

    func testInventoryRequestAndResponseUseSharedKeys() throws {
        let requestID = UUID().uuidString
        let request = signedInventoryRequest(requestID: requestID)
        XCTAssertTrue(CompanionPhotoManagementSupport.verifySignedRequest(request))

        let item = WatchUserImageInventoryItem(
            storedFileName: "companion_test.jpg",
            displayName: "Companion Test"
        )
        let response = CompanionPhotoManagementSupport.makeInventoryResponsePayload(
            requestID: requestID,
            items: [item]
        )
        XCTAssertEqual(response["type"] as? String, WatchSyncKeys.companionPhotoInventoryResponseType)
        let parsed = try XCTUnwrap(CompanionPhotoManagementSupport.parseInventoryResponse(response))
        XCTAssertEqual(parsed.requestID, requestID)
        XCTAssertEqual(parsed.items.count, 1)
        XCTAssertEqual(parsed.items.first?.storedFileName, "companion_test.jpg")
    }

    func testUnsignedInventoryRequestRejected() {
        let payload = [
            "type": WatchSyncKeys.companionPhotoInventoryRequestType,
            WatchSyncKeys.companionPhotoInventoryRequestIDKey: UUID().uuidString,
        ]
        XCTAssertFalse(CompanionPhotoManagementSupport.verifySignedRequest(payload))
    }

    func testReplayedSignedInventoryRequestRejected() {
        let requestID = UUID().uuidString
        let payload = signedInventoryRequest(requestID: requestID)
        XCTAssertTrue(CompanionPhotoManagementSupport.verifySignedRequest(payload))
        XCTAssertFalse(CompanionPhotoManagementSupport.verifySignedRequest(payload))
    }

    func testDeleteRequestAndAckUseSharedKeys() throws {
        let requestID = UUID().uuidString
        let request = signedDeleteRequest(requestID: requestID, storedFileName: "companion_test.jpg")
        XCTAssertTrue(CompanionPhotoManagementSupport.verifySignedRequest(request))

        let ack = CompanionPhotoManagementSupport.makeDeleteAckPayload(
            requestID: requestID,
            storedFileName: "companion_test.jpg",
            status: CompanionPhotoManagementSupport.deleteStatusDeleted
        )
        XCTAssertEqual(ack["type"] as? String, WatchSyncKeys.companionPhotoDeleteAckType)
        let parsed = try XCTUnwrap(CompanionPhotoManagementSupport.parseDeleteAck(ack))
        XCTAssertEqual(parsed.requestID, requestID)
        XCTAssertEqual(parsed.status, "deleted")
    }

    func testInventoryRejectsUnsafePaths() {
        let response = CompanionPhotoManagementSupport.makeInventoryResponsePayload(
            requestID: "req",
            items: []
        )
        var payload = response
        payload[WatchSyncKeys.companionPhotoInventoryItemsKey] = [[
            CompanionPhotoManagementSupport.inventoryItemStoredFileNameKey: "../escape.jpg",
            CompanionPhotoManagementSupport.inventoryItemDisplayNameKey: "Bad",
        ]]
        let parsed = CompanionPhotoManagementSupport.parseInventoryResponse(payload)
        XCTAssertNotNil(parsed)
        XCTAssertTrue(parsed?.items.isEmpty == true)
    }

    private func signedInventoryRequest(requestID: String) -> [String: Any] {
        let issuedAt = Date()
        var payload: [String: Any] = [
            "type": WatchSyncKeys.companionPhotoInventoryRequestType,
            WatchSyncKeys.companionPhotoInventoryRequestIDKey: requestID,
            WatchSyncKeys.companionPhotoManagementIssuedAtKey: issuedAt.timeIntervalSince1970,
        ]
        payload[WatchSyncKeys.companionPhotoManagementSignatureKey] = CompanionPhotoManagementAuth.sign(
            type: WatchSyncKeys.companionPhotoInventoryRequestType,
            requestID: requestID,
            issuedAt: issuedAt,
            extra: "",
            peerBundleID: "com.egopfe.dirdiving.ios"
        ) ?? ""
        return payload
    }

    private func signedDeleteRequest(requestID: String, storedFileName: String) -> [String: Any] {
        let issuedAt = Date()
        var payload: [String: Any] = [
            "type": WatchSyncKeys.companionPhotoDeleteRequestType,
            WatchSyncKeys.companionPhotoDeleteRequestIDKey: requestID,
            WatchSyncKeys.companionPhotoDeleteFileNameKey: storedFileName,
            WatchSyncKeys.companionPhotoManagementIssuedAtKey: issuedAt.timeIntervalSince1970,
        ]
        payload[WatchSyncKeys.companionPhotoManagementSignatureKey] = CompanionPhotoManagementAuth.sign(
            type: WatchSyncKeys.companionPhotoDeleteRequestType,
            requestID: requestID,
            issuedAt: issuedAt,
            extra: storedFileName,
            peerBundleID: "com.egopfe.dirdiving.ios"
        ) ?? ""
        return payload
    }
}
