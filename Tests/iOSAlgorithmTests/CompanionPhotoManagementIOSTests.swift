import XCTest

final class CompanionPhotoManagementIOSTests: XCTestCase {
    func testInventoryResponseMapsToFullList() throws {
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

    func testDeleteAckMapsToDeletedOnWatchState() {
        let ack = CompanionPhotoManagementSupport.parseDeleteAck([
            "type": WatchSyncKeys.companionPhotoDeleteAckType,
            WatchSyncKeys.companionPhotoDeleteRequestIDKey: "req-delete",
            WatchSyncKeys.companionPhotoDeleteFileNameKey: "companion_a.jpg",
            WatchSyncKeys.companionPhotoDeleteStatusKey: CompanionPhotoManagementSupport.deleteStatusDeleted,
        ])
        XCTAssertEqual(CompanionPhotoManagementSupport.deleteStatus(for: ack?.status ?? ""), .deletedOnWatch)
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
