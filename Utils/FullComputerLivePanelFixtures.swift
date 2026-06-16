import Foundation

/// Deterministic Full Computer live UI fixtures for previews and state-matrix tests (Command 11).
enum FullComputerLivePanelFixtures {
    static func ndlGreen(runtimeMinutes: Int = 28) -> FullComputerDecoPresentation {
        baseNoDeco(ndlMinutes: 38, ndlAccent: .green, runtimeMinutes: runtimeMinutes)
    }

    static func ndlYellow(runtimeMinutes: Int = 28) -> FullComputerDecoPresentation {
        baseNoDeco(ndlMinutes: 10, ndlAccent: .yellow, runtimeMinutes: runtimeMinutes)
    }

    static func ndlRed(runtimeMinutes: Int = 28) -> FullComputerDecoPresentation {
        baseNoDeco(ndlMinutes: 5, ndlAccent: .red, runtimeMinutes: runtimeMinutes)
    }

    static func decoApproaching() -> FullComputerDecoPresentation {
        baseDeco(
            stopState: .approachingStop,
            stopDirection: .ascend,
            stopPanelAccent: .yellow,
            titleKey: "live.fc.deco.approach.title",
            instructionKey: "live.fc.deco.instruction.ascend_to_stop",
            nextStopDepthMeters: 6.0,
            stopRemainingSeconds: 120,
            remainingStopCount: 2,
            ascentAllowedBetweenStops: false
        )
    }

    static func holdingStop() -> FullComputerDecoPresentation {
        baseDeco(
            stopState: .holdingStop,
            stopDirection: .hold,
            stopPanelAccent: .green,
            titleKey: "live.fc.deco.hold.title",
            instructionKey: "live.fc.deco.instruction.maintain_depth",
            nextStopDepthMeters: 6.0,
            stopRemainingSeconds: 119,
            remainingStopCount: 2,
            ascentAllowedBetweenStops: false,
            timerAccruing: true
        )
    }

    static func tooShallow() -> FullComputerDecoPresentation {
        baseDeco(
            stopState: .tooShallow,
            stopDirection: .descend,
            stopPanelAccent: .yellow,
            titleKey: "live.fc.deco.too_shallow.title",
            instructionKey: "live.fc.deco.instruction.descend_to_stop",
            nextStopDepthMeters: 6.0,
            stopRemainingSeconds: 119,
            remainingStopCount: 2,
            ascentAllowedBetweenStops: false
        )
    }

    static func tooDeep() -> FullComputerDecoPresentation {
        baseDeco(
            stopState: .tooDeep,
            stopDirection: .ascend,
            stopPanelAccent: .yellow,
            titleKey: "live.fc.deco.too_deep.title",
            instructionKey: "live.fc.deco.instruction.ascend_to_stop",
            nextStopDepthMeters: 6.0,
            stopRemainingSeconds: 119,
            remainingStopCount: 2,
            ascentAllowedBetweenStops: false
        )
    }

    static func ceilingViolation() -> FullComputerDecoPresentation {
        baseDeco(
            stopState: .ceilingViolation,
            stopDirection: .descend,
            stopPanelAccent: .red,
            titleKey: "live.fc.deco.hold.title",
            instructionKey: "live.fc.deco.instruction.ceiling_violation",
            nextStopDepthMeters: 6.0,
            stopRemainingSeconds: 120,
            remainingStopCount: 2,
            ascentAllowedBetweenStops: false,
            ceilingViolation: true
        )
    }

    static func decoCompleted() -> FullComputerDecoPresentation {
        baseDeco(
            stopState: .decoCompleted,
            stopDirection: .none,
            stopPanelAccent: .green,
            titleKey: "live.fc.deco.completed.title",
            instructionKey: "live.fc.deco.completed.instruction",
            nextStopDepthMeters: nil,
            stopRemainingSeconds: nil,
            remainingStopCount: 0,
            ascentAllowedBetweenStops: true,
            ceilingMetersExact: 0
        )
    }

    static func sensorDegraded() -> FullComputerDecoPresentation {
        var presentation = ndlGreen()
        return FullComputerDecoPresentation(
            mode: presentation.mode,
            immersionAccent: presentation.immersionAccent,
            immersionStatusKey: "live.depth.automation.unavailable.title",
            ndlDisplayMinutes: presentation.ndlDisplayMinutes,
            ndlAccent: presentation.ndlAccent,
            ttsMinutes: presentation.ttsMinutes,
            runtimeMinutes: presentation.runtimeMinutes,
            ceilingMetersExact: presentation.ceilingMetersExact,
            ceilingMetersRounded: presentation.ceilingMetersRounded,
            nextStopDepthMeters: presentation.nextStopDepthMeters,
            nextStopMinutes: presentation.nextStopMinutes,
            remainingStopCount: presentation.remainingStopCount,
            ceilingViolation: presentation.ceilingViolation,
            ascentAllowedBetweenStops: presentation.ascentAllowedBetweenStops,
            showDecoStopPanel: presentation.showDecoStopPanel,
            showCeilingViolationBanner: presentation.showCeilingViolationBanner,
            usedConservativeFallback: true,
            diagnostics: ["sensor_degraded"],
            stopState: presentation.stopState,
            stopDirection: presentation.stopDirection,
            stopPanelAccent: presentation.stopPanelAccent,
            stopPanelTitleKey: presentation.stopPanelTitleKey,
            stopInstructionKey: presentation.stopInstructionKey,
            stopRemainingSeconds: presentation.stopRemainingSeconds,
            activeGasLabel: presentation.activeGasLabel,
            showDecoProgressPanel: presentation.showDecoProgressPanel,
            hideManualStopwatch: presentation.hideManualStopwatch,
            timerAccruing: presentation.timerAccruing
        )
    }

    static var visualRegressionStateNames: [String] {
        [
            "activity_selection",
            "diving_mode_selection",
            "fc_predive_valid",
            "fc_predive_invalid",
            "gauge_ttv_off",
            "gauge_ttv_on",
            "ndl_green",
            "ndl_yellow_10",
            "ndl_red_5",
            "deco_approaching",
            "holding_stop",
            "too_shallow",
            "too_deep",
            "ceiling_violation",
            "gas_switch_available",
            "gas_switch_ignored",
            "gas_lost",
            "deco_completed",
            "sensor_degraded",
            "recovery_after_restart",
        ]
    }

    static var localizedPresentationFixtures: [(String, FullComputerDecoPresentation)] {
        [
            ("ndl_green", ndlGreen()),
            ("ndl_yellow_10", ndlYellow()),
            ("ndl_red_5", ndlRed()),
            ("deco_approaching", decoApproaching()),
            ("holding_stop", holdingStop()),
            ("too_shallow", tooShallow()),
            ("too_deep", tooDeep()),
            ("ceiling_violation", ceilingViolation()),
            ("deco_completed", decoCompleted()),
            ("sensor_degraded", sensorDegraded()),
        ]
    }

    private static func baseNoDeco(
        ndlMinutes: Int,
        ndlAccent: FullComputerNDLAccent,
        runtimeMinutes: Int
    ) -> FullComputerDecoPresentation {
        FullComputerDecoPresentation(
            mode: .noDecompression,
            immersionAccent: .diving,
            immersionStatusKey: "live.status.in_dive",
            ndlDisplayMinutes: ndlMinutes,
            ndlAccent: ndlAccent,
            ttsMinutes: 0,
            runtimeMinutes: runtimeMinutes,
            ceilingMetersExact: 0,
            ceilingMetersRounded: 0,
            nextStopDepthMeters: nil,
            nextStopMinutes: nil,
            remainingStopCount: 0,
            ceilingViolation: false,
            ascentAllowedBetweenStops: true,
            showDecoStopPanel: false,
            showCeilingViolationBanner: false,
            usedConservativeFallback: false,
            diagnostics: [],
            stopState: nil,
            stopDirection: .none,
            stopPanelAccent: .green,
            stopPanelTitleKey: "",
            stopInstructionKey: nil,
            stopRemainingSeconds: nil,
            activeGasLabel: "AIR",
            showDecoProgressPanel: false,
            hideManualStopwatch: false,
            timerAccruing: false
        )
    }

    private static func baseDeco(
        stopState: FullComputerDecoStopState,
        stopDirection: FullComputerDecoStopDirection,
        stopPanelAccent: FullComputerDecoStopPanelAccent,
        titleKey: String,
        instructionKey: String?,
        nextStopDepthMeters: Double?,
        stopRemainingSeconds: Int?,
        remainingStopCount: Int,
        ascentAllowedBetweenStops: Bool,
        ceilingViolation: Bool = false,
        ceilingMetersExact: Double = 6.0,
        timerAccruing: Bool = false
    ) -> FullComputerDecoPresentation {
        FullComputerDecoPresentation(
            mode: .decompression,
            immersionAccent: ceilingViolation ? .ceilingViolation : .decompression,
            immersionStatusKey: ceilingViolation
                ? "live.fc.status.ceiling_violation"
                : "live.fc.status.in_deco",
            ndlDisplayMinutes: nil,
            ndlAccent: nil,
            ttsMinutes: 30,
            runtimeMinutes: 42,
            ceilingMetersExact: ceilingMetersExact,
            ceilingMetersRounded: ceilingMetersExact,
            nextStopDepthMeters: nextStopDepthMeters,
            nextStopMinutes: stopRemainingSeconds.map { max(1, $0 / 60) },
            remainingStopCount: remainingStopCount,
            ceilingViolation: ceilingViolation,
            ascentAllowedBetweenStops: ascentAllowedBetweenStops,
            showDecoStopPanel: true,
            showCeilingViolationBanner: ceilingViolation,
            usedConservativeFallback: false,
            diagnostics: [],
            stopState: stopState,
            stopDirection: stopDirection,
            stopPanelAccent: stopPanelAccent,
            stopPanelTitleKey: titleKey,
            stopInstructionKey: instructionKey,
            stopRemainingSeconds: stopRemainingSeconds,
            activeGasLabel: "TMX 18/45",
            showDecoProgressPanel: true,
            hideManualStopwatch: true,
            timerAccruing: timerAccruing
        )
    }
}
