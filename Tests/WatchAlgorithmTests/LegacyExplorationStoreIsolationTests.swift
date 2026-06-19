import XCTest

final class LegacyExplorationStoreIsolationTests: XCTestCase {
    func testExplorationStoreArchivedOutsideServicesPath() throws {
        let archived = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Legacy/Experimental/ExplorationStore/ExplorationStore.swift")
        XCTAssertTrue(FileManager.default.fileExists(atPath: archived.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: archived.deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("Services/ExplorationStore.swift").path))
    }

    func testProjectYmlStillExcludesExplorationStoreFromWatchMain() throws {
        let project = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .appendingPathComponent("project.yml")
        )
        XCTAssertTrue(project.contains("- ExplorationStore.swift"))
    }

    func testSharedRuntimeDoesNotImportExplorationStore() throws {
        let roots = [
            "Shared/Utils/ApneaSessionEngine.swift",
            "Shared/Utils/SnorkelingSessionEngine.swift",
            "Services/ApneaWatchRuntimeStore.swift"
        ]
        for root in roots {
            let url = URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .appendingPathComponent(root)
            let source = try String(contentsOf: url)
            XCTAssertFalse(source.contains("ExplorationStore"))
        }
    }
}
