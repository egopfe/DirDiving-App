import XCTest

final class FullComputerWatchArchitectureGuardTests: XCTestCase {
    private var repoRoot: URL!

    override func setUp() {
        super.setUp()
        repoRoot = FullComputerWatchArchitectureGuard.repositoryRoot(from: #filePath)
    }

    func testWatchFullComputerMayConsumeSharedBuhlmannCore() throws {
        let approvedConsumers = FullComputerWatchArchitectureGuard.watchSwiftFiles(repoRoot: repoRoot)
            .filter { FullComputerWatchArchitectureGuard.approvedSharedCoreConsumerFileNames.contains($0.lastPathComponent) }
        XCTAssertFalse(approvedConsumers.isEmpty, "Expected approved Full Computer consumer files")
        for file in approvedConsumers {
            let source = try String(contentsOf: file, encoding: .utf8).lowercased()
            XCTAssertTrue(
                FullComputerWatchArchitectureGuard.sharedCoreBuhlmannReferenceTokens.contains { source.contains($0) },
                "\(file.lastPathComponent) should reference shared Bühlmann APIs"
            )
        }
    }

    func testWatchDoesNotDefineDuplicateBuhlmannEngine() throws {
        let engineDefinition = try XCTUnwrap(
            repoRoot.appendingPathComponent("Shared/BuhlmannCore/BuhlmannEngine.swift")
        )
        XCTAssertTrue(FileManager.default.fileExists(atPath: engineDefinition.path))

        for file in FullComputerWatchArchitectureGuard.watchSwiftFiles(repoRoot: repoRoot) {
            let source = FullComputerWatchArchitectureGuard.codeWithoutLineComments(
                try String(contentsOf: file, encoding: .utf8)
            )
            for pattern in FullComputerWatchArchitectureGuard.duplicateEngineDefinitionPatterns {
                XCTAssertFalse(
                    source.contains(pattern),
                    "\(file.lastPathComponent) must not define a duplicate Bühlmann engine (\(pattern))"
                )
            }
        }
    }

    func testWatchDoesNotReimplementTissueGFOrNDLMath() throws {
        for file in FullComputerWatchArchitectureGuard.watchSwiftFiles(repoRoot: repoRoot) {
            guard FullComputerWatchArchitectureGuard.approvedSharedCoreConsumerFileNames.contains(file.lastPathComponent) == false else {
                continue
            }
            let source = FullComputerWatchArchitectureGuard.codeWithoutLineComments(
                try String(contentsOf: file, encoding: .utf8)
            )
            for pattern in FullComputerWatchArchitectureGuard.forbiddenReimplementedMathPatterns {
                XCTAssertFalse(
                    source.contains(pattern),
                    "\(file.lastPathComponent) must not reimplement decompression math (\(pattern))"
                )
            }
        }
    }

    func testWatchRuntimeDoesNotContainCCRRuntime() throws {
        try assertWatchRootsExclude(tokens: FullComputerWatchArchitectureGuard.forbiddenCCRAndRatioTokens)
    }

    func testWatchRuntimeDoesNotContainRatioDecoRuntime() throws {
        try assertWatchRootsExclude(tokens: ["ratio_deco", "ratiodeco"])
    }

    func testSharedBuhlmannCoreImportsFoundationOnly() throws {
        for file in FullComputerWatchArchitectureGuard.sharedBuhlmannCoreFiles(repoRoot: repoRoot) {
            let source = try String(contentsOf: file, encoding: .utf8).lowercased()
            for forbidden in FullComputerWatchArchitectureGuard.forbiddenSharedCoreImports {
                XCTAssertFalse(
                    source.contains(forbidden),
                    "\(file.lastPathComponent) must not import platform layer: \(forbidden)"
                )
            }
            XCTAssertTrue(source.contains("import foundation"), "\(file.lastPathComponent) must import Foundation")
        }
    }

    func testOnlyExplicitFullComputerRuntimeFilesConsumeSharedCore() throws {
        for file in FullComputerWatchArchitectureGuard.watchSwiftFiles(repoRoot: repoRoot) {
            let source = FullComputerWatchArchitectureGuard.codeWithoutLineComments(
                try String(contentsOf: file, encoding: .utf8)
            )
            let referencesCore = FullComputerWatchArchitectureGuard.strictSharedCoreConsumerTokens.contains { source.contains($0) }
            guard referencesCore else { continue }
            XCTAssertTrue(
                FullComputerWatchArchitectureGuard.approvedSharedCoreConsumerFileNames.contains(file.lastPathComponent),
                "\(file.lastPathComponent) references shared Bühlmann core but is not in the approved allowlist"
            )
        }
    }

    private func assertWatchRootsExclude(tokens: [String]) throws {
        for file in FullComputerWatchArchitectureGuard.watchSwiftFiles(repoRoot: repoRoot) {
            let source = FullComputerWatchArchitectureGuard.codeWithoutLineComments(
                try String(contentsOf: file, encoding: .utf8)
            )
            for token in tokens {
                XCTAssertFalse(
                    source.contains(token),
                    "\(file.lastPathComponent) must not reference forbidden runtime token: \(token)"
                )
            }
        }
    }
}
