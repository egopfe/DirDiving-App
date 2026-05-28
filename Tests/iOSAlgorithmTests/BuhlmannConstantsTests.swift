import XCTest

final class BuhlmannConstantsTests: XCTestCase {
    func testZHL16CConstantsHaveSixteenCompartmentsForNitrogenAndHelium() {
        XCTAssertEqual(BuhlmannConstants.compartmentCount, 16)
        XCTAssertEqual(BuhlmannConstants.halfTimesN2.count, 16)
        XCTAssertEqual(BuhlmannConstants.halfTimesHe.count, 16)
        XCTAssertEqual(BuhlmannConstants.aN2.count, 16)
        XCTAssertEqual(BuhlmannConstants.bN2.count, 16)
        XCTAssertEqual(BuhlmannConstants.aHe.count, 16)
        XCTAssertEqual(BuhlmannConstants.bHe.count, 16)
    }

    func testZHL16CReferenceConstantsUseExpectedBoundaryValues() {
        XCTAssertEqual(BuhlmannConstants.halfTimesN2.first ?? 0, 5.0, accuracy: 0.0001)
        XCTAssertEqual(BuhlmannConstants.halfTimesN2.last ?? 0, 635.0, accuracy: 0.0001)
        XCTAssertEqual(BuhlmannConstants.halfTimesHe.first ?? 0, 1.88, accuracy: 0.0001)
        XCTAssertEqual(BuhlmannConstants.halfTimesHe.last ?? 0, 240.03, accuracy: 0.0001)
        XCTAssertEqual(BuhlmannConstants.aN2.first ?? 0, 1.1696, accuracy: 0.0001)
        XCTAssertEqual(BuhlmannConstants.bHe.last ?? 0, 0.9267, accuracy: 0.0001)
    }

    func testMixedGasCoefficientsStayBetweenNitrogenAndHeliumCoefficients() {
        let a = BuhlmannConstants.coefficientA(index: 0, pn2: 0.5, phe: 0.5)
        let b = BuhlmannConstants.coefficientB(index: 0, pn2: 0.5, phe: 0.5)
        XCTAssertGreaterThan(a, min(BuhlmannConstants.aN2[0], BuhlmannConstants.aHe[0]))
        XCTAssertLessThan(a, max(BuhlmannConstants.aN2[0], BuhlmannConstants.aHe[0]))
        XCTAssertGreaterThan(b, min(BuhlmannConstants.bN2[0], BuhlmannConstants.bHe[0]))
        XCTAssertLessThan(b, max(BuhlmannConstants.bN2[0], BuhlmannConstants.bHe[0]))
    }
}

