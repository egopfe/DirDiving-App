import Combine
import Foundation
import UIKit

@MainActor
final class IOSSnorkelingSessionPhotoStore: ObservableObject {
    static var testHook_storageDirectoryURL: URL?

    @Published private(set) var attachments: [SnorkelingSessionPhotoAttachment] = []

    private let storageKey = "dirdiving_ios_snorkeling_session_photos_v1"

    init() {
        load()
    }

    func attachments(for sessionID: UUID) -> [SnorkelingSessionPhotoAttachment] {
        attachments.filter { $0.sessionID == sessionID }.sorted { $0.createdAt > $1.createdAt }
    }

    func attachments(for sessionID: UUID, markerID: UUID) -> [SnorkelingSessionPhotoAttachment] {
        attachments.filter { $0.sessionID == sessionID && $0.markerID == markerID }
    }

    func thumbnailImage(for attachment: SnorkelingSessionPhotoAttachment) -> UIImage? {
        let url = SnorkelingSessionPhotoSupport.fileURL(for: attachment, base: storageBase())
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else {
            return nil
        }
        return image
    }

    @discardableResult
    func addPhoto(
        sessionID: UUID,
        markerID: UUID? = nil,
        imageData: Data,
        stripLocationMetadata: Bool = true
    ) throws -> SnorkelingSessionPhotoAttachment {
        let id = UUID()
        let filename = SnorkelingSessionPhotoSupport.makeFilename(for: id)
        try SnorkelingSessionPhotoSupport.ensureDirectoryExists(base: storageBase())
        let attachment = SnorkelingSessionPhotoAttachment(
            id: id,
            sessionID: sessionID,
            markerID: markerID,
            localFilename: filename,
            stripLocationMetadata: stripLocationMetadata
        )
        let url = SnorkelingSessionPhotoSupport.fileURL(for: attachment, base: storageBase())
        let payload: Data
        if stripLocationMetadata, let image = UIImage(data: imageData) {
            payload = image.jpegData(compressionQuality: 0.85) ?? imageData
        } else {
            payload = imageData
        }
        try payload.write(to: url, options: [.atomic, .completeFileProtection])
        attachments.insert(attachment, at: 0)
        persist()
        return attachment
    }

    func delete(id: UUID) {
        guard let attachment = attachments.first(where: { $0.id == id }) else { return }
        let url = SnorkelingSessionPhotoSupport.fileURL(for: attachment, base: storageBase())
        try? FileManager.default.removeItem(at: url)
        attachments.removeAll { $0.id == id }
        persist()
    }

    private func storageBase() -> URL {
        Self.testHook_storageDirectoryURL
            ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func load() {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([SnorkelingSessionPhotoAttachment].self, from: data) else {
            attachments = []
            return
        }
        attachments = decoded
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(attachments) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
