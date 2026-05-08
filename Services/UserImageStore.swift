import SwiftUI

@MainActor
final class UserImageStore: ObservableObject {
    @Published private(set) var imageNames: [String] = []
    init() { reload() }

    func reload() {
        let extensions = ["png", "jpg", "jpeg", "heic"]
        var names: [String] = []
        for ext in extensions {
            let urls = Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: "UserImages") ?? []
            names.append(contentsOf: urls.map { $0.lastPathComponent })
        }
        imageNames = names.sorted()
    }

    func image(for fileName: String) -> UIImage? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil, subdirectory: "UserImages") else { return nil }
        return UIImage(contentsOfFile: url.path)
    }
}
