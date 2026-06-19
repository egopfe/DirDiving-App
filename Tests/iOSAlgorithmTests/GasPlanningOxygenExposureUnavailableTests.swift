import XCTest

final class GasPlanningOxygenExposureUnavailableTests: XCTestCase {
    func testValidCNSZeroRemainsAvailable() {
        let analysis = TechnicalGasAnalysis(
            gas: GasMix(name: "Air", oxygen: 0.21, helium: 0, maxPPO2: 1.4),
            ppO2AtDepth: 0.21,
            densityAtDepth: 1.2,
            densityRating: .green,
            endMeters: 10,
            eadMeters: 10,
            consumptionLiters: 100,
            remainingLiters: 200,
            remainingBar: 100,
            rockBottomLiters: 50,
            minimumGasBar: 25,
            turnPressureBar: 120,
            cnsPercent: 0,
            cnsDescentBottomPercent: 0,
            cnsDescentBottomAvailable: true,
            otu: 0,
            cnsDailyPercent: 0,
            otuDaily24h: 0,
            otuWeekly: 0,
            airBreakRecoveryApplied: false,
            warnings: [],
            states: [.validReference],
            usesBottomPhaseConsumptionEstimate: false
        )
        XCTAssertTrue(analysis.cnsDescentBottomAvailable)
        XCTAssertEqual(analysis.cnsDescentBottomPercent, 0)
        XCTAssertFalse(analysis.cnsDescentBottomExceedsPlannerThreshold(checkEnabled: true))
    }

    func testUnavailableDescentBottomDoesNotTriggerThreshold() {
        let analysis = TechnicalGasAnalysis(
            gas: GasMix(name: "Air", oxygen: 0.21, helium: 0, maxPPO2: 1.4),
            ppO2AtDepth: 0.21,
            densityAtDepth: 1.2,
            densityRating: .green,
            endMeters: 10,
            eadMeters: 10,
            consumptionLiters: 100,
            remainingLiters: 200,
            remainingBar: 100,
            rockBottomLiters: 50,
            minimumGasBar: 25,
            turnPressureBar: 120,
            cnsPercent: 25,
            cnsDescentBottomPercent: 0,
            cnsDescentBottomAvailable: false,
            otu: 10,
            cnsDailyPercent: 25,
            otuDaily24h: 10,
            otuWeekly: 10,
            airBreakRecoveryApplied: false,
            warnings: [],
            states: [.calculationIncomplete],
            usesBottomPhaseConsumptionEstimate: true
        )
        XCTAssertFalse(analysis.cnsDescentBottomAvailable)
        XCTAssertFalse(analysis.cnsDescentBottomExceedsPlannerThreshold(checkEnabled: true))
        XCTAssertEqual(analysis.cnsDescentBottomPercentDisplay, DIRIOSLocalizer.string("planner.exposure.unavailable"))
    }

    func testPreviewAnalysisMarksUnavailableWhenDescentBottomIntegrationFails() {
        var input = GasPlanInput()
        input.plannedBottomMinutes = 0.001
        input.plannedDepthMeters = 30
        let analysis = GasPlanningService.analyze(input: input, mode: .technical)
        if analysis.cnsDescentBottomAvailable {
            XCTAssertTrue(analysis.cnsDescentBottomPercent.isFinite)
        } else {
            XCTAssertTrue(analysis.states.contains(.calculationIncomplete))
        }
    }
}
