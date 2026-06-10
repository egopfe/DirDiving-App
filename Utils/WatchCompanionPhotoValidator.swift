import ImageIO
import UIKit
import UniformTypeIdentifiers

enum WatchCompanionPhotoValidationError: LocalizedError, Equatable {
    case invalidFileName
    case invalidFileSize
    case undecodableImage
    case dimensionsTooLarge
    case reencodeFailed

    var errorDescription: String? {
        switch self {
        case .invalidFileName:
            return String(localized: "image.error.invalid_filename")
        case .invalidFileSize:
            return String(localized: "image.error.invalid_size")
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
/// watchOS can decode HEIC but cannot encode it; all stored and displayed images are rasterized to JPEG/bitmap.
enum WatchCompanionPhotoValidator {
    static let maxBytes = 10 * 1_024 * 1_024
    static let maxPixelDimension: CGFloat = 4_096
    private static let allowedExtensions: Set<String> = ["png", "jpg", "jpeg", "heic"]
    private static let storedExtensions: Set<String> = ["png", "jpg", "jpeg"]

    static func validateAndNormalize(data: Data, suggestedFileName: String) throws -> (data: Data, fileName: String) {
        guard isAllowedByteCount(data.count) else {
            throw WatchCompanionPhotoValidationError.invalidFileSize
        }
        guard let image = decodeImage(data: data) else {
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
        guard let jpeg = jpegRepresentation(from: image, quality: 0.85) else {
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

    /// Loads an on-disk or bundled image for SwiftUI display without triggering HEIC encoding.
    static func imageForDisplay(atPath path: String) -> UIImage? {
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url), let image = decodeImage(data: data) else {
            guard let image = UIImage(contentsOfFile: path) else { return nil }
            return rasterizedBitmap(image)
        }
        return rasterizedBitmap(image)
    }

    /// Loads an on-disk or bundled image for SwiftUI display from a bundle resource path such as `UserImages/photo.jpg`.
    static func imageForDisplay(resourceName: String, bundle: Bundle = .main) -> UIImage? {
        if resourceName.hasPrefix("/") {
            return imageForDisplay(atPath: resourceName)
        }

        let resourceURL = URL(fileURLWithPath: resourceName)
        let fileName = resourceURL.lastPathComponent
        let subdirectory = resourceURL.deletingLastPathComponent().path
        let baseName = resourceURL.deletingPathExtension().lastPathComponent
        let pathExtension = resourceURL.pathExtension

        if !subdirectory.isEmpty, subdirectory != ".", !baseName.isEmpty {
            if let url = bundle.url(
                forResource: baseName,
                withExtension: pathExtension.isEmpty ? nil : pathExtension,
                subdirectory: subdirectory
            ) {
                return imageForDisplay(atPath: url.path)
            }
        }

        if let url = bundle.url(forResource: fileName, withExtension: nil) {
            return imageForDisplay(atPath: url.path)
        }

        if let url = bundle.url(forResource: resourceName, withExtension: nil) {
            return imageForDisplay(atPath: url.path)
        }

        return nil
    }

    static func decodeImage(data: Data) -> UIImage? {
        if let image = UIImage(data: data) {
            return image
        }
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }

    static func rasterizedBitmap(_ image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        let width = cgImage.width
        let height = cgImage.height
        guard width > 0, height > 0 else { return image }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return image
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let bitmap = context.makeImage() else { return image }
        return UIImage(cgImage: bitmap, scale: image.scale, orientation: image.imageOrientation)
    }

    static func jpegRepresentation(from image: UIImage, quality: CGFloat) -> Data? {
        let bitmap = rasterizedBitmap(image)
        if let data = bitmap.jpegData(compressionQuality: quality) {
            return data
        }
        guard let cgImage = bitmap.cgImage else { return nil }
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            data,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        ) else {
            return nil
        }
        let options = [kCGImageDestinationLossyCompressionQuality: quality] as CFDictionary
        CGImageDestinationAddImage(destination, cgImage, options)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return data as Data
    }

    static func migrateLegacyHEICFileIfNeeded(at url: URL) {
        guard url.pathExtension.lowercased() == "heic" else { return }
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        guard let data = try? Data(contentsOf: url),
              let normalized = try? validateAndNormalize(data: data, suggestedFileName: url.lastPathComponent) else {
            try? FileManager.default.removeItem(at: url)
            return
        }
        let destination = url.deletingPathExtension().appendingPathExtension("jpg")
        do {
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            try normalized.data.write(to: destination, options: [.atomic, .completeFileProtection])
            try FileManager.default.removeItem(at: url)
        } catch {
            return
        }
    }

    private static func isAllowedByteCount(_ byteCount: Int) -> Bool {
        byteCount > 0 && byteCount <= maxBytes
    }

    private static func sanitizedFileName(_ fileName: String) -> String? {
        let lastPathComponent = URL(fileURLWithPath: fileName).lastPathComponent
        let url = URL(fileURLWithPath: lastPathComponent)
        let pathExtension = url.pathExtension.lowercased()
        guard storedExtensions.contains(pathExtension) else { return nil }
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
