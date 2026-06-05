import UIKit
import XCTest
@testable import DIRDivingWatchApp

final class WatchCompanionPhotoValidatorTests: XCTestCase {
    func testValidJPEGAccepted() throws {
        let image = UIImage(systemName: "photo")!
        let data = image.jpegData(compressionQuality: 0.9)!
        let result = try WatchCompanionPhotoValidator.validateAndNormalize(data: data, suggestedFileName: "test.jpg")
        XCTAssertTrue(result.fileName.hasSuffix(".jpg"))
        XCTAssertFalse(result.data.isEmpty)
        XCTAssertEqual(result.data.prefix(2), Data([0xFF, 0xD8]))
    }

    func testTextBytesWithJpgExtensionRejected() {
        let data = Data("not-an-image".utf8)
        XCTAssertThrowsError(try WatchCompanionPhotoValidator.validateAndNormalize(data: data, suggestedFileName: "bad.jpg"))
    }
}
