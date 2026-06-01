import XCTest

final class DiveDepthMeasurementIngestionTests: XCTestCase {
    func testSkipsSecondAddSampleWhenStartBranchAlreadyStored() {
        XCTAssertFalse(
            DiveDepthMeasurementIngestion.shouldInvokeAddSampleAfterPreDiveBranch(sampleAddedInPreDiveBranch: true)
        )
    }

    func testInvokesAddSampleWhenStartBranchDidNotStore() {
        XCTAssertTrue(
            DiveDepthMeasurementIngestion.shouldInvokeAddSampleAfterPreDiveBranch(sampleAddedInPreDiveBranch: false)
        )
    }
}
