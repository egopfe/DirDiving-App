import XCTest

@MainActor
final class UserImageStorePolicyTests: XCTestCase {
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
}
