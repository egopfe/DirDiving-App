import Foundation

struct WatchUserImageInventoryItem: Codable, Equatable, Identifiable, Sendable {
    let id: String
    let storedFileName: String
    let displayName: String
    let importedAt: Date?
    let byteCount: Int?
    let pixelWidth: Int?
    let pixelHeight: Int?
    let isUploaded: Bool
    let isDeletable: Bool

    init(
        storedFileName: String,
        displayName: String,
        importedAt: Date? = nil,
        byteCount: Int? = nil,
        pixelWidth: Int? = nil,
        pixelHeight: Int? = nil,
        isUploaded: Bool = true,
        isDeletable: Bool = true
    ) {
        self.id = storedFileName
        self.storedFileName = storedFileName
        self.displayName = displayName
        self.importedAt = importedAt
        self.byteCount = byteCount
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
        self.isUploaded = isUploaded
        self.isDeletable = isDeletable
    }
}

enum CompanionPhotoManagementSupport {
    /// Companion photo inventory/delete messages use paired WatchConnectivity trust (not HMAC v2 dive payloads).
    /// Filename sanitization + bundled-image rejection provide defense-in-depth on Watch MAIN.
    static let inventoryStatusOK = "ok"
    static let inventoryStatusFailed = "failed"

    static let deleteStatusDeleted = "deleted"
    static let deleteStatusNotFound = "notFound"
    static let deleteStatusRejected = "rejected"
    static let deleteStatusFailed = "failed"

    static let inventoryItemStoredFileNameKey = "storedFileName"
    static let inventoryItemDisplayNameKey = "displayName"
    static let inventoryItemImportedAtKey = "importedAt"
    static let inventoryItemByteCountKey = "byteCount"
    static let inventoryItemPixelWidthKey = "pixelWidth"
    static let inventoryItemPixelHeightKey = "pixelHeight"
    static let inventoryItemIsUploadedKey = "isUploaded"
    static let inventoryItemIsDeletableKey = "isDeletable"

    static func isInventoryRequest(_ payload: [String: Any]) -> Bool {
        payload["type"] as? String == WatchSyncKeys.companionPhotoInventoryRequestType
    }

    static func isInventoryResponse(_ payload: [String: Any]) -> Bool {
        payload["type"] as? String == WatchSyncKeys.companionPhotoInventoryResponseType
    }

    static func isDeleteRequest(_ payload: [String: Any]) -> Bool {
        payload["type"] as? String == WatchSyncKeys.companionPhotoDeleteRequestType
    }

    static func isDeleteAck(_ payload: [String: Any]) -> Bool {
        payload["type"] as? String == WatchSyncKeys.companionPhotoDeleteAckType
    }

    static func makeInventoryRequestPayload(requestID: String) -> [String: Any] {
        [
            "type": WatchSyncKeys.companionPhotoInventoryRequestType,
            WatchSyncKeys.companionPhotoInventoryRequestIDKey: requestID,
        ]
    }

    static func makeInventoryResponsePayload(
        requestID: String?,
        items: [WatchUserImageInventoryItem],
        status: String = inventoryStatusOK,
        errorCode: String? = nil
    ) -> [String: Any] {
        var payload: [String: Any] = [
            "type": WatchSyncKeys.companionPhotoInventoryResponseType,
            WatchSyncKeys.companionPhotoInventoryItemsKey: items.map(itemDictionary),
            WatchSyncKeys.companionPhotoInventoryGeneratedAtKey: Date().timeIntervalSince1970,
            WatchSyncKeys.companionPhotoInventoryStatusKey: status,
        ]
        if let requestID {
            payload[WatchSyncKeys.companionPhotoInventoryRequestIDKey] = requestID
        }
        if let errorCode {
            payload[WatchSyncKeys.companionPhotoInventoryErrorCodeKey] = errorCode
        }
        return payload
    }

    static func makeDeleteRequestPayload(requestID: String, storedFileName: String) -> [String: Any] {
        [
            "type": WatchSyncKeys.companionPhotoDeleteRequestType,
            WatchSyncKeys.companionPhotoDeleteRequestIDKey: requestID,
            WatchSyncKeys.companionPhotoDeleteFileNameKey: storedFileName,
        ]
    }

    static func makeDeleteAckPayload(
        requestID: String,
        storedFileName: String,
        status: String,
        errorCode: String? = nil
    ) -> [String: Any] {
        var payload: [String: Any] = [
            "type": WatchSyncKeys.companionPhotoDeleteAckType,
            WatchSyncKeys.companionPhotoDeleteRequestIDKey: requestID,
            WatchSyncKeys.companionPhotoDeleteFileNameKey: storedFileName,
            WatchSyncKeys.companionPhotoDeleteStatusKey: status,
        ]
        if let errorCode {
            payload[WatchSyncKeys.companionPhotoDeleteErrorCodeKey] = errorCode
        }
        return payload
    }

    struct ParsedInventoryResponse: Equatable {
        let requestID: String?
        let items: [WatchUserImageInventoryItem]
        let generatedAt: Date?
        let status: String
        let errorCode: String?
    }

    struct ParsedDeleteAck: Equatable {
        let requestID: String
        let storedFileName: String
        let status: String
        let errorCode: String?
    }

    static func parseInventoryResponse(_ payload: [String: Any]) -> ParsedInventoryResponse? {
        guard isInventoryResponse(payload) else { return nil }
        let status = payload[WatchSyncKeys.companionPhotoInventoryStatusKey] as? String ?? inventoryStatusFailed
        let rawItems = payload[WatchSyncKeys.companionPhotoInventoryItemsKey] as? [[String: Any]] ?? []
        let generatedAt: Date?
        if let interval = payload[WatchSyncKeys.companionPhotoInventoryGeneratedAtKey] as? TimeInterval {
            generatedAt = Date(timeIntervalSince1970: interval)
        } else {
            generatedAt = nil
        }
        return ParsedInventoryResponse(
            requestID: payload[WatchSyncKeys.companionPhotoInventoryRequestIDKey] as? String,
            items: rawItems.compactMap(parseInventoryItem),
            generatedAt: generatedAt,
            status: status,
            errorCode: payload[WatchSyncKeys.companionPhotoInventoryErrorCodeKey] as? String
        )
    }

    static func parseDeleteAck(_ payload: [String: Any]) -> ParsedDeleteAck? {
        guard isDeleteAck(payload),
              let requestID = payload[WatchSyncKeys.companionPhotoDeleteRequestIDKey] as? String,
              !requestID.isEmpty,
              let storedFileName = payload[WatchSyncKeys.companionPhotoDeleteFileNameKey] as? String,
              !storedFileName.isEmpty,
              let status = payload[WatchSyncKeys.companionPhotoDeleteStatusKey] as? String else {
            return nil
        }
        return ParsedDeleteAck(
            requestID: requestID,
            storedFileName: storedFileName,
            status: status,
            errorCode: payload[WatchSyncKeys.companionPhotoDeleteErrorCodeKey] as? String
        )
    }

    static func deleteErrorCode(for error: Error) -> String {
        if let deleteError = error as? UserImageStore.DeleteError {
            switch deleteError {
            case .notDeletable, .outsideUserImagesDirectory:
                return "rejected"
            case .invalidFileName:
                return "invalidFileName"
            case .notFound:
                return "notFound"
            case .deleteFailed:
                return "deleteFailed"
            }
        }
        return "unknown"
    }

    static func deleteStatus(for error: UserImageStore.DeleteError) -> String {
        switch error {
        case .notFound:
            return deleteStatusNotFound
        case .notDeletable, .outsideUserImagesDirectory, .invalidFileName:
            return deleteStatusRejected
        case .deleteFailed:
            return deleteStatusFailed
        }
    }

    private static func itemDictionary(_ item: WatchUserImageInventoryItem) -> [String: Any] {
        var dict: [String: Any] = [
            inventoryItemStoredFileNameKey: item.storedFileName,
            inventoryItemDisplayNameKey: item.displayName,
            inventoryItemIsUploadedKey: item.isUploaded,
            inventoryItemIsDeletableKey: item.isDeletable,
        ]
        if let importedAt = item.importedAt {
            dict[inventoryItemImportedAtKey] = importedAt.timeIntervalSince1970
        }
        if let byteCount = item.byteCount {
            dict[inventoryItemByteCountKey] = byteCount
        }
        if let pixelWidth = item.pixelWidth {
            dict[inventoryItemPixelWidthKey] = pixelWidth
        }
        if let pixelHeight = item.pixelHeight {
            dict[inventoryItemPixelHeightKey] = pixelHeight
        }
        return dict
    }

    private static func parseInventoryItem(_ dict: [String: Any]) -> WatchUserImageInventoryItem? {
        guard let storedFileName = dict[inventoryItemStoredFileNameKey] as? String,
              !storedFileName.contains("/"),
              !storedFileName.contains(".."),
              let displayName = dict[inventoryItemDisplayNameKey] as? String else {
            return nil
        }
        let importedAt: Date?
        if let interval = dict[inventoryItemImportedAtKey] as? TimeInterval {
            importedAt = Date(timeIntervalSince1970: interval)
        } else {
            importedAt = nil
        }
        return WatchUserImageInventoryItem(
            storedFileName: storedFileName,
            displayName: displayName,
            importedAt: importedAt,
            byteCount: dict[inventoryItemByteCountKey] as? Int,
            pixelWidth: dict[inventoryItemPixelWidthKey] as? Int,
            pixelHeight: dict[inventoryItemPixelHeightKey] as? Int,
            isUploaded: dict[inventoryItemIsUploadedKey] as? Bool ?? true,
            isDeletable: dict[inventoryItemIsDeletableKey] as? Bool ?? true
        )
    }
}
