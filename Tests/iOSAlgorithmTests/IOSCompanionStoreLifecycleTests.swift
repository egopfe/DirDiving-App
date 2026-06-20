import XCTest

/// Verifies lazy activity store wiring in `DIRDivingiOSApp` without duplicating the full app dependency graph.
final class IOSCompanionStoreLifecycleTests: XCTestCase {
    private func readSource(_ relativePath: String) -> String {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent(relativePath)
        return (try? String(contentsOf: url, encoding: .utf8)) ?? ""
    }

    func testAppRootUsesStoreCoordinator() {
        let source = readSource("iOSApp/App/DIRDivingiOSApp.swift")
        XCTAssertTrue(source.contains("IOSCompanionStoreCoordinator"))
        XCTAssertTrue(source.contains("applyApneaEnvironment"))
        XCTAssertTrue(source.contains("applySnorkelingEnvironment"))
    }

    func testAppRootDoesNotEagerlyDeclareAllActivityStateObjects() {
        let source = readSource("iOSApp/App/DIRDivingiOSApp.swift")
        XCTAssertFalse(source.contains("@StateObject private var apneaLogbookStore"))
        XCTAssertFalse(source.contains("@StateObject private var snorkelingLogbookStore"))
        XCTAssertFalse(source.contains("@StateObject private var apneaProfileStore"))
    }

    func testCoordinatorProvidesLazyApneaAndSnorkelingBundles() {
        let source = readSource("iOSApp/Services/IOSCompanionStoreCoordinator.swift")
        XCTAssertTrue(source.contains("func ensureApneaStores()"))
        XCTAssertTrue(source.contains("func ensureSnorkelingStores()"))
        XCTAssertTrue(source.contains("private var apneaBundle"))
        XCTAssertTrue(source.contains("private var snorkelingBundle"))
    }

    func testWatchSyncUsesLazyLogbookAttachment() {
        let source = readSource("iOSApp/Services/IOSCompanionStoreCoordinator.swift")
        XCTAssertTrue(source.contains("lazyApneaLogbookForSync"))
        XCTAssertTrue(source.contains("lazySnorkelingLogbookForSync"))
    }
}
