import UIKit

enum CCRPlannerPDFBuilder {
    static func build(context: PDFExportCCRPlannerContext) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let disclaimer = String(localized: "ccr.pdf.disclaimer")
        let title = String(localized: "pdf.export.section.ccr_plan")
        let input = context.input
        let plan = context.plan
        let environment = input.plannerEnvironment

        return renderer.pdfData { pdf in
            let page = PDFPageContext()
            page.attach(pdf, title: title, generatedAt: Date())

            page.drawSectionTitle(String(localized: "ccr.pdf.profile"))
            page.drawLine(String(localized: "ccr.rebreather_model"), value: input.rebreatherModel.isEmpty ? "—" : input.rebreatherModel)
            page.drawLine(
                String(localized: "planner.field.max_depth"),
                value: Formatters.depth(input.maxDepthMeters, units: context.unitPreference).text
            )
            page.drawLine(
                String(localized: "planner.field.bottom_time"),
                value: "\(Formatters.zero(input.bottomTimeMinutes)) min"
            )
            page.drawLine("GF Low", value: "\(Int(input.gfLow))%")
            page.drawLine("GF High", value: "\(Int(input.gfHigh))%")

            page.drawSpacer()
            page.drawSectionTitle(String(localized: "ccr.setpoint.header"))
            page.drawLine(String(localized: "ccr.setpoint.low"), value: Formatters.one(input.setpointProfile.lowSetpoint) + " bar")
            page.drawLine(String(localized: "ccr.setpoint.high"), value: Formatters.one(input.setpointProfile.highSetpoint) + " bar")
            page.drawLine(
                String(localized: "ccr.setpoint.switch_depth"),
                value: Formatters.depth(input.setpointProfile.switchDepthMeters, units: context.unitPreference).text
            )
            page.drawLine(String(localized: "ccr.setpoint.mode"), value: input.setpointProfile.mode.localizedTitle)
            if input.setpointProfile.mode == .manual, input.setpointProfile.useLowSetpointOnShallowAscent {
                page.drawLine(
                    String(localized: "ccr.setpoint.shallow_ascent"),
                    value: Formatters.depth(input.setpointProfile.shallowAscentSetpointDepthMeters, units: context.unitPreference).text
                )
            }

            page.drawSpacer()
            page.drawSectionTitle(String(localized: "ccr.diluent"))
            page.drawLine(String(localized: "planner.gas.editor.mix_type"), value: input.diluent.label)
            page.drawLine("O₂", value: "\(input.diluent.oxygenPercent)%")
            page.drawLine("He", value: "\(input.diluent.heliumPercent)%")

            page.drawSpacer()
            page.drawSectionTitle(String(localized: "ccr.bailout"))
            for (index, bailout) in input.bailoutGases.enumerated() {
                page.drawParagraph("\(String(localized: "ccr.bailout")) \(index + 1): \(bailout.label)")
                page.drawLine(String(localized: "equipment.tank_size"), value: bailout.tankSize.rawValue)
                page.drawLine(
                    String(localized: "planner.field.switch_depth"),
                    value: Formatters.depth(bailout.switchDepthMeters, units: context.unitPreference).text
                )
                if let mod = bailout.gasMix.modMeters(environment: environment) {
                    page.drawLine(
                        String(localized: "planner.gas.editor.mod"),
                        value: Formatters.depth(mod, units: context.unitPreference).text
                    )
                }
                page.drawSpacer(6)
            }

            page.drawSectionTitle(String(localized: "ccr.pdf.schedule"))
            page.drawLine("TTS", value: "\(plan.ttsMinutes) min")
            page.drawLine(String(localized: "planner.export.runtime_line"), value: "\(plan.totalRuntimeMinutes) min")
            if plan.decoStops.isEmpty {
                page.drawParagraph(String(localized: "planner.export.no_deco_stops"))
            } else {
                for stop in plan.decoStops {
                    page.drawLine(
                        Formatters.depth(stop.depthMeters, units: context.unitPreference).text,
                        value: "\(stop.minutes) min · SP \(Formatters.one(stop.ppO2))"
                    )
                }
            }

            page.drawSpacer()
            page.drawSectionTitle(String(localized: "ccr.cns.header"))
            page.drawLine(String(localized: "planner.metric.cns_full_plan"), value: "\(Formatters.one(plan.cnsFullPlanPercent))%")
            page.drawLine(String(localized: "planner.metric.cns_descent_bottom"), value: "\(Formatters.one(plan.cnsDescentBottomPercent))%")
            page.drawLine(String(localized: "planner.metric.otu"), value: Formatters.one(plan.otuFullPlan))

            if let maxPPN2 = plan.ppN2Timeline.map(\.ppN2Bar).max(), maxPPN2.isFinite {
                page.drawSpacer()
                page.drawSectionTitle(String(localized: "ccr.pdf.narcosis"))
                page.drawLine(String(localized: "ccr.pdf.ppn2_max"), value: Formatters.one(maxPPN2) + " bar")
                if let maxEND = plan.endTimeline.map(\.endMeters).max() {
                    page.drawLine(
                        String(localized: "ccr.pdf.end_max"),
                        value: Formatters.depth(maxEND, units: context.unitPreference).text
                    )
                }
            }

            if !plan.bailoutScenarios.isEmpty {
                page.drawSpacer()
                page.drawSectionTitle(String(localized: "ccr.bailout.heuristic_analysis"))
                page.drawParagraph(String(localized: "ccr.bailout.heuristic_disclaimer"))
                for scenario in plan.bailoutScenarios {
                    page.drawParagraph("\(scenario.kind.localizedTitle): \(scenario.status.localizedTitle)")
                    for warning in scenario.warnings {
                        page.drawParagraph(warning)
                    }
                }
            }

            if !plan.warnings.isEmpty {
                page.drawSpacer()
                page.drawSectionTitle(String(localized: "pdf.export.plan.warnings"))
                plan.warnings.forEach { page.drawParagraph($0.message) }
            }

            page.finish(disclaimer: disclaimer)
        }
    }
}

private extension CCRPlanInput {
    var plannerEnvironment: PlannerEnvironment {
        switch PlannerEnvironment.make(altitudeMeters: altitudeMeters, salinity: salinity) {
        case .success(let environment):
            return environment
        case .failure:
            return .seaLevelSaltWater
        }
    }
}

private extension GasMix {
    func modMeters(environment: PlannerEnvironment) -> Double? {
        GasMixValidator.modMeters(oxygenFraction: oxygen, maxPPO2: maxPPO2, environment: environment)
    }
}
