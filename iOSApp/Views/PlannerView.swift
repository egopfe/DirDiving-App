import SwiftUI
import Charts

struct PlannerView: View {
    @EnvironmentObject private var store: PlannerStore
    @AppStorage(PlannerSafetyAcknowledgment.storageKey) private var plannerSafetyAckRevision = ""
    @AppStorage(IOSUnitPreference.storageKey) private var unitsRaw = IOSUnitPreference.metric.rawValue
    @State private var showPlan = false
    @State private var showPlanningReferenceInfo = false
    @State private var showCalculateError = false
    @State private var calculateErrorMessage = ""

    private var unitPreference: IOSUnitPreference { IOSUnitPreference.fromStorage(unitsRaw) }

    private var plannerSafetyAcknowledged: Bool {
        plannerSafetyAckRevision == PlannerSafetyAcknowledgment.currentRevision
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DIRBackground()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 7) {
                            Text(String(localized: "Planner"))
                                .dirScreenTitleStyle()
                            Text(String(localized: "planner.header.subtitle"))
                                .dirScreenSubtitleStyle()
                        }
                        plannerSafetyAcknowledgment
                        DIRWarningBox(text: String(localized: "planner.units.metric_notice"))
                        Group {
                            modePicker
                            profileCard
                            repetitivePlanningCard
                            plannerCylindersCard
                            technicalAnalysisCard
                            reserveCard
                            teamPreviewCard
                            plannerMODInputWarnings
                            plannerWarnings
                            calculateButton
                        }
                        .disabled(!plannerSafetyAcknowledged)
                        .opacity(plannerSafetyAcknowledged ? 1 : 0.45)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 18)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showPlan) {
                PlanResultView()
                    .environmentObject(store)
            }
            .task {
                if store.mode != .advanced {
                    store.mode = .advanced
                }
                store.input.ensurePlannerCylindersFromLegacy()
                store.refreshDerivedPlanningPreview()
            }
            .alert(String(localized: "planner.reference.info.title"), isPresented: $showPlanningReferenceInfo) {
                Button(String(localized: "OK"), role: .cancel) {}
            } message: {
                Text(String(localized: "planner.reference.info.message"))
            }
            .alert(String(localized: "planner.calculate.error.title"), isPresented: $showCalculateError) {
                Button(String(localized: "OK"), role: .cancel) {}
            } message: {
                Text(calculateErrorMessage)
            }
        }
    }

    private var modePicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "slider.horizontal.3")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DIRTheme.cyan)
                Text(String(localized: "planner.mode.advanced_only"))
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(RoundedRectangle(cornerRadius: 8).fill(DIRTheme.surface2.opacity(0.82)))
            .accessibilityLabel(String(localized: "planner.mode.advanced_only"))
        }
    }

    private func salinityLabel(_ mode: SalinityMode) -> String {
        switch mode {
        case .fresh: return String(localized: "salinity.fresh")
        case .salt: return String(localized: "salinity.salt")
        }
    }

    /// Display-only labels for the segmented control. `PlannerMode` raw values stay unchanged for Codable persistence.
    private func plannerModeTabLabel(_ mode: PlannerMode) -> String {
        switch mode {
        case .recreational: return String(localized: "Semplice")
        case .advanced: return String(localized: "Avanzato")
        case .technical: return String(localized: "Tecnico")
        case .overhead: return String(localized: "Overhead")
        }
    }

    private var profileCard: some View {
        DIRCard(String(localized: "planner.profile.title"), icon: nil, accent: DIRTheme.cyan) {
            VStack(spacing: 0) {
                plannerDepthField(String(localized: "planner.field.max_depth"), meters: $store.input.plannedDepthMeters)
                Divider().overlay(DIRTheme.hairline)
                plannerDepthField(String(localized: "planner.field.avg_depth"), meters: $store.input.plannedAverageDepthMeters)
                Divider().overlay(DIRTheme.hairline)
                HStack(spacing: 8) {
                    Text(String(localized: "planner.field.planning_reference"))
                        .font(.callout)
                        .foregroundStyle(.white)
                    Button {
                        showPlanningReferenceInfo = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.callout)
                            .foregroundStyle(DIRTheme.cyan)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(String(localized: "planner.reference.info.title"))
                    Spacer()
                    Picker(String(localized: "planner.field.planning_reference"), selection: $store.input.planningDepthReference) {
                        Text(String(localized: "planner.reference.max_depth")).tag(PlanningDepthReference.maximumDepth)
                        Text(String(localized: "planner.reference.avg_depth")).tag(PlanningDepthReference.averageDepth)
                    }
                    .labelsHidden()
                    .tint(DIRTheme.cyan)
                    .onChange(of: store.input.planningDepthReference) { _, _ in
                        store.refreshDerivedPlanningPreview()
                    }
                }
                Text(String(localized: "planner.reference.helper"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 10)
                Divider().overlay(DIRTheme.hairline)
                plannerField(String(localized: "planner.field.bottom_time"), value: $store.input.plannedBottomMinutes, unit: "min", step: 1)
                Divider().overlay(DIRTheme.hairline)
                plannerTemperatureField(String(localized: "planner.field.temperature"), celsius: $store.input.waterTemperatureCelsius)
                Divider().overlay(DIRTheme.hairline)
                plannerDepthField(String(localized: "planner.field.altitude"), meters: $store.input.altitudeMeters, step: unitPreference == .metric ? 100 : 300)
                Divider().overlay(DIRTheme.hairline)
                plannerField(String(localized: "planner.field.gf_low"), value: $store.input.gfLow, unit: "%", step: 5)
                Divider().overlay(DIRTheme.hairline)
                plannerField(String(localized: "planner.field.gf_high"), value: $store.input.gfHigh, unit: "%", step: 5)
                Divider().overlay(DIRTheme.hairline)
                HStack {
                    Text(String(localized: "planner.field.salinity"))
                        .font(.callout)
                        .foregroundStyle(.white)
                    Spacer()
                    Picker(String(localized: "planner.field.salinity"), selection: $store.input.salinity) {
                        ForEach(SalinityMode.allCases) { mode in
                            Text(salinityLabel(mode)).tag(mode)
                        }
                    }
                    .labelsHidden()
                    .tint(DIRTheme.cyan)
                }
                .padding(.vertical, 10)
                environmentStatusRow
            }
        }
    }

    private var environmentStatusRow: some View {
        Group {
            Divider().overlay(DIRTheme.hairline)
            if liveValidation.states.contains(.invalidEnvironment),
               case .failure(let error) = PlannerEnvironment.make(altitudeMeters: store.input.altitudeMeters, salinity: store.input.salinity) {
                let summary = PlannerUserFacingCopy.invalidEnvironmentSummary(for: store.input, error: error)
                VStack(alignment: .leading, spacing: 6) {
                    Text(String(localized: "planner.environment.invalid.title"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(DIRTheme.red)
                    Text(summary.statusMessage)
                        .font(.caption)
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    if let hint = summary.correctiveHint {
                        Text(hint)
                            .font(.caption2)
                            .foregroundStyle(DIRTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.vertical, 10)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(String(localized: "planner.environment.invalid.a11y"))
            } else if let summary = store.plan.environmentSummary {
                VStack(alignment: .leading, spacing: 6) {
                    Text(summary.isActive ? String(localized: "planner.environment.active.title") : String(localized: "planner.environment.default.title"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(summary.isActive ? DIRTheme.cyan : DIRTheme.muted)
                    Text(summary.statusMessage)
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                    if summary.isActive {
                        Text(
                            String(
                                format: String(localized: "planner.environment.active.detail"),
                                Formatters.one(summary.surfacePressureBar),
                                Formatters.zero(summary.waterDensityKgPerM3)
                            )
                        )
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.white.opacity(0.86))
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.vertical, 10)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(summary.statusMessage)
            }
        }
    }

    private var repetitivePlanningCard: some View {
        DIRCard(String(localized: "planner.repetitive.title"), icon: "arrow.triangle.2.circlepath", accent: DIRTheme.yellow) {
            VStack(alignment: .leading, spacing: 10) {
                Toggle(isOn: $store.repetitivePlanningEnabled) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "planner.repetitive.toggle"))
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.white)
                        Text(String(localized: "planner.repetitive.toggle_hint"))
                            .font(.caption2)
                            .foregroundStyle(DIRTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .tint(DIRTheme.cyan)
                .accessibilityHint(String(localized: "planner.repetitive.toggle.a11y"))

                if store.repetitivePlanningEnabled {
                    Divider().overlay(DIRTheme.hairline)
                    plannerField(
                        String(localized: "planner.repetitive.surface_interval"),
                        value: $store.surfaceIntervalMinutes,
                        unit: "min",
                        step: 5
                    )
                    repetitiveSnapshotStatusView
                    if let context = store.plan.repetitiveContext, context.tissueStateApplied {
                        DIRWarningBox(text: String(localized: "planner.repetitive.active_notice"))
                    } else if let issue = store.plan.repetitiveContext?.snapshotIssue {
                        plannerStateWarning(issue.userFacingMessage)
                    }
                    Text(String(localized: "planner.repetitive.reference_only"))
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.yellow)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(String(localized: "planner.repetitive.not_from_log"))
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text(String(localized: "planner.repetitive.clean_dive"))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var repetitiveSnapshotStatusView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(String(localized: "planner.repetitive.snapshot.status"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DIRTheme.muted)
                Spacer()
                Text(repetitiveSnapshotStatusLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(repetitiveSnapshotStatusColor)
            }
            if let createdAt = store.lastTissueSnapshot?.createdAt {
                Text(
                    String(
                        format: String(localized: "planner.repetitive.snapshot.timestamp"),
                        createdAt.formatted(date: .abbreviated, time: .shortened)
                    )
                )
                .font(.caption2.monospacedDigit())
                .foregroundStyle(.white.opacity(0.86))
            }
            if let source = store.plan.repetitiveContext?.snapshotSource {
                Text(source)
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(repetitiveSnapshotAccessibilityLabel)
    }

    private var repetitiveSnapshotStatusLabel: String {
        guard store.repetitivePlanningEnabled else {
            return String(localized: "planner.repetitive.snapshot.disabled")
        }
        if store.plan.repetitiveContext?.tissueStateApplied == true {
            return String(localized: "planner.repetitive.snapshot.loaded")
        }
        if store.lastTissueSnapshot == nil {
            return String(localized: "planner.repetitive.snapshot.missing")
        }
        if let issue = store.plan.repetitiveContext?.snapshotIssue {
            return issue.userFacingMessage.title
        }
        return String(localized: "planner.repetitive.snapshot.unavailable")
    }

    private var repetitiveSnapshotStatusColor: Color {
        if store.plan.repetitiveContext?.tissueStateApplied == true {
            return DIRTheme.green
        }
        if store.repetitivePlanningEnabled && store.plan.repetitiveContext?.snapshotIssue != nil {
            return DIRTheme.red
        }
        return DIRTheme.yellow
    }

    private var repetitiveSnapshotAccessibilityLabel: String {
        [repetitiveSnapshotStatusLabel, store.plan.repetitiveContext?.snapshotIssue?.userFacingMessage.correctiveHint]
            .compactMap { $0 }
            .joined(separator: ". ")
    }

    private var plannerCylindersCard: some View {
        DIRCard(String(localized: "planner.card.cylinders"), icon: "fuelpump", accent: DIRTheme.cyan) {
            VStack(spacing: 12) {
                ForEach($store.input.plannerCylinders) { $entry in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(String(localized: "planner.cylinder.title"))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(DIRTheme.muted)
                            Spacer()
                            if store.input.plannerCylinders.count > 1 {
                                Button(role: .destructive) {
                                    store.input.plannerCylinders.removeAll { $0.id == entry.id }
                                    store.input.syncLegacyGasesFromPlannerCylinders()
                                } label: {
                                    Text(String(localized: "planner.cylinder.remove"))
                                        .font(.caption2.weight(.semibold))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        HStack {
                            Text(String(localized: "planner.cylinder.role"))
                                .foregroundStyle(DIRTheme.muted)
                            Spacer()
                            Picker("", selection: $entry.role) {
                                ForEach(GasRole.allCases) { role in
                                    Text(role.localizedTitle).tag(role)
                                }
                            }
                            .labelsHidden()
                            .tint(DIRTheme.cyan)
                        }
                        .font(.callout)
                        HStack {
                            Text(String(localized: "planner.cylinder.tank_size"))
                                .foregroundStyle(DIRTheme.muted)
                            Spacer()
                            Picker("", selection: $entry.tankSize) {
                                ForEach(TankSize.allCases) { size in
                                    Text(size.rawValue).tag(size)
                                }
                            }
                            .labelsHidden()
                            .tint(DIRTheme.cyan)
                        }
                        .font(.callout)
                        Text(
                            String(
                                format: String(localized: "planner.mod.value_format"),
                                Formatters.depth(entry.modMeters(environment: store.input.plannerEnvironment), units: unitPreference).text
                            )
                        )
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(DIRTheme.cyan)
                        if entry.role != .bottom {
                            plannerDepthField(
                                String(localized: "planner.field.switch_depth"),
                                meters: $entry.switchDepthMeters,
                                step: 1
                            )
                        }
                        GasMixCard(
                            mix: $entry.gas,
                            accent: entry.role == .bottom ? DIRTheme.green : DIRTheme.yellow,
                            unitPreference: unitPreference,
                            plannerEnvironment: store.input.plannerEnvironment
                        ) {
                            store.input.syncLegacyGasesFromPlannerCylinders()
                            store.refreshDerivedPlanningPreview()
                        }
                        .onChange(of: entry.role) { _, newRole in
                            entry.gas.role = newRole
                            store.input.syncLegacyGasesFromPlannerCylinders()
                            store.refreshDerivedPlanningPreview()
                        }
                        .onChange(of: entry.switchDepthMeters) { _, _ in
                            store.refreshDerivedPlanningPreview()
                        }
                        if entry.isSwitchDepthBeyondMOD(environment: store.input.plannerEnvironment) {
                            Text(String(localized: "planner.mod.exceeds_allowed"))
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(DIRTheme.red)
                        }
                    }
                    Divider().overlay(DIRTheme.hairline)
                }
                Button {
                    store.input.plannerCylinders.append(
                        PlannerCylinderEntry(
                            role: .deco,
                            tankSize: .liters12,
                            gas: GasMix(name: "Deco", role: .deco, oxygen: 0.50, helium: 0, maxPPO2: 1.6)
                        )
                    )
                } label: {
                    Text(String(localized: "planner.cylinder.add"))
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(DIRTheme.cyan)
                }
                .buttonStyle(.plain)
                Divider().overlay(DIRTheme.hairline)
                Text(String(localized: "planner.section.consumption"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DIRTheme.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                plannerField(String(localized: "planner.field.sac_rmv"), value: $store.input.sacLitersPerMinute, unit: "L/min", step: 1)
                Divider().overlay(DIRTheme.hairline)
                plannerField(String(localized: "planner.field.sac_emergency"), value: $store.input.emergencySacLitersPerMinute, unit: "L/min", step: 1)
            }
        }
        .onChange(of: store.input.plannerCylinders) { _, _ in
            store.input.syncLegacyGasesFromPlannerCylinders()
            store.refreshDerivedPlanningPreview()
        }
    }

    private var technicalAnalysisCard: some View {
        DIRCard(String(localized: "planner.card.density_end"), icon: "gauge", accent: DIRTheme.yellow) {
            let endMeasurement = Formatters.depth(store.analysis.endMeters, units: unitPreference)
            let eadMeasurement = store.analysis.eadMeters.map { Formatters.depth($0, units: unitPreference) }
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    DIRMetricTile(title: "PPO2", value: Formatters.one(store.analysis.ppO2AtDepth), color: warningColor(ppO2: store.analysis.ppO2AtDepth))
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: String(localized: "planner.metric.density"), value: Formatters.one(store.analysis.densityAtDepth), unit: "g/L", color: densityColor(store.analysis.densityRating))
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "END", value: endMeasurement.value, unit: endMeasurement.unit, color: store.analysis.endMeters > 30 ? DIRTheme.yellow : DIRTheme.green)
                }
                Divider().overlay(DIRTheme.hairline)
                HStack(spacing: 0) {
                    DIRMetricTile(title: "EAD", value: eadMeasurement?.value ?? "-", unit: eadMeasurement?.unit, color: DIRTheme.cyan)
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(
                        title: String(localized: "planner.metric.cns_preview"),
                        value: store.analysis.cnsPercentDisplay,
                        unit: "%",
                        color: store.analysis.cnsPercent > 80 ? DIRTheme.red : DIRTheme.cyan
                    )
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "OTU", value: Formatters.zero(store.analysis.otu), color: DIRTheme.cyan)
                }
                plannerMutedFootnote(String(localized: "planner.metric.cns_preview.footnote"))
                Divider().overlay(DIRTheme.hairline)
                Text(String(localized: "planner.oxygen_exposure.disclaimer"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel(String(localized: "planner.oxygen_exposure.a11y"))
                Text(
                    String(
                        format: String(localized: "planner.oxygen_exposure.daily_summary"),
                        Formatters.zero(store.analysis.cnsDailyPercent),
                        Formatters.zero(store.analysis.otuDaily24h)
                    )
                )
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var reserveCard: some View {
        DIRCard(String(localized: "planner.card.reserve"), icon: "gauge", accent: DIRTheme.green) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    DIRMetricTile(title: String(localized: "planner.metric.available"), value: Formatters.zero(store.input.availableGasLiters), unit: "L", color: DIRTheme.green)
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: String(localized: "planner.metric.consumption"), value: Formatters.zero(store.analysis.consumptionLiters), unit: "L", color: DIRTheme.yellow)
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: String(localized: "planner.metric.remaining"), value: Formatters.zero(store.analysis.remainingBar), unit: "bar", color: store.analysis.remainingLiters < store.analysis.rockBottomLiters ? DIRTheme.red : DIRTheme.green)
                }
                Divider().overlay(DIRTheme.hairline)
                HStack(spacing: 0) {
                    DIRMetricTile(title: String(localized: "planner.metric.rock_bottom"), value: Formatters.zero(store.analysis.minimumGasBar), unit: "bar", color: DIRTheme.orange)
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: String(localized: "planner.metric.turn_pressure"), value: Formatters.zero(store.analysis.turnPressureBar), unit: "bar", color: DIRTheme.cyan)
                }
                if store.analysis.usesBottomPhaseConsumptionEstimate {
                    Text(String(localized: "planner.gas.bottom_phase_estimate_footnote"))
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.muted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Text(String(localized: "planner.gas.turn_pressure_rule_footnote"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var liveMODIssues: [MODValidationIssue] {
        PlannerMODValidator.liveInputIssues(input: store.input, environment: store.input.plannerEnvironment)
    }

    private var liveValidation: PlannerValidationResult {
        PlannerInputValidator.validate(store.input)
    }

    private var canCalculatePlan: Bool {
        plannerSafetyAcknowledged && liveValidation.isValid && liveMODIssues.isEmpty
    }

    @ViewBuilder
    private var plannerMODInputWarnings: some View {
        if !liveMODIssues.isEmpty {
            DIRCard(String(localized: "planner.mod.validation.title"), icon: "exclamationmark.triangle.fill", accent: DIRTheme.red) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(liveMODIssues) { issue in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(localized: "planner.mod.exceeds_allowed"))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(DIRTheme.red)
                            Text(
                                String(
                                    format: String(localized: "planner.mod.detail_format"),
                                    issue.gasLabel,
                                    Formatters.depth(issue.switchDepthMeters, units: unitPreference).text,
                                    Formatters.depth(issue.modMeters, units: unitPreference).text
                                )
                            )
                            .font(.caption2)
                            .foregroundStyle(.white)
                        }
                    }
                    Text(String(localized: "planner.mod.incompatible"))
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.muted)
                }
            }
        }
    }

    @ViewBuilder
    private var plannerWarnings: some View {
        if store.analysis.warnings.isEmpty {
            DIRWarningBox(text: String(localized: "planner.disclaimer.informative"))
        } else {
            DIRCard(String(localized: "planner.warning.title"), icon: "exclamationmark.triangle.fill", accent: DIRTheme.red) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(store.analysis.warnings, id: \.self) { warning in
                        HStack(alignment: .top, spacing: 8) {
                            Circle()
                                .fill(DIRTheme.red)
                                .frame(width: 7, height: 7)
                                .padding(.top, 6)
                            Text(warning)
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
        }
    }

    private var teamPreviewCard: some View {
        DIRCard(String(localized: "planner.team.matching_title"), icon: "person.2", accent: DIRTheme.cyan) {
            VStack(spacing: 10) {
                Text(String(localized: "planner.team.preview_only"))
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(DIRTheme.yellow)
                    .frame(maxWidth: .infinity, alignment: .leading)
                ForEach(store.input.teamMembers) { member in
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(member.name)
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(.white)
                            Text(String(format: String(localized: "planner.team.sac_format"), Formatters.zero(member.sacLitersPerMinute)))
                                .font(.caption)
                                .foregroundStyle(DIRTheme.muted)
                        }
                        Spacer()
                        Text(String(format: String(localized: "planner.team.available_gas_format"), Formatters.zero(member.cylinder.availableGasLiters)))
                            .font(.callout.monospacedDigit().weight(.semibold))
                            .foregroundStyle(DIRTheme.cyan)
                    }
                    Divider().overlay(DIRTheme.hairline)
                }
                Text(String(localized: "planner.team.preview_only_notice"))
                    .font(.footnote)
                    .foregroundStyle(DIRTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var plannerSafetyAcknowledgment: some View {
        Toggle(
            isOn: Binding(
                get: { plannerSafetyAcknowledged },
                set: { plannerSafetyAckRevision = $0 ? PlannerSafetyAcknowledgment.currentRevision : "" }
            )
        ) {
            Text(String(localized: "planner.safety_ack.label"))
                .font(.callout.weight(.semibold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
        .tint(DIRTheme.cyan)
        .padding(.vertical, 4)
        .accessibilityHint(String(localized: "planner.safety_ack.hint"))
    }

    private var calculateButton: some View {
        Button {
            let validation = PlannerInputValidator.validate(store.input)
            if !validation.isValid {
                calculateErrorMessage = validation.messages.first ?? String(localized: "planner.gas.mix_invalid")
                showCalculateError = true
                return
            }
            if PlannerGasSchedule.hasMODBlockingIssues(input: store.input) {
                calculateErrorMessage = String(localized: "planner.mod.block_calculate")
                showCalculateError = true
                return
            }
            store.calculate()
            showPlan = true
        } label: {
            HStack(spacing: 8) {
                if store.isCalculating {
                    ProgressView()
                        .tint(.black)
                }
                Text(String(localized: store.isCalculating ? "planner.calculate.in_progress" : "Calcola Piano"))
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(canCalculatePlan ? .black : DIRTheme.muted)
            }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(canCalculatePlan ? DIRTheme.cyan : DIRTheme.surface2)
                        .shadow(color: DIRTheme.cyan.opacity(canCalculatePlan ? 0.28 : 0), radius: 14, x: 0, y: 8)
                )
        }
        .buttonStyle(.plain)
        .disabled(!canCalculatePlan || store.isCalculating)
        .padding(.top, 4)
        .accessibilityLabel(String(localized: "Calcola Piano"))
        .accessibilityHint(
            liveMODIssues.isEmpty
                ? String(localized: "planner.safety_ack.hint")
                : String(localized: "planner.mod.block_calculate")
        )
    }

    private func depthDisplayBinding(_ meters: Binding<Double>) -> Binding<Double> {
        Binding(
            get: { Formatters.depthValue(meters.wrappedValue, units: unitPreference) },
            set: { meters.wrappedValue = max(0, Formatters.metersFromDepthDisplay($0, units: unitPreference)) }
        )
    }

    private func temperatureDisplayBinding(_ celsius: Binding<Double>) -> Binding<Double> {
        Binding(
            get: {
                switch unitPreference {
                case .metric: return celsius.wrappedValue
                case .imperial: return IOSUnitConversions.fahrenheit(fromCelsius: celsius.wrappedValue)
                }
            },
            set: { celsius.wrappedValue = Formatters.celsiusFromTemperatureDisplay($0, units: unitPreference) }
        )
    }

    private func plannerDepthField(_ title: String, meters: Binding<Double>, step: Double = 1) -> some View {
        let displayStep = unitPreference == .metric ? step : max(1, IOSUnitConversions.feet(fromMeters: step))
        return plannerField(
            title,
            value: depthDisplayBinding(meters),
            unit: Formatters.depthUnitLabel(unitPreference),
            step: displayStep
        )
    }

    private func plannerTemperatureField(_ title: String, celsius: Binding<Double>) -> some View {
        plannerField(
            title,
            value: temperatureDisplayBinding(celsius),
            unit: Formatters.temperatureUnitLabel(unitPreference),
            step: unitPreference == .metric ? 1 : 2
        )
    }

    private func plannerField(_ title: String, value: Binding<Double>, unit: String, step: Double) -> some View {
        HStack {
            Text(title)
                .font(.callout)
                .foregroundStyle(.white)
            Spacer()
            Text("\(Formatters.zero(value.wrappedValue)) \(unit)")
                .font(.callout.monospacedDigit())
                .foregroundStyle(.white)
                .frame(width: 96, alignment: .trailing)
            HStack(spacing: 1) {
                Button {
                    value.wrappedValue = max(0, value.wrappedValue - step)
                } label: {
                    Image(systemName: "minus")
                        .frame(width: 28, height: 24)
                }
                Button {
                    value.wrappedValue += step
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 28, height: 24)
                }
            }
            .font(.caption.weight(.bold))
            .foregroundStyle(DIRTheme.cyan)
            .background(RoundedRectangle(cornerRadius: 5).fill(DIRTheme.surface2))
        }
        .padding(.vertical, 10)
    }

    private func densityColor(_ rating: GasDensityRating) -> Color {
        switch rating {
        case .green: return DIRTheme.green
        case .yellow: return DIRTheme.yellow
        case .red: return DIRTheme.red
        }
    }

    private func warningColor(ppO2: Double) -> Color {
        ppO2 > store.input.bottomGas.maxPPO2 ? DIRTheme.red : DIRTheme.green
    }

    private func plannerMutedFootnote(_ text: String) -> some View {
        Text(text)
            .font(.caption2)
            .foregroundStyle(DIRTheme.muted)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
    }

    private func plannerStateWarning(_ message: PlannerUserFacingMessage) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(message.title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(message.severity == .blocking ? DIRTheme.red : DIRTheme.yellow)
            Text(message.message)
                .font(.caption)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
            if let hint = message.correctiveHint {
                Text(hint)
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message.accessibilityLabel)
    }
}

struct PlanResultView: View {
    @EnvironmentObject private var store: PlannerStore
    @AppStorage(IOSUnitPreference.storageKey) private var unitsRaw = IOSUnitPreference.metric.rawValue
    @AppStorage(PlannerCNSDescentBottomCheckSettings.storageKey) private var cnsDescentBottomCheckEnabled = PlannerCNSDescentBottomCheckSettings.defaultEnabled

    private var unitPreference: IOSUnitPreference { IOSUnitPreference.fromStorage(unitsRaw) }

    private var cnsDescentBottomWarningActive: Bool {
        store.plan.gasAnalysis.cnsDescentBottomExceedsPlannerThreshold(checkEnabled: cnsDescentBottomCheckEnabled)
    }

    private var cnsDescentBottomTileAccessibilityLabel: String {
        let value = Formatters.zero(store.plan.gasAnalysis.cnsDescentBottomPercent)
        let base = "\(String(localized: "planner.metric.cns_descent_bottom")), \(value) percent"
        guard cnsDescentBottomWarningActive else { return base }
        return "\(String(localized: "planner.accessibility.cns_descent_bottom.warning.label")) \(base)"
    }

    private var cnsDescentBottomWarningBanner: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(DIRTheme.red)
                Text(String(localized: "planner.cns_descent_bottom.warning"))
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(DIRTheme.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text(String(localized: "planner.cns_descent_bottom.warning.hint"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(localized: "planner.accessibility.cns_descent_bottom.warning.label"))
        .accessibilityHint(String(localized: "planner.accessibility.cns_descent_bottom.warning.hint"))
    }

    private func plannerResultMutedFootnote(_ text: String) -> some View {
        Text(text)
            .font(.caption2)
            .foregroundStyle(DIRTheme.muted)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
    }

    private func depthText(_ meters: Double) -> String {
        Formatters.depth(meters, units: unitPreference).text
    }
    @State private var tab: PlanTab = .plan

    private var planShareText: String {
        var lines = [String(localized: "planner.export.header")]
        lines.append("TTR: \(store.plan.ttrMinutes) min")
        lines.append("NDL: \(Formatters.one(store.plan.ndlMinutes)) min")
        lines.append("CNS: \(Formatters.zero(store.plan.cnsPercent))% · OTU: \(Formatters.zero(store.plan.otu))")
        if store.plan.decoStops.isEmpty {
            lines.append(String(localized: "planner.export.no_deco_stops"))
        } else {
            lines.append(String(localized: "planner.export.deco_stops"))
            for stop in store.plan.decoStops {
                lines.append(String(format: String(localized: "planner.export.deco_stop_line"), depthText(stop.depthMeters), stop.minutes, stop.gas, Formatters.one(stop.ppO2)))
            }
        }
        lines.append(String(localized: "planner.export.indicative_footer"))
        return lines.joined(separator: "\n")
    }

    var body: some View {
        ZStack {
            DIRBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    resultHeaderBadge
                    resultTabs
                    modValidationSection
                    resultWarningsSection
                    bailoutScheduleHint
                    switch tab {
                    case .plan:
                        resultGrid
                        gasLedgerCard
                        ascentTable
                        contingencyCard
                        teamMatchCard
                        briefingCard
                    case .curve:
                        buhlmannChart
                    case .charts:
                        segmentTimeline
                        gfComparisonCard
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 18)
            }
        }
        .navigationTitle(String(localized: "planner.result.title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: planShareText) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(DIRTheme.cyan)
                }
                .accessibilityLabel(Text(String(localized: "planner.export.share.a11y")))
            }
        }
    }

    private var referenceDepthSummary: String {
        let label: String
        switch store.input.planningDepthReference {
        case .maximumDepth:
            label = String(localized: "planner.result.reference_depth.max")
        case .averageDepth:
            label = String(localized: "planner.result.reference_depth.average")
        }
        return String(format: String(localized: "planner.result.reference_depth"), label)
    }

    private var resultHeaderBadge: some View {
        let header = store.plan.resultHeader
        let accent = resultHeaderAccent(header.severity)
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: resultHeaderIcon(header.kind))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(accent)
                Text(header.title)
                    .font(.callout.weight(.bold))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text(header.subtitle)
                .font(.caption)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
            if store.plan.calculationCompleteness == .incompletePartialStops {
                incompleteCalculationBanner
            }
            if store.plan.repetitiveContext?.tissueStateApplied == true {
                Text(String(localized: "planner.repetitive.result_badge"))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(DIRTheme.yellow)
            }
            Text(referenceDepthSummary)
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
            Text(String(localized: "planner.header.reference_only.hint"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                .fill(accent.opacity(0.12))
                .overlay(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).stroke(accent.opacity(0.45), lineWidth: 1))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(header.title). \(header.subtitle)")
    }

    private var incompleteCalculationBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "planner.result.calculation_incomplete"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(DIRTheme.red)
                .fixedSize(horizontal: false, vertical: true)
            Text(String(localized: "planner.result.calculation_incomplete.detail"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
            Text(String(localized: "planner.result.calculation_incomplete.recovery"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(DIRTheme.red.opacity(0.12))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.red.opacity(0.45), lineWidth: 1))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(String(localized: "planner.result.calculation_incomplete")) \(String(localized: "planner.result.calculation_incomplete.detail"))"
        )
    }

    @ViewBuilder
    private var resultWarningsSection: some View {
        let warnings = store.plan.userFacingWarnings.filter { $0.severity != .info }
        if !warnings.isEmpty {
            DIRCard(String(localized: "planner.result.warnings.title"), icon: "exclamationmark.triangle.fill", accent: DIRTheme.red) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(warnings) { warning in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(warning.title)
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(warning.severity == .blocking ? DIRTheme.red : DIRTheme.yellow)
                            Text(warning.message)
                                .font(.caption)
                                .foregroundStyle(.white)
                                .fixedSize(horizontal: false, vertical: true)
                            if let hint = warning.correctiveHint {
                                Text(hint)
                                    .font(.caption2)
                                    .foregroundStyle(DIRTheme.muted)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(warning.accessibilityLabel)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var bailoutScheduleHint: some View {
        if !PlannerGasSchedule.bailoutCylinders(from: store.input).isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                DIRWarningBox(text: String(localized: "planner.bailout.schedule_hint"))
                ForEach(PlannerGasSchedule.bailoutAvailabilityWarnings(input: store.input), id: \.self) { warning in
                    Text(warning)
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.yellow)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    @ViewBuilder
    private var gasLedgerCard: some View {
        if let failure = store.plan.gasLedgerFailure {
            DIRCard(String(localized: "planner.gas_ledger.title"), icon: "fuelpump", accent: DIRTheme.red) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(failure.userFacingMessage.title)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(DIRTheme.red)
                    Text(failure.userFacingMessage.message)
                        .font(.caption)
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    if let hint = failure.userFacingMessage.correctiveHint {
                        Text(hint)
                            .font(.caption2)
                            .foregroundStyle(DIRTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        } else if let ledger = store.plan.gasLedger {
            DIRCard(String(localized: "planner.gas_ledger.title"), icon: "fuelpump", accent: DIRTheme.cyan) {
                VStack(spacing: 10) {
                    Text(String(localized: "planner.gas_ledger.subtitle"))
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                    ForEach(ledger.entries, id: \.cylinderId) { entry in
                        gasLedgerEntryRow(entry, ledger: ledger)
                        Divider().overlay(DIRTheme.hairline)
                    }
                    if !ledger.unusedPlannedEntries.isEmpty {
                        Text(String(localized: "planner.gas_ledger.unused_title"))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(DIRTheme.muted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ForEach(ledger.unusedPlannedEntries, id: \.cylinderId) { entry in
                            unusedGasLedgerEntryRow(entry)
                            Divider().overlay(DIRTheme.hairline)
                        }
                    }
                }
            }
        }
    }

    private func gasLedgerEntryRow(_ entry: GasConsumptionLedger.Entry, ledger: GasConsumptionLedger) -> some View {
        let cylinderLabel = store.input.plannerCylinders.first(where: { $0.id == entry.cylinderId })?.tankSize.rawValue
            ?? store.input.primaryCylinder.name
        let reserveBreached = ledger.warnings.contains {
            if case .reserveBreached(let gas) = $0 { return gas == entry.gasLabel }
            return false
        }
        let minimumBreached = ledger.warnings.contains {
            if case .minimumGasBreached(let gas) = $0 { return gas == entry.gasLabel }
            return false
        }
        let lostGasFailed = ledger.warnings.contains {
            if case .lostGasContingencyFailed(let gas) = $0 { return gas == entry.gasLabel }
            return false
        }
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.gasLabel)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white)
                    Text("\(entry.role.localizedTitle) · \(cylinderLabel)")
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.muted)
                }
                Spacer()
                if reserveBreached || minimumBreached || lostGasFailed {
                    Text(String(localized: "planner.gas_ledger.reserve_flag"))
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(DIRTheme.red)
                }
            }
            HStack(spacing: 0) {
                DIRMetricTile(title: String(localized: "planner.metric.consumption"), value: Formatters.zero(entry.consumedLiters), unit: "L", color: DIRTheme.yellow)
                Divider().overlay(DIRTheme.hairline)
                DIRMetricTile(title: String(localized: "planner.metric.remaining"), value: Formatters.zero(entry.remainingLiters), unit: "L", color: entry.remainingLiters < 0 ? DIRTheme.red : DIRTheme.green)
                Divider().overlay(DIRTheme.hairline)
                DIRMetricTile(title: String(localized: "planner.gas_ledger.remaining_pressure"), value: Formatters.zero(entry.remainingBar), unit: "bar", color: reserveBreached ? DIRTheme.red : DIRTheme.cyan)
            }
            if lostGasFailed {
                Text(String(localized: "planner.gas_ledger.warning.lost_gas.message"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.yellow)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            String(
                format: String(localized: "planner.gas_ledger.entry.a11y"),
                entry.gasLabel,
                Formatters.zero(entry.consumedLiters),
                Formatters.zero(entry.remainingBar)
            )
        )
    }

    private func unusedGasLedgerEntryRow(_ entry: GasConsumptionLedger.UnusedPlannedEntry) -> some View {
        let cylinderLabel = store.input.plannerCylinders.first(where: { $0.id == entry.cylinderId })?.tankSize.rawValue
            ?? store.input.primaryCylinder.name
        let subtitle = entry.isStandbyOrBailout
            ? String(localized: "planner.gas_ledger.unused_standby")
            : String(localized: "planner.gas_ledger.unused_planned")
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.gasLabel)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white)
                    Text("\(entry.role.localizedTitle) · \(cylinderLabel)")
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.muted)
                }
                Spacer()
                Text(subtitle)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(DIRTheme.yellow)
            }
            HStack(spacing: 0) {
                DIRMetricTile(
                    title: String(localized: "planner.gas_ledger.available_gas"),
                    value: Formatters.zero(entry.availableLiters),
                    unit: "L",
                    color: DIRTheme.cyan
                )
                Divider().overlay(DIRTheme.hairline)
                DIRMetricTile(
                    title: String(localized: "planner.gas_ledger.remaining_pressure"),
                    value: Formatters.zero(entry.availableBar),
                    unit: "bar",
                    color: DIRTheme.cyan
                )
            }
            Text(String(localized: "planner.gas_ledger.not_consumed_note"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func resultHeaderAccent(_ severity: PlannerWarningSeverity) -> Color {
        switch severity {
        case .info: return DIRTheme.cyan
        case .warning: return DIRTheme.yellow
        case .blocking: return DIRTheme.red
        }
    }

    private func resultHeaderIcon(_ kind: PlannerResultHeaderKind) -> String {
        switch kind {
        case .noDecoReference: return "checkmark.circle"
        case .decoRequiredReference: return "arrow.up.circle"
        case .invalidInput, .unsupportedProfile, .noValidDecompressionSolution, .calculationIncomplete: return "xmark.octagon"
        case .repetitiveReferencePlan: return "arrow.triangle.2.circlepath"
        case .environmentAdjustedReferencePlan: return "mountain.2"
        }
    }

    @ViewBuilder
    private var modValidationSection: some View {
        if !store.plan.modValidationIssues.isEmpty {
            DIRCard(String(localized: "planner.mod.validation.title"), icon: "exclamationmark.triangle.fill", accent: DIRTheme.red) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(store.plan.modValidationIssues) { issue in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(localized: "planner.mod.exceeds_allowed"))
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(DIRTheme.red)
                            Text(
                                String(
                                    format: String(localized: "planner.mod.detail_format"),
                                    issue.gasLabel,
                                    depthText(issue.switchDepthMeters),
                                    depthText(issue.modMeters)
                                )
                            )
                            .font(.caption)
                            .foregroundStyle(.white)
                        }
                    }
                    Text(String(localized: "planner.mod.incompatible"))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                    Text(String(localized: "planner.mod.hint"))
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.muted)
                }
            }
        }
    }

    private var resultTabs: some View {
        HStack(spacing: 0) {
            ForEach(PlanTab.allCases) { item in
                Button {
                    tab = item
                } label: {
                    VStack(spacing: 10) {
                        Text(item.title)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(tab == item ? DIRTheme.cyan : .white.opacity(0.72))
                        Rectangle()
                            .fill(tab == item ? DIRTheme.cyan : .clear)
                            .frame(height: 2)
                    }
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .accessibilityLabel(tabAccessibilityLabel(for: item))
                .accessibilityAddTraits(tab == item ? .isSelected : [])
            }
        }
        .padding(.top, 10)
    }

    private func tabAccessibilityLabel(for item: PlanTab) -> String {
        if tab == item {
            return String(format: String(localized: "planner.tab.a11y.selected"), item.title)
        }
        return String(format: String(localized: "planner.tab.a11y.unselected"), item.title)
    }

    private var resultGrid: some View {
        let endMeasurement = Formatters.depth(store.analysis.endMeters, units: unitPreference)
        return VStack(spacing: 0) {
            HStack(spacing: 0) {
                    DIRMetricTile(title: "TTR", value: "\(store.plan.ttrMinutes)", unit: "min")
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: String(localized: "planner.result.deco_stops"), value: "\(store.plan.decoStops.count)")
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "OTU", value: Formatters.zero(store.plan.otu))
            }
            Divider().overlay(DIRTheme.hairline)
            HStack(spacing: 0) {
                DIRMetricTile(
                    title: String(localized: "planner.result.max_depth"),
                    value: Formatters.depth(store.input.plannedDepthMeters, units: unitPreference).value,
                    unit: Formatters.depth(store.input.plannedDepthMeters, units: unitPreference).unit
                )
                Divider().overlay(DIRTheme.hairline)
                DIRMetricTile(title: String(localized: "planner.result.bottom_time"), value: Formatters.zero(store.input.plannedBottomMinutes), unit: "min")
                Divider().overlay(DIRTheme.hairline)
                DIRMetricTile(
                    title: String(localized: "planner.metric.cns_full_plan"),
                    value: store.plan.gasAnalysis.cnsPercentDisplay,
                    unit: "%"
                )
            }
            plannerResultMutedFootnote(String(localized: "planner.metric.cns_full_plan.footnote"))
            Divider().overlay(DIRTheme.hairline)
            HStack(spacing: 0) {
                DIRMetricTile(title: "NDL", value: Formatters.one(store.plan.ndlMinutes), unit: "min")
            }
            Text(String(localized: "planner.ndl.reference_ascent_footnote"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
            Divider().overlay(DIRTheme.hairline)
            HStack(spacing: 0) {
                DIRMetricTile(
                    title: String(localized: "planner.metric.cns_descent_bottom"),
                    value: Formatters.zero(store.plan.gasAnalysis.cnsDescentBottomPercent),
                    unit: "%",
                    color: cnsDescentBottomWarningActive ? DIRTheme.red : DIRTheme.cyan,
                    icon: cnsDescentBottomWarningActive ? "exclamationmark.triangle.fill" : nil
                )
                .accessibilityLabel(cnsDescentBottomTileAccessibilityLabel)
            }
            plannerResultMutedFootnote(String(localized: "planner.metric.cns_descent_bottom.footnote"))
            if cnsDescentBottomWarningActive {
                cnsDescentBottomWarningBanner
            }
            Divider().overlay(DIRTheme.hairline)
            HStack(spacing: 0) {
                DIRMetricTile(
                    title: String(localized: "planner.metric.cns_ascent_deco_estimate"),
                    value: Formatters.zero(store.plan.gasAnalysis.cnsAscentDecoEstimatePercent),
                    unit: "%",
                    color: DIRTheme.cyan
                )
            }
            plannerResultMutedFootnote(String(localized: "planner.metric.cns_ascent_deco_estimate.footnote"))
            Divider().overlay(DIRTheme.hairline)
            VStack(spacing: 4) {
                Text(String(localized: "planner.oxygen_exposure.disclaimer"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
                Text(
                    String(
                        format: String(localized: "planner.oxygen_exposure.daily_summary"),
                        Formatters.zero(store.plan.gasAnalysis.cnsDailyPercent),
                        Formatters.zero(store.plan.gasAnalysis.otuDaily24h)
                    )
                )
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
                if store.plan.gasAnalysis.airBreakRecoveryApplied {
                    Text(String(localized: "planner.oxygen_exposure.air_break_applied"))
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.yellow)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            HStack(spacing: 0) {
                DIRMetricTile(title: String(localized: "planner.metric.density"), value: Formatters.one(store.analysis.densityAtDepth), unit: "g/L", color: store.analysis.densityRating == .red ? DIRTheme.red : DIRTheme.cyan)
                Divider().overlay(DIRTheme.hairline)
                DIRMetricTile(
                    title: "END",
                    value: endMeasurement.value,
                    unit: endMeasurement.unit,
                    color: DIRTheme.yellow
                )
                Divider().overlay(DIRTheme.hairline)
                DIRMetricTile(title: String(localized: "planner.metric.turn_pressure"), value: Formatters.zero(store.analysis.turnPressureBar), unit: "bar", color: DIRTheme.cyan)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(DIRTheme.surface.opacity(0.72))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(DIRTheme.hairline, lineWidth: 1))
        )
    }

    private var ascentTable: some View {
        DIRCard(String(localized: "planner.result.ascent_plan"), icon: nil, accent: DIRTheme.cyan) {
            if store.plan.calculationCompleteness == .incompletePartialStops {
                incompleteCalculationBanner
            } else {
                VStack(spacing: 9) {
                    tableRow([
                        String(localized: "planner.table.depth"),
                        String(localized: "planner.table.time"),
                        String(localized: "planner.table.gas"),
                        "PPO2"
                    ], isHeader: true)
                    ForEach(store.plan.decoStops) { stop in
                        tableRow([
                            depthText(stop.depthMeters),
                            "\(stop.minutes) min",
                            stop.gas,
                            Formatters.one(stop.ppO2)
                        ])
                    }
                    tableRow([depthText(0), "-", String(localized: "planner.table.surface"), "-"])
                }
            }
        }
    }

    private var segmentTimeline: some View {
        DIRCard(String(localized: "planner.result.timeline"), icon: "list.bullet.rectangle", accent: DIRTheme.cyan) {
            VStack(spacing: 8) {
                tableRow([
                    String(localized: "planner.table.type"),
                    String(localized: "planner.table.depth_short"),
                    String(localized: "planner.table.min"),
                    String(localized: "planner.table.gas")
                ], isHeader: true)
                ForEach(store.plan.segments) { segment in
                    tableRow([
                        segment.kind.rawValue,
                        depthText(segment.depthMeters),
                        Formatters.one(segment.minutes),
                        segment.gas
                    ])
                }
            }
        }
    }

    private var gfComparisonCard: some View {
        DIRCard(String(localized: "planner.result.gf_compare"), icon: "chart.line.uptrend.xyaxis", accent: DIRTheme.green) {
            VStack(spacing: 8) {
                tableRow([
                    "GF",
                    "TTS",
                    String(localized: "planner.table.stops"),
                    String(localized: "planner.table.note")
                ], isHeader: true)
                ForEach(store.plan.gfComparisons) { comparison in
                    tableRow([
                        comparison.label,
                        "\(comparison.ttsMinutes) min",
                        "\(comparison.stopCount)",
                        comparison.conservatismNote
                    ])
                }
            }
        }
    }

    private var contingencyCard: some View {
        DIRCard(String(localized: "planner.result.contingencies"), icon: "exclamationmark.triangle", accent: DIRTheme.yellow) {
            VStack(spacing: 10) {
                ForEach(store.plan.contingencyPlans) { plan in
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(plan.scenario.rawValue)
                                .font(.callout.weight(.bold))
                                .foregroundStyle(DIRTheme.yellow)
                            Spacer()
                            Text("\(plan.ttsMinutes) min")
                                .font(.callout.monospacedDigit().weight(.semibold))
                                .foregroundStyle(.white)
                        }
                        Text("\(Formatters.zero(plan.gasRequiredLiters)) L - \(plan.action)")
                            .font(.caption)
                            .foregroundStyle(DIRTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Divider().overlay(DIRTheme.hairline)
                }
            }
        }
    }

    private var teamMatchCard: some View {
        DIRCard(String(localized: "planner.team.match_title"), icon: "person.2", accent: DIRTheme.cyan) {
            VStack(spacing: 8) {
                tableRow([
                    String(localized: "planner.table.diver"),
                    String(localized: "planner.table.sac"),
                    String(localized: "planner.table.gas"),
                    String(localized: "planner.table.status")
                ], isHeader: true)
                ForEach(store.plan.teamMatches) { match in
                    tableRow([
                        match.diverName,
                        "\(Formatters.zero(match.sacLitersMinute))",
                        String(format: String(localized: "planner.team.available_gas_format"), Formatters.zero(match.availableLiters)),
                        match.status
                    ])
                }
            }
        }
    }

    private var briefingCard: some View {
        DIRCard(String(localized: "planner.briefing.title"), icon: "doc.text", accent: DIRTheme.green) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(store.plan.briefingLines, id: \.self) { line in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(DIRTheme.cyan)
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)
                        Text(line)
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.86))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Divider().overlay(DIRTheme.hairline)
                Text(String(localized: "planner.briefing.share_note"))
                    .font(.caption)
                    .foregroundStyle(DIRTheme.muted)
            }
        }
    }

    private func tableRow(_ values: [String], isHeader: Bool = false) -> some View {
        HStack {
            ForEach(Array(values.enumerated()), id: \.offset) { _, value in
                Text(value)
                    .font(isHeader ? .caption2.weight(.semibold) : .caption.monospacedDigit())
                    .foregroundStyle(isHeader ? DIRTheme.muted : .white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var buhlmannChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            if store.input.buhlmannUsesTrimixBackGas {
                DIRWarningBox(text: String(localized: "planner.gas.trimix_buhlmann_disclaimer"))
            }
            DIRCard(String(localized: "planner.buhlmann.curve_title"), icon: nil, accent: DIRTheme.cyan) {
                Text(String(localized: "planner.buhlmann.curve_disclaimer"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
                Chart(store.buhlmann.curve) { point in
                    LineMark(
                        x: .value(String(localized: "planner.buhlmann.axis.depth"), point.depthMeters),
                        y: .value(String(localized: "planner.buhlmann.axis.ndl"), point.ndlMinutes),
                        series: .value("Compartimenti", point.compartmentGroup)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
                .chartXAxis {
                    AxisMarks { AxisGridLine().foregroundStyle(DIRTheme.faint); AxisValueLabel().foregroundStyle(DIRTheme.muted) }
                }
                .chartXAxisLabel(String(localized: "planner.buhlmann.axis.depth"))
                .chartYAxis {
                    AxisMarks { AxisGridLine().foregroundStyle(DIRTheme.faint); AxisValueLabel().foregroundStyle(DIRTheme.muted) }
                }
                .chartYAxisLabel(String(localized: "planner.buhlmann.axis.ndl"))
                .frame(height: 220)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(String(localized: "planner.buhlmann.chart.a11y.label"))
                .accessibilityHint(String(localized: "planner.buhlmann.chart.a11y.hint"))
            }
        }
    }
}

enum PlanTab: String, CaseIterable, Identifiable {
    case plan
    case curve
    case charts

    var id: String { rawValue }

    var title: String {
        switch self {
        case .plan: return String(localized: "planner.tab.plan")
        case .curve: return String(localized: "planner.tab.curve")
        case .charts: return String(localized: "planner.tab.charts")
        }
    }
}
