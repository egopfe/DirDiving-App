import XCTest

final class ActivitySyncSchemaRegistryTests: XCTestCase {
    func testRegistryHasSessionSyncRecords() {
        XCTAssertNotNil(ActivitySyncSchemaRegistry.record(named: "Diving session sync"))
        XCTAssertNotNil(ActivitySyncSchemaRegistry.record(named: "Apnea session sync"))
        XCTAssertNotNil(ActivitySyncSchemaRegistry.record(named: "Snorkeling session sync"))
    }

    func testRegistryVersionsValid() {
        XCTAssertTrue(ActivitySyncSchemaRegistry.verifyUniqueCurrentVersions().isEmpty)
    }

    func testFullComputerCheckpointDocumentedAsV1() {
        let record = ActivitySyncSchemaRegistry.record(named: "Full Computer checkpoint")
        XCTAssertEqual(record?.currentVersion, 1)
    }
}
