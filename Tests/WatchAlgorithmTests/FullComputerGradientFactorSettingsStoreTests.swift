import XCTest

@MainActor
final class FullComputerGradientFactorSettingsStoreTests: XCTestCase {
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

    func testSaveAndReloadWatchPreset() {
        let store = FullComputerGradientFactorSettingsStore.shared
        XCTAssertTrue(
            store.updateWatchPreset(
                .conservative2080,
                isDiveActive: false,
                isApneaActive: false,
                isSnorkelingActive: false,
                isFullComputerRuntimeStarted: false,
                hasActiveImportedIOSPlan: false
            )
        )
        XCTAssertEqual(store.selectedWatchPreset, .conservative2080)
        XCTAssertEqual(
            UserDefaults.standard.string(forKey: FullComputerGradientFactorSettingsStore.watchDefaultStorageKey),
            FullComputerGradientFactorPreset.conservative2080.rawValue
        )
    }

    func testInvalidStoredPresetFallsBackToStandard() {
        XCTAssertEqual(FullComputerGradientFactorPreset.load(from: "custom_gf"), .standard3070)
    }

    func testActiveDiveBlocksUpdate() {
        let store = FullComputerGradientFactorSettingsStore.shared
        XCTAssertFalse(
            store.updateWatchPreset(
                .moderate4085,
                isDiveActive: true,
                isApneaActive: false,
                isSnorkelingActive: false,
                isFullComputerRuntimeStarted: false,
                hasActiveImportedIOSPlan: false
            )
        )
        XCTAssertEqual(store.selectedWatchPreset, .standard3070)
    }

    func testFullComputerRuntimeStartedBlocksUpdate() {
        let store = FullComputerGradientFactorSettingsStore.shared
        XCTAssertFalse(
            store.updateWatchPreset(
                .moderate4085,
                isDiveActive: false,
                isApneaActive: false,
                isSnorkelingActive: false,
                isFullComputerRuntimeStarted: true,
                hasActiveImportedIOSPlan: false
            )
        )
    }

    func testIOSPlanActiveBlocksUpdate() {
        let store = FullComputerGradientFactorSettingsStore.shared
        XCTAssertFalse(
            store.updateWatchPreset(
                .moderate4085,
                isDiveActive: false,
                isApneaActive: false,
                isSnorkelingActive: false,
                isFullComputerRuntimeStarted: false,
                hasActiveImportedIOSPlan: true
            )
        )
    }

    func testResolvedUsesWatchSettingsWithoutIOSPlan() {
        let store = FullComputerGradientFactorSettingsStore.shared
        _ = store.updateWatchPreset(
            .conservative2080,
            isDiveActive: false,
            isApneaActive: false,
            isSnorkelingActive: false,
            isFullComputerRuntimeStarted: false,
            hasActiveImportedIOSPlan: false
        )
        let resolved = store.resolvedPreset(
            importedPlanPreset: nil,
            hasActiveImportedIOSPlan: false,
            isDiveActive: false,
            isApneaActive: false,
            isSnorkelingActive: false,
            isFullComputerRuntimeStarted: false
        )
        XCTAssertEqual(resolved.source, .watchSettings)
        XCTAssertEqual(resolved.preset, .conservative2080)
        XCTAssertFalse(resolved.isLocked)
    }

    func testResolvedUsesIOSPlanWhenActive() {
        let store = FullComputerGradientFactorSettingsStore.shared
        let resolved = store.resolvedPreset(
            importedPlanPreset: .conservative2080,
            hasActiveImportedIOSPlan: true,
            isDiveActive: false,
            isApneaActive: false,
            isSnorkelingActive: false,
            isFullComputerRuntimeStarted: false
        )
        XCTAssertEqual(resolved.source, .iosPlan)
        XCTAssertEqual(resolved.preset, .conservative2080)
        XCTAssertTrue(resolved.isLocked)
    }
}
