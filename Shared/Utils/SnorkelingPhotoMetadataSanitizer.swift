import Foundation
import ImageIO
import UniformTypeIdentifiers

enum SnorkelingPhotoMetadataSanitizationError: Error, Equatable {
    case invalidImageData
    case encodingFailed
    case gpsMetadataRemains
}

enum SnorkelingPhotoMetadataSanitizer {
    private static let gpsMetadataKeys: [CFString] = [
        kCGImagePropertyGPSDictionary,
        kCGImagePropertyGPSLatitude,
        kCGImagePropertyGPSLongitude,
        kCGImagePropertyGPSLatitudeRef,
        kCGImagePropertyGPSLongitudeRef,
        kCGImagePropertyGPSAltitude,
        kCGImagePropertyGPSAltitudeRef,
        kCGImagePropertyGPSTimeStamp,
        kCGImagePropertyGPSDateStamp,
    ]

    static func containsGPSMetadata(in data: Data) -> Bool {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any] else {
            return false
        }
        return gpsMetadataPresent(in: properties)
    }

    static func sanitizeRemovingLocation(from imageData: Data, compressionQuality: CGFloat = 0.85) throws -> Data {
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              let type = CGImageSourceGetType(source),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            throw SnorkelingPhotoMetadataSanitizationError.invalidImageData
        }

        let sanitizedProperties = sanitizedMetadata(from: source)
        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(output, type, 1, nil) else {
            throw SnorkelingPhotoMetadataSanitizationError.encodingFailed
        }

        var options: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: compressionQuality,
            kCGImageDestinationMetadata: sanitizedProperties,
        ]
        CGImageDestinationAddImage(destination, image, options as CFDictionary)
        guard CGImageDestinationFinalize(destination) else {
            throw SnorkelingPhotoMetadataSanitizationError.encodingFailed
        }

        let result = output as Data
        if containsGPSMetadata(in: result) {
            throw SnorkelingPhotoMetadataSanitizationError.gpsMetadataRemains
        }
        return result
    }

    private static func sanitizedMetadata(from source: CGImageSource) -> [CFString: Any] {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any] else {
            return [:]
        }
        var sanitized = properties
        sanitized.removeValue(forKey: kCGImagePropertyGPSDictionary)
        for key in gpsMetadataKeys {
            sanitized.removeValue(forKey: key)
        }
        if var exif = sanitized[kCGImagePropertyExifDictionary] as? [CFString: Any] {
            exif.removeValue(forKey: kCGImagePropertyGPSDictionary)
            sanitized[kCGImagePropertyExifDictionary] = exif
        }
        if var tiff = sanitized[kCGImagePropertyTIFFDictionary] as? [CFString: Any] {
            tiff.removeValue(forKey: kCGImagePropertyGPSDictionary)
            sanitized[kCGImagePropertyTIFFDictionary] = tiff
        }
        return sanitized
    }

    private static func gpsMetadataPresent(in properties: [CFString: Any]) -> Bool {
        if properties[kCGImagePropertyGPSDictionary] != nil { return true }
        for key in gpsMetadataKeys where properties[key] != nil {
            return true
        }
        if let exif = properties[kCGImagePropertyExifDictionary] as? [CFString: Any],
           exif[kCGImagePropertyGPSDictionary] != nil {
            return true
        }
        if let tiff = properties[kCGImagePropertyTIFFDictionary] as? [CFString: Any],
           tiff[kCGImagePropertyGPSDictionary] != nil {
            return true
        }
        return false
    }
}
