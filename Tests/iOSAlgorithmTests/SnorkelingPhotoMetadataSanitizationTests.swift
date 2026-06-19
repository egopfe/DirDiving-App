import XCTest
import ImageIO
import CoreGraphics
import UniformTypeIdentifiers

final class SnorkelingPhotoMetadataSanitizationTests: XCTestCase {
    func testSanitizedPhotoRemovesEXIFGPSDictionary() throws {
        let original = try makeGPSFixtureImage()
        XCTAssertTrue(SnorkelingPhotoMetadataSanitizer.containsGPSMetadata(in: original))
        let sanitized = try SnorkelingPhotoMetadataSanitizer.sanitizeRemovingLocation(from: original)
        XCTAssertFalse(SnorkelingPhotoMetadataSanitizer.containsGPSMetadata(in: sanitized))
    }

    func testSanitizedPhotoRemainsDecodable() throws {
        let original = try makeGPSFixtureImage()
        let sanitized = try SnorkelingPhotoMetadataSanitizer.sanitizeRemovingLocation(from: original)
        XCTAssertNotNil(CGImageSourceCreateWithData(sanitized as CFData, nil))
    }

    func testOriginalPhotoIsNotMutated() throws {
        let original = try makeGPSFixtureImage()
        let copy = original
        _ = try SnorkelingPhotoMetadataSanitizer.sanitizeRemovingLocation(from: original)
        XCTAssertEqual(original, copy)
    }

    func testInvalidPhotoFailsClosed() {
        XCTAssertThrowsError(try SnorkelingPhotoMetadataSanitizer.sanitizeRemovingLocation(from: Data([0, 1, 2])))
    }

    @MainActor
    func testPhotoStoreStripsGPSOnImport() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        IOSSnorkelingSessionPhotoStore.testHook_storageDirectoryURL = directory
        defer {
            IOSSnorkelingSessionPhotoStore.testHook_storageDirectoryURL = nil
            try? FileManager.default.removeItem(at: directory)
        }

        let store = IOSSnorkelingSessionPhotoStore()
        let fixture = try makeGPSFixtureImage()
        let attachment = try store.addPhoto(sessionID: UUID(), imageData: fixture, stripLocationMetadata: true)
        let url = SnorkelingSessionPhotoSupport.fileURL(for: attachment, base: directory)
        let stored = try Data(contentsOf: url)
        XCTAssertFalse(SnorkelingPhotoMetadataSanitizer.containsGPSMetadata(in: stored))
    }

    private func makeGPSFixtureImage() throws -> Data {
        let size = 8
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: nil,
            width: size,
            height: size,
            bitsPerComponent: 8,
            bytesPerRow: size * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ), let image = context.makeImage() else {
            throw SnorkelingPhotoMetadataSanitizationError.invalidImageData
        }

        let metadata: [CFString: Any] = [
            kCGImagePropertyGPSDictionary: [
                kCGImagePropertyGPSLatitude: 44.123,
                kCGImagePropertyGPSLatitudeRef: "N",
                kCGImagePropertyGPSLongitude: 8.456,
                kCGImagePropertyGPSLongitudeRef: "E",
            ]
        ]
        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(output, UTType.jpeg.identifier as CFString, 1, nil) else {
            throw SnorkelingPhotoMetadataSanitizationError.encodingFailed
        }
        CGImageDestinationAddImage(destination, image, metadata as CFDictionary)
        guard CGImageDestinationFinalize(destination) else {
            throw SnorkelingPhotoMetadataSanitizationError.encodingFailed
        }
        return output as Data
    }
}
