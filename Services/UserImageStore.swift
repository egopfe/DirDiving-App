import SwiftUI

extension Notification.Name {
    static let companionPhotoDidArrive = Notification.Name("dirdiving_companion_photo_did_arrive")
}

@MainActor
final class UserImageStore: ObservableObject {
    @Published private(set) var imageNames: [String] = []

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
        if Bundle.main.url(forResource: fileName, withExtension: nil, subdirectory: "UserImages") != nil {
            return "UserImages/\(fileName)"
        }
        let documentURL = documentsImagesDirectory.appendingPathComponent(fileName)
        return FileManager.default.fileExists(atPath: documentURL.path) ? documentURL.path : nil
    }

    static func importCompanionPhoto(from sourceURL: URL, fileName: String) throws {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("UserImages", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let destination = directory.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }
        try FileManager.default.copyItem(at: sourceURL, to: destination)
        NotificationCenter.default.post(name: .companionPhotoDidArrive, object: nil)
    }
}
