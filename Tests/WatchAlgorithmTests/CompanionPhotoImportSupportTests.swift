import UIKit
import XCTest
@testable import DIRDivingWatchApp

@MainActor
final class CompanionPhotoImportSupportTests: XCTestCase {
    private var tempDirectory: URL!

    override func setUpWithError() throws {
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("CompanionPhotoImport-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        if let tempDirectory {
            try? FileManager.default.removeItem(at: tempDirectory)
        }
        tempDirectory = nil
    }

    func testValidatorRejectsCorruptNonImageBytes() {
        let data = Data("not-an-image".utf8)
        XCTAssertThrowsError(
            try WatchCompanionPhotoValidator.validateAndNormalize(data: data, suggestedFileName: "bad.jpg")
        )
    }

    func testUniqueDestinationURLAppendsSuffixInsteadOfOverwriting() throws {
        let first = tempDirectory.appendingPathComponent("companion_test.jpg")
        try Data([0x01]).write(to: first)
        let second = CompanionPhotoImportSupport.uniqueDestinationURL(
            in: tempDirectory,
            preferredFileName: "companion_test.jpg"
        )
        XCTAssertEqual(second.lastPathComponent, "companion_test-2.jpg")
        XCTAssertFalse(FileManager.default.fileExists(atPath: second.path))
    }

    func testImportCreatesUserImagesDirectoryWhenMissing() throws {
        let documents = documentsUserImagesDirectory()
        try? FileManager.default.removeItem(at: documents)
        XCTAssertFalse(FileManager.default.fileExists(atPath: documents.path))

        let source = try writeTemporaryJPEG(named: "seed.jpg")
        defer { cleanupStoredFiles(matching: "companion_import_dir_") }

        let stored = try UserImageStore.importCompanionPhoto(from: source, fileName: "companion_import_dir_test.jpg")
        XCTAssertTrue(FileManager.default.fileExists(atPath: documents.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: documents.appendingPathComponent(stored).path))
    }

    func testImportStoresNormalizedJPG() throws {
        let source = try writeTemporaryJPEG(named: "normalized.jpg")
        defer { cleanupStoredFiles(matching: "companion_import_norm_") }

        let stored = try UserImageStore.importCompanionPhoto(from: source, fileName: "companion_import_norm_test.jpg")
        let storedURL = documentsUserImagesDirectory().appendingPathComponent(stored)
        let storedData = try Data(contentsOf: storedURL)
        XCTAssertEqual(storedData.prefix(2), Data([0xFF, 0xD8]))
        XCTAssertTrue(stored.hasSuffix(".jpg"))
    }

    func testImportReturnsActualStoredFileName() throws {
        let source = try writeTemporaryJPEG(named: "actual-name.jpg")
        defer { cleanupStoredFiles(matching: "companion_import_name_") }

        let preferred = "companion_import_name_test.jpg"
        let stored = try UserImageStore.importCompanionPhoto(from: source, fileName: preferred)
        XCTAssertEqual(stored, preferred)
        XCTAssertTrue(FileManager.default.fileExists(atPath: documentsUserImagesDirectory().appendingPathComponent(stored).path))
    }

    func testDuplicateDestinationFilenamesDoNotOverwriteSilently() throws {
        let sourceOne = try writeTemporaryJPEG(named: "dup-one.jpg")
        let sourceTwo = try writeTemporaryJPEG(named: "dup-two.jpg")
        let preferred = "companion_duplicate_\(UUID().uuidString).jpg"
        defer { cleanupStoredFiles(matching: preferred) }

        let firstStored = try UserImageStore.importCompanionPhoto(from: sourceOne, fileName: preferred)
        let secondStored = try UserImageStore.importCompanionPhoto(from: sourceTwo, fileName: preferred)
        XCTAssertNotEqual(firstStored, secondStored)
        XCTAssertTrue(secondStored.contains("-2"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: documentsUserImagesDirectory().appendingPathComponent(firstStored).path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: documentsUserImagesDirectory().appendingPathComponent(secondStored).path))
    }

    func testAckPayloadUsesSharedMetadataKeys() {
        let payload = CompanionPhotoImportSupport.makeAckPayload(
            photoID: "photo-123",
            status: CompanionPhotoImportSupport.ackStatusImported,
            storedFileName: "companion_photo-123.jpg"
        )
        XCTAssertEqual(payload["type"] as? String, WatchSyncKeys.companionPhotoAckType)
        XCTAssertEqual(payload[WatchSyncKeys.companionPhotoIDKey] as? String, "photo-123")
        XCTAssertEqual(payload[WatchSyncKeys.companionPhotoAckStatusKey] as? String, "imported")
        XCTAssertEqual(payload[WatchSyncKeys.companionPhotoAckStoredFileNameKey] as? String, "companion_photo-123.jpg")
    }

    private func documentsUserImagesDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("UserImages", isDirectory: true)
    }

    private func writeTemporaryJPEG(named: String) throws -> URL {
        let image = UIImage(systemName: "photo")!
        let data = try XCTUnwrap(image.jpegData(compressionQuality: 0.9))
        let url = tempDirectory.appendingPathComponent(named)
        try data.write(to: url)
        return url
    }

    private func cleanupStoredFiles(matching prefix: String) {
        let directory = documentsUserImagesDirectory()
        let urls = (try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? []
        for url in urls where url.lastPathComponent.contains(prefix) {
            try? FileManager.default.removeItem(at: url)
        }
    }
}
