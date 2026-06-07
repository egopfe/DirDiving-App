import UIKit

enum PlannerPDFBuilder {
    static func build(context: PDFExportPlannerContext) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let disclaimer = String(localized: "pdf.export.disclaimer")
        let title = String(localized: "pdf.export.section.plan")
        let environment = context.input.plannerEnvironment

        return renderer.pdfData { pdf in
            let page = PDFPageContext()
            page.attach(pdf, title: title, generatedAt: Date())

            page.drawSectionTitle(String(localized: "pdf.export.plan.profile"))
            page.drawLine(String(localized: "pdf.export.plan.mode"), value: context.mode.localizedTabTitle)
            page.drawLine(
                String(localized: "planner.field.max_depth"),
                value: Formatters.depth(context.input.plannedDepthMeters, units: context.unitPreference).text
            )
            if context.mode != .base {
                page.drawLine(
                    String(localized: "planner.field.avg_depth"),
                    value: Formatters.depth(context.input.plannedAverageDepthMeters, units: context.unitPreference).text
                )
                let reference = context.input.planningDepthReference == .maximumDepth
                    ? String(localized: "planner.reference.max_depth")
                    : String(localized: "planner.reference.avg_depth")
                page.drawLine(String(localized: "planner.field.planning_reference"), value: reference)
            }
            page.drawLine(
                String(localized: "planner.field.bottom_time"),
                value: "\(Formatters.zero(context.input.plannedBottomMinutes)) min"
            )
            if context.mode == .technical || context.mode == .deco {
                page.drawLine("GF Low", value: "\(Int(context.input.gfLow))%")
                page.drawLine("GF High", value: "\(Int(context.input.gfHigh))%")
            }

            page.drawSpacer()
            page.drawSectionTitle(String(localized: "pdf.export.plan.gases"))
            var input = context.input
            if input.plannerCylinders.isEmpty {
                input.ensurePlannerCylindersFromLegacy()
            }
            let active = PlannerModePolicy.activePlanInput(from: input, mode: context.mode)
            for (index, entry) in active.plannerCylinders.enumerated() {
                page.drawParagraph("\(String(localized: "pdf.export.plan.cylinder")) \(index + 1): \(entry.role.localizedTitle)")
                page.drawLine(String(localized: "planner.gas.editor.cylinder"), value: entry.tankSize.rawValue)
                page.drawLine(String(localized: "planner.gas.editor.mix_type"), value: entry.gas.mixKind.plannerPickerTitle)
                page.drawLine("O₂", value: "\(PlannerGasEditingSupport.oxygenPercent(from: entry.gas))%")
                page.drawLine("He", value: "\(PlannerGasEditingSupport.heliumPercent(from: entry.gas))%")
                page.drawLine("N₂", value: "\(PlannerGasEditingSupport.nitrogenPercent(from: entry.gas))%")
                page.drawLine(String(localized: "planner.gas.ppo2_max"), value: Formatters.one(entry.gas.maxPPO2))
                page.drawLine(
                    String(localized: "planner.gas.editor.mod"),
                    value: Formatters.depth(entry.modMeters(environment: environment), units: context.unitPreference).text
                )
                page.drawLine(
                    String(localized: "planner.gas.editor.working_pressure_section"),
                    value: "\(Formatters.zero(entry.startPressure)) \(entry.pressureUnit.rawValue)"
                )
                if entry.role != .bottom {
                    page.drawLine(
                        String(localized: "planner.field.switch_depth"),
                        value: Formatters.depth(entry.switchDepthMeters, units: context.unitPreference).text
                    )
                }
                page.drawSpacer(6)
            }

            page.drawSectionTitle(String(localized: "pdf.export.plan.schedule"))
            page.drawLine("NDL", value: "\(Formatters.one(context.plan.ndlMinutes)) min")
            page.drawLine("TTS", value: "\(context.plan.ttsMinutes) min")
            page.drawLine(String(localized: "planner.export.runtime_line"), value: "\(context.plan.totalRuntimeMinutes) min")

            if context.plan.decoStops.isEmpty {
                page.drawParagraph(String(localized: "planner.export.no_deco_stops"))
            } else {
                page.drawParagraph(String(localized: "planner.export.deco_stops"))
                for stop in context.plan.decoStops {
                    page.drawLine(
                        Formatters.depth(stop.depthMeters, units: context.unitPreference).text,
                        value: "\(stop.minutes) min · \(stop.gas) · PPO₂ \(Formatters.one(stop.ppO2))"
                    )
                }
            }

            let warnings = warningLines(context: context)
            if !warnings.isEmpty {
                page.drawSpacer()
                page.drawSectionTitle(String(localized: "pdf.export.plan.warnings"))
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
        page.drawSectionTitle(String(localized: "pdf.export.ratio_deco.section"))
        page.drawParagraph(String(localized: "pdf.export.ratio_deco.disclaimer"))
        page.drawLine(
            String(localized: "planner.ratio_deco.profile.header"),
            value: bundle.preset.name
        )
        page.drawLine("TTS", value: "\(bundle.schedule.ttsMinutes) min")
        page.drawLine(
            String(localized: "pdf.export.ratio_deco.validation"),
            value: bundle.validation.localizedStatusTitle
        )
        page.drawLine(
            String(localized: "planner.ratio_deco.summary.tts_difference"),
            value: "\(bundle.schedule.ttsMinutes - context.plan.ttsMinutes) min"
        )
        if bundle.schedule.stops.isEmpty {
            page.drawParagraph(String(localized: "planner.export.no_deco_stops"))
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
                page.drawParagraph(String(localized: "planner.ratio_deco.validation.unavailable_base"))
            case .ceilingViolation:
                page.drawParagraph(String(localized: "planner.ratio_deco.validation.ceiling"))
            case .modExceeded:
                page.drawParagraph(String(localized: "planner.ratio_deco.validation.mod"))
            case .decoDepthLimitExceeded:
                page.drawParagraph(String(localized: "planner.mode.deco.depth_limit.message"))
            }
        }
    }

    private static func warningLines(context: PDFExportPlannerContext) -> [String] {
        var lines: [String] = []
        for issue in context.modIssues {
            lines.append(
                String(
                    format: String(localized: "planner.mod.detail_format"),
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
