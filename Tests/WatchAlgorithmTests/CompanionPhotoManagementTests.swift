import XCTest

final class CompanionPhotoManagementTests: XCTestCase {
    func testInventoryRequestAndResponseUseSharedKeys() throws {
        let requestID = UUID().uuidString
        let request = CompanionPhotoManagementSupport.makeInventoryRequestPayload(requestID: requestID)
        XCTAssertEqual(request["type"] as? String, WatchSyncKeys.companionPhotoInventoryRequestType)
        XCTAssertEqual(request[WatchSyncKeys.companionPhotoInventoryRequestIDKey] as? String, requestID)

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

    func testDeleteRequestAndAckUseSharedKeys() throws {
        let requestID = UUID().uuidString
        let request = CompanionPhotoManagementSupport.makeDeleteRequestPayload(
            requestID: requestID,
            storedFileName: "companion_test.jpg"
        )
        XCTAssertEqual(request["type"] as? String, WatchSyncKeys.companionPhotoDeleteRequestType)

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
        XCTAssertEqual(parsed?.items.count, 0)
    }
}
