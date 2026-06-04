import UIKit

enum WatchCompanionPhotoValidationError: LocalizedError, Equatable {
    case invalidFileName
    case invalidFileSize
    case undecodableImage
    case dimensionsTooLarge
    case reencodeFailed

    var errorDescription: String? {
        switch self {
        case .invalidFileName:
            return String(localized: "Nome file immagine non valido")
        case .invalidFileSize:
            return String(localized: "Dimensione immagine non valida")
        case .undecodableImage:
            return String(localized: "user_images.error.not_image")
        case .dimensionsTooLarge:
            return String(localized: "user_images.error.dimensions")
        case .reencodeFailed:
            return String(localized: "user_images.error.encode_failed")
        }
    }
}

/// Decode, bound, and normalize companion photos before storage (SEC-P2-002).
enum WatchCompanionPhotoValidator {
    static let maxBytes = 10 * 1_024 * 1_024
    static let maxPixelDimension: CGFloat = 4_096
    private static let allowedExtensions: Set<String> = ["png", "jpg", "jpeg", "heic"]

    static func validateAndNormalize(data: Data, suggestedFileName: String) throws -> (data: Data, fileName: String) {
        guard isAllowedByteCount(data.count) else {
            throw WatchCompanionPhotoValidationError.invalidFileSize
        }
        guard let image = UIImage(data: data) else {
            throw WatchCompanionPhotoValidationError.undecodableImage
        }
        let pixelWidth = image.size.width * image.scale
        let pixelHeight = image.size.height * image.scale
        guard pixelWidth > 0, pixelHeight > 0 else {
            throw WatchCompanionPhotoValidationError.undecodableImage
        }
        guard max(pixelWidth, pixelHeight) <= maxPixelDimension else {
            throw WatchCompanionPhotoValidationError.dimensionsTooLarge
        }
        guard let jpeg = image.jpegData(compressionQuality: 0.85) else {
            throw WatchCompanionPhotoValidationError.reencodeFailed
        }
        guard isAllowedByteCount(jpeg.count) else {
            throw WatchCompanionPhotoValidationError.invalidFileSize
        }
        let baseName = suggestedFileName
            .replacingOccurrences(of: ".jpeg", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: ".jpg", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: ".png", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: ".heic", with: "", options: .caseInsensitive)
        guard let fileName = sanitizedFileName("\(baseName).jpg") else {
            throw WatchCompanionPhotoValidationError.invalidFileName
        }
        return (jpeg, fileName)
    }

    private static func isAllowedByteCount(_ byteCount: Int) -> Bool {
        byteCount > 0 && byteCount <= maxBytes
    }

    private static func sanitizedFileName(_ fileName: String) -> String? {
        let lastPathComponent = URL(fileURLWithPath: fileName).lastPathComponent
        let url = URL(fileURLWithPath: lastPathComponent)
        let pathExtension = url.pathExtension.lowercased()
        guard allowedExtensions.contains(pathExtension) else { return nil }
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
}
