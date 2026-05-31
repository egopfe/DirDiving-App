import SwiftUI

extension Notification.Name {
    static let companionPhotoDidArrive = Notification.Name("dirdiving_companion_photo_did_arrive")
}

@MainActor
final class UserImageStore: ObservableObject {
    @Published private(set) var imageNames: [String] = []

    enum ImportError: LocalizedError, Equatable {
        case invalidFileName
        case invalidFileSize

        var errorDescription: String? {
            switch self {
            case .invalidFileName:
                return String(localized: "Nome file immagine non valido")
            case .invalidFileSize:
                return String(localized: "Dimensione immagine non valida")
            }
        }
    }

    static let maxCompanionPhotoBytes = 10 * 1_024 * 1_024
    private static let allowedCompanionPhotoExtensions: Set<String> = ["png", "jpg", "jpeg", "heic"]

    private var documentsImagesDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("UserImages", isDirectory: true)
    }

    init() {
        reload()
        NotificationCenter.default.addObserver(forName: .companionPhotoDidArrive, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.reload() }
        }
    }

    func reload() {
        try? FileManager.default.createDirectory(at: documentsImagesDirectory, withIntermediateDirectories: true)
        let extensions = ["png", "jpg", "jpeg", "heic"]
        var names: Set<String> = []
        for ext in extensions {
            let bundleURLs = Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: "UserImages") ?? []
            names.formUnion(bundleURLs.map(\.lastPathComponent))
            let documentURLs = (try? FileManager.default.contentsOfDirectory(at: documentsImagesDirectory, includingPropertiesForKeys: nil)) ?? []
            names.formUnion(documentURLs.filter { $0.pathExtension.lowercased() == ext }.map(\.lastPathComponent))
        }
        imageNames = names.sorted()
    }

    func imageResourceName(for fileName: String) -> String? {
        guard let sanitized = Self.sanitizedCompanionPhotoFileName(fileName) else { return nil }
        if Bundle.main.url(forResource: sanitized, withExtension: nil, subdirectory: "UserImages") != nil {
            return "UserImages/\(sanitized)"
        }
        let documentURL = documentsImagesDirectory.appendingPathComponent(sanitized)
        return FileManager.default.fileExists(atPath: documentURL.path) ? documentURL.path : nil
    }

    static func importCompanionPhoto(from sourceURL: URL, fileName: String) throws {
        guard let sanitized = sanitizedCompanionPhotoFileName(fileName) else {
            throw ImportError.invalidFileName
        }
        let resourceSize = try sourceURL.resourceValues(forKeys: [.fileSizeKey]).fileSize
        if let resourceSize, !isAllowedCompanionPhotoByteCount(resourceSize) {
            throw ImportError.invalidFileSize
        }
        let data = try Data(contentsOf: sourceURL)
        guard isAllowedCompanionPhotoByteCount(data.count) else {
            throw ImportError.invalidFileSize
        }
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("UserImages", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let destination = directory.appendingPathComponent(sanitized)
        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }
        try data.write(to: destination, options: [.atomic, .completeFileProtection])
        NotificationCenter.default.post(name: .companionPhotoDidArrive, object: nil)
    }

    static func sanitizedCompanionPhotoFileName(_ fileName: String) -> String? {
        let lastPathComponent = URL(fileURLWithPath: fileName).lastPathComponent
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
}
