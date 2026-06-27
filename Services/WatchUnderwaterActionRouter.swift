import Foundation

enum WatchUnderwaterPrimaryAction: Equatable, Sendable {
    case acknowledgeAlarm
    case liveStopwatchStart
    case liveStopwatchStop
    case compassSetOrUpdateBearing
    case userImagesNext
    case returnToDashboard
    case unavailable(reasonKey: String)

    var hintLabelKey: String {
        switch self {
        case .acknowledgeAlarm:
            return "watch.hardware.action.ack"
        case .liveStopwatchStart:
            return "watch.hardware.action.start"
        case .liveStopwatchStop:
            return "watch.hardware.action.stop"
        case .compassSetOrUpdateBearing:
            return "watch.hardware.action.set_bearing"
        case .userImagesNext:
            return "watch.hardware.action.next_image"
        case .returnToDashboard:
            return "watch.hardware.action.dashboard"
        case .unavailable:
            return "watch.hardware.action.unavailable"
        }
    }

    var localizedHintLabel: String {
        String(localized: String.LocalizationValue(hintLabelKey))
    }
}

struct WatchUnderwaterActionContext: Equatable, Sendable {
    var selectedPage: AppPage
    var selectedActivity: DIRActivityMode
    var selectedDivingMode: DIRDivingMode
    var isSessionActive: Bool
    var alarmWarningMessage: String?
    var apneaOperationalOverlayPresent: Bool
    var isStopwatchRunning: Bool
    var stopwatchHiddenByFullComputer: Bool
    var bearingDegrees: Double?
    var hasUserImages: Bool
}

enum WatchUnderwaterActionResolver {
    static func resolvedPrimaryAction(context: WatchUnderwaterActionContext) -> WatchUnderwaterPrimaryAction {
        if context.alarmWarningMessage != nil || context.apneaOperationalOverlayPresent {
            return .acknowledgeAlarm
        }

        guard context.isSessionActive else {
            return .unavailable(reasonKey: "watch.hardware.action.unavailable")
        }

        switch context.selectedPage {
        case .live:
            if context.selectedActivity != .diving {
                return .unavailable(reasonKey: "watch.hardware.action.unavailable")
            }
            if context.stopwatchHiddenByFullComputer {
                return .unavailable(reasonKey: "watch.hardware.action.unavailable")
            }
            return context.isStopwatchRunning ? .liveStopwatchStop : .liveStopwatchStart

        case .compass:
            guard context.selectedActivity == .diving else {
                return .unavailable(reasonKey: "watch.hardware.action.unavailable")
            }
            return .compassSetOrUpdateBearing

        case .userImages:
            guard context.selectedActivity == .diving, context.hasUserImages else {
                return .unavailable(reasonKey: "watch.hardware.action.unavailable")
            }
            return .userImagesNext

        case .settings:
            return .returnToDashboard

        default:
            return .returnToDashboard
        }
    }
}

enum WatchUnderwaterActionRouterError: LocalizedError {
    case unavailable

    var errorDescription: String? {
        String(localized: "watch.hardware.toast.unavailable")
    }
}

@MainActor
final class WatchUnderwaterActionRouter: ObservableObject {
    static private(set) weak var shared: WatchUnderwaterActionRouter?

    private let navigation: AppNavigationStore
    private let dive: DiveManager
    private let compass: CompassManager
    private let activitySelection: DIRActivitySelectionStore
    private let apneaRuntime: ApneaWatchRuntimeStore
    private let imageStore: UserImageStore

    init(
        navigation: AppNavigationStore,
        dive: DiveManager,
        compass: CompassManager,
        activitySelection: DIRActivitySelectionStore,
        apneaRuntime: ApneaWatchRuntimeStore,
        imageStore: UserImageStore
    ) {
        self.navigation = navigation
        self.dive = dive
        self.compass = compass
        self.activitySelection = activitySelection
        self.apneaRuntime = apneaRuntime
        self.imageStore = imageStore
        Self.shared = self
    }

    func currentContext() -> WatchUnderwaterActionContext {
        let isSessionActive = dive.isDiveActive
            || apneaRuntime.isSessionActive
            || (SnorkelingWatchRuntimeStore.shared?.isSessionActive ?? false)

        let hidesStopwatch = activitySelection.selectedDivingMode == .fullComputer
            && (dive.fullComputerSnapshot?.decoPresentation.hideManualStopwatch == true)

        return WatchUnderwaterActionContext(
            selectedPage: navigation.selectedPage,
            selectedActivity: activitySelection.selectedActivity,
            selectedDivingMode: activitySelection.selectedDivingMode,
            isSessionActive: isSessionActive,
            alarmWarningMessage: dive.alarmWarningMessage,
            apneaOperationalOverlayPresent: apneaRuntime.operationalOverlay != nil,
            isStopwatchRunning: dive.isStopwatchRunning,
            stopwatchHiddenByFullComputer: hidesStopwatch,
            bearingDegrees: compass.bearingDegrees,
            hasUserImages: !imageStore.imageNames.isEmpty
        )
    }

    func resolvedPrimaryAction() -> WatchUnderwaterPrimaryAction {
        WatchUnderwaterActionResolver.resolvedPrimaryAction(context: currentContext())
    }

    func executePrimaryAction() throws {
        let action = resolvedPrimaryAction()
        switch action {
        case .acknowledgeAlarm:
            if dive.alarmWarningMessage != nil {
                dive.dismissAlarmWarning()
            } else if let overlay = apneaRuntime.operationalOverlay {
                apneaRuntime.dismissOperationalOverlay(eventID: overlay.eventID)
            }
            navigation.reportHardwareActionToast(String(localized: "watch.hardware.toast.ack"))
            HapticService.shared.confirm()

        case .liveStopwatchStart:
            dive.startStopwatch()
            navigation.reportHardwareActionToast(String(localized: "watch.hardware.toast.stopwatch_started"))
            HapticService.shared.confirm()

        case .liveStopwatchStop:
            dive.stopStopwatch()
            navigation.reportHardwareActionToast(String(localized: "watch.hardware.toast.stopwatch_stopped"))
            HapticService.shared.confirm()

        case .compassSetOrUpdateBearing:
            compass.setBearing()
            navigation.reportHardwareActionToast(String(localized: "watch.hardware.toast.bearing_set"))
            HapticService.shared.confirm()

        case .userImagesNext:
            guard imageStore.advanceToNextImageForWatchRuntime() else {
                navigation.reportHardwareActionToast(String(localized: "watch.hardware.toast.unavailable"))
                HapticService.shared.warnIfNeeded()
                throw WatchUnderwaterActionRouterError.unavailable
            }
            navigation.reportHardwareActionToast(String(localized: "watch.hardware.action.next_image"))
            HapticService.shared.confirm()

        case .returnToDashboard:
            navigation.selectedPage = .live
            navigation.reportHardwareActionToast(String(localized: "watch.hardware.toast.dashboard"))
            HapticService.shared.confirm()

        case .unavailable:
            navigation.reportHardwareActionToast(String(localized: "watch.hardware.toast.unavailable"))
            HapticService.shared.warnIfNeeded()
            throw WatchUnderwaterActionRouterError.unavailable
        }
    }
}
