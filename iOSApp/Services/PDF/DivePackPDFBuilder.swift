import UIKit

enum DivePackPDFBuilder {
    static func build(
        plannerContext: PDFExportPlannerContext,
        checklistProfile: EquipmentProfile,
        includeChecklist: Bool,
        siteName: String?
    ) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let disclaimer = DIRIOSLocalizer.string("pdf.export.disclaimer")
        let title = DIRIOSLocalizer.string("pdf.export.section.dive_pack")

        return renderer.pdfData { pdf in
            let page = PDFPageContext()
            page.attach(pdf, title: title, generatedAt: Date())

            page.drawSectionTitle(DIRIOSLocalizer.string("pdf.export.section.plan"))
            page.drawParagraph(DIRIOSLocalizer.string("pdf.export.dive_pack.plan_intro"))
            appendPlanSummary(page: page, context: plannerContext)

            if let ratioDeco = plannerContext.plan.ratioDeco, ratioDeco.method != .buhlmann {
                appendRatioDecoSection(page: page, context: plannerContext, bundle: ratioDeco)
            }

            page.drawSpacer(16)
            page.drawSectionTitle(DIRIOSLocalizer.string("pdf.export.section.briefing"))
            plannerContext.plan.briefingLines.forEach { page.drawParagraph($0) }

            page.drawSpacer(16)
            page.drawSectionTitle(DIRIOSLocalizer.string("pdf.export.section.checklist"))
            if includeChecklist {
                let yesLabel = DIRIOSLocalizer.string("pdf.export.checklist.yes")
                let noLabel = DIRIOSLocalizer.string("pdf.export.checklist.no")
                for item in checklistProfile.migratedChecklistItems {
                    page.drawChecklistRow(
                        yesLabel: yesLabel,
                        noLabel: noLabel,
                        itemText: ChecklistPDFBuilder.exportLine(for: item, unitPreference: plannerContext.unitPreference)
                    )
                }
            } else {
                page.drawParagraph(DIRIOSLocalizer.string("pdf.export.dive_pack.checklist_unavailable"))
            }

            page.finish(disclaimer: disclaimer)
        }
    }

    private static func appendPlanSummary(page: PDFPageContext, context: PDFExportPlannerContext) {
        page.drawLine(DIRIOSLocalizer.string("pdf.export.plan.mode"), value: context.mode.localizedTabTitle)
        page.drawLine(
            DIRIOSLocalizer.string("planner.field.max_depth"),
            value: Formatters.depth(context.input.plannedDepthMeters, units: context.unitPreference).text
        )
        page.drawLine(
            DIRIOSLocalizer.string("planner.field.bottom_time"),
            value: "\(Formatters.zero(context.input.plannedBottomMinutes)) min"
        )
        page.drawLine("TTS", value: "\(context.plan.ttsMinutes) min")
        if context.plan.decoStops.isEmpty {
            page.drawParagraph(DIRIOSLocalizer.string("planner.export.no_deco_stops"))
        } else {
            for stop in context.plan.decoStops {
                page.drawParagraph(
                    "\(Formatters.depth(stop.depthMeters, units: context.unitPreference).text) · \(stop.minutes) min · \(stop.gas)"
                )
            }
        }
        if !PlannerGasSchedule.bailoutCylinders(from: context.input).isEmpty {
            page.drawParagraph(DIRIOSLocalizer.string("planner.bailout.schedule_hint"))
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
}
