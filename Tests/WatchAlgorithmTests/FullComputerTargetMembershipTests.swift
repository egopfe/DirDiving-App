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

    func testSnorkelingMainMembershipIsIntentional() throws {
        let project = try String(contentsOf: repoRoot.appendingPathComponent("project.yml"), encoding: .utf8)
        XCTAssertFalse(
            project.contains("- SnorkelingView.swift"),
            "SnorkelingView must not remain excluded from MAIN Watch target"
        )
        XCTAssertTrue(
            project.contains("Services/SnorkelingWatchRuntimeStore.swift"),
            "Snorkeling runtime store must compile in MAIN Watch target"
        )
        XCTAssertTrue(
            project.contains("Views/SnorkelingView.swift") || FileManager.default.fileExists(
                atPath: repoRoot.appendingPathComponent("Views/SnorkelingView.swift").path
            ),
            "Snorkeling production view must exist for MAIN promotion"
        )
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

    func testWatchLaunchabilityAPIsReflectCurrentArchitecture() {
        XCTAssertTrue(DIRActivityMode.diving.isLaunchableOnWatchMAIN)
        XCTAssertTrue(DIRActivityMode.apnea.isLaunchableOnWatchMAIN)
        XCTAssertTrue(DIRActivityMode.snorkeling.isLaunchableOnWatchMAIN)

        XCTAssertTrue(DIRActivityMode.diving.isLaunchableOnIOSCompanionMAIN)
        XCTAssertTrue(DIRActivityMode.apnea.isLaunchableOnIOSCompanionMAIN)
        XCTAssertTrue(DIRActivityMode.snorkeling.isLaunchableOnIOSCompanionMAIN)
    }

    func testSnorkelingRuntimeDoesNotDependOnFullComputerRuntime() throws {
        let snorkelingSources = [
            "Views/SnorkelingView.swift",
            "Services/SnorkelingWatchRuntimeStore.swift",
            "Utils/SnorkelingWatchPresentation.swift",
        ]
        let forbidden = [
            "FullComputerRuntimeEngine",
            "FullComputerDecoSolver",
            "BuhlmannEngine",
            "buhlmannEngine",
        ]
        for relative in snorkelingSources {
            let source = try String(
                contentsOf: repoRoot.appendingPathComponent(relative),
                encoding: .utf8
            )
            for token in forbidden {
                XCTAssertFalse(
                    source.contains(token),
                    "\(relative) must not reference Full Computer / Bühlmann runtime: \(token)"
                )
            }
        }
    }

    func testFullComputerAlgorithmSourcesDoNotDependOnSnorkelingDomain() throws {
        let fcSources = [
            "Services/FullComputerRuntimeEngine.swift",
            "Utils/FullComputerDecoSolver.swift",
        ]
        let forbidden = [
            "SnorkelingSessionEngine",
            "SnorkelingWatchRuntimeStore",
            "SnorkelingNavigationEngine",
            "dirdiving_snorkeling",
        ]
        for relative in fcSources {
            let path = repoRoot.appendingPathComponent(relative)
            guard FileManager.default.fileExists(atPath: path.path) else { continue }
            let source = try String(contentsOf: path, encoding: .utf8)
            for token in forbidden {
                XCTAssertFalse(
                    source.contains(token),
                    "\(relative) must not depend on Snorkeling domain: \(token)"
                )
            }
        }
    }

    func testPermanentModeTabDisabled() {
        XCTAssertFalse(WatchModeSelectionPreferences.hasMultipleStableModes)
    }
}
