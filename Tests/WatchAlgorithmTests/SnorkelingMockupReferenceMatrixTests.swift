import XCTest

final class SnorkelingMockupReferenceMatrixTests: XCTestCase {
    func testMatrixAccountsForAllTenMockupFiles() {
        XCTAssertEqual(SnorkelingMockupReferenceMatrix.count, 10)
        let fileNames = SnorkelingMockupReferenceMatrix.all.map(\.fileName)
        XCTAssertEqual(Set(fileNames).count, 10, "Duplicate mockup file names in matrix")

        for reference in SnorkelingMockupReferenceMatrix.all {
            XCTAssertTrue(reference.fileName.hasPrefix("SNORKELING_"))
            XCTAssertTrue(reference.fileName.hasSuffix(".png"))
        }

        for index in 1...7 {
            let id = String(format: "SNORKELING_WATCH_%02d", index)
            XCTAssertTrue(
                SnorkelingMockupReferenceMatrix.all.contains(where: { $0.id == id }),
                "Missing matrix entry for \(id)"
            )
        }
        for index in 1...3 {
            let id = String(format: "SNORKELING_IOS_%02d", index)
            XCTAssertTrue(
                SnorkelingMockupReferenceMatrix.all.contains(where: { $0.id == id }),
                "Missing matrix entry for \(id)"
            )
        }
    }

    func testWatchPresentationStagesAreIndexed() {
        let stages = SnorkelingMockupReferenceMatrix.presentationStagesReferencedByWatchMockups()
        XCTAssertTrue(stages.contains("ready"))
        XCTAssertTrue(stages.contains("surfaceDashboard"))
        XCTAssertTrue(stages.contains("dipInProgress"))
        XCTAssertTrue(stages.contains("navigation"))
        XCTAssertTrue(stages.contains("returnToEntry"))
        XCTAssertTrue(stages.contains("saveMarker"))
        XCTAssertTrue(stages.contains("sessionSummary"))
        XCTAssertEqual(stages, Set(SnorkelingWatchStage.allCases.map(\.rawValue)))
    }

    func testReferencePNGsExistInDocsOnly() {
        let root = repositoryRoot()
        let missing = SnorkelingMockupReferenceMatrix.referencePNGExists(at: root)
        XCTAssertTrue(missing.isEmpty, "Missing reference PNGs: \(missing)")
    }

    func testExecutableWatchFixturesHavePresentationStage() {
        for reference in SnorkelingMockupReferenceMatrix.all where reference.platform == .watch && reference.hasExecutableFixture {
            XCTAssertNotNil(reference.presentationStage, "Missing presentation stage for \(reference.id)")
        }
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
