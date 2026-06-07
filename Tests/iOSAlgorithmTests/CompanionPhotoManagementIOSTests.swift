import XCTest

final class CompanionPhotoManagementIOSTests: XCTestCase {
    override func setUp() {
        super.setUp()
        CompanionPhotoManagementAuth.responseReplayCache.reset()
        WatchSyncAuth.resetPeerTrust()
    }

    func testInventoryResponseMapsToFullList() throws {
        try installPeerSecret()
        let item = WatchUserImageInventoryItem(
            storedFileName: "companion_a.jpg",
            displayName: "Companion A",
            importedAt: Date(timeIntervalSince1970: 1_700_000_000),
            byteCount: 12_345,
            pixelWidth: 400,
            pixelHeight: 300,
            isUploaded: true,
            isDeletable: true
        )
        let payload = CompanionPhotoManagementSupport.makeInventoryResponsePayload(
            requestID: "req-1",
            items: [item]
        )
        let parsed = try XCTUnwrap(CompanionPhotoManagementSupport.parseInventoryResponse(payload))
        XCTAssertEqual(parsed.status, CompanionPhotoManagementSupport.inventoryStatusOK)
        XCTAssertEqual(parsed.items.count, 1)
        XCTAssertEqual(parsed.items.first?.storedFileName, "companion_a.jpg")
        XCTAssertEqual(parsed.items.first?.byteCount, 12_345)
    }

    func testDeleteAckMapsToDeletedOnWatchState() throws {
        try installPeerSecret()
        let ack = CompanionPhotoManagementSupport.makeDeleteAckPayload(
            requestID: "req-delete",
            storedFileName: "companion_a.jpg",
            status: CompanionPhotoManagementSupport.deleteStatusDeleted
        )
        let parsed = try XCTUnwrap(CompanionPhotoManagementSupport.parseDeleteAck(ack))
        XCTAssertEqual(CompanionPhotoManagementSupport.deleteStatus(for: parsed.status), .deletedOnWatch)
    }

    private func installPeerSecret() throws {
        let secret = Data(repeating: 3, count: 32)
        let result = WatchSyncAuth.ingestSharedSecretFromContext([
            WatchSyncAuth.contextKey: secret.base64EncodedString()
        ])
        guard WatchSyncAuth.hasPeerSecret(), result == .acceptedFirstTrust else {
            throw XCTSkip("Peer secret unavailable in test keychain")
        }
    }

    func testDeleteAckMapsRejectedAndNotFoundStates() {
        XCTAssertEqual(
            CompanionPhotoManagementSupport.deleteStatus(for: CompanionPhotoManagementSupport.deleteStatusRejected),
            .rejectedByWatch
        )
        XCTAssertEqual(
            CompanionPhotoManagementSupport.deleteStatus(for: CompanionPhotoManagementSupport.deleteStatusNotFound),
            .notFound
        )
        XCTAssertEqual(
            CompanionPhotoManagementSupport.deleteStatus(for: CompanionPhotoManagementSupport.deleteStatusFailed),
            .failed
        )
    }

    func testSharedInventoryAndDeleteKeysMatchWatch() {
        XCTAssertEqual(WatchSyncKeys.companionPhotoInventoryRequestType, "companionPhotoInventoryRequest")
        XCTAssertEqual(WatchSyncKeys.companionPhotoInventoryResponseType, "companionPhotoInventoryResponse")
        XCTAssertEqual(WatchSyncKeys.companionPhotoDeleteRequestType, "companionPhotoDeleteRequest")
        XCTAssertEqual(WatchSyncKeys.companionPhotoDeleteAckType, "companionPhotoDeleteAck")
    }
}
