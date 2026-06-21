import XCTest

final class MockupAntiEmbeddingTests: XCTestCase {
    func testProjectYmlDoesNotBundleMockups() throws {
        let source = try String(
            contentsOf: repositoryRoot().appendingPathComponent("project.yml"),
            encoding: .utf8
        )
        XCTAssertFalse(source.contains("mockups/"), "mockups/ must not appear in project.yml resource bundles")
    }

    func testProductionSwiftSourcesDoNotEmbedRasterMockups() throws {
        let roots = MockupVisualRegressionSoftwareGatePolicy.productionSourceScanRoots
        for rootPath in roots {
            let url = repositoryRoot().appendingPathComponent(rootPath)
            guard FileManager.default.fileExists(atPath: url.path) else { continue }
            try scanDirectory(url, relativeRoot: rootPath)
        }
    }

    func testMockupsReadmeStatesLocalCanonicalAssets() throws {
        let readme = try String(
            contentsOf: repositoryRoot().appendingPathComponent("mockups/README.md"),
            encoding: .utf8
        )
        XCTAssertTrue(readme.contains("59"))
        XCTAssertTrue(readme.localizedCaseInsensitiveContains("design references only"))
        XCTAssertFalse(readme.contains("maintained outside this repository"))
    }

    private func scanDirectory(_ url: URL, relativeRoot: String) throws {
        let resourceKeys: [URLResourceKey] = [.isRegularFileKey, .isDirectoryKey]
        let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: resourceKeys
        )
        while let item = enumerator?.nextObject() as? URL {
            let values = try item.resourceValues(forKeys: Set(resourceKeys))
            if values.isDirectory == true {
                continue
            }
            guard item.pathExtension == "swift" else { continue }
            let relative = item.path.replacingOccurrences(of: repositoryRoot().path + "/", with: "")
            if MockupVisualRegressionSoftwareGatePolicy.mockupReferenceAllowlistPathFragments.contains(where: { relative.contains($0) }) {
                continue
            }
            let source = try String(contentsOf: item, encoding: .utf8)
            for pattern in MockupVisualRegressionSoftwareGatePolicy.mockupEmbeddingForbiddenPatterns {
                XCTAssertFalse(
                    source.contains(pattern),
                    "Forbidden mockup embedding '\(pattern)' in \(relative)"
                )
            }
        }
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
