import Foundation

struct SnorkelingSessionPhotoAttachment: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var sessionID: UUID
    var markerID: UUID?
    var localFilename: String
    var stripLocationMetadata: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        sessionID: UUID,
        markerID: UUID? = nil,
        localFilename: String,
        stripLocationMetadata: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.sessionID = sessionID
        self.markerID = markerID
        self.localFilename = localFilename
        self.stripLocationMetadata = stripLocationMetadata
        self.createdAt = createdAt
    }
}

enum SnorkelingSessionPhotoSupport {
    static let directoryName = "dirdiving_snorkeling_session_photos"

    static func photoDirectoryURL(base: URL? = nil) -> URL {
        let root = base ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return root.appendingPathComponent(directoryName, isDirectory: true)
    }

    static func fileURL(for attachment: SnorkelingSessionPhotoAttachment, base: URL? = nil) -> URL {
        photoDirectoryURL(base: base).appendingPathComponent(attachment.localFilename)
    }

    static func makeFilename(for id: UUID) -> String {
        "\(id.uuidString.lowercased()).jpg"
    }

    static func ensureDirectoryExists(base: URL? = nil) throws {
        let url = photoDirectoryURL(base: base)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
}
