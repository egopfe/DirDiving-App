import XCTest

final class ApneaChecklistTests: XCTestCase {
    func testDefaultChecklistHasSevenItems() {
        XCTAssertEqual(ApneaChecklistCatalog.defaultItems().count, 7)
    }

    func testDefaultItemsUnchecked() {
        XCTAssertTrue(ApneaChecklistCatalog.defaultItems().allSatisfy { !$0.isChecked })
    }
}
