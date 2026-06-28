import XCTest

@MainActor
final class FullComputerGradientFactorRuntimeResolutionTests: XCTestCase {
    override func setUp() {
        super.setUp()
        FullComputerGradientFactorSettingsStore.shared.resetForTests()
        FullComputerPrediveConfigurationStore.shared.resetForTests()
        FullComputerImportedPlanStore.shared.resetForTests()
    }

    override func tearDown() {
        FullComputerGradientFactorSettingsStore.shared.resetForTests()
        FullComputerPrediveConfigurationStore.shared.resetForTests()
        FullComputerImportedPlanStore.shared.resetForTests()
        super.tearDown()
    }

    func testPrediveConfirmationFreezesSnapshot() {
        let configuration = FullComputerPrediveConfigurationStore.shared
        _ = FullComputerGradientFactorSettingsStore.shared.updateWatchPreset(
            .moderate4085,
            isDiveActive: false,
            isApneaActive: false,
            isSnorkelingActive: false,
            isFullComputerRuntimeStarted: false,
            hasActiveImportedIOSPlan: false
        )
        configuration.applyWatchGradientFactorPresetIfAllowed(.moderate4085)
        let resolved = configuration.resolvedGradientFactorsForRuntime()
        configuration.commitConfirmedProfile(resolvedGradientFactors: resolved)

        XCTAssertEqual(configuration.confirmedGradientFactors?.preset, .moderate4085)
        XCTAssertEqual(configuration.confirmedGradientFactors?.source, .watchSettings)

        _ = FullComputerGradientFactorSettingsStore.shared.updateWatchPreset(
            .conservative2080,
            isDiveActive: false,
            isApneaActive: false,
            isSnorkelingActive: false,
            isFullComputerRuntimeStarted: false,
            hasActiveImportedIOSPlan: false
        )

        XCTAssertEqual(configuration.resolvedGradientFactorsForRuntime().preset, .moderate4085)
        let runtimePlan = configuration.runtimePlan()
        XCTAssertEqual(runtimePlan?.gfLow, 40)
        XCTAssertEqual(runtimePlan?.gfHigh, 85)
    }

    func testRuntimePlanUsesConfirmedSnapshotNotDraftChanges() {
        let configuration = FullComputerPrediveConfigurationStore.shared
        configuration.updateDraft { profile in
            profile.gfLow = 30
            profile.gfHigh = 70
        }
        configuration.commitConfirmedProfile(
            resolvedGradientFactors: .watchSettings(preset: .standard3070)
        )
        configuration.updateDraft { profile in
            profile.gfLow = 40
            profile.gfHigh = 85
        }
        let runtimePlan = configuration.runtimePlan()
        XCTAssertEqual(runtimePlan?.gfLow, 30)
        XCTAssertEqual(runtimePlan?.gfHigh, 70)
    }

    func testImportedPlanPresetMustMatchSupportedValues() throws {
        let package = try makePackage(gfLow: 30, gfHigh: 80)
        XCTAssertFalse(FullComputerImportedPlanStore.shared.importPayload(package, source: "test"))
        XCTAssertEqual(FullComputerImportedPlanStore.shared.lastImportError, .invalidGradientFactors)
    }

    func testImportedPlanWithSupportedPresetAccepted() throws {
        let package = try makePackage(gfLow: 30, gfHigh: 70, preset: .standard3070)
        XCTAssertTrue(FullComputerImportedPlanStore.shared.importPayload(package, source: "test"))
    }

    private func makePackage(
        gfLow: Double,
        gfHigh: Double,
        preset: FullComputerGradientFactorPreset? = nil
    ) throws -> DivePlanPackage {
        let bottom = DivePlanGasPayload(
            name: "Air",
            role: .bottom,
            oxygenFraction: 0.21,
            heliumFraction: 0,
            maxPPO2Bar: 1.4
        )
        let body = DivePlanPackageBody(
            schemaVersion: 1,
            algorithmVersion: DivePlanPackageCodec.algorithmVersion,
            planID: UUID(),
            revision: 1,
            createdAt: Date(),
            expiresAt: nil,
            environment: DivePlanEnvironmentPayload(altitudeMeters: 0, salinityRaw: SalinityMode.salt.rawValue),
            gfLow: gfLow,
            gfHigh: gfHigh,
            gradientFactorPreset: preset?.rawValue,
            gases: [bottom],
            bottomSegments: [],
            plannedSwitches: [],
            plannerSummary: DivePlanSummaryPayload(
                modeLabel: "OC",
                planKind: "single",
                maxDepthMeters: 30,
                bottomMinutes: 20,
                totalRuntimeMinutes: 45,
                requiresDeco: false,
                decoStopCount: 0
            ),
            capabilities: .current
        )
        return try DivePlanPackageCodec.seal(body)
    }
}
