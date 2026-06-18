import XCTest

final class SnorkelingArchitectureIsolationTests: XCTestCase {
    private let productionSnorkelingPaths = SnorkelingArchitectureIsolation.productionSourcePaths

    private let forbiddenSymbols = SnorkelingArchitectureIsolation.forbiddenExecutableSymbols

    func testSnorkelingIsolationScannerIgnoresLineComments() {
        let source = """
        // ExplorationStore
        let value = 1
        """
        let stripped = SnorkelingArchitectureIsolation.stripCommentsAndStringLiterals(from: source)
        XCTAssertFalse(stripped.contains("ExplorationStore"))
    }

    func testSnorkelingIsolationScannerIgnoresDocumentationComments() {
        let source = """
        /// Independent from ExplorationStore runtime.
        let value = 1
        """
        let stripped = SnorkelingArchitectureIsolation.stripCommentsAndStringLiterals(from: source)
        XCTAssertFalse(stripped.contains("ExplorationStore"))
    }

    func testSnorkelingIsolationScannerIgnoresBlockComments() {
        let source = """
        /*
         ExplorationStore
         DiveManager
        */
        let value = 1
        """
        let stripped = SnorkelingArchitectureIsolation.stripCommentsAndStringLiterals(from: source)
        XCTAssertFalse(stripped.contains("ExplorationStore"))
        XCTAssertFalse(stripped.contains("DiveManager"))
    }

    func testSnorkelingIsolationScannerRejectsExecutableExplorationStoreReference() {
        let source = "let store = ExplorationStore()"
        XCTAssertEqual(
            SnorkelingArchitectureIsolation.violations(in: source).map(\.symbol),
            ["ExplorationStore"]
        )
    }

    func testSnorkelingIsolationScannerRejectsExecutableDiveManagerReference() {
        let source = "DiveManager.shared.start()"
        XCTAssertTrue(
            SnorkelingArchitectureIsolation.violations(in: source).contains(
                SnorkelingArchitectureIsolation.Violation(file: "<inline>", symbol: "DiveManager")
            )
        )
    }

    func testSnorkelingIsolationScannerRejectsExecutableApneaRuntimeReference() {
        let source = "var engine = ApneaSessionEngine()"
        XCTAssertTrue(
            SnorkelingArchitectureIsolation.violations(in: source).contains(
                SnorkelingArchitectureIsolation.Violation(file: "<inline>", symbol: "ApneaSessionEngine")
            )
        )
    }

    func testSnorkelingIsolationScannerRejectsExecutableFullComputerRuntimeReference() {
        let source = "FullComputerRuntimeEngine()"
        XCTAssertTrue(
            SnorkelingArchitectureIsolation.violations(in: source).contains(
                SnorkelingArchitectureIsolation.Violation(file: "<inline>", symbol: "FullComputerRuntimeEngine")
            )
        )
    }

    func testSnorkelingProductionSourcesContainNoForeignRuntimeDependency() throws {
        let violations = try SnorkelingArchitectureIsolation.violations(inRepositoryRoot: repositoryRoot())
        XCTAssertTrue(violations.isEmpty, violations.map { "\($0.file): \($0.symbol)" }.joined(separator: ", "))
    }

    func testSnorkelingFeedSourcesDoNotReferenceForeignRuntime() throws {
        try testSnorkelingProductionSourcesContainNoForeignRuntimeDependency()
    }

    func testSnorkelingDepthFeedReusesSharedDepthMeasurementFeedOnly() throws {
        let text = try String(
            contentsOf: repositoryRoot().appendingPathComponent("Shared/Utils/SnorkelingDepthFeed.swift"),
            encoding: .utf8
        )
        XCTAssertTrue(text.contains("DepthMeasurementFeed.ingest"))
        XCTAssertFalse(
            SnorkelingArchitectureIsolation.violations(in: text, file: "SnorkelingDepthFeed.swift")
                .contains(where: { $0.symbol == "DiveManager" })
        )
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
