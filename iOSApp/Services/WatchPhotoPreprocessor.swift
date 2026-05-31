import UIKit

enum WatchPhotoPreprocessor {
    /// Target max dimension for Watch companion reference images.
    static let optimalMaxDimension: CGFloat = 400
    static let optimalMaxBytes = 350_000

    struct Result {
        let data: Data
        let didConvert: Bool
        let conversionWarning: Bool
    }

    enum Failure: LocalizedError {
        case unreadableImage
        case conversionFailed

        var errorDescription: String? {
            switch self {
            case .unreadableImage:
                return String(localized: "watch_photo.error.load")
            case .conversionFailed:
                return String(localized: "watch_photo.error.convert")
            }
        }
    }

    static func prepareForWatch(from data: Data) throws -> Result {
        guard let source = UIImage(data: data) else {
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
            let renderer = UIGraphicsImageRenderer(size: newSize)
            outputImage = renderer.image { _ in
                source.draw(in: CGRect(origin: .zero, size: newSize))
            }
        } else {
            outputImage = source
        }

        guard let jpeg = outputImage.jpegData(compressionQuality: needsConversion ? 0.78 : 0.88) else {
            throw Failure.conversionFailed
        }
        return Result(data: jpeg, didConvert: needsConversion, conversionWarning: needsConversion)
    }
}
