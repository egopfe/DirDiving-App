import ImageIO
import UIKit
import UniformTypeIdentifiers

enum WatchPhotoPreprocessor {
    /// Target max dimension for Watch companion reference images.
    static let optimalMaxDimension: CGFloat = 400
    static let optimalMaxBytes = 350_000
    static let maxInputBytes = 10 * 1_024 * 1_024
    static let maxInputDimension = 8_192

    struct Result {
        let data: Data
        let didConvert: Bool
        let conversionWarning: Bool
    }

    struct ImageDimensions {
        let width: Int
        let height: Int
    }

    enum Failure: LocalizedError {
        case unreadableImage
        case conversionFailed
        case oversizedBytes
        case oversizedDimensions

        var errorDescription: String? {
            switch self {
            case .unreadableImage:
                return DIRIOSLocalizer.string("watch_photo.error.load")
            case .conversionFailed:
                return DIRIOSLocalizer.string("watch_photo.error.convert")
            case .oversizedBytes:
                return DIRIOSLocalizer.string("watch_photo.error.load")
            case .oversizedDimensions:
                return DIRIOSLocalizer.string("watch_photo.error.load")
            }
        }
    }

    static func preflightImageData(_ data: Data) throws {
        guard !data.isEmpty, data.count <= maxInputBytes else {
            throw Failure.oversizedBytes
        }
        guard let dimensions = imageDimensionsWithoutFullDecode(data) else {
            throw Failure.unreadableImage
        }
        guard dimensions.width <= maxInputDimension, dimensions.height <= maxInputDimension else {
            throw Failure.oversizedDimensions
        }
    }

    static func imageDimensionsWithoutFullDecode(_ data: Data) -> ImageDimensions? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = properties[kCGImagePropertyPixelWidth] as? Int,
              let height = properties[kCGImagePropertyPixelHeight] as? Int,
              width > 0, height > 0 else {
            return nil
        }
        return ImageDimensions(width: width, height: height)
    }

    static func prepareForWatch(from data: Data) throws -> Result {
        try preflightImageData(data)
        guard let source = decodeImage(data: data) else {
            throw Failure.unreadableImage
        }
        let size = source.size
        let maxSide = max(size.width, size.height)
        let needsResize = maxSide > optimalMaxDimension + 4
        let isJPEG = data.starts(with: [0xFF, 0xD8])
        let needsReencode = !isJPEG || data.count > optimalMaxBytes
        let needsConversion = needsResize || needsReencode

        let outputImage: UIImage
        if needsResize {
            let scale = optimalMaxDimension / maxSide
            let newSize = CGSize(width: size.width * scale, height: size.height * scale)
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            format.opaque = true
            let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
            outputImage = renderer.image { _ in
                source.draw(in: CGRect(origin: .zero, size: newSize))
            }
        } else {
            outputImage = source
        }

        let bitmap = rasterizedBitmap(outputImage)
        guard let jpeg = jpegRepresentation(from: bitmap, quality: needsConversion ? 0.78 : 0.88) else {
            throw Failure.conversionFailed
        }
        return Result(data: jpeg, didConvert: needsConversion, conversionWarning: needsConversion)
    }

    private static func decodeImage(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }

    private static func rasterizedBitmap(_ image: UIImage) -> UIImage {
        let size = image.size
        guard size.width > 0, size.height > 0 else { return image }
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    private static func jpegRepresentation(from image: UIImage, quality: CGFloat) -> Data? {
        if let data = image.jpegData(compressionQuality: quality) {
            return data
        }
        guard let cgImage = image.cgImage else { return nil }
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
}
