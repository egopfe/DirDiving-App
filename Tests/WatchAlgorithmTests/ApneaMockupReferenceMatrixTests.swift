import XCTest

final class ApneaMockupReferenceMatrixTests: XCTestCase {
    func testMatrixAccountsForAllTwentyThreeMockupFiles() {
        XCTAssertEqual(ApneaMockupReferenceMatrix.count, 23)
        let fileNames = ApneaMockupReferenceMatrix.all.map(\.fileName)
        XCTAssertEqual(Set(fileNames).count, 23, "Duplicate mockup file names in matrix")

        for reference in ApneaMockupReferenceMatrix.all {
            XCTAssertTrue(reference.fileName.hasPrefix("APNEA_"))
            XCTAssertTrue(reference.fileName.hasSuffix(".png"))
        }

        for index in 1...8 {
            let id = String(format: "APNEA_WATCH_%02d", index)
            XCTAssertTrue(
                ApneaMockupReferenceMatrix.all.contains(where: { $0.id == id }),
                "Missing matrix entry for \(id)"
            )
        }
        for index in 1...15 {
            let id = String(format: "APNEA_IOS_%02d", index)
            XCTAssertTrue(
                ApneaMockupReferenceMatrix.all.contains(where: { $0.id == id }),
                "Missing matrix entry for \(id)"
            )
        }
    }

    func testWatchPresentationStagesAreIndexed() {
        let stages = ApneaMockupReferenceMatrix.presentationStagesReferencedByWatchMockups()
        XCTAssertTrue(stages.contains("ready"))
        XCTAssertTrue(stages.contains("dive"))
        XCTAssertTrue(stages.contains("ascent"))
        XCTAssertTrue(stages.contains("surfaceRecovery"))
        XCTAssertTrue(stages.contains("sessionSummary"))
    }

    func testExecutableWatchFixturesHavePresentationStage() {
        for reference in ApneaMockupReferenceMatrix.all where reference.platform == .watch && reference.hasExecutableFixture {
            XCTAssertNotNil(reference.presentationStage, "Missing presentation stage for \(reference.id)")
        }
    }
}
