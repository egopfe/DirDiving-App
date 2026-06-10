import SwiftUI
import ImageIO

extension Notification.Name {
    static let companionPhotoDidArrive = Notification.Name("dirdiving_companion_photo_did_arrive")
    static let companionPhotoDidDelete = Notification.Name("dirdiving_companion_photo_did_delete")
}

enum UserImageStoreNotificationKeys {
    static let fileName = "fileName"
}

@MainActor
final class UserImageStore: ObservableObject {
    @Published private(set) var imageNames: [String] = []
    @Published private(set) var uploadedInventory: [WatchUserImageInventoryItem] = []

    enum ImportError: LocalizedError, Equatable {
        case invalidFileName
        case invalidFileSize
        case invalidImageContent

        var errorDescription: String? {
            switch self {
            case .invalidFileName:
                return String(localized: "image.error.invalid_filename")
            case .invalidFileSize:
                return String(localized: "image.error.invalid_size")
            case .invalidImageContent:
                return String(localized: "user_images.error.not_image")
            }
        }
    }

    enum DeleteError: LocalizedError, Equatable {
        case notDeletable
        case invalidFileName
        case notFound
        case outsideUserImagesDirectory
        case deleteFailed

        var errorDescription: String? {
            switch self {
            case .notDeletable:
                return String(localized: "user_images.delete.error")
            case .invalidFileName:
                return String(localized: "image.error.invalid_filename")
            case .notFound:
                return String(localized: "user_images.delete.error")
            case .outsideUserImagesDirectory:
                return String(localized: "user_images.delete.error")
            case .deleteFailed:
                return String(localized: "user_images.delete.error")
            }
        }
    }

    private struct MetadataEntry: Codable, Equatable {
        let storedFileName: String
        let displayName: String
        let importedAt: Date
        let byteCount: Int?
        let pixelWidth: Int?
        let pixelHeight: Int?
    }

    static let maxCompanionPhotoBytes = 10 * 1_024 * 1_024
    private static let allowedCompanionPhotoExtensions: Set<String> = ["png", "jpg", "jpeg", "heic"]
    private static let metadataFileName = "metadata.json"

    private var documentsImagesDirectory: URL {
        Self.userImagesDocumentsDirectory()
    }

    init() {
        reload()
        NotificationCenter.default.addObserver(forName: .companionPhotoDidArrive, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.reload() }
        }
        NotificationCenter.default.addObserver(forName: .companionPhotoDidDelete, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.reload() }
        }
    }

    static func userImagesDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("UserImages", isDirectory: true)
    }

    func reload() {
        try? FileManager.default.createDirectory(at: documentsImagesDirectory, withIntermediateDirectories: true)
        migrateLegacyHEICFilesIfNeeded()
        let extensions = ["png", "jpg", "jpeg", "heic"]
        var names: Set<String> = []
        for ext in extensions {
            let bundleURLs = Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: "UserImages") ?? []
            names.formUnion(bundleURLs.map(\.lastPathComponent))
            let documentURLs = (try? FileManager.default.contentsOfDirectory(at: documentsImagesDirectory, includingPropertiesForKeys: nil)) ?? []
            names.formUnion(
                documentURLs
                    .filter {
                        $0.pathExtension.lowercased() == ext && $0.lastPathComponent != Self.metadataFileName
                    }
                    .map(\.lastPathComponent)
            )
        }
        imageNames = names.sorted()
        uploadedInventory = buildUploadedInventory()
    }

    func canDeleteImage(named fileName: String) -> Bool {
        Self.isUploadedDocumentImage(named: fileName)
    }

    func deleteImage(named fileName: String) throws {
        try Self.deleteUploadedImage(named: fileName)
        reload()
    }

    @discardableResult
    static func deleteUploadedImage(named fileName: String) throws -> String {
        guard let sanitized = sanitizedCompanionPhotoFileName(fileName) else {
            throw DeleteError.invalidFileName
        }
        guard isUploadedDocumentImage(named: sanitized) else {
            if isBundledCompanionPhoto(named: sanitized) {
                throw DeleteError.notDeletable
            }
            throw DeleteError.notFound
        }
        let url = try secureUploadedDocumentURL(for: sanitized)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw DeleteError.notFound
        }
        do {
            try FileManager.default.removeItem(at: url)
            removeMetadataEntry(for: sanitized)
            NotificationCenter.default.post(
                name: .companionPhotoDidDelete,
                object: nil,
                userInfo: [UserImageStoreNotificationKeys.fileName: sanitized]
            )
            return sanitized
        } catch {
            throw DeleteError.deleteFailed
        }
    }

    func deleteAllUploadedImages() throws {
        let uploadedNames = uploadedInventory.map(\.storedFileName)
        for name in uploadedNames {
            try deleteImage(named: name)
        }
    }

    func buildUploadedInventory() -> [WatchUserImageInventoryItem] {
        Self.buildUploadedInventory()
    }

    private func migrateLegacyHEICFilesIfNeeded() {
        let documentURLs = (try? FileManager.default.contentsOfDirectory(at: documentsImagesDirectory, includingPropertiesForKeys: nil)) ?? []
        for url in documentURLs where url.pathExtension.lowercased() == "heic" {
            WatchCompanionPhotoValidator.migrateLegacyHEICFileIfNeeded(at: url)
        }
    }

    func imageResourceName(for fileName: String) -> String? {
        guard let sanitized = Self.sanitizedCompanionPhotoFileName(fileName) else { return nil }
        if Bundle.main.url(forResource: sanitized, withExtension: nil, subdirectory: "UserImages") != nil {
            return "UserImages/\(sanitized)"
        }
        let documentURL = documentsImagesDirectory.appendingPathComponent(sanitized)
        return FileManager.default.fileExists(atPath: documentURL.path) ? documentURL.path : nil
    }

    @discardableResult
    static func importCompanionPhoto(from sourceURL: URL, fileName: String) throws -> String {
        guard let sanitized = sanitizedCompanionPhotoFileName(fileName) else {
            throw ImportError.invalidFileName
        }
        let resourceSize = try sourceURL.resourceValues(forKeys: [.fileSizeKey]).fileSize
        if let resourceSize, !isAllowedCompanionPhotoByteCount(resourceSize) {
            throw ImportError.invalidFileSize
        }
        let rawData = try Data(contentsOf: sourceURL)
        let normalized: (data: Data, fileName: String)
        do {
            normalized = try WatchCompanionPhotoValidator.validateAndNormalize(data: rawData, suggestedFileName: sanitized)
        } catch let validationError as WatchCompanionPhotoValidationError {
            throw validationError
        } catch {
            throw ImportError.invalidImageContent
        }
        let directory = userImagesDocumentsDirectory()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let destination = CompanionPhotoImportSupport.uniqueDestinationURL(
            in: directory,
            preferredFileName: normalized.fileName
        )
        try normalized.data.write(to: destination, options: [.atomic, .completeFileProtection])
        let storedFileName = destination.lastPathComponent
        let dimensions = imageDimensions(at: destination)
        let byteCount = try destination.resourceValues(forKeys: [.fileSizeKey]).fileSize
        saveMetadataEntry(
            MetadataEntry(
                storedFileName: storedFileName,
                displayName: displayName(for: storedFileName),
                importedAt: Date(),
                byteCount: byteCount,
                pixelWidth: dimensions?.width,
                pixelHeight: dimensions?.height
            )
        )
        NotificationCenter.default.post(
            name: .companionPhotoDidArrive,
            object: nil,
            userInfo: [UserImageStoreNotificationKeys.fileName: storedFileName]
        )
        return storedFileName
    }

    static func sanitizedCompanionPhotoFileName(_ fileName: String) -> String? {
        let lastPathComponent = URL(fileURLWithPath: fileName).lastPathComponent
        guard !lastPathComponent.isEmpty, lastPathComponent != metadataFileName else { return nil }
        guard !lastPathComponent.contains("/"), !lastPathComponent.contains("..") else { return nil }
        let url = URL(fileURLWithPath: lastPathComponent)
        let pathExtension = url.pathExtension.lowercased()
        guard allowedCompanionPhotoExtensions.contains(pathExtension) else { return nil }

        let rawBaseName = url.deletingPathExtension().lastPathComponent
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_ "))
        let cleanedScalars = rawBaseName.unicodeScalars.map { scalar in
            allowedCharacters.contains(scalar) ? Character(scalar) : "_"
        }
        let cleanedBaseName = String(cleanedScalars)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .prefix(80)
        guard !cleanedBaseName.isEmpty else { return nil }
        return "\(cleanedBaseName).\(pathExtension)"
    }

    static func isAllowedCompanionPhotoByteCount(_ byteCount: Int) -> Bool {
        byteCount > 0 && byteCount <= maxCompanionPhotoBytes
    }

    static func isBundledCompanionPhoto(named fileName: String) -> Bool {
        guard let sanitized = sanitizedCompanionPhotoFileName(fileName) else { return false }
        return Bundle.main.url(forResource: sanitized, withExtension: nil, subdirectory: "UserImages") != nil
    }

    static func isUploadedDocumentImage(named fileName: String) -> Bool {
        guard let sanitized = sanitizedCompanionPhotoFileName(fileName) else { return false }
        let url = userImagesDocumentsDirectory().appendingPathComponent(sanitized)
        return FileManager.default.fileExists(atPath: url.path)
    }

    static func secureUploadedDocumentURL(for sanitizedFileName: String) throws -> URL {
        guard sanitizedCompanionPhotoFileName(sanitizedFileName) == sanitizedFileName else {
            throw DeleteError.invalidFileName
        }
        let directory = userImagesDocumentsDirectory().standardizedFileURL
        let destination = directory.appendingPathComponent(sanitizedFileName).standardizedFileURL
        let directoryPath = directory.path
        let destinationPath = destination.path
        guard destinationPath.hasPrefix(directoryPath + "/") else {
            throw DeleteError.outsideUserImagesDirectory
        }
        return destination
    }

    static func buildUploadedInventory() -> [WatchUserImageInventoryItem] {
        let directory = userImagesDocumentsDirectory()
        let metadataByName = loadMetadataEntries().reduce(into: [String: MetadataEntry]()) { partial, entry in
            partial[entry.storedFileName] = entry
        }
        let urls = (try? FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey, .creationDateKey],
            options: [.skipsHiddenFiles]
        )) ?? []
        return urls
            .filter { url in
                let ext = url.pathExtension.lowercased()
                return allowedCompanionPhotoExtensions.contains(ext) && url.lastPathComponent != metadataFileName
            }
            .compactMap { url -> WatchUserImageInventoryItem? in
                let storedFileName = url.lastPathComponent
                guard sanitizedCompanionPhotoFileName(storedFileName) != nil else { return nil }
                let metadata = metadataByName[storedFileName]
                let values = try? url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey, .creationDateKey])
                let dimensions = imageDimensions(at: url)
                return WatchUserImageInventoryItem(
                    storedFileName: storedFileName,
                    displayName: metadata?.displayName ?? displayName(for: storedFileName),
                    importedAt: metadata?.importedAt ?? values?.creationDate ?? values?.contentModificationDate,
                    byteCount: metadata?.byteCount ?? values?.fileSize,
                    pixelWidth: metadata?.pixelWidth ?? dimensions?.width,
                    pixelHeight: metadata?.pixelHeight ?? dimensions?.height,
                    isUploaded: true,
                    isDeletable: true
                )
            }
            .sorted { lhs, rhs in
                (lhs.importedAt ?? .distantPast) > (rhs.importedAt ?? .distantPast)
            }
    }

    private static func metadataFileURL() -> URL {
        userImagesDocumentsDirectory().appendingPathComponent(metadataFileName)
    }

    private static func loadMetadataEntries() -> [MetadataEntry] {
        let url = metadataFileURL()
        guard let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([MetadataEntry].self, from: data)) ?? []
    }

    private static func saveMetadataEntry(_ entry: MetadataEntry) {
        var entries = loadMetadataEntries().filter { $0.storedFileName != entry.storedFileName }
        entries.append(entry)
        persistMetadataEntries(entries)
    }

    private static func removeMetadataEntry(for storedFileName: String) {
        let entries = loadMetadataEntries().filter { $0.storedFileName != storedFileName }
        persistMetadataEntries(entries)
    }

    private static func persistMetadataEntries(_ entries: [MetadataEntry]) {
        let url = metadataFileURL()
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: url, options: [.atomic, .completeFileProtection])
    }

    private static func displayName(for storedFileName: String) -> String {
        let stem = storedFileName
            .split(separator: ".")
            .dropLast()
            .joined(separator: ".")
        guard !stem.isEmpty else { return storedFileName }
        return stem
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
    }

    private static func imageDimensions(at url: URL) -> (width: Int, height: Int)? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = properties[kCGImagePropertyPixelWidth] as? Int,
              let height = properties[kCGImagePropertyPixelHeight] as? Int else {
            return nil
        }
        return (width, height)
    }
}
