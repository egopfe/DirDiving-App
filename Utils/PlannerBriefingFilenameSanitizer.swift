import Foundation

/// Strict briefing-card filename validation — equivalent strength to companion photo sanitization.
enum PlannerBriefingFilenameSanitizer {
    static let allowedExtensions: Set<String> = ["png"]
    static let maxBaseNameLength = 80

    enum RejectionReason: Equatable {
        case empty
        case pathTraversal
        case absolutePath
        case urlScheme
        case controlCharacter
        case invalidExtension
        case overlongName
        case outsideStorageDirectory
    }

    static func sanitizedFileName(_ fileName: String) -> String? {
        guard let reason = rejectionReason(for: fileName) else {
            return normalizedFileName(fileName)
        }
        _ = reason
        return nil
    }

    static func rejectionReason(for fileName: String) -> RejectionReason? {
        let trimmed = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .empty }
        if trimmed.contains("..") { return .pathTraversal }
        if trimmed.contains("/") || trimmed.contains("\\") { return .pathTraversal }
        if trimmed.hasPrefix("/") || trimmed.hasPrefix("\\") { return .absolutePath }
        if trimmed.lowercased().hasPrefix("file:") { return .urlScheme }
        if trimmed.removingPercentEncoding?.contains("..") == true { return .pathTraversal }
        if trimmed.unicodeScalars.contains(where: { $0.value < 32 }) { return .controlCharacter }
        if trimmed.contains("\0") { return .controlCharacter }

        let lastPathComponent = URL(fileURLWithPath: trimmed).lastPathComponent
        let url = URL(fileURLWithPath: lastPathComponent)
        let ext = url.pathExtension.lowercased()
        guard allowedExtensions.contains(ext) else { return .invalidExtension }

        let base = url.deletingPathExtension().lastPathComponent
        let cleaned = cleanedBaseName(base)
        guard !cleaned.isEmpty else { return .empty }
        guard cleaned.count <= maxBaseNameLength else { return .overlongName }
        return nil
    }

    static func isConfinedToStorageDirectory(_ fileName: String, storageDirectory: URL) -> Bool {
        guard let sanitized = sanitizedFileName(fileName) else { return false }
        let directory = storageDirectory.standardizedFileURL
        let destination = directory.appendingPathComponent(sanitized).standardizedFileURL
        let directoryPath = directory.path
        let destinationPath = destination.path
        return destinationPath.hasPrefix(directoryPath + "/") || destinationPath == directoryPath
    }

    private static func normalizedFileName(_ fileName: String) -> String {
        let lastPathComponent = URL(fileURLWithPath: fileName.trimmingCharacters(in: .whitespacesAndNewlines)).lastPathComponent
        let url = URL(fileURLWithPath: lastPathComponent)
        let ext = url.pathExtension.lowercased()
        let cleaned = cleanedBaseName(url.deletingPathExtension().lastPathComponent)
        return "\(cleaned).\(ext)"
    }

    private static func cleanedBaseName(_ rawBaseName: String) -> String {
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_ "))
        let cleanedScalars = rawBaseName.unicodeScalars.map { scalar in
            allowedCharacters.contains(scalar) ? Character(scalar) : "_"
        }
        return String(cleanedScalars)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .prefix(maxBaseNameLength)
            .description
    }
}
