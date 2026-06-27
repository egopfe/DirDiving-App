import Foundation
import Combine

@MainActor
final class FullComputerGradientFactorSettingsStore: ObservableObject {
    static let shared = FullComputerGradientFactorSettingsStore()

    static let watchDefaultStorageKey = "dirdiving.fullComputer.gradientFactorPreset.watchDefault"

    @Published private(set) var selectedWatchPreset: FullComputerGradientFactorPreset

    private init() {
        selectedWatchPreset = Self.loadWatchPreset()
    }

    func updateWatchPreset(
        _ preset: FullComputerGradientFactorPreset,
        isDiveActive: Bool,
        isApneaActive: Bool,
        isSnorkelingActive: Bool,
        isFullComputerRuntimeStarted: Bool,
        hasActiveImportedIOSPlan: Bool
    ) -> Bool {
        guard !isModificationBlocked(
            isDiveActive: isDiveActive,
            isApneaActive: isApneaActive,
            isSnorkelingActive: isSnorkelingActive,
            isFullComputerRuntimeStarted: isFullComputerRuntimeStarted,
            hasActiveImportedIOSPlan: hasActiveImportedIOSPlan
        ) else {
            return false
        }
        guard selectedWatchPreset != preset else { return true }
        selectedWatchPreset = preset
        persistWatchPreset(preset)
        FullComputerPrediveConfigurationStore.shared.applyWatchGradientFactorPresetIfAllowed(preset)
        return true
    }

    func resolvedPreset(
        importedPlanPreset: FullComputerGradientFactorPreset?,
        hasActiveImportedIOSPlan: Bool,
        isDiveActive: Bool,
        isApneaActive: Bool,
        isSnorkelingActive: Bool,
        isFullComputerRuntimeStarted: Bool,
        confirmedSnapshot: FullComputerResolvedGradientFactors? = nil
    ) -> FullComputerResolvedGradientFactors {
        if let confirmedSnapshot {
            return confirmedSnapshot
        }

        let sessionLocked = FullComputerGradientFactorLockContext.isAnySessionActive(
            isDiveActive: isDiveActive,
            isApneaActive: isApneaActive,
            isSnorkelingActive: isSnorkelingActive
        )

        if sessionLocked {
            let preset = importedPlanPreset ?? selectedWatchPreset
            let source: FullComputerGradientFactorSource = hasActiveImportedIOSPlan ? .iosPlan : .watchSettings
            return .lockedSnapshot(preset: preset, source: source, reason: .activeDive)
        }

        if isFullComputerRuntimeStarted {
            let preset = importedPlanPreset ?? selectedWatchPreset
            let source: FullComputerGradientFactorSource = hasActiveImportedIOSPlan ? .iosPlan : .watchSettings
            return .lockedSnapshot(preset: preset, source: source, reason: .fullComputerRuntimeStarted)
        }

        if hasActiveImportedIOSPlan, let importedPlanPreset {
            return .iosPlan(preset: importedPlanPreset)
        }

        return .watchSettings(preset: selectedWatchPreset)
    }

    func isModificationBlocked(
        isDiveActive: Bool,
        isApneaActive: Bool,
        isSnorkelingActive: Bool,
        isFullComputerRuntimeStarted: Bool,
        hasActiveImportedIOSPlan: Bool
    ) -> Bool {
        if FullComputerGradientFactorLockContext.isAnySessionActive(
            isDiveActive: isDiveActive,
            isApneaActive: isApneaActive,
            isSnorkelingActive: isSnorkelingActive
        ) {
            return true
        }
        if isFullComputerRuntimeStarted { return true }
        if hasActiveImportedIOSPlan { return true }
        return false
    }

    func lockReason(
        isDiveActive: Bool,
        isApneaActive: Bool,
        isSnorkelingActive: Bool,
        isFullComputerRuntimeStarted: Bool,
        hasActiveImportedIOSPlan: Bool
    ) -> FullComputerGradientFactorLockReason? {
        if FullComputerGradientFactorLockContext.isAnySessionActive(
            isDiveActive: isDiveActive,
            isApneaActive: isApneaActive,
            isSnorkelingActive: isSnorkelingActive
        ) {
            return .activeDive
        }
        if isFullComputerRuntimeStarted { return .fullComputerRuntimeStarted }
        if hasActiveImportedIOSPlan { return .importedIOSPlan }
        return nil
    }

    func syncDraftProfileFromWatchSettingsIfAllowed(
        configuration: FullComputerPrediveConfigurationStore? = nil,
        importedPlanStore: FullComputerImportedPlanStore? = nil,
        isDiveActive: Bool,
        isApneaActive: Bool,
        isSnorkelingActive: Bool,
        isFullComputerRuntimeStarted: Bool
    ) {
        let planStore = importedPlanStore ?? FullComputerImportedPlanStore.shared
        guard planStore.activatedPlanID == nil else { return }
        guard !isModificationBlocked(
            isDiveActive: isDiveActive,
            isApneaActive: isApneaActive,
            isSnorkelingActive: isSnorkelingActive,
            isFullComputerRuntimeStarted: isFullComputerRuntimeStarted,
            hasActiveImportedIOSPlan: false
        ) else {
            return
        }
        (configuration ?? FullComputerPrediveConfigurationStore.shared)
            .applyWatchGradientFactorPresetIfAllowed(selectedWatchPreset)
    }

    #if DEBUG
    func resetForTests() {
        selectedWatchPreset = .watchDefault
        UserDefaults.standard.removeObject(forKey: Self.watchDefaultStorageKey)
    }
    #endif

    private static func loadWatchPreset() -> FullComputerGradientFactorPreset {
        FullComputerGradientFactorPreset.load(from: UserDefaults.standard.string(forKey: watchDefaultStorageKey))
    }

    private func persistWatchPreset(_ preset: FullComputerGradientFactorPreset) {
        UserDefaults.standard.set(preset.rawValue, forKey: Self.watchDefaultStorageKey)
    }
}
