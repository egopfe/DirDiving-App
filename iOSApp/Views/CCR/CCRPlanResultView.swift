import SwiftUI
import Charts

struct CCRPlanResultView: View {
    @EnvironmentObject private var store: PlannerStore
    @AppStorage(PlannerSafetyAcknowledgment.storageKey) private var plannerSafetyAckRevision = ""
    @AppStorage(IOSUnitPreference.storageKey) private var unitsRaw = IOSUnitPreference.metric.rawValue
    @State private var shareablePDF: ShareablePDFItem?
    @State private var pdfExportAlertMessage: String?

    private var plan: CCRPlanResult { store.ccrPlan }
    private var unitPreference: IOSUnitPreference { IOSUnitPreference.fromStorage(unitsRaw) }
    private var plannerSafetyAcknowledged: Bool {
        plannerSafetyAckRevision == PlannerSafetyAcknowledgment.currentRevision
    }

    var body: some View {
        DIRScreenContainer {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(String(localized: "planner.result.ccr.title"))
                        .dirScreenTitleStyle()
                    DIRWarningBox(text: String(localized: "ccr.reference_estimate_only"))

                    summaryCard
                    tissueAnalyticsEntry
                    cnsCard
                    depthChartCard
                    ppo2ChartCard
                    ppn2ChartCard
                    endChartCard
                    gasDensityChartCard
                    cnsTimelineCard
                    scheduleCard
                    bailoutCard
                    warningsCard
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .dirCompanionScrollSurface()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    store.returnToPlannerModeSelection()
                } label: {
                    Label(String(localized: "planner.mode_selection.back"), systemImage: "chevron.left")
                        .foregroundStyle(DIRTheme.cyan)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if canExportCCRPlan {
                    Button {
                        shareCCRPlanPDF()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(DIRTheme.cyan)
                    }
                    .accessibilityLabel(Text(String(localized: "pdf.export.share.ccr_plan")))
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .sheet(item: $shareablePDF) { item in
            ShareSheetView(activityItems: [item.url])
        }
        .alert(String(localized: "pdf.export.error.title"), isPresented: Binding(
            get: { pdfExportAlertMessage != nil },
            set: { if !$0 { pdfExportAlertMessage = nil } }
        )) {
            Button(String(localized: "pdf.export.cancel"), role: .cancel) {}
        } message: {
            Text(pdfExportAlertMessage ?? "")
        }
    }

    @ViewBuilder
    private var tissueAnalyticsEntry: some View {
        if showsTissueAnalyticsEntry, let presentation = tissueAnalyticsPresentation {
            NavigationLink {
                TissueNarcosisAnalyticsView(presentation: presentation, initialTab: .tissues)
            } label: {
                TissueAnalyticsEntryCard()
            }
            .buttonStyle(.plain)
        }
    }

    private var showsTissueAnalyticsEntry: Bool {
        !plan.tissueTrace.isEmpty && plan.buhlmannState != .invalidInput
    }

    private var tissueAnalyticsPresentation: TissueAnalyticsPresentation? {
        TissueAnalyticsService.presentationForCCRPlan(plan: plan, input: store.ccrInput)
    }

    private var canExportCCRPlan: Bool {
        PDFExportService.canExportCCRPlan(ccrPDFContext())
    }

    private func ccrPDFContext() -> PDFExportCCRPlannerContext {
        PDFShareActions.ccrContext(
            store: store,
            safetyAcknowledged: plannerSafetyAcknowledged,
            unitPreference: unitPreference
        )
    }

    private func shareCCRPlanPDF() {
        let context = ccrPDFContext()
        guard PDFExportService.canExportCCRPlan(context) else {
            pdfExportAlertMessage = PDFShareActions.invalidPlanMessage()
            return
        }
        do {
            let url = try PDFExportService.exportCCRPlan(context: context)
            shareablePDF = ShareablePDFItem(url: url)
        } catch {
            pdfExportAlertMessage = PDFShareActions.invalidPlanMessage()
        }
    }

    private var summaryCard: some View {
        DIRCard(String(localized: "ccr.plan.summary"), icon: "list.bullet.rectangle", accent: DIRTheme.cyan) {
            VStack(alignment: .leading, spacing: 6) {
                metric(String(localized: "planner.tts"), "\(plan.ttsMinutes) min")
                metric(String(localized: "planner.runtime"), "\(plan.totalRuntimeMinutes) min")
                metric(String(localized: "ccr.diluent"), store.ccrInput.diluent.label)
                metric(
                    String(localized: "ccr.setpoint.strategy"),
                    "\(store.ccrInput.setpointProfile.lowSetpoint) / \(store.ccrInput.setpointProfile.highSetpoint) @ \(Int(store.ccrInput.setpointProfile.switchDepthMeters)) m"
                )
            }
        }
    }

    private var cnsCard: some View {
        DIRCard(String(localized: "ccr.cns.header"), icon: "heart.text.square", accent: DIRTheme.orange) {
            VStack(alignment: .leading, spacing: 6) {
                metric(String(localized: "planner.metric.cns_full_plan"), "\(Formatters.one(plan.cnsFullPlanPercent))%")
                metric(String(localized: "planner.metric.cns_descent_bottom"), "\(Formatters.one(plan.cnsDescentBottomPercent))%")
                metric(String(localized: "planner.metric.otu"), Formatters.one(plan.otuFullPlan))
            }
        }
    }

    private var depthChartCard: some View {
        DIRCard(String(localized: "planner.chart.depth_profile"), icon: "chart.xyaxis.line", accent: DIRTheme.cyan) {
            Chart(plan.depthProfilePoints) { point in
                LineMark(
                    x: .value("Time", point.elapsedMinutes),
                    y: .value("Depth", point.depthMeters)
                )
                .foregroundStyle(DIRTheme.cyan)
            }
            .chartYScale(domain: .automatic(includesZero: true))
            .frame(height: 180)
        }
    }

    private var ppo2ChartCard: some View {
        DIRCard(String(localized: "ccr.ppo2.timeline"), icon: "waveform.path.ecg", accent: DIRTheme.orange) {
            Chart(plan.ppO2Timeline, id: \.runtimeMinutes) { sample in
                LineMark(
                    x: .value("Time", sample.runtimeMinutes),
                    y: .value("PPO2", sample.ppO2Bar)
                )
                .foregroundStyle(DIRTheme.orange)
            }
            .frame(height: 160)
        }
    }

    private var ppn2ChartCard: some View {
        DIRCard(String(localized: "ccr.ppn2.timeline"), icon: "lungs", accent: DIRTheme.green) {
            Chart(plan.ppN2Timeline, id: \.runtimeMinutes) { sample in
                LineMark(
                    x: .value("Time", sample.runtimeMinutes),
                    y: .value("PPN2", sample.ppN2Bar)
                )
                .foregroundStyle(DIRTheme.green)
            }
            .frame(height: 160)
        }
    }

    private var endChartCard: some View {
        DIRCard(String(localized: "ccr.end.timeline"), icon: "brain.head.profile", accent: DIRTheme.yellow) {
            Chart(plan.endTimeline, id: \.runtimeMinutes) { sample in
                LineMark(
                    x: .value("Time", sample.runtimeMinutes),
                    y: .value("END", sample.endMeters)
                )
                .foregroundStyle(DIRTheme.yellow)
            }
            .frame(height: 160)
        }
    }

    @ViewBuilder
    private var gasDensityChartCard: some View {
        let densitySamples = plan.gasDensityTimeline.compactMap { sample -> (Double, Double)? in
            guard let density = sample.gasDensityGramsPerLiter else { return nil }
            return (sample.runtimeMinutes, density)
        }
        if !densitySamples.isEmpty {
            DIRCard(String(localized: "ccr.gas_density.timeline"), icon: "scalemass", accent: DIRTheme.muted) {
                Chart(densitySamples, id: \.0) { sample in
                    LineMark(
                        x: .value("Time", sample.0),
                        y: .value("Density", sample.1)
                    )
                    .foregroundStyle(DIRTheme.muted)
                }
                .frame(height: 140)
                Text(String(localized: "ccr.gas_density.approximation"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
            }
        }
    }

    @ViewBuilder
    private var cnsTimelineCard: some View {
        if plan.cnsTimeline.count > 1 {
            DIRCard(String(localized: "ccr.cns.timeline"), icon: "chart.line.uptrend.xyaxis", accent: DIRTheme.orange) {
                Chart(plan.cnsTimeline, id: \.runtimeMinutes) { sample in
                    LineMark(
                        x: .value("Time", sample.runtimeMinutes),
                        y: .value("CNS", sample.cnsPercent)
                    )
                    .foregroundStyle(DIRTheme.orange)
                }
                .frame(height: 140)
            }
        }
    }

    private var scheduleCard: some View {
        DIRCard(String(localized: "ccr.schedule.header"), icon: "tablecells", accent: DIRTheme.cyan) {
            ForEach(plan.schedule.prefix(20)) { row in
                HStack {
                    Text("\(Int(row.runtimeMinutes))'")
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(DIRTheme.muted)
                    Text(Formatters.depth(row.depthMeters, units: unitPreference).text)
                        .font(.caption)
                    Spacer()
                    Text(String(format: "SP %.1f", row.activeSetpointBar))
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.orange)
                }
            }
        }
    }

    private var bailoutCard: some View {
        DIRCard(String(localized: "ccr.bailout.analysis"), icon: "exclamationmark.shield", accent: DIRTheme.yellow) {
            ForEach(plan.bailoutScenarios) { scenario in
                VStack(alignment: .leading, spacing: 4) {
                    Text(scenario.kind.localizedTitle)
                        .font(.caption.bold())
                    Text(statusLabel(scenario.status))
                        .font(.caption2)
                        .foregroundStyle(statusColor(scenario.status))
                    ForEach(scenario.warnings, id: \.self) { warning in
                        Text(warning).font(.caption2).foregroundStyle(DIRTheme.yellow)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var warningsCard: some View {
        Group {
            if !plan.warnings.isEmpty {
                DIRCard(String(localized: "planner.warnings.header"), icon: "info.circle", accent: DIRTheme.yellow) {
                    ForEach(plan.warnings) { warning in
                        Text(warning.message)
                            .font(.caption)
                            .foregroundStyle(DIRTheme.muted)
                    }
                }
            }
        }
    }

    private func metric(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).font(.caption).foregroundStyle(DIRTheme.muted)
            Spacer()
            Text(value).font(.caption.bold()).foregroundStyle(.white)
        }
    }

    private func statusLabel(_ status: CCRBailoutScenarioStatus) -> String {
        switch status {
        case .pass: return String(localized: "ccr.bailout.status.pass")
        case .warning: return String(localized: "ccr.bailout.status.warning")
        case .fail: return String(localized: "ccr.bailout.status.fail")
        }
    }

    private func statusColor(_ status: CCRBailoutScenarioStatus) -> Color {
        switch status {
        case .pass: return DIRTheme.green
        case .warning: return DIRTheme.yellow
        case .fail: return DIRTheme.red
        }
    }
}
