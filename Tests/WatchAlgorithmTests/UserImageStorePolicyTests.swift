import UIKit
import XCTest

@MainActor
final class UserImageStorePolicyTests: XCTestCase {
    private var tempDirectory: URL!

    override func setUpWithError() throws {
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("UserImageStorePolicy-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        cleanupStoredFiles(matching: "policy_")
        if let tempDirectory {
            try? FileManager.default.removeItem(at: tempDirectory)
        }
        tempDirectory = nil
    }

    func testCompanionPhotoFileNameIsSanitizedAndWhitelisted() {
        XCTAssertEqual(
            UserImageStore.sanitizedCompanionPhotoFileName("../unsafe:photo.JPG"),
            "unsafe_photo.jpg"
        )
        XCTAssertNil(UserImageStore.sanitizedCompanionPhotoFileName("../notes.txt"))
        XCTAssertNil(UserImageStore.sanitizedCompanionPhotoFileName("photo"))
    }

    func testCompanionPhotoSizeIsBounded() {
        XCTAssertFalse(UserImageStore.isAllowedCompanionPhotoByteCount(0))
        XCTAssertTrue(UserImageStore.isAllowedCompanionPhotoByteCount(UserImageStore.maxCompanionPhotoBytes))
        XCTAssertFalse(UserImageStore.isAllowedCompanionPhotoByteCount(UserImageStore.maxCompanionPhotoBytes + 1))
    }

    func testImportedDocumentImageCanBeDeleted() throws {
        let source = try writeTemporaryJPEG(named: "policy-delete.jpg")
        let preferred = "policy_delete_\(UUID().uuidString).jpg"
        let stored = try UserImageStore.importCompanionPhoto(from: source, fileName: preferred)
        let store = UserImageStore()
        XCTAssertTrue(store.canDeleteImage(named: stored))
        try store.deleteImage(named: stored)
        XCTAssertFalse(UserImageStore.isUploadedDocumentImage(named: stored))
        XCTAssertFalse(store.imageNames.contains(stored))
    }

    func testDeletingInvalidPathTraversalFilenameFails() {
        XCTAssertThrowsError(try UserImageStore.deleteUploadedImage(named: "../escape.jpg"))
        XCTAssertFalse(UserImageStore.isUploadedDocumentImage(named: "../escape.jpg"))
    }

    func testInventoryContainsUploadedImages() throws {
        let sourceOne = try writeTemporaryJPEG(named: "policy-one.jpg")
        let sourceTwo = try writeTemporaryJPEG(named: "policy-two.jpg")
        let first = try UserImageStore.importCompanionPhoto(from: sourceOne, fileName: "policy_inventory_\(UUID().uuidString).jpg")
        let second = try UserImageStore.importCompanionPhoto(from: sourceTwo, fileName: "policy_inventory_\(UUID().uuidString).jpg")
        defer {
            cleanupStoredFiles(matching: first)
            cleanupStoredFiles(matching: second)
        }
        let inventory = UserImageStore.buildUploadedInventory()
        XCTAssertTrue(inventory.contains { $0.storedFileName == first })
        XCTAssertTrue(inventory.contains { $0.storedFileName == second })
        XCTAssertTrue(inventory.allSatisfy(\.isDeletable))
    }

    func testInventoryUpdatesAfterDelete() throws {
        let source = try writeTemporaryJPEG(named: "policy-inv-delete.jpg")
        let stored = try UserImageStore.importCompanionPhoto(from: source, fileName: "policy_inventory_delete_\(UUID().uuidString).jpg")
        defer { cleanupStoredFiles(matching: stored) }
        XCTAssertTrue(UserImageStore.buildUploadedInventory().contains { $0.storedFileName == stored })
        _ = try UserImageStore.deleteUploadedImage(named: stored)
        XCTAssertFalse(UserImageStore.buildUploadedInventory().contains { $0.storedFileName == stored })
    }

    private func writeTemporaryJPEG(named: String) throws -> URL {
        let image = UIImage(systemName: "photo")!
        let data = try XCTUnwrap(image.jpegData(compressionQuality: 0.9))
        let url = tempDirectory.appendingPathComponent(named)
        try data.write(to: url)
        return url
    }

    private func cleanupStoredFiles(matching prefix: String) {
        let directory = UserImageStore.userImagesDocumentsDirectory()
        let urls = (try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? []
        for url in urls where url.lastPathComponent.contains(prefix) {
            try? FileManager.default.removeItem(at: url)
        }
    }
}
