import UIKit
import XCTest

@MainActor
final class WatchPhotoTransferPipelineTests: XCTestCase {
    private var tempDirectory: URL!

    override func setUp() {
        super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("WatchPhotoTransferPipeline-\(UUID().uuidString)", isDirectory: true)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        tempDirectory = nil
        super.tearDown()
    }

    func testImportStoreInventoryAndDeletePipeline() throws {
        let source = try writeTemporaryJPEG(named: "pipeline_test.jpg")
        let stored = try UserImageStore.importCompanionPhoto(from: source, fileName: "pipeline_test_\(UUID().uuidString).jpg")
        XCTAssertFalse(stored.isEmpty)
        XCTAssertTrue(UserImageStore.buildUploadedInventory().contains { $0.storedFileName == stored })

        _ = try UserImageStore.deleteUploadedImage(named: stored)
        XCTAssertFalse(UserImageStore.buildUploadedInventory().contains { $0.storedFileName == stored })
    }

    func testWCSessionEndToEndLimitationDocumented() {
        XCTAssertFalse(
            ProcessInfo.processInfo.environment.keys.contains("DIRDIVING_WATCH_WCSESSION_E2E"),
            "WCSession photo file E2E is intentionally out of unit-test scope; use paired iPhone + Watch QA matrix."
        )
    }

    private func writeTemporaryJPEG(named: String) throws -> URL {
        let image = UIImage(systemName: "photo")!
        let data = try XCTUnwrap(image.jpegData(compressionQuality: 0.9))
        let url = tempDirectory.appendingPathComponent(named)
        try data.write(to: url)
        return url
    }
}
