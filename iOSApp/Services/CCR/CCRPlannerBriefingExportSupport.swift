import Foundation

enum CCRPlannerBriefingExportSupport {
    static func makeExportInput(
        plan: CCRPlanResult,
        input: CCRPlanInput,
        unitPreference: IOSUnitPreference,
        plannerSessionId: UUID
    ) -> PlannerBriefingImageExportInput? {
        guard plan.validationResult.isValid else { return nil }

        let decoPresentation = DecoStopsPresentationBuilder.rows(
            from: plan.decoStops,
            depthFormatter: { Formatters.depth($0, units: unitPreference).text },
            ppO2Formatter: { Formatters.one($0) }
        )
        let decoRows = PlannerBriefingImageExportService.decoRows(from: decoPresentation)
        let runtimeRows = runtimeRows(from: plan.schedule, unitPreference: unitPreference)
        let summaryRows = summaryRows(plan: plan, input: input, unitPreference: unitPreference)

        guard !decoRows.isEmpty || !runtimeRows.isEmpty || !summaryRows.isEmpty else {
            return nil
        }

        return PlannerBriefingImageExportInput(
            modeLabel: DIRIOSLocalizer.string("planner.mode.ccr"),
            plannerSessionId: plannerSessionId,
            decoStopRows: decoRows,
            runtimeRows: runtimeRows,
            summaryRows: summaryRows,
            includesDecoStopsInRuntime: !plan.decoStops.isEmpty
        )
    }

    static func runtimeRows(
        from schedule: [CCRScheduleRow],
        unitPreference: IOSUnitPreference
    ) -> [PlannerBriefingRuntimeExportRow] {
        schedule.map { row in
            PlannerBriefingRuntimeExportRow(
                kindLabel: row.phase.runtimeRowTitle,
                depthLabel: Formatters.depth(row.depthMeters, units: unitPreference).text,
                timeLabel: "\(Int(row.runtimeMinutes)) min",
                gasLabel: "SP \(Formatters.one(row.activeSetpointBar)) · \(row.diluentLabel)"
            )
        }
    }

    static func summaryRows(
        plan: CCRPlanResult,
        input: CCRPlanInput,
        unitPreference: IOSUnitPreference
    ) -> [PlannerBriefingSummaryExportRow] {
        var rows: [PlannerBriefingSummaryExportRow] = [
            PlannerBriefingSummaryExportRow(
                label: DIRIOSLocalizer.string("ccr.diluent"),
                value: input.diluent.label
            ),
            PlannerBriefingSummaryExportRow(
                label: DIRIOSLocalizer.string("ccr.setpoint.strategy"),
                value: "\(Formatters.one(input.setpointProfile.lowSetpoint)) / \(Formatters.one(input.setpointProfile.highSetpoint)) @ \(Formatters.depth(input.setpointProfile.switchDepthMeters, units: unitPreference).text)"
            ),
            PlannerBriefingSummaryExportRow(
                label: DIRIOSLocalizer.string("planner.tts"),
                value: "\(plan.ttsMinutes) min"
            ),
            PlannerBriefingSummaryExportRow(
                label: DIRIOSLocalizer.string("planner.runtime"),
                value: "\(plan.totalRuntimeMinutes) min"
            ),
            PlannerBriefingSummaryExportRow(
                label: DIRIOSLocalizer.string("planner.metric.cns_full_plan"),
                value: exposureLabel(plan.oxygenExposure.cnsPercent, suffix: "%")
            ),
            PlannerBriefingSummaryExportRow(
                label: DIRIOSLocalizer.string("planner.metric.otu"),
                value: exposureLabel(plan.oxygenExposure.otu, suffix: nil)
            ),
            PlannerBriefingSummaryExportRow(
                label: DIRIOSLocalizer.string("ccr.gas_density.timeline"),
                value: gasDensityLabel(from: plan.gasDensityTimeline)
            ),
            PlannerBriefingSummaryExportRow(
                label: DIRIOSLocalizer.string("ccr.bailout.heuristic_disclaimer"),
                value: DIRIOSLocalizer.string("ccr.bailout.limitation.not_oc_deco")
            ),
        ]
        rows.append(
            PlannerBriefingSummaryExportRow(
                label: DIRIOSLocalizer.string("planner.watch_briefing.ref_only"),
                value: PlannerBriefingTransferSupport.referenceOnlyFooter
            )
        )
        return rows
    }

    private static func exposureLabel(_ value: Double?, suffix: String?) -> String {
        guard let value else {
            return DIRIOSLocalizer.string("ccr.exposure.unavailable.label")
        }
        let formatted = Formatters.one(value)
        guard let suffix, !suffix.isEmpty else { return formatted }
        return "\(formatted)\(suffix)"
    }

    private static func gasDensityLabel(from timeline: [CCRTimelineSample]) -> String {
        let values = timeline.compactMap(\.gasDensityGramsPerLiter)
        guard let peak = values.max() else {
            return DIRIOSLocalizer.string("ccr.gas_density.unavailable.label")
        }
        return "\(Formatters.one(peak)) g/L"
    }
}
