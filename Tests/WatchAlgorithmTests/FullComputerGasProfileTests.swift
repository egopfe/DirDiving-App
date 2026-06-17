import XCTest

final class FullComputerGasProfileTests: XCTestCase {
    func testAirProfileValidates() {
        let profile = FullComputerGasProfile.defaultAirGF3070
        XCTAssertTrue(FullComputerGasProfileValidator.isValid(profile))
        XCTAssertEqual(profile.bottomGas.nitrogenFraction, 0.79, accuracy: 0.01)
    }

    func testEANProfileAndRuntimePlan() {
        var profile = FullComputerGasProfile.defaultAirGF3070
        profile.applyBottomGasKind(.ean)
        profile.bottomGas.oxygenFraction = 0.32
        profile.bottomGas.name = "EAN32"
        XCTAssertTrue(FullComputerGasProfileValidator.isValid(profile))
        let plan = FullComputerRuntimePlan(profile: profile)
        XCTAssertEqual(plan.activeGas.name, "EAN32")
        XCTAssertEqual(Int((plan.activeGas.oxygenFraction * 100).rounded()), 32)
    }

    func testTrimixFractionConstraint() {
        var profile = FullComputerGasProfile.defaultAirGF3070
        profile.applyBottomGasKind(.trimix)
        profile.bottomGas.oxygenFraction = 0.18
        profile.bottomGas.heliumFraction = 0.45
        XCTAssertTrue(FullComputerGasProfileValidator.isValid(profile))
        profile.bottomGas.heliumFraction = 0.90
        XCTAssertFalse(FullComputerGasProfileValidator.isValid(profile))
    }

    func testMultipleDecoGasesOrderedBySwitchDepth() {
        var profile = FullComputerGasProfile.defaultAirGF3070
        var o2 = FullComputerConfiguredGas.oxygen(at: 6)
        o2.maxPPO2Bar = 2.0
        profile.decoGases = [
            .ean50(at: 21),
            o2
        ]
        profile.normalizeSortOrders()
        let enabled = profile.enabledDecoGases
        XCTAssertEqual(enabled.map(\.name), ["EAN50", "O2"])
        XCTAssertTrue(FullComputerGasProfileValidator.isValid(profile))
        let plan = FullComputerRuntimePlan(profile: profile)
        XCTAssertEqual(plan.decoGases.count, 2)
        XCTAssertEqual(plan.decoGases.first?.name, "EAN50")
    }

    func testHypoxicDecoGasRejected() {
        var profile = FullComputerGasProfile.defaultAirGF3070
        profile.decoGases = [
            FullComputerConfiguredGas(
                name: "Hypoxic",
                role: .deco,
                oxygenFraction: 0.10,
                heliumFraction: 0,
                maxPPO2Bar: 1.4,
                switchDepthMeters: 3
            )
        ]
        let issues = FullComputerGasProfileValidator.validate(profile)
        XCTAssertTrue(issues.contains(where: {
            if case .hypoxic = $0 { return true }
            return false
        }))
    }

    func testSerializationRoundTrip() throws {
        var profile = FullComputerGasProfile.defaultAirGF3070
        profile.decoGases = [.ean50(at: 21), .oxygen(at: 6)]
        let data = try JSONEncoder().encode(profile)
        let decoded = try JSONDecoder().decode(FullComputerGasProfile.self, from: data)
        XCTAssertEqual(decoded, profile)
    }

    @MainActor
    func testConfigurationStoreBlocksEditWhenDiveActive() {
        #if DEBUG
        FullComputerPrediveConfigurationStore.shared.resetForTests()
        #endif
        let logStore = DiveLogStore()
        let dive = DiveManager(logStore: logStore, gpsManager: GPSManager(), ascentSettings: AscentRateSettingsStore())
        let store = FullComputerPrediveConfigurationStore.shared
        let before = store.draftProfile.bottomGas.oxygenFraction
        dive.isDiveActive = true
        store.setBottomGasKind(.ean)
        XCTAssertEqual(store.draftProfile.bottomGas.oxygenFraction, before)
        dive.isDiveActive = false
    }

    func testFutureGasTTSPolicyActiveGasOnly() {
        var profile = FullComputerGasProfile.defaultAirGF3070
        profile.decoGases = [.ean50(at: 21)]
        profile.futureGasTTSPolicy = .activeGasOnly
        let plan = FullComputerRuntimePlan(profile: profile)
        XCTAssertTrue(plan.decoGases.isEmpty)
    }
}
