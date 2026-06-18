import XCTest

final class FullComputerTargetMembershipTests: XCTestCase {
    private var repoRoot: URL!

    override func setUp() {
        super.setUp()
        repoRoot = FullComputerWatchArchitectureGuard.repositoryRoot(from: #filePath)
    }

    func testProjectYAMLIncludesSharedBuhlmannCoreOnBothTargets() throws {
        let project = try String(contentsOf: repoRoot.appendingPathComponent("project.yml"), encoding: .utf8)
        XCTAssertTrue(project.contains("path: Shared"), "Shared module must be in target sources")
        XCTAssertTrue(project.contains("Shared/BuhlmannCore/BuhlmannEngine.swift") || project.contains("path: Shared"))
    }

    func testProjectYAMLExcludesSnorkelingWatchUI() throws {
        let project = try String(contentsOf: repoRoot.appendingPathComponent("project.yml"), encoding: .utf8)
        XCTAssertFalse(project.contains("- ApneaView.swift"))
        XCTAssertTrue(project.contains("- SnorkelingView.swift"))
    }

    func testNoDuplicateIOSLocalBuhlmannEngine() throws {
        let iosEngine = repoRoot.appendingPathComponent("iOSApp/Algorithms/Buhlmann/BuhlmannEngine.swift")
        XCTAssertFalse(FileManager.default.fileExists(atPath: iosEngine.path))
        let bridge = repoRoot.appendingPathComponent("iOSApp/Algorithms/Buhlmann/BuhlmannGas+GasMix.swift")
        XCTAssertTrue(FileManager.default.fileExists(atPath: bridge.path))
    }

    func testCanonicalBuhlmannEngineExistsOnlyInSharedCore() throws {
        let shared = repoRoot.appendingPathComponent("Shared/BuhlmannCore/BuhlmannEngine.swift")
        XCTAssertTrue(FileManager.default.fileExists(atPath: shared.path))
    }

    func testWatchLaunchabilityAPIsArePlatformSpecific() {
        XCTAssertTrue(DIRActivityMode.diving.isLaunchableOnWatchMAIN)
        XCTAssertTrue(DIRActivityMode.apnea.isLaunchableOnWatchMAIN)
        XCTAssertFalse(DIRActivityMode.snorkeling.isLaunchableOnWatchMAIN)

        XCTAssertTrue(DIRActivityMode.diving.isLaunchableOnIOSCompanionMAIN)
        XCTAssertTrue(DIRActivityMode.apnea.isLaunchableOnIOSCompanionMAIN)
        XCTAssertFalse(DIRActivityMode.snorkeling.isLaunchableOnIOSCompanionMAIN)
    }

    func testPermanentModeTabDisabled() {
        XCTAssertFalse(WatchModeSelectionPreferences.hasMultipleStableModes)
    }
}
