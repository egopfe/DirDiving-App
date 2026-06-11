import UIKit

enum PlannerPDFBuilder {
    static func build(context: PDFExportPlannerContext) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let disclaimer = DIRIOSLocalizer.string("pdf.export.disclaimer")
        let title = DIRIOSLocalizer.string("pdf.export.section.plan")
        let environment = context.input.plannerEnvironment

        return renderer.pdfData { pdf in
            let page = PDFPageContext()
            page.attach(pdf, title: title, generatedAt: Date())

            page.drawSectionTitle(DIRIOSLocalizer.string("pdf.export.plan.profile"))
            page.drawLine(DIRIOSLocalizer.string("pdf.export.plan.mode"), value: context.mode.localizedTabTitle)
            page.drawLine(
                DIRIOSLocalizer.string("planner.field.max_depth"),
                value: Formatters.depth(context.input.plannedDepthMeters, units: context.unitPreference).text
            )
            if PlannerResultPresentation.presentation(for: context.mode).showsAverageDepthGasConsumptionToggle,
               context.input.averageDepthGasConsumptionEnabled {
                page.drawLine(
                    DIRIOSLocalizer.string("planner.field.avg_depth"),
                    value: Formatters.depth(context.input.plannedAverageDepthMeters, units: context.unitPreference).text
                )
                page.drawLine(
                    DIRIOSLocalizer.string("planner.field.planning_reference"),
                    value: DIRIOSLocalizer.string("planner.technical.gas_consumption.reference.average")
                )
            } else if context.mode == .technical {
                page.drawLine(
                    DIRIOSLocalizer.string("planner.field.planning_reference"),
                    value: DIRIOSLocalizer.string("planner.technical.gas_consumption.reference.max")
                )
            }
            page.drawLine(
                DIRIOSLocalizer.string("planner.field.bottom_time"),
                value: "\(Formatters.zero(context.input.plannedBottomMinutes)) min"
            )
            if context.mode == .technical || context.mode == .deco {
                page.drawLine("GF Low", value: "\(Int(context.input.gfLow))%")
                page.drawLine("GF High", value: "\(Int(context.input.gfHigh))%")
            }

            page.drawSpacer()
            page.drawSectionTitle(DIRIOSLocalizer.string("pdf.export.plan.gases"))
            var input = context.input
            if input.plannerCylinders.isEmpty {
                input.ensurePlannerCylindersFromLegacy()
            }
            let active = PlannerModePolicy.activePlanInput(from: input, mode: context.mode)
            for (index, entry) in active.plannerCylinders.enumerated() {
                page.drawParagraph("\(DIRIOSLocalizer.string("pdf.export.plan.cylinder")) \(index + 1): \(entry.role.localizedTitle)")
                page.drawLine(DIRIOSLocalizer.string("planner.gas.editor.cylinder"), value: entry.tankSize.rawValue)
                page.drawLine(DIRIOSLocalizer.string("planner.gas.editor.mix_type"), value: entry.gas.mixKind.plannerPickerTitle)
                page.drawLine("O₂", value: "\(PlannerGasEditingSupport.oxygenPercent(from: entry.gas))%")
                page.drawLine("He", value: "\(PlannerGasEditingSupport.heliumPercent(from: entry.gas))%")
                page.drawLine("N₂", value: "\(PlannerGasEditingSupport.nitrogenPercent(from: entry.gas))%")
                page.drawLine(DIRIOSLocalizer.string("planner.gas.ppo2_max"), value: Formatters.one(entry.gas.maxPPO2))
                page.drawLine(
                    DIRIOSLocalizer.string("planner.gas.editor.mod"),
                    value: Formatters.depth(entry.modMeters(environment: environment), units: context.unitPreference).text
                )
                page.drawLine(
                    DIRIOSLocalizer.string("planner.gas.editor.working_pressure_section"),
                    value: Formatters.pressure(
                        fromBar: PlannerGasEditingSupport.startPressureBar(for: entry),
                        unit: context.pressureUnitPreference
                    ).text
                )
                if entry.role != .bottom {
                    page.drawLine(
                        DIRIOSLocalizer.string("planner.field.switch_depth"),
                        value: Formatters.depth(entry.switchDepthMeters, units: context.unitPreference).text
                    )
                }
                page.drawSpacer(6)
            }

            page.drawSectionTitle(DIRIOSLocalizer.string("planner.runtime.title"))
            page.drawLine("NDL", value: "\(Formatters.one(context.plan.ndlMinutes)) min")
            page.drawLine("TTS", value: "\(context.plan.ttsMinutes) min")
            page.drawLine(DIRIOSLocalizer.string("planner.export.runtime_line"), value: "\(context.plan.totalRuntimeMinutes) min")

            if context.plan.ascentTableRows.isEmpty, context.plan.decoStops.isEmpty {
                page.drawParagraph(DIRIOSLocalizer.string("planner.export.no_deco_stops"))
            } else if !context.plan.ascentTableRows.isEmpty {
                for row in context.plan.ascentTableRows {
                    page.drawParagraph(
                        "\(row.kind.localizedTitle) · \(row.depthLabel) / \(row.timeLabel) · \(row.gas) · PPO₂ \(row.ppO2Label)"
                    )
                }
            } else {
                page.drawParagraph(DIRIOSLocalizer.string("planner.export.deco_stops"))
                for stop in context.plan.decoStops {
                    page.drawLine(
                        "\(PlannerAscentRowKind.decoStop.localizedTitle) · \(Formatters.depth(stop.depthMeters, units: context.unitPreference).text)",
                        value: "\(stop.minutes) min · \(stop.gas) · PPO₂ \(Formatters.one(stop.ppO2))"
                    )
                }
            }

            let warnings = warningLines(context: context)
            if !warnings.isEmpty {
                page.drawSpacer()
                page.drawSectionTitle(DIRIOSLocalizer.string("pdf.export.plan.warnings"))
                warnings.forEach { page.drawParagraph($0) }
            }

            if let ratioDeco = context.plan.ratioDeco, ratioDeco.method != .buhlmann {
                appendRatioDecoSection(page: page, context: context, bundle: ratioDeco)
            }

            page.finish(disclaimer: disclaimer)
        }
    }

    private static func appendRatioDecoSection(
        page: PDFPageContext,
        context: PDFExportPlannerContext,
        bundle: RatioDecoPlanningBundle
    ) {
        page.drawSpacer()
        page.drawSectionTitle(DIRIOSLocalizer.string("pdf.export.ratio_deco.section"))
        page.drawParagraph(DIRIOSLocalizer.string("pdf.export.ratio_deco.disclaimer"))
        if !bundle.validation.isBuhlmannCompatible {
            page.drawParagraph(DIRIOSLocalizer.string("planner.ratio_deco.validation.not_validated_plan"))
        }
        page.drawLine(
            DIRIOSLocalizer.string("planner.ratio_deco.profile.header"),
            value: bundle.preset.name
        )
        page.drawLine("TTS", value: "\(bundle.schedule.ttsMinutes) min")
        page.drawLine(
            DIRIOSLocalizer.string("pdf.export.ratio_deco.validation"),
            value: bundle.validation.localizedStatusTitle
        )
        page.drawLine(
            DIRIOSLocalizer.string("planner.ratio_deco.summary.tts_difference"),
            value: "\(bundle.schedule.ttsMinutes - context.plan.ttsMinutes) min"
        )
        if bundle.schedule.stops.isEmpty {
            page.drawParagraph(DIRIOSLocalizer.string("planner.export.no_deco_stops"))
        } else {
            for stop in bundle.schedule.stops {
                page.drawLine(
                    Formatters.depth(stop.depthMeters, units: context.unitPreference).text,
                    value: "\(Int(stop.durationMinutes.rounded())) min · \(stop.gasLabel)"
                )
            }
        }
        for warning in bundle.validation.warnings {
            switch warning {
            case .unavailableInBaseMode:
                page.drawParagraph(DIRIOSLocalizer.string("planner.ratio_deco.validation.unavailable_base"))
            case .unavailableInCCRMode:
                page.drawParagraph(DIRIOSLocalizer.string("planner.ratio_deco.unavailable_ccr"))
            case .ceilingViolation:
                page.drawParagraph(DIRIOSLocalizer.string("planner.ratio_deco.validation.ceiling"))
            case .modExceeded:
                page.drawParagraph(DIRIOSLocalizer.string("planner.ratio_deco.validation.mod"))
            case .decoDepthLimitExceeded:
                page.drawParagraph(DIRIOSLocalizer.string("planner.mode.deco.depth_limit.message"))
            }
        }
    }

    private static func warningLines(context: PDFExportPlannerContext) -> [String] {
        var lines: [String] = []
        for issue in context.modIssues {
            let detailKey = context.mode == .base
                ? "planner.base.gas_depth.detail_format"
                : "planner.mod.detail_format"
            lines.append(
                DIRIOSLocalizer.formatted(
                    detailKey,
                    issue.gasLabel,
                    Formatters.depth(issue.switchDepthMeters, units: context.unitPreference).text,
                    Formatters.depth(issue.modMeters, units: context.unitPreference).text
                )
            )
        }
        for state in context.validation.states {
            switch state {
            case .basicNoDecoLimitExceeded, .decoDepthLimitExceeded, .MODExceeded, .PPO2Exceeded:
                let message = PlannerUserFacingCopy.message(for: state)
                lines.append([message.title, message.message].joined(separator: ": "))
            default:
                continue
            }
        }
        for warning in context.plan.userFacingWarnings where warning.severity != .info {
            lines.append([warning.title, warning.message].joined(separator: ": "))
        }
        if let guidance = context.plan.modeGuidanceMessage {
            lines.append([guidance.title, guidance.message].joined(separator: ": "))
        }
        return lines
    }
}
