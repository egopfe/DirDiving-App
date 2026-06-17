import XCTest

final class FullComputerUIStateMatrixTests: XCTestCase {
    func testVisualRegressionMatrixHasTwentyStates() {
        XCTAssertEqual(FullComputerLivePanelFixtures.visualRegressionStateNames.count, 20)
    }

    func testPresentationFixturesExposeLocalizedTitleKeys() {
        for (name, presentation) in FullComputerLivePanelFixtures.localizedPresentationFixtures {
            if !presentation.stopPanelTitleKey.isEmpty {
                let localized = String(localized: String.LocalizationValue(presentation.stopPanelTitleKey))
                XCTAssertFalse(localized.isEmpty, "Missing title localization for \(name)")
                XCTAssertFalse(localized.hasPrefix("live.fc."), "Untranslated title for \(name)")
            }
            if let instructionKey = presentation.stopInstructionKey {
                let localized = String(localized: String.LocalizationValue(instructionKey))
                XCTAssertFalse(localized.isEmpty, "Missing instruction localization for \(name)")
                XCTAssertFalse(localized.hasPrefix("live.fc."), "Untranslated instruction for \(name)")
            }
        }
    }

    func testNDLAccentThresholdsMatchCommandEleven() {
        XCTAssertEqual(FullComputerDecoSolver.ndlAccent(for: 11), .green)
        XCTAssertEqual(FullComputerDecoSolver.ndlAccent(for: 10), .yellow)
        XCTAssertEqual(FullComputerDecoSolver.ndlAccent(for: 5), .red)
        XCTAssertEqual(FullComputerDecoSolver.ndlAccent(for: 4), .red)
    }

    func testTooShallowAndTooDeepUseDistinctTitles() {
        var tracker = FullComputerDecoStopTracker(
            engagedStopDepthMeters: 6.0,
            lastModelRemainingMinutes: 2,
            progressInvalidated: false,
            previousState: .holdingStop
        )
        let shallow = FullComputerDecoStopStateMachine.evaluate(
            input: machineInput(depth: 4.0, remainingMinutes: 2, remainingStops: 2, ceilingViolation: false),
            tracker: tracker
        )
        XCTAssertEqual(shallow.state, .tooShallow)
        XCTAssertEqual(shallow.titleKey, "live.fc.deco.too_shallow.title")

        let deep = FullComputerDecoStopStateMachine.evaluate(
            input: machineInput(depth: 8.0, remainingMinutes: 2, remainingStops: 2, ceilingViolation: false),
            tracker: tracker
        )
        XCTAssertEqual(deep.state, .tooDeep)
        XCTAssertEqual(deep.titleKey, "live.fc.deco.too_deep.title")
    }

    func testPrediveReadinessBlocksUnavailableSensor() {
        let readiness = FullComputerPrediveReadiness.evaluate(
            depthAutomationAvailable: false,
            validationIssues: []
        )
        XCTAssertEqual(readiness, .sensorUnavailable)
        XCTAssertNotNil(readiness.errorMessage)
    }

    func testItalianBundleContainsNewFCUIKeys() throws {
        let bundle = try XCTUnwrap(Bundle(path: Bundle.main.path(forResource: "it", ofType: "lproj") ?? ""))
        let keys = [
            "live.fc.deco.too_shallow.title",
            "live.fc.gas_switch.verify_cylinder",
            "live.unit.min",
            "watch.full_computer.recovery_active.a11y",
        ]
        for key in keys {
            let value = bundle.localizedString(forKey: key, value: nil, table: nil)
            XCTAssertNotEqual(value, key, "Missing Italian localization for \(key)")
        }
    }

    func testEnglishBundleContainsNewFCUIKeys() throws {
        let bundle = try XCTUnwrap(Bundle(path: Bundle.main.path(forResource: "en", ofType: "lproj") ?? ""))
        let keys = [
            "live.fc.deco.too_deep.title",
            "live.fc.gas_switch.ignore.a11y",
            "live.unit.m",
            "startup.diving_mode.full_computer.a11y",
        ]
        for key in keys {
            let value = bundle.localizedString(forKey: key, value: nil, table: nil)
            XCTAssertNotEqual(value, key, "Missing English localization for \(key)")
        }
    }

    private func machineInput(
        depth: Double,
        remainingMinutes: Int,
        remainingStops: Int,
        ceilingViolation: Bool
    ) -> FullComputerDecoStopMachineInput {
        FullComputerDecoStopMachineInput(
            depthMeters: depth,
            stopDepthMeters: 6.0,
            modelRemainingMinutes: remainingMinutes,
            remainingStopCount: remainingStops,
            ceilingViolation: ceilingViolation,
            ceilingMetersExact: 6.0,
            decoRequired: true,
            deltaSeconds: 1
        )
    }
}
