import Foundation

/// Visual-only banner priority for active live dive — does not alter warning logic or thresholds.
enum LiveDiveBannerPresentationPolicy {
    struct Input: Equatable {
        var showAscentAlarmBanner: Bool
        var depthSafetyState: DepthSafetyState
        var exceededSupportedDepthRange: Bool
        var isDepthDataStale: Bool
        var isManualNoDepthSession: Bool
        var hapticsEnabled: Bool
        var isDepthAutomationMockFallbackActive: Bool
        var isSimulationDepthActive: Bool
        var showsAutoDiveHint: Bool
        var showsManualHandoffNote: Bool
    }

    struct Output: Equatable {
        var showAscentBanner: Bool
        var showDepthSafetyBanner: Bool
        var showSensorBanner: Bool
        var showExceededSupplementalText: Bool
        var compactSecondaryNotices: Bool
        var secondaryNoticeTitles: [String]
        var showsAutoDiveHint: Bool
        var showsManualHandoffNote: Bool
    }

    static func evaluate(_ input: Input) -> Output {
        let hasCriticalSafety = input.showAscentAlarmBanner || input.depthSafetyState != .normal
        var secondaryTitles: [String] = []
        if !input.hapticsEnabled {
            secondaryTitles.append(String(localized: "live.haptics.off"))
        }
        if input.isDepthAutomationMockFallbackActive {
            secondaryTitles.append(String(localized: "watch.depth_source.mock_fallback"))
        } else if input.isSimulationDepthActive {
            secondaryTitles.append(String(localized: "watch.depth_source.simulation_active"))
        }
        if input.showsAutoDiveHint {
            secondaryTitles.append(String(localized: "live.auto_dive.active.hint"))
        }
        if input.showsManualHandoffNote {
            secondaryTitles.append(String(localized: "live.manual_lifecycle.handoff.note"))
        }
        if input.isDepthDataStale {
            secondaryTitles.append(String(localized: "live.depth.stale.title"))
        } else if input.isManualNoDepthSession {
            secondaryTitles.append(String(localized: "live.manual.nodepth.title"))
        }

        let compactSecondary = hasCriticalSafety && secondaryTitles.count >= 2
        return Output(
            showAscentBanner: input.showAscentAlarmBanner,
            showDepthSafetyBanner: input.depthSafetyState != .normal,
            showSensorBanner: !compactSecondary && (input.isDepthDataStale || input.isManualNoDepthSession),
            showExceededSupplementalText: input.exceededSupportedDepthRange && input.depthSafetyState != .exceeded,
            compactSecondaryNotices: compactSecondary,
            secondaryNoticeTitles: secondaryTitles,
            showsAutoDiveHint: !compactSecondary && input.showsAutoDiveHint,
            showsManualHandoffNote: !compactSecondary && input.showsManualHandoffNote
        )
    }
}
