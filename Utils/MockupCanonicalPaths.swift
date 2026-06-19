import Foundation

/// Canonical mockup asset locations for audit matrices and validation scripts (Command 15).
enum MockupCanonicalPaths {
    static let root = "mockups"
    static let iosCompanionSelection = "mockups/IOS_COMPANION_ACTIVITY_SELECTION_POST_ONBOARDING.png"
    static let iosApneaDirectory = "mockups/iOS"
    static let watchApneaSnorkelingDirectory = "mockups/Apple_Watch"
    static let fullComputerDirectory = "mockups"
    static let legacyArchiveDirectory = "Docs/ReferenceUI/archive"

    static func snorkelingPNG(fileName: String) -> String {
        if fileName.contains("WATCH") {
            return "\(watchApneaSnorkelingDirectory)/\(fileName)"
        }
        return "\(iosApneaDirectory)/\(fileName)"
    }

    static func apneaPNG(fileName: String, platform: ApneaMockupPlatform) -> String {
        switch platform {
        case .watch: return "\(watchApneaSnorkelingDirectory)/\(fileName)"
        case .ios: return "\(iosApneaDirectory)/\(fileName)"
        }
    }

    static func fullComputerPNG(fileName: String) -> String {
        "\(fullComputerDirectory)/\(fileName)"
    }

    static func fileExists(at repositoryRoot: URL, relativePath: String) -> Bool {
        FileManager.default.fileExists(atPath: repositoryRoot.appendingPathComponent(relativePath).path)
    }
}
