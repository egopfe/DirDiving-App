import Foundation
import Combine

@MainActor
final class DIRActivitySelectionStore: ObservableObject {
    static private(set) weak var shared: DIRActivitySelectionStore?

    @Published private(set) var selection = DIRActivitySelectionState.gaugeDefault
    @Published private(set) var startupStep: DIRStartupLaunchStep?
    @Published private(set) var sessionConfigured = false
    @Published var modeChangeBlockedToast: String?

    private var toastTask: Task<Void, Never>?

    init() {
        Self.shared = self
    }

    var isStartupFlowActive: Bool { startupStep != nil }

    var selectedActivity: DIRActivityMode { selection.activity }
    var selectedDivingMode: DIRDivingMode { selection.divingMode }

    func beginColdLaunch() {
        sessionConfigured = false
        selection = DIRActivitySelectionState(
            activity: DIRStartupSelectionPolicy.defaultActivityMode,
            divingMode: DIRStartupSelectionPolicy.defaultDivingMode,
            fullComputerPrediveConfirmed: false
        )
        applyLaunchStep(DIRStartupSelectionPolicy.resolveLaunchStep())
    }

    /// Routes startup for the given launch entry. Normal cold launch never applies water auto-open routing.
    func beginInitialLaunch(entry: WatchLaunchEntryPoint = .userColdLaunch) {
        sessionConfigured = false
        if entry == .userColdLaunch {
            selection = DIRActivitySelectionState(
                activity: DIRStartupSelectionPolicy.defaultActivityMode,
                divingMode: DIRStartupSelectionPolicy.defaultDivingMode,
                fullComputerPrediveConfirmed: false
            )
        } else if WatchWaterAutoOpenPolicy.mode != .disabled {
            selection.fullComputerPrediveConfirmed = false
            let destination = WatchWaterAutoOpenPolicy.activeDestination()
            selection.activity = destination.activity
            selection.divingMode = destination.divingMode
        } else {
            selection = DIRActivitySelectionState(
                activity: DIRStartupSelectionPolicy.defaultActivityMode,
                divingMode: DIRStartupSelectionPolicy.defaultDivingMode,
                fullComputerPrediveConfirmed: false
            )
        }
        applyLaunchStep(WatchLaunchRoutingPolicy.resolvedStartupStep(for: entry))
    }

    /// Applies water-entry startup routing without starting a session or bypassing Full Computer predive.
    func beginWaterAutoLaunch() {
        guard canChangeModes else {
            presentModeChangeBlocked()
            return
        }
        beginInitialLaunch(entry: .waterAutoLaunchIntent)
    }

    func selectActivity(_ activity: DIRActivityMode) {
        guard canChangeModes else {
            presentModeChangeBlocked()
            return
        }
        selection.activity = activity
        selection.fullComputerPrediveConfirmed = false
        applyLaunchStep(DIRStartupSelectionPolicy.nextStepAfterActivitySelection(activity))
    }

    func selectDivingMode(_ mode: DIRDivingMode) {
        guard canChangeModes else {
            presentModeChangeBlocked()
            return
        }
        let policy = DepthCapabilityPolicy.current
        if mode == .fullComputer, !policy.supportsFullComputerRuntime {
            modeChangeBlockedToast = policy.fullComputerDisabledReason
            scheduleToastClear()
            return
        }
        if mode == .gauge, !policy.supportsDivingGaugeRuntime {
            modeChangeBlockedToast = policy.gaugeDisabledReason
            scheduleToastClear()
            return
        }
        selection.divingMode = mode
        selection.fullComputerPrediveConfirmed = false
        applyLaunchStep(
            DIRStartupSelectionPolicy.nextStepAfterDivingModeSelection(
                activity: selection.activity,
                divingMode: mode
            )
        )
    }

    func confirmFullComputerPredive() {
        guard selection.divingMode == .fullComputer else { return }
        FullComputerPrediveConfigurationStore.shared.commitConfirmedProfile()
        selection.fullComputerPrediveConfirmed = true
        completeStartup(activity: selection.activity, divingMode: .fullComputer)
    }

    func proceedToFullComputerConfirmation() {
        guard selection.divingMode == .fullComputer else { return }
        guard FullComputerPrediveConfigurationStore.shared.isDraftValid else { return }
        startupStep = .fullComputerConfirmation
    }

    func cancelFullComputerPredive() {
        selection.fullComputerPrediveConfirmed = false
        startupStep = .fullComputerPrediveConfiguration
    }

    func cancelFullComputerPrediveToModeSelection() {
        selection.fullComputerPrediveConfirmed = false
        startupStep = .divingModeSelection(activity: .diving)
    }

    func dismissComingSoon() {
        startupStep = .activitySelection
    }

    func reopenStartupFlowFromSettings() {
        guard canChangeModes else {
            presentModeChangeBlocked()
            return
        }
        sessionConfigured = false
        selection.fullComputerPrediveConfirmed = false
        startupStep = .activitySelection
    }

    var canChangeModes: Bool {
        if let apnea = ApneaWatchRuntimeStore.shared, apnea.isSessionActive {
            return false
        }
        if let snorkeling = SnorkelingWatchRuntimeStore.shared, snorkeling.isSessionActive {
            return false
        }
        guard let dive = DiveManager.shared else { return true }
        return !dive.isDiveActive
    }

    func presentModeChangeBlocked() {
        modeChangeBlockedToast = String(localized: "startup.mode_change.blocked")
        scheduleToastClear()
    }

    private func scheduleToastClear() {
        toastTask?.cancel()
        toastTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_200_000_000)
            if !Task.isCancelled {
                modeChangeBlockedToast = nil
            }
        }
    }

    private func applyLaunchStep(_ step: DIRStartupLaunchStep) {
        switch step {
        case .ready(let activity, let divingMode):
            completeStartup(activity: activity, divingMode: divingMode)
        default:
            startupStep = step
        }
    }

    private func completeStartup(activity: DIRActivityMode, divingMode: DIRDivingMode) {
        selection.activity = activity
        selection.divingMode = divingMode
        if divingMode == .fullComputer, !selection.fullComputerPrediveConfirmed {
            startupStep = .fullComputerConfirmation
            return
        }
        startupStep = nil
        sessionConfigured = true
        WatchWaterAutoOpenPolicy.recordSelectedDestination(
            activity: activity,
            divingMode: divingMode
        )
        DiveManager.shared?.recordSessionModeSelection(
            activity: activity,
            divingMode: divingMode
        )
    }
}
