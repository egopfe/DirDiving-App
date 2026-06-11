import UIKit

enum BriefingPDFBuilder {
    static func build(context: PDFExportPlannerContext, siteName: String?) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let disclaimer = DIRIOSLocalizer.string("pdf.export.disclaimer")
        let title = DIRIOSLocalizer.string("pdf.export.section.briefing")
        let analysis = context.plan.gasAnalysis

        return renderer.pdfData { pdf in
            let page = PDFPageContext()
            page.attach(pdf, title: title, generatedAt: Date())

            page.drawSectionTitle(DIRIOSLocalizer.string("pdf.export.briefing.overview"))
            if let siteName, !siteName.isEmpty {
                page.drawLine(DIRIOSLocalizer.string("pdf.export.briefing.site"), value: siteName)
            }
            page.drawLine(DIRIOSLocalizer.string("pdf.export.briefing.objective"), value: context.mode.localizedTabTitle)
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
            }
            page.drawLine(
                DIRIOSLocalizer.string("planner.field.bottom_time"),
                value: "\(Formatters.zero(context.input.plannedBottomMinutes)) min"
            )

            page.drawSpacer()
            page.drawSectionTitle(DIRIOSLocalizer.string("pdf.export.briefing.gas_plan"))
            for line in context.plan.briefingLines {
                page.drawParagraph(line)
            }

            page.drawSpacer()
            page.drawSectionTitle(DIRIOSLocalizer.string("planner.runtime.title"))
            page.drawLine("TTS", value: "\(context.plan.ttsMinutes) min")
            if context.plan.ascentTableRows.isEmpty, context.plan.decoStops.isEmpty {
                page.drawParagraph(DIRIOSLocalizer.string("planner.export.no_deco_stops"))
            } else if !context.plan.ascentTableRows.isEmpty {
                for row in context.plan.ascentTableRows {
                    page.drawParagraph(
                        "\(row.kind.localizedTitle) · \(row.depthLabel) / \(row.timeLabel) · \(row.gas) · PPO₂ \(row.ppO2Label)"
                    )
                }
            } else {
                for stop in context.plan.decoStops {
                    page.drawParagraph(
                        "\(PlannerAscentRowKind.decoStop.localizedTitle) · \(Formatters.depth(stop.depthMeters, units: context.unitPreference).text) / \(stop.minutes) min · \(stop.gas)"
                    )
                }
            }

            page.drawSpacer()
            page.drawSectionTitle(DIRIOSLocalizer.string("pdf.export.briefing.gas_management"))
            page.drawLine(
                DIRIOSLocalizer.string("planner.metric.turn_pressure"),
                value: "\(Formatters.zero(analysis.turnPressureBar)) bar"
            )
            page.drawLine(
                DIRIOSLocalizer.string("planner.metric.rock_bottom"),
                value: "\(Formatters.zero(analysis.minimumGasBar)) bar"
            )
            page.drawLine(
                DIRIOSLocalizer.string("planner.metric.remaining"),
                value: "\(Formatters.zero(analysis.remainingBar)) bar"
            )

            if !context.plan.contingencyPlans.isEmpty {
                page.drawSpacer()
                page.drawSectionTitle(DIRIOSLocalizer.string("pdf.export.briefing.contingency"))
                for plan in context.plan.contingencyPlans {
                    page.drawParagraph("\(plan.scenario.rawValue): \(plan.action)")
                }
            }

            if !context.plan.teamMatches.isEmpty {
                page.drawSpacer()
                page.drawSectionTitle(DIRIOSLocalizer.string("pdf.export.briefing.team"))
                for match in context.plan.teamMatches {
                    page.drawParagraph("\(match.diverName) · SAC \(Formatters.zero(match.sacLitersMinute)) L/min · \(match.status)")
                }
            }

            page.drawSpacer()
            page.drawParagraph(DIRIOSLocalizer.string("planner.briefing.share_note"))

            if let ratioDeco = context.plan.ratioDeco, ratioDeco.method != .buhlmann {
                page.ensureSpace(160)
                page.drawSpacer()
                page.drawSectionTitle(DIRIOSLocalizer.string("pdf.export.ratio_deco.section"))
                page.drawParagraph(DIRIOSLocalizer.string("pdf.export.ratio_deco.disclaimer"))
                page.drawLine(
                    DIRIOSLocalizer.string("pdf.export.ratio_deco.validation"),
                    value: ratioDeco.validation.localizedStatusTitle
                )
                for stop in ratioDeco.schedule.stops {
                    page.drawParagraph(
                        "\(Formatters.depth(stop.depthMeters, units: context.unitPreference).text) / \(Int(stop.durationMinutes.rounded())) min · \(stop.gasLabel)"
                    )
                }
            }

            page.finish(disclaimer: disclaimer)
        }
    }
}
