import Foundation

struct CompanionPhotoTransferStatus: Equatable {
    enum State: String, Equatable {
        case queued
        case sending
        case deliveredToConnectivity
        case importedOnWatch
        case rejectedByWatch
        case failed
    }

    let photoID: String
    let fileName: String
    var state: State
    var errorMessage: String?
    var storedFileNameOnWatch: String?
    var rejectionErrorCode: String?
}

enum CompanionPhotoTransferSupport {
    static let ackStatusImported = "imported"
    static let ackStatusRejected = "rejected"

    static func makeFileName(photoID: UUID) -> String {
        "companion_\(photoID.uuidString).jpg"
    }

    static func makeTransferMetadata(photoID: String, fileName: String) -> [String: Any] {
        [
            WatchSyncKeys.companionPhotoIDKey: photoID,
            WatchSyncKeys.companionPhotoFileNameKey: fileName,
        ]
    }

    static func isCompanionPhotoAck(_ payload: [String: Any]) -> Bool {
        payload["type"] as? String == WatchSyncKeys.companionPhotoAckType
    }

    struct ParsedAck: Equatable {
        let photoID: String
        let status: String
        let storedFileName: String?
        let errorCode: String?
    }

    static func parseCompanionPhotoAck(_ payload: [String: Any]) -> ParsedAck? {
        guard isCompanionPhotoAck(payload),
              let photoID = payload[WatchSyncKeys.companionPhotoIDKey] as? String,
              !photoID.isEmpty,
              let status = payload[WatchSyncKeys.companionPhotoAckStatusKey] as? String else {
            return nil
        }
        return ParsedAck(
            photoID: photoID,
            status: status,
            storedFileName: payload[WatchSyncKeys.companionPhotoAckStoredFileNameKey] as? String,
            errorCode: payload[WatchSyncKeys.companionPhotoAckErrorCodeKey] as? String
        )
    }

    static func applyAck(
        _ ack: ParsedAck,
        to transfer: inout CompanionPhotoTransferStatus?
    ) {
        guard var current = transfer, current.photoID == ack.photoID else { return }
        switch ack.status {
        case ackStatusImported:
            current.state = .importedOnWatch
            current.storedFileNameOnWatch = ack.storedFileName
            current.errorMessage = nil
            current.rejectionErrorCode = nil
        case ackStatusRejected:
            current.state = .rejectedByWatch
            current.rejectionErrorCode = ack.errorCode
        default:
            return
        }
        transfer = current
    }

    static let expectedWatchSyncPhotoKeys: [String: String] = [
        "companionPhotoFileNameKey": WatchSyncKeys.companionPhotoFileNameKey,
        "companionPhotoIDKey": WatchSyncKeys.companionPhotoIDKey,
        "companionPhotoAckType": WatchSyncKeys.companionPhotoAckType,
        "companionPhotoAckStatusKey": WatchSyncKeys.companionPhotoAckStatusKey,
        "companionPhotoAckStoredFileNameKey": WatchSyncKeys.companionPhotoAckStoredFileNameKey,
        "companionPhotoAckErrorCodeKey": WatchSyncKeys.companionPhotoAckErrorCodeKey,
    ]
}
