import Foundation

struct PendingPhotoManagementResponse: Codable, Equatable, Identifiable {
    enum Kind: String, Codable {
        case deleteAck
        case inventoryPublish
    }

    let id: String
    let kind: Kind
    let requestID: String
    let storedFileName: String?
    let status: String
    let errorCode: String?
    let payloadJSON: Data
    let createdAt: Date
    var retryCount: Int
    var lastAttemptAt: Date?

    static func deleteAck(
        requestID: String,
        storedFileName: String,
        status: String,
        errorCode: String?,
        payload: [String: Any]
    ) -> PendingPhotoManagementResponse? {
        guard let payloadJSON = serialize(payload) else { return nil }
        return PendingPhotoManagementResponse(
            id: "delete-\(requestID)",
            kind: .deleteAck,
            requestID: requestID,
            storedFileName: storedFileName,
            status: status,
            errorCode: errorCode,
            payloadJSON: payloadJSON,
            createdAt: Date(),
            retryCount: 0,
            lastAttemptAt: nil
        )
    }

    static func inventoryPublish(requestID: String?, payload: [String: Any]) -> PendingPhotoManagementResponse? {
        guard let payloadJSON = serialize(payload) else { return nil }
        return PendingPhotoManagementResponse(
            id: "inventory-\(requestID ?? UUID().uuidString)",
            kind: .inventoryPublish,
            requestID: requestID ?? "",
            storedFileName: nil,
            status: CompanionPhotoManagementSupport.inventoryStatusOK,
            errorCode: nil,
            payloadJSON: payloadJSON,
            createdAt: Date(),
            retryCount: 0,
            lastAttemptAt: nil
        )
    }

    var wirePayload: [String: Any] {
        (try? JSONSerialization.jsonObject(with: payloadJSON) as? [String: Any]) ?? [:]
    }

    private static func serialize(_ payload: [String: Any]) -> Data? {
        try? JSONSerialization.data(withJSONObject: payload)
    }
}

enum PendingPhotoManagementResponseQueue {
    static let maxRetryCount = 12
    static let fileName = "dirdiving_watch_pending_photo_management_responses.json"

    static func fileURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    static func load() -> [PendingPhotoManagementResponse] {
        let url = fileURL()
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url) else {
            return []
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let decoded = try? decoder.decode([PendingPhotoManagementResponse].self, from: data) else {
            return []
        }
        return decoded
    }

    static func save(_ entries: [PendingPhotoManagementResponse]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(entries) else { return }
        try? data.write(to: fileURL(), options: [.atomic, .completeFileProtection])
    }

    static func enqueue(_ entry: PendingPhotoManagementResponse?, existing: [PendingPhotoManagementResponse]) -> [PendingPhotoManagementResponse] {
        guard let entry else { return existing }
        var updated = existing.filter { $0.id != entry.id }
        updated.append(entry)
        return updated.sorted { $0.createdAt < $1.createdAt }
    }

    static func dequeue(id: String, from entries: [PendingPhotoManagementResponse]) -> [PendingPhotoManagementResponse] {
        entries.filter { $0.id != id }
    }

    static func shouldRetry(_ entry: PendingPhotoManagementResponse) -> Bool {
        entry.retryCount < maxRetryCount
    }
}
