    import SwiftUI
import Charts

struct PlannerView: View {
    @EnvironmentObject private var store: PlannerStore
    @EnvironmentObject private var equipment: EquipmentStore
    @AppStorage(PlannerSafetyAcknowledgment.storageKey) private var plannerSafetyAckRevision = ""
    @AppStorage(IOSUnitPreference.storageKey) private var unitsRaw = IOSUnitPreference.metric.rawValue
    @AppStorage(IOSPressureUnitPreference.storageKey) private var pressureUnitRaw = IOSPressureUnitPreference.storageValue(for: .bar)
    @State private var showPlan = false
    @State private var showPlanningReferenceInfo = false
    @State private var showCalculateError = false
    @State private var calculateErrorMessage = ""
    @State private var showPlannerReferenceDetails = false
    @State private var showChecklistImportPrompt = false
    @State private var showChecklistImportSheet = false
    @State private var checklistImportCandidates: [ChecklistPlannerImportCandidate] = []
    @State private var pendingChecklistExportAfterCalculate = false
    @State private var showPlannerPDFMenu = false
    @State private var shareablePDF: ShareablePDFItem?
    @State private var pdfExportAlertMessage: String?

    private var unitPreference: IOSUnitPreference { IOSUnitPreference.fromStorage(unitsRaw) }
    private var pressureUnitPreference: PressureUnit { IOSPressureUnitPreference.fromStorage(pressureUnitRaw) }
    private var modePresentation: PlannerResultPresentation { PlannerResultPresentation.presentation(for: store.mode) }

    private var profileMaxDepthLimitMeters: Double? {
        switch store.mode {
        case .base:
            return PlannerModeLimits.basicMaximumDepthMeters(for: store.input)
        case .deco:
            return PlannerModeLimits.decoMaximumDepthMeters(for: store.input)
        case .technical, .ccr:
            return nil
        }
    }

    private var profileMaxAverageDepthLimitMeters: Double? {
        modePresentation.showsAverageDepthInput ? store.input.plannedDepthMeters : nil
    }

    private var profileMaxBottomMinutes: Double? {
        store.mode == .base ? PlannerModeLimits.basicMaximumBottomMinutes(for: store.input) : nil
    }

    private var plannerSafetyAcknowledged: Bool {
        plannerSafetyAckRevision == PlannerSafetyAcknowledgment.currentRevision
    }

    var body: some View {
        NavigationStack {
            DIRScreenContainer {
                ScrollViewReader { scrollProxy in
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 7) {
                                Text(DIRIOSLocalizer.string("Planner"))
                                    .dirScreenTitleStyle()
                                Text(DIRIOSLocalizer.string("planner.header.subtitle"))
                                    .dirScreenSubtitleStyle()
                            }
                            plannerSafetyAcknowledgment
                            DIRWarningBox(text: DIRIOSLocalizer.string("planner.reference_only.warning"))
                            plannerReferenceDetailsSection
                            Group {
                                currentModeBanner
                                if store.mode != .base {
                                    decompressionMethodCard
                                }
                                if store.mode != .base, store.decompressionMethod != .buhlmann {
                                    RatioDecoPresetCard()
                                }
                                profileCard
                                if modePresentation.showsRepetitivePlanning {
                                    repetitivePlanningCard
                                }
                                if modePresentation.showsCNSDescentBottomSettings {
                                    PlannerCNSDescentBottomSettingsCard()
                                        .id(PlannerCNSDescentBottomCheckSettings.scrollTargetID)
                                }
                                plannerCylindersCard
                                if modePresentation.showsExtendedAnalysisTiles {
                                    technicalAnalysisCard
                                }
                                if modePresentation.showsReserveCard {
                                    emergencyCard
                                }
                                if modePresentation.showsReserveCard {
                                    reserveCard
                                }
                                plannerMODInputWarnings
                                plannerModeLimitWarnings
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
                    .dirCompanionScrollSurface()
                    .onChange(of: store.scrollToCNSThresholdSettings) { _, shouldScroll in
                        guard shouldScroll else { return }
                        scrollToCNSThresholdSettings(using: scrollProxy)
                    }
                    .onChange(of: showPlan) { _, isShowing in
                        guard !isShowing, store.scrollToCNSThresholdSettings else { return }
                        scrollToCNSThresholdSettings(using: scrollProxy)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        store.returnToPlannerModeSelection()
                    } label: {
                        Label(DIRIOSLocalizer.string("planner.mode_selection.back"), systemImage: "chevron.left")
                            .foregroundStyle(DIRTheme.cyan)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showPlannerPDFMenu = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(DIRTheme.cyan)
                    }
                    .accessibilityLabel(Text(DIRIOSLocalizer.string("pdf.export.share.a11y")))
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .confirmationDialog(
                DIRIOSLocalizer.string("pdf.export.share.a11y"),
                isPresented: $showPlannerPDFMenu,
                titleVisibility: .visible
            ) {
                Button(DIRIOSLocalizer.string("pdf.export.share.plan")) {
                    sharePlannerPDF(kind: .plan)
                }
                Button(DIRIOSLocalizer.string("pdf.export.share.briefing")) {
                    sharePlannerPDF(kind: .briefing)
                }
                Button(DIRIOSLocalizer.string("pdf.export.share.dive_pack")) {
                    sharePlannerPDF(kind: .divePack)
                }
                Button(DIRIOSLocalizer.string("pdf.export.cancel"), role: .cancel) {}
            }
            .sheet(item: $shareablePDF) { item in
                ShareSheetView(activityItems: [item.url])
            }
            .alert(DIRIOSLocalizer.string("pdf.export.error.title"), isPresented: Binding(
                get: { pdfExportAlertMessage != nil },
                set: { if !$0 { pdfExportAlertMessage = nil } }
            )) {
                Button(DIRIOSLocalizer.string("common.ok"), role: .cancel) {}
            } message: {
                Text(pdfExportAlertMessage ?? "")
            }
            .navigationDestination(isPresented: $showPlan) {
                PlanResultView(pendingChecklistExportPrompt: pendingChecklistExportAfterCalculate)
                    .environmentObject(store)
                    .environmentObject(equipment)
            }
            .task {
                store.bootstrapPlannerIfNeeded()
            }
            .alert(DIRIOSLocalizer.string("planner.reference.info.title"), isPresented: $showPlanningReferenceInfo) {
                Button(DIRIOSLocalizer.string("common.ok"), role: .cancel) {}
            } message: {
                Text(DIRIOSLocalizer.string("planner.reference.info.message"))
            }
            .alert(DIRIOSLocalizer.string("planner.calculate.error.title"), isPresented: $showCalculateError) {
                Button(DIRIOSLocalizer.string("common.ok"), role: .cancel) {}
            } message: {
                Text(calculateErrorMessage)
            }
            .confirmationDialog(
                DIRIOSLocalizer.string("checklist_planner.sync.import_prompt"),
                isPresented: $showChecklistImportPrompt,
                titleVisibility: .visible
            ) {
                Button(DIRIOSLocalizer.string("checklist_planner.sync.import_all")) {
                    importAllFromChecklist()
                }
                Button(DIRIOSLocalizer.string("checklist_planner.sync.choose_import")) {
                    openChecklistImportSheet()
                }
                Button(DIRIOSLocalizer.string("checklist_planner.sync.cancel"), role: .cancel) {}
            }
            .sheet(isPresented: $showChecklistImportSheet) {
                ChecklistPlannerSyncSheet(
                    flow: .importFromChecklist,
                    importCandidates: $checklistImportCandidates,
                    exportCandidates: .constant([]),
                    onConfirm: { confirmChecklistImport() },
                    onCancel: { showChecklistImportSheet = false }
                )
            }
        }
        .dirCompanionTabRoot()
    }

    private var currentModeBanner: some View {
        DIRCard(store.mode.localizedTabTitle, icon: "point.topleft.down.curvedto.point.bottomright.up", accent: DIRTheme.cyan) {
            Text(store.mode.localizedDescription)
                .font(.caption)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var decompressionMethodCard: some View {
        DIRCard(DIRIOSLocalizer.string("planner.deco_method.header"), icon: "arrow.triangle.branch", accent: DIRTheme.cyan) {
            PlannerDecompressionMethodPicker(method: $store.decompressionMethod, mode: store.mode)
        }
    }

    private func salinityLabel(_ mode: SalinityMode) -> String {
        switch mode {
        case .fresh: return DIRIOSLocalizer.string("salinity.fresh")
        case .salt: return DIRIOSLocalizer.string("salinity.salt")
        }
    }

    /// Display-only labels for legacy call sites.
    private func plannerModeTabLabel(_ mode: PlannerMode) -> String {
        mode.localizedTabTitle
    }

    private var profileCard: some View {
        DIRCard(DIRIOSLocalizer.string("planner.profile.title"), icon: nil, accent: DIRTheme.cyan) {
            VStack(spacing: 0) {
                plannerDepthField(
                    DIRIOSLocalizer.string("planner.field.max_depth"),
                    meters: $store.input.plannedDepthMeters,
                    maxMeters: profileMaxDepthLimitMeters
                )
                if store.mode == .deco {
                    Text(DIRIOSLocalizer.string("planner.deco.gas_consumption.conservative_depth_note"))
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.vertical, 8)
                }
                if modePresentation.showsAverageDepthGasConsumptionToggle {
                    Divider().overlay(DIRTheme.hairline)
                    Toggle(isOn: Binding(
                        get: { store.input.averageDepthGasConsumptionEnabled },
                        set: { enabled in
                            store.input.usesAverageDepthForGasConsumption = enabled
                            if enabled {
                                store.input.ensureDefaultAverageDepthIfNeeded()
                            }
                        }
                    )) {
                        Text(DIRIOSLocalizer.string("planner.technical.average_depth.gas_toggle"))
                            .font(.callout)
                            .foregroundStyle(.white)
                    }
                    .tint(DIRTheme.cyan)
                    .padding(.vertical, 8)

                    if store.input.averageDepthGasConsumptionEnabled {
                        Divider().overlay(DIRTheme.hairline)
                        plannerDepthField(
                            DIRIOSLocalizer.string("planner.field.avg_depth"),
                            meters: $store.input.plannedAverageDepthMeters,
                            maxMeters: profileMaxAverageDepthLimitMeters
                        )
                        Text(DIRIOSLocalizer.string("planner.technical.average_depth.gas_enabled_note"))
                            .font(.caption2)
                            .foregroundStyle(DIRTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.vertical, 8)
                    } else {
                        Text(DIRIOSLocalizer.string("planner.technical.average_depth.gas_disabled_note"))
                            .font(.caption2)
                            .foregroundStyle(DIRTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.vertical, 8)
                    }
                }
                Divider().overlay(DIRTheme.hairline)
                plannerField(
                    DIRIOSLocalizer.string("planner.field.bottom_time"),
                    value: $store.input.plannedBottomMinutes,
                    unit: "min",
                    step: 1,
                    maxValue: profileMaxBottomMinutes
                )
                Divider().overlay(DIRTheme.hairline)
                plannerTemperatureField(DIRIOSLocalizer.string("planner.field.temperature"), celsius: $store.input.waterTemperatureCelsius)
                if store.mode == .technical {
                    Divider().overlay(DIRTheme.hairline)
                    plannerDepthField(DIRIOSLocalizer.string("planner.field.altitude"), meters: $store.input.altitudeMeters, step: unitPreference == .metric ? 100 : 300)
                        .onChange(of: store.input.altitudeMeters) { _, _ in
                            store.clampAllSwitchDepthsToMOD()
                        }
                    Divider().overlay(DIRTheme.hairline)
                    HStack {
                        Text(DIRIOSLocalizer.string("planner.field.salinity"))
                            .font(.callout)
                            .foregroundStyle(.white)
                        Spacer()
                        Picker(DIRIOSLocalizer.string("planner.field.salinity"), selection: $store.input.salinity) {
                            ForEach(SalinityMode.allCases) { mode in
                                Text(salinityLabel(mode)).tag(mode)
                            }
                        }
                        .labelsHidden()
                        .tint(DIRTheme.cyan)
                        .onChange(of: store.input.salinity) { _, _ in
                            store.clampAllSwitchDepthsToMOD()
                        }
                    }
                    .padding(.vertical, 10)
                    environmentStatusRow
                }
                if modePresentation.showsManualGFControls {
                    Divider().overlay(DIRTheme.hairline)
                    plannerField(DIRIOSLocalizer.string("planner.field.gf_low"), value: $store.input.gfLow, unit: "%", step: 5)
                    Divider().overlay(DIRTheme.hairline)
                    plannerField(DIRIOSLocalizer.string("planner.field.gf_high"), value: $store.input.gfHigh, unit: "%", step: 5)
                }
                if modePresentation.showsGFPresets {
                    Divider().overlay(DIRTheme.hairline)
                    gfPresetRow
                }
            }
        }
    }

    private var gfPresetRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(DIRIOSLocalizer.string("planner.field.gf_preset"))
                .font(.callout)
                .foregroundStyle(.white)
            VStack(spacing: 8) {
                ForEach(PlannerGFPreset.allCases) { preset in
                    gfPresetOptionCard(
                        preset: preset,
                        isSelected: gfPresetBinding.wrappedValue == preset
                    )
                }
            }
            .accessibilityElement(children: .contain)
            Text(
                DIRIOSLocalizer.formatted(
                    "planner.gf.preset.explanation_format",
                    gfPresetBinding.wrappedValue.displayPair
                )
            )
            .font(.caption2)
            .foregroundStyle(DIRTheme.muted)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 10)
    }

    private func gfPresetOptionCard(preset: PlannerGFPreset, isSelected: Bool) -> some View {
        Button {
            gfPresetBinding.wrappedValue = preset
        } label: {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(preset.localizedTitle)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(preset.localizedGFValueLine)
                        .font(.caption.monospacedDigit().weight(.medium))
                        .foregroundStyle(isSelected ? DIRTheme.cyan : DIRTheme.muted)
                }
                Spacer(minLength: 0)
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(DIRTheme.cyan)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? DIRTheme.cyan.opacity(0.12) : DIRTheme.surface2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected ? DIRTheme.cyan.opacity(0.85) : DIRTheme.hairline,
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(preset.accessibilityLabel)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private var gfPresetBinding: Binding<PlannerGFPreset> {
        Binding(
            get: { PlannerModePolicy.matchingGFPreset(for: store.input) ?? .standard },
            set: { preset in
                Task { @MainActor in
                    PlannerModePolicy.applyGFPreset(preset, to: &store.input)
                }
            }
        )
    }

    private var environmentStatusRow: some View {
        Group {
            Divider().overlay(DIRTheme.hairline)
            if liveValidation.states.contains(.invalidEnvironment),
               case .failure(let error) = PlannerEnvironment.make(altitudeMeters: store.input.altitudeMeters, salinity: store.input.salinity) {
                let summary = PlannerUserFacingCopy.invalidEnvironmentSummary(for: store.input, error: error)
                VStack(alignment: .leading, spacing: 6) {
                    Text(DIRIOSLocalizer.string("planner.environment.invalid.title"))
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
                .accessibilityLabel(DIRIOSLocalizer.string("planner.environment.invalid.a11y"))
            } else if let summary = store.plan.environmentSummary {
                VStack(alignment: .leading, spacing: 6) {
                    Text(summary.isActive ? DIRIOSLocalizer.string("planner.environment.active.title") : DIRIOSLocalizer.string("planner.environment.default.title"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(summary.isActive ? DIRTheme.cyan : DIRTheme.muted)
                    Text(summary.statusMessage)
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                    if summary.isActive {
                        Text(
                            String(
                                format: DIRIOSLocalizer.string("planner.environment.active.detail"),
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
        DIRCard(DIRIOSLocalizer.string("planner.repetitive.title"), icon: "arrow.triangle.2.circlepath", accent: DIRTheme.yellow) {
            VStack(alignment: .leading, spacing: 10) {
                Toggle(isOn: $store.repetitivePlanningEnabled) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(DIRIOSLocalizer.string("planner.repetitive.toggle"))
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.white)
                        Text(DIRIOSLocalizer.string("planner.repetitive.toggle_hint"))
                            .font(.caption2)
                            .foregroundStyle(DIRTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .tint(DIRTheme.cyan)
                .accessibilityHint(DIRIOSLocalizer.string("planner.repetitive.toggle.a11y"))

                if store.repetitivePlanningEnabled {
                    Divider().overlay(DIRTheme.hairline)
                    plannerField(
                        DIRIOSLocalizer.string("planner.repetitive.surface_interval"),
                        value: $store.surfaceIntervalMinutes,
                        unit: "min",
                        step: 5
                    )
                    repetitiveSnapshotStatusView
                    if let context = store.plan.repetitiveContext, context.tissueStateApplied {
                        DIRWarningBox(text: DIRIOSLocalizer.string("planner.repetitive.active_notice"))
                    } else if let issue = store.plan.repetitiveContext?.snapshotIssue {
                        plannerStateWarning(issue.userFacingMessage)
                    }
                    Text(DIRIOSLocalizer.string("planner.repetitive.reference_only"))
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.yellow)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(DIRIOSLocalizer.string("planner.repetitive.not_from_log"))
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text(DIRIOSLocalizer.string("planner.repetitive.clean_dive"))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private func scrollToCNSThresholdSettings(using scrollProxy: ScrollViewProxy) {
        DispatchQueue.main.async {
            guard modePresentation.showsCNSDescentBottomSettings else {
                store.acknowledgeCNSThresholdSettingsFocus()
                return
            }
            withAnimation(.easeInOut(duration: 0.35)) {
                scrollProxy.scrollTo(PlannerCNSDescentBottomCheckSettings.scrollTargetID, anchor: .center)
            }
            store.acknowledgeCNSThresholdSettingsFocus()
        }
    }

    private var repetitiveSnapshotStatusView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(DIRIOSLocalizer.string("planner.repetitive.snapshot.status"))
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
                        format: DIRIOSLocalizer.string("planner.repetitive.snapshot.timestamp"),
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
            return DIRIOSLocalizer.string("planner.repetitive.snapshot.disabled")
        }
        if store.plan.repetitiveContext?.tissueStateApplied == true {
            return DIRIOSLocalizer.string("planner.repetitive.snapshot.loaded")
        }
        if store.lastTissueSnapshot == nil {
            return DIRIOSLocalizer.string("planner.repetitive.snapshot.missing")
        }
        if let issue = store.plan.repetitiveContext?.snapshotIssue {
            return issue.userFacingMessage.title
        }
        return DIRIOSLocalizer.string("planner.repetitive.snapshot.unavailable")
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

    private var visibleBackGasCylinders: [PlannerCylinderEntry] {
        store.input.plannerCylinders.filter { $0.role == .bottom }
    }

    private var visibleDecoGasCylinders: [PlannerCylinderEntry] {
        guard store.mode == .deco, store.input.decoGasPlanningEnabled else { return [] }
        let deco = store.input.plannerCylinders
            .filter { $0.role == .deco }
            .sorted { $0.switchDepthMeters > $1.switchDepthMeters }
        return Array(deco.prefix(1))
    }

    private var visiblePlannerCylinders: [PlannerCylinderEntry] {
        switch store.mode {
        case .base:
            return visibleBackGasCylinders
        case .deco:
            return visibleBackGasCylinders + visibleDecoGasCylinders
        case .technical, .ccr:
            return store.input.plannerCylinders
        }
    }

    private var plannerCylindersCard: some View {
        DIRCard(DIRIOSLocalizer.string("planner.card.cylinders"), icon: "fuelpump", accent: DIRTheme.cyan) {
            VStack(spacing: 12) {
                if !checklistGasItems.isEmpty {
                    Button {
                        showChecklistImportPrompt = true
                    } label: {
                        Text(DIRIOSLocalizer.string("checklist_planner.sync.use_checklist"))
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(DIRTheme.cyan)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan.opacity(0.7), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    Divider().overlay(DIRTheme.hairline)
                }
                if store.mode == .deco {
                    ForEach(visibleBackGasCylinders) { entry in
                        if let index = store.input.plannerCylinders.firstIndex(where: { $0.id == entry.id }) {
                            plannerCylinderEditor(at: index)
                        }
                    }
                    decoDecompressionGasToggleSection
                    if store.input.decoGasPlanningEnabled {
                        Text(DIRIOSLocalizer.string("planner.deco.decompression_gas.description"))
                            .font(.caption2)
                            .foregroundStyle(DIRTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                        ForEach(visibleDecoGasCylinders) { entry in
                            if let index = store.input.plannerCylinders.firstIndex(where: { $0.id == entry.id }) {
                                plannerCylinderEditor(at: index)
                            }
                        }
                    } else {
                        Text(DIRIOSLocalizer.string("planner.deco.decompression_gas.off_note"))
                            .font(.caption2)
                            .foregroundStyle(DIRTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                } else {
                    ForEach(visiblePlannerCylinders) { entry in
                        if let index = store.input.plannerCylinders.firstIndex(where: { $0.id == entry.id }) {
                            plannerCylinderEditor(at: index)
                        }
                    }
                }
                if store.mode == .technical {
                    addTechnicalCylinderButtons
                }
                if modePresentation.showsExtendedAnalysisTiles {
                    Divider().overlay(DIRTheme.hairline)
                    Text(DIRIOSLocalizer.string("planner.section.consumption"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(DIRTheme.muted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    plannerField(DIRIOSLocalizer.string("planner.field.sac_rmv"), value: $store.input.sacLitersPerMinute, unit: "L/min", step: 1)
                }
            }
        }
    }

    private var decoDecompressionGasToggleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider().overlay(DIRTheme.hairline)
            Toggle(isOn: decoGasEnabledBinding) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(DIRIOSLocalizer.string("planner.deco.decompression_gas.toggle"))
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(DIRIOSLocalizer.string("planner.deco.decompression_gas.title"))
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.muted)
                }
            }
            .tint(DIRTheme.cyan)
        }
        .padding(.vertical, 4)
    }

    private var decoGasEnabledBinding: Binding<Bool> {
        Binding(
            get: { store.input.decoGasPlanningEnabled },
            set: { enabled in
                store.input.isDecoGasEnabled = enabled
                if enabled {
                    store.input.ensureDefaultDecoGasIfNeeded()
                    if let deco = store.input.plannerCylinders.first(where: { $0.role == .deco }) {
                        store.normalizeNewCylinderSwitchDepth(cylinderID: deco.id)
                    }
                }
                store.refreshDerivedPlanningPreview()
            }
        )
    }

    @ViewBuilder
    private var addTechnicalCylinderButtons: some View {
        Button {
            let entry = PlannerCylinderEntry(
                role: .deco,
                tankSize: .liters12,
                gas: GasMix(name: "Deco", role: .deco, oxygen: 0.50, helium: 0, maxPPO2: 1.6)
            )
            store.input.plannerCylinders.append(entry)
            store.normalizeNewCylinderSwitchDepth(cylinderID: entry.id)
        } label: {
            Text(DIRIOSLocalizer.string("planner.cylinder.add"))
                .font(.callout.weight(.semibold))
                .foregroundStyle(DIRTheme.cyan)
        }
        .buttonStyle(.plain)
    }

    private func plannerCylinderEditor(at index: Int) -> some View {
        let entry = store.input.plannerCylinders[index]
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Spacer()
                if store.mode == .technical, store.input.plannerCylinders.count > 1 {
                    Button(role: .destructive) {
                        store.input.plannerCylinders.removeAll { $0.id == entry.id }
                    } label: {
                        Text(DIRIOSLocalizer.string("planner.cylinder.remove"))
                            .font(.caption2.weight(.semibold))
                    }
                    .buttonStyle(.plain)
                }
            }
            PlannerCylinderGasEditorView(
                entry: $store.input.plannerCylinders[index],
                cylinderNumber: cylinderDisplayNumber(for: entry),
                sectionTitle: cylinderSectionTitle(for: entry),
                plannerMode: store.mode,
                allowedMixKinds: PlannerModePolicy.allowedMixKinds(for: store.mode),
                unitPreference: unitPreference,
                pressureUnitPreference: pressureUnitPreference,
                plannerEnvironment: store.input.plannerEnvironment,
                plannedDepthMeters: store.input.plannedDepthMeters,
                showsRoleEditor: store.mode == .technical,
                showsTankEditor: store.mode == .technical,
                switchDepthMeters: entry.role != .bottom ? clampedSwitchDepthBinding(for: index) : nil,
                maxSwitchDepthMeters: entry.role != .bottom
                    ? entry.usableSwitchDepthMeters(environment: store.input.plannerEnvironment)
                    : nil,
                onGasOrPPO2Changed: {
                    store.normalizeSwitchDepthAfterGasOrPPO2Change(cylinderID: entry.id)
                },
                onPressureChanged: {
                    store.refreshDerivedPlanningPreview()
                }
            )
            if entry.gas.mixKind == .trimix {
                Text(DIRIOSLocalizer.string("planner.gas.trimix_buhlmann_disclaimer"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Divider().overlay(DIRTheme.hairline)
        }
    }

    private func cylinderDisplayNumber(for entry: PlannerCylinderEntry) -> Int {
        let visible = visiblePlannerCylinders
        return (visible.firstIndex(where: { $0.id == entry.id }) ?? 0) + 1
    }

    private func cylinderSectionTitle(for entry: PlannerCylinderEntry) -> String? {
        guard store.mode == .deco else { return nil }
        switch entry.role {
        case .bottom:
            return DIRIOSLocalizer.string("planner.deco.back_gas.title")
        case .deco:
            return DIRIOSLocalizer.string("planner.deco.decompression_gas.title")
        default:
            return nil
        }
    }

    private var technicalAnalysisCard: some View {
        DIRCard(DIRIOSLocalizer.string("planner.card.density_end"), icon: "gauge", accent: DIRTheme.yellow) {
            let endMeasurement = Formatters.depth(store.analysis.endMeters, units: unitPreference)
            let eadMeasurement = store.analysis.eadMeters.map { Formatters.depth($0, units: unitPreference) }
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    DIRMetricTile(title: "PPO2", value: Formatters.one(store.analysis.ppO2AtDepth), color: warningColor(ppO2: store.analysis.ppO2AtDepth))
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: DIRIOSLocalizer.string("planner.metric.density"), value: Formatters.one(store.analysis.densityAtDepth), unit: "g/L", color: densityColor(store.analysis.densityRating))
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "END", value: endMeasurement.value, unit: endMeasurement.unit, color: store.analysis.endMeters > 30 ? DIRTheme.yellow : DIRTheme.green)
                }
                Divider().overlay(DIRTheme.hairline)
                HStack(spacing: 0) {
                    DIRMetricTile(title: "EAD", value: eadMeasurement?.value ?? "-", unit: eadMeasurement?.unit, color: DIRTheme.cyan)
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(
                        title: DIRIOSLocalizer.string("planner.metric.cns_preview"),
                        value: store.analysis.cnsPercentDisplay,
                        unit: "%",
                        color: store.analysis.cnsPercent > 80 ? DIRTheme.red : DIRTheme.cyan
                    )
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "OTU", value: Formatters.zero(store.analysis.otu), color: DIRTheme.cyan)
                }
                plannerMutedFootnote(DIRIOSLocalizer.string("planner.metric.cns_preview.footnote"))
                Divider().overlay(DIRTheme.hairline)
                Text(DIRIOSLocalizer.string("planner.oxygen_exposure.disclaimer"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel(DIRIOSLocalizer.string("planner.oxygen_exposure.a11y"))
                Text(
                    String(
                        format: DIRIOSLocalizer.string("planner.oxygen_exposure.daily_summary"),
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

    private var emergencyCard: some View {
        let automaticAscentMinutes = ScheduleGasConsumptionService.automaticAscentMinutes(
            plannedDepthMeters: store.input.plannedDepthMeters
        )
        let totalEmergencyMinutes = ScheduleGasConsumptionService.emergencyMinutesUsed(input: store.input)
        let rockBottomLiters = ScheduleGasConsumptionService.rockBottomLiters(
            input: store.input,
            environment: store.input.plannerEnvironment
        )
        let cylinderVolume = store.input.primaryCylinder.volumeLiters
        let minimumGasBar = cylinderVolume > 0 ? rockBottomLiters / cylinderVolume : nil
        return DIRCard(DIRIOSLocalizer.string("planner.emergency.title"), icon: "cross.case.fill", accent: DIRTheme.orange) {
            VStack(alignment: .leading, spacing: 0) {
                Text(DIRIOSLocalizer.string("planner.emergency.subtitle"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 8)
                plannerField(
                    DIRIOSLocalizer.string("planner.emergency.team_size"),
                    value: teamSizeBinding,
                    unit: "",
                    step: 1,
                    minValue: 1,
                    maxValue: IOSAlgorithmConfiguration.maxPlannerEmergencyTeamSize
                )
                plannerMutedFootnote(DIRIOSLocalizer.string("planner.emergency.team_size.detail"))
                Divider().overlay(DIRTheme.hairline)
                plannerField(
                    DIRIOSLocalizer.string("planner.emergency.sac"),
                    value: $store.input.emergencySacLitersPerMinute,
                    unit: "L/min",
                    step: 1
                )
                plannerMutedFootnote(DIRIOSLocalizer.string("planner.emergency.sac.detail"))
                Divider().overlay(DIRTheme.hairline)
                plannerField(
                    DIRIOSLocalizer.string("planner.emergency.extra_minutes"),
                    value: emergencyExtraMinutesBinding,
                    unit: "min",
                    step: 1,
                    maxValue: IOSAlgorithmConfiguration.maxEmergencyExtraMinutes
                )
                plannerMutedFootnote(DIRIOSLocalizer.string("planner.emergency.extra_minutes.detail"))
                Divider().overlay(DIRTheme.hairline)
                plannerReadOnlyRow(
                    DIRIOSLocalizer.string("planner.emergency.automatic_ascent"),
                    value: String(
                        format: DIRIOSLocalizer.string("planner.emergency.minutes_format"),
                        Formatters.one(automaticAscentMinutes)
                    )
                )
                plannerReadOnlyRow(
                    DIRIOSLocalizer.string("planner.emergency.total_time"),
                    value: String(
                        format: DIRIOSLocalizer.string("planner.emergency.total_time.format"),
                        Formatters.one(totalEmergencyMinutes)
                    )
                )
                Divider().overlay(DIRTheme.hairline)
                GasQuantityMetricTile(
                    title: DIRIOSLocalizer.string("planner.emergency.rock_bottom"),
                    display: GasLedgerDisplayFormatter.displayValue(
                        liters: rockBottomLiters,
                        pressureBar: minimumGasBar,
                        cylinderVolumeLiters: cylinderVolume,
                        pressureUnit: pressureUnitPreference
                    ),
                    color: DIRTheme.orange
                )
                plannerMutedFootnote(DIRIOSLocalizer.string("planner.emergency.footnote"))
            }
        }
    }

    private var teamSizeBinding: Binding<Double> {
        Binding(
            get: { ScheduleGasConsumptionService.normalizedTeamSize(store.input.teamSize) },
            set: { store.input.teamSize = ScheduleGasConsumptionService.normalizedTeamSize($0) }
        )
    }

    private var emergencyExtraMinutesBinding: Binding<Double> {
        Binding(
            get: { store.input.emergencyExtraMinutes },
            set: { store.input.emergencyExtraMinutes = ScheduleGasConsumptionService.normalizedEmergencyExtraMinutes($0) }
        )
    }

    private var reserveCard: some View {
        let cylinderVolume = store.input.primaryCylinder.volumeLiters
        return DIRCard(DIRIOSLocalizer.string("planner.available_gas.title"), icon: "gauge", accent: DIRTheme.green) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    GasQuantityMetricTile(
                        title: DIRIOSLocalizer.string("planner.gas_ledger.available_gas"),
                        display: GasLedgerDisplayFormatter.displayValue(
                            liters: store.input.availableGasLiters,
                            pressureBar: store.input.primaryCylinder.startPressureBar,
                            cylinderVolumeLiters: cylinderVolume,
                            pressureUnit: pressureUnitPreference
                        ),
                        color: DIRTheme.green
                    )
                    Divider().overlay(DIRTheme.hairline)
                    GasQuantityMetricTile(
                        title: DIRIOSLocalizer.string("planner.gas_ledger.estimated_consumption"),
                        display: GasLedgerDisplayFormatter.displayValue(
                            liters: store.analysis.consumptionLiters,
                            pressureBar: cylinderVolume > 0 ? store.analysis.consumptionLiters / cylinderVolume : nil,
                            cylinderVolumeLiters: cylinderVolume,
                            pressureUnit: pressureUnitPreference
                        ),
                        color: DIRTheme.yellow
                    )
                    Divider().overlay(DIRTheme.hairline)
                    GasQuantityMetricTile(
                        title: DIRIOSLocalizer.string("planner.metric.remaining"),
                        display: GasLedgerDisplayFormatter.displayValue(
                            liters: store.analysis.remainingLiters,
                            pressureBar: store.analysis.remainingBar,
                            cylinderVolumeLiters: cylinderVolume,
                            pressureUnit: pressureUnitPreference
                        ),
                        color: store.analysis.remainingLiters < store.analysis.rockBottomLiters ? DIRTheme.red : DIRTheme.green
                    )
                }
                Divider().overlay(DIRTheme.hairline)
                HStack(spacing: 0) {
                    GasQuantityMetricTile(
                        title: DIRIOSLocalizer.string("planner.metric.rock_bottom"),
                        display: GasLedgerDisplayFormatter.displayValue(
                            liters: store.analysis.rockBottomLiters,
                            pressureBar: store.analysis.minimumGasBar,
                            cylinderVolumeLiters: cylinderVolume,
                            pressureUnit: pressureUnitPreference
                        ),
                        color: DIRTheme.orange
                    )
                    Divider().overlay(DIRTheme.hairline)
                    let turnLiters = store.analysis.turnPressureBar * cylinderVolume
                    GasQuantityMetricTile(
                        title: DIRIOSLocalizer.string("planner.metric.turn_pressure"),
                        display: GasLedgerDisplayFormatter.displayValue(
                            liters: turnLiters,
                            pressureBar: store.analysis.turnPressureBar,
                            cylinderVolumeLiters: cylinderVolume,
                            pressureUnit: pressureUnitPreference
                        ),
                        color: DIRTheme.cyan
                    )
                }
                if store.analysis.usesBottomPhaseConsumptionEstimate {
                    Text(DIRIOSLocalizer.string("planner.gas.bottom_phase_estimate_footnote"))
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.muted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Text(DIRIOSLocalizer.string("planner.gas.turn_pressure_rule_footnote"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var liveMODIssues: [MODValidationIssue] {
        guard store.mode.isOpenCircuit else { return [] }
        let active = PlannerModePolicy.activePlanInput(from: store.input, mode: store.mode)
        return PlannerMODValidator.liveInputIssues(input: active, environment: active.plannerEnvironment)
    }

    private var liveValidation: PlannerValidationResult {
        PlannerModePolicy.validate(draft: store.input, mode: store.mode)
    }

    private var canCalculatePlan: Bool {
        plannerSafetyAcknowledged && liveValidation.isValid && liveMODIssues.isEmpty
    }

    @ViewBuilder
    private var plannerModeLimitWarnings: some View {
        if liveValidation.states.contains(.basicNoDecoLimitExceeded) {
            let message = PlannerUserFacingCopy.message(for: .basicNoDecoLimitExceeded)
            DIRWarningBox(
                text: [message.title, message.message, message.correctiveHint].compactMap { $0 }.joined(separator: "\n"),
                severity: .critical
            )
        }
        if liveValidation.states.contains(.decoDepthLimitExceeded) {
            let message = PlannerUserFacingCopy.message(for: .decoDepthLimitExceeded)
            DIRWarningBox(
                text: [message.title, message.message, message.correctiveHint].compactMap { $0 }.joined(separator: "\n"),
                severity: .critical
            )
        }
        if store.mode == .technical {
            DIRWarningBox(
                text: [
                    DIRIOSLocalizer.string("planner.mode.technical.notice.title"),
                    DIRIOSLocalizer.string("planner.mode.technical.notice.message")
                ].joined(separator: "\n"),
                severity: .info
            )
        }
    }

    @ViewBuilder
    private var plannerMODInputWarnings: some View {
        if !liveMODIssues.isEmpty {
            switch store.mode {
            case .base:
                baseGasDepthCompatibilityWarning(issues: liveMODIssues)
            case .deco, .technical:
                genericMODInputWarnings(issues: liveMODIssues)
            case .ccr:
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private func baseGasDepthCompatibilityWarning(issues: [MODValidationIssue]) -> some View {
        DIRCard(DIRIOSLocalizer.string("planner.base.gas_depth.title"), icon: "exclamationmark.triangle.fill", accent: DIRTheme.red) {
            VStack(alignment: .leading, spacing: 8) {
                Text(DIRIOSLocalizer.string("planner.base.gas_depth.message"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DIRTheme.red)
                    .fixedSize(horizontal: false, vertical: true)
                ForEach(issues) { issue in
                    Text(
                        DIRIOSLocalizer.formatted(
                            "planner.base.gas_depth.detail_format",
                            issue.gasLabel,
                            Formatters.depth(issue.switchDepthMeters, units: unitPreference).text,
                            Formatters.depth(issue.modMeters, units: unitPreference).text
                        )
                    )
                    .font(.caption2)
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                }
                Text(DIRIOSLocalizer.string("planner.base.gas_depth.hint"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder
    private func genericMODInputWarnings(issues: [MODValidationIssue]) -> some View {
        DIRCard(DIRIOSLocalizer.string("planner.mod.validation.title"), icon: "exclamationmark.triangle.fill", accent: DIRTheme.red) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(issues) { issue in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(DIRIOSLocalizer.string("planner.mod.exceeds_allowed"))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(DIRTheme.red)
                        Text(
                            DIRIOSLocalizer.formatted(
                                "planner.mod.detail_format",
                                issue.gasLabel,
                                Formatters.depth(issue.switchDepthMeters, units: unitPreference).text,
                                Formatters.depth(issue.modMeters, units: unitPreference).text
                            )
                        )
                        .font(.caption2)
                        .foregroundStyle(.white)
                    }
                }
                Text(DIRIOSLocalizer.string("planner.mod.incompatible"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
            }
        }
    }

    private var modBlockCalculateMessage: String {
        store.mode == .base
            ? DIRIOSLocalizer.string("planner.base.gas_depth.block_calculate")
            : DIRIOSLocalizer.string("planner.mod.block_calculate")
    }

    @ViewBuilder
    private var plannerWarnings: some View {
        if store.analysis.warnings.isEmpty {
            DIRWarningBox(text: DIRIOSLocalizer.string("planner.disclaimer.informative"))
        } else {
            DIRCard(DIRIOSLocalizer.string("planner.warning.title"), icon: "exclamationmark.triangle.fill", accent: DIRTheme.red) {
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

    private var plannerSafetyAcknowledgment: some View {
        Toggle(
            isOn: Binding(
                get: { plannerSafetyAcknowledged },
                set: { plannerSafetyAckRevision = $0 ? PlannerSafetyAcknowledgment.currentRevision : "" }
            )
        ) {
            Text(DIRIOSLocalizer.string("planner.safety_ack.label"))
                .font(.callout.weight(.semibold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
        .tint(DIRTheme.cyan)
        .padding(.vertical, 4)
        .accessibilityHint(DIRIOSLocalizer.string("planner.safety_ack.hint"))
    }

    private var plannerReferenceDetailsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showPlannerReferenceDetails.toggle()
                }
            } label: {
                HStack(spacing: 6) {
                    Text(
                        showPlannerReferenceDetails
                            ? DIRIOSLocalizer.string("planner.reference.details.hide")
                            : DIRIOSLocalizer.string("planner.reference.details.read_more")
                    )
                    .font(DIRTypography.captionSemibold)
                    .foregroundStyle(DIRTheme.cyan)
                    Spacer(minLength: 0)
                    Image(systemName: showPlannerReferenceDetails ? "chevron.up" : "chevron.down")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(DIRTheme.muted)
                }
            }
            .buttonStyle(.plain)
            .accessibilityHint(DIRIOSLocalizer.string("planner.reference.details.summary"))

            if showPlannerReferenceDetails {
                DIRWarningBox(text: DIRIOSLocalizer.string("planner.units.metric_notice"))
            }
        }
    }

    private var calculateButton: some View {
        Button {
            let validation = PlannerModePolicy.validate(draft: store.input, mode: store.mode)
            if !validation.isValid {
                calculateErrorMessage = validation.messages.first ?? DIRIOSLocalizer.string("planner.gas.mix_invalid")
                showCalculateError = true
                return
            }
            if !liveMODIssues.isEmpty {
                calculateErrorMessage = modBlockCalculateMessage
                showCalculateError = true
                return
            }
            store.calculate()
            pendingChecklistExportAfterCalculate = !ChecklistPlannerSyncMapper.cylindersMissingFromChecklist(
                plannerCylinders: store.input.plannerCylinders,
                checklist: equipment.profile.checklistItems
            ).isEmpty
            showPlan = true
        } label: {
            HStack(spacing: 8) {
                if store.isCalculating {
                    ProgressView()
                        .tint(.black)
                }
                Text(
                    store.isCalculating
                        ? DIRIOSLocalizer.string("planner.calculate.in_progress")
                        : DIRIOSLocalizer.string("planner.calculate")
                )
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
        .accessibilityLabel(
            store.isCalculating
                ? DIRIOSLocalizer.string("planner.calculate.in_progress")
                : DIRIOSLocalizer.string("planner.calculate")
        )
        .accessibilityHint(
            liveMODIssues.isEmpty
                ? DIRIOSLocalizer.string("planner.safety_ack.hint")
                : modBlockCalculateMessage
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

    private func plannerDepthField(_ title: String, meters: Binding<Double>, step: Double = 1, maxMeters: Double? = nil) -> some View {
        let displayStep = unitPreference == .metric ? step : max(1, IOSUnitConversions.feet(fromMeters: step))
        let displayMax = maxMeters.map { unitPreference == .metric ? $0 : IOSUnitConversions.feet(fromMeters: $0) }
        return plannerField(
            title,
            value: depthDisplayBinding(meters),
            unit: Formatters.depthUnitLabel(unitPreference),
            step: displayStep,
            maxValue: displayMax
        )
    }

    private func clampedSwitchDepthBinding(for index: Int) -> Binding<Double> {
        Binding(
            get: {
                guard store.input.plannerCylinders.indices.contains(index) else { return 0 }
                return store.input.plannerCylinders[index].switchDepthMeters
            },
            set: { proposed in
                store.clampSwitchDepth(forCylinderAt: index, proposedMeters: proposed)
            }
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

    private func plannerReadOnlyRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.callout)
                .foregroundStyle(.white)
            Spacer()
            Text(value)
                .font(.callout.monospacedDigit())
                .foregroundStyle(DIRTheme.cyan)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 10)
    }

    private func plannerField(
        _ title: String,
        value: Binding<Double>,
        unit: String,
        step: Double,
        minValue: Double = 0,
        maxValue: Double? = nil
    ) -> some View {
        HStack {
            Text(title)
                .font(.callout)
                .foregroundStyle(.white)
            Spacer()
            Group {
                if unit.isEmpty {
                    Text(Formatters.zero(value.wrappedValue))
                } else {
                    Text("\(Formatters.zero(value.wrappedValue)) \(unit)")
                }
            }
            .font(.callout.monospacedDigit())
            .foregroundStyle(.white)
            .frame(width: 96, alignment: .trailing)
            HStack(spacing: 1) {
                Button {
                    value.wrappedValue = max(minValue, value.wrappedValue - step)
                } label: {
                    Image(systemName: "minus")
                        .frame(width: 28, height: 24)
                }
                Button {
                    if let maxValue {
                        value.wrappedValue = min(maxValue, value.wrappedValue + step)
                    } else {
                        value.wrappedValue += step
                    }
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 28, height: 24)
                }
                .disabled(maxValue.map { value.wrappedValue >= $0 - 0.001 } ?? false)
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

    private var checklistGasItems: [EquipmentChecklistItem] {
        ChecklistPlannerSyncMapper.checklistGasItems(from: equipment.profile.checklistItems)
    }

    private func openChecklistImportSheet() {
        checklistImportCandidates = ChecklistPlannerSyncMapper.importCandidates(
            checklist: equipment.profile.checklistItems,
            plannerCylinders: store.input.plannerCylinders
        )
        showChecklistImportSheet = true
    }

    private func importAllFromChecklist() {
        var candidates = ChecklistPlannerSyncMapper.importCandidates(
            checklist: equipment.profile.checklistItems,
            plannerCylinders: store.input.plannerCylinders
        )
        let needsRoleSelection = candidates.contains { ($0.assignedRole ?? ChecklistPlannerSyncMapper.resolvedRole(for: $0.checklistItem)) == nil }
        if needsRoleSelection {
            openChecklistImportSheet()
            return
        }
        for index in candidates.indices {
            candidates[index].isSelected = true
            if candidates[index].duplicatePlannerIndex != nil {
                candidates[index].duplicateAction = .replace
            }
        }
        checklistImportCandidates = candidates
        confirmChecklistImport()
    }

    private func confirmChecklistImport() {
        store.input.ensurePlannerCylindersFromLegacy()
        ChecklistPlannerSyncMapper.applyImport(
            candidates: checklistImportCandidates,
            to: &store.input.plannerCylinders,
            environment: store.input.plannerEnvironment
        )
        for candidate in checklistImportCandidates where candidate.isSelected {
            if let index = store.input.plannerCylinders.firstIndex(where: {
                ChecklistPlannerSyncMapper.fingerprint(for: $0) == ChecklistPlannerSyncMapper.fingerprint(
                    for: candidate.checklistItem,
                    role: candidate.assignedRole ?? ChecklistPlannerSyncMapper.resolvedRole(for: candidate.checklistItem) ?? .deco
                )
            }) {
                store.normalizeNewCylinderSwitchDepth(cylinderID: store.input.plannerCylinders[index].id)
            }
        }
        store.input.syncLegacyGasesFromPlannerCylinders()
        store.refreshDerivedPlanningPreview()
        showChecklistImportSheet = false
    }

    private enum PlannerPDFShareKind {
        case plan, briefing, divePack
    }

    private func plannerPDFContext() -> PDFExportPlannerContext {
        PDFShareActions.plannerContext(
            store: store,
            safetyAcknowledged: plannerSafetyAcknowledged,
            unitPreference: unitPreference,
            pressureUnitPreference: pressureUnitPreference,
            modIssues: liveMODIssues
        )
    }

    private func sharePlannerPDF(kind: PlannerPDFShareKind) {
        let context = plannerPDFContext()
        guard PDFExportService.canExportPlan(context) else {
            pdfExportAlertMessage = PDFShareActions.invalidPlanMessage()
            return
        }
        do {
            let url: URL
            switch kind {
            case .plan:
                url = try PDFExportService.exportPlan(context: context)
            case .briefing:
                url = try PDFExportService.exportBriefing(context: context)
            case .divePack:
                url = try PDFExportService.exportDivePack(
                    plannerContext: context,
                    checklistProfile: equipment.profile
                )
            }
            shareablePDF = ShareablePDFItem(url: url)
        } catch {
            pdfExportAlertMessage = PDFShareActions.invalidPlanMessage()
        }
    }
}

struct PlanResultView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: PlannerStore
    @EnvironmentObject private var equipment: EquipmentStore
    @EnvironmentObject private var plannerBriefingTransfer: PlannerBriefingWatchTransferService
    var pendingChecklistExportPrompt: Bool = false
    @AppStorage(IOSUnitPreference.storageKey) private var unitsRaw = IOSUnitPreference.metric.rawValue
    @AppStorage(IOSPressureUnitPreference.storageKey) private var pressureUnitRaw = IOSPressureUnitPreference.storageValue(for: .bar)
    @AppStorage(PlannerCNSDescentBottomCheckSettings.storageKey) private var cnsDescentBottomCheckEnabled = PlannerCNSDescentBottomCheckSettings.defaultEnabled
    @AppStorage(PlannerCNSDescentBottomCheckSettings.thresholdStorageKey) private var cnsThresholdPercent = PlannerCNSDescentBottomCheckSettings.defaultThresholdPercent
    @AppStorage(PlannerSafetyAcknowledgment.storageKey) private var plannerSafetyAckRevision = ""
    @State private var showResultPDFMenu = false
    @State private var shareablePDF: ShareablePDFItem?
    @State private var pdfExportAlertMessage: String?

    private var plannerSafetyAcknowledged: Bool {
        plannerSafetyAckRevision == PlannerSafetyAcknowledgment.currentRevision
    }

    private var liveMODIssues: [MODValidationIssue] {
        guard store.mode.isOpenCircuit else { return [] }
        let active = PlannerModePolicy.activePlanInput(from: store.input, mode: store.mode)
        return PlannerMODValidator.liveInputIssues(input: active, environment: active.plannerEnvironment)
    }

    private var canExportPlanPDF: Bool {
        PDFExportService.canExportPlan(resultPDFContext())
    }

    private var unitPreference: IOSUnitPreference { IOSUnitPreference.fromStorage(unitsRaw) }
    private var pressureUnitPreference: PressureUnit { IOSPressureUnitPreference.fromStorage(pressureUnitRaw) }
    private var modePresentation: PlannerResultPresentation { PlannerResultPresentation.presentation(for: store.mode) }

    private var cnsDescentBottomThresholdPercent: Double {
        Double(PlannerCNSDescentBottomCheckSettings.clamp(cnsThresholdPercent))
    }

    private var cnsDescentBottomWarningActive: Bool {
        store.plan.gasAnalysis.cnsDescentBottomExceedsPlannerThreshold(
            checkEnabled: cnsDescentBottomCheckEnabled,
            thresholdPercent: cnsDescentBottomThresholdPercent
        )
    }

    private var fullPlanCNSWarningActive: Bool {
        store.plan.gasAnalysis.showsFullPlanOxygenExposureWarning
            || store.plan.states.contains(.oxygenExposureElevated)
    }

    private var weeklyOTUWarningActive: Bool {
        store.plan.gasAnalysis.showsWeeklyOTUElevatedWarning
    }

    private var weeklyOTUTileAccessibilityLabel: String {
        let value = Formatters.zero(store.plan.gasAnalysis.otuWeekly)
        let base = "\(DIRIOSLocalizer.string("planner.metric.otu_weekly")), \(value)"
        guard weeklyOTUWarningActive else { return base }
        return "\(DIRIOSLocalizer.string("planner.warning.otu_weekly_elevated")) \(base)"
    }

    private var weeklyOTUWarningBanner: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(DIRTheme.yellow)
            VStack(alignment: .leading, spacing: 4) {
                Text(DIRIOSLocalizer.string("planner.warning.otu_weekly_elevated"))
                    .font(.caption)
                    .foregroundStyle(DIRTheme.yellow)
                Text(DIRIOSLocalizer.string("planner.metric.otu_weekly.footnote"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 8).fill(DIRTheme.yellow.opacity(0.12)))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(DIRIOSLocalizer.string("planner.warning.otu_weekly_elevated"))
        .accessibilityHint(DIRIOSLocalizer.string("planner.metric.otu_weekly.footnote"))
    }

    private var cnsDescentBottomTileAccessibilityLabel: String {
        let value = Formatters.zero(store.plan.gasAnalysis.cnsDescentBottomPercent)
        let base = "\(DIRIOSLocalizer.string("planner.metric.cns_descent_bottom")), \(value) percent"
        guard cnsDescentBottomWarningActive else { return base }
        return String(
            format: DIRIOSLocalizer.string("planner.accessibility.cns_descent_bottom.warning.label"),
            Formatters.zero(cnsDescentBottomThresholdPercent)
        ) + " \(base)"
    }

    private var cnsDescentBottomWarningMessage: String {
        String(
            format: DIRIOSLocalizer.string("planner.cns_descent_bottom.warning"),
            Formatters.zero(cnsDescentBottomThresholdPercent)
        )
    }

    private var cnsDescentBottomWarningBanner: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(DIRTheme.red)
                Text(cnsDescentBottomWarningMessage)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(DIRTheme.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text(DIRIOSLocalizer.string("planner.cns_descent_bottom.warning.hint"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
            cnsThresholdEditLink
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            String(
                format: DIRIOSLocalizer.string("planner.accessibility.cns_descent_bottom.warning.label"),
                Formatters.zero(cnsDescentBottomThresholdPercent)
            )
        )
        .accessibilityHint(DIRIOSLocalizer.string("planner.accessibility.cns_descent_bottom.warning.hint"))
    }

    private var cnsThresholdEditLink: some View {
        Button {
            store.requestCNSThresholdSettingsFocus()
            dismiss()
        } label: {
            Text(
                String(
                    format: DIRIOSLocalizer.string("planner.result.cns_threshold_edit"),
                    Formatters.zero(cnsDescentBottomThresholdPercent)
                )
            )
            .font(.caption2.weight(.semibold))
            .foregroundStyle(DIRTheme.cyan)
        }
        .buttonStyle(.plain)
        .accessibilityHint(DIRIOSLocalizer.string("planner.result.cns_threshold_edit.a11y"))
    }

    private var cnsThresholdResultFootnote: some View {
        Group {
            if cnsDescentBottomCheckEnabled {
                HStack {
                    Text(
                        String(
                            format: DIRIOSLocalizer.string("planner.result.cns_threshold_summary"),
                            Formatters.zero(cnsDescentBottomThresholdPercent)
                        )
                    )
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
                    Spacer(minLength: 8)
                    cnsThresholdEditLink
                }
            }
        }
    }

    private var fullPlanCNSTileAccessibilityLabel: String {
        let value = store.plan.gasAnalysis.cnsPercentDisplay
        let base = "\(DIRIOSLocalizer.string("planner.metric.cns_full_plan")), \(value) percent"
        guard fullPlanCNSWarningActive else { return base }
        return "\(DIRIOSLocalizer.string("planner.accessibility.cns_full_plan.warning.label")) \(base)"
    }

    private var fullPlanCNSWarningBanner: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(DIRTheme.yellow)
                Text(DIRIOSLocalizer.string("planner.cns_full_plan.warning"))
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(DIRTheme.yellow)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text(DIRIOSLocalizer.string("planner.cns_full_plan.warning.hint"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(DIRIOSLocalizer.string("planner.accessibility.cns_full_plan.warning.label"))
        .accessibilityHint(DIRIOSLocalizer.string("planner.accessibility.cns_full_plan.warning.hint"))
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

    private var decoStopsPresentationRows: [DecoStopPresentationRow] {
        DecoStopsPresentationBuilder.rows(
            from: store.plan.decoStops,
            depthFormatter: { depthText($0) },
            ppO2Formatter: { Formatters.one($0) }
        )
    }

    private var showsDecoStopsSection: Bool {
        DecoStopsPresentationBuilder.shouldShowSection(mode: store.mode, decoStops: store.plan.decoStops)
    }

    private var showsNoDecoStopsNote: Bool {
        DecoStopsPresentationBuilder.shouldShowNoStopsNote(mode: store.mode, decoStops: store.plan.decoStops)
    }

    private var canSendWatchBriefing: Bool {
        !store.plan.ascentTableRows.isEmpty || !decoStopsPresentationRows.isEmpty
    }

    private var runtimeIncludesDecoStops: Bool {
        !store.plan.decoStops.isEmpty
            || store.plan.ascentTableRows.contains { $0.kind == .decoStop }
    }

    private var watchBriefingStatusMessage: String? {
        switch plannerBriefingTransfer.state {
        case .idle:
            return nil
        case .generating:
            return DIRIOSLocalizer.string("planner.watch_briefing.generating")
        case .sending:
            return DIRIOSLocalizer.string("planner.watch_briefing.sending")
        case .queued:
            return DIRIOSLocalizer.string("planner.watch_briefing.queued")
        case .sent:
            return DIRIOSLocalizer.string("planner.watch_briefing.sent")
        case .failed:
            return DIRIOSLocalizer.string("planner.watch_briefing.failed")
        }
    }

    private var isWatchBriefingActionDisabled: Bool {
        switch plannerBriefingTransfer.state {
        case .generating, .sending:
            return true
        default:
            return false
        }
    }

    private var watchBriefingStatusColor: Color {
        if case .failed = plannerBriefingTransfer.state {
            return DIRTheme.red
        }
        return DIRTheme.cyan
    }

    @State private var tab: PlanTab = .plan
    @State private var showChecklistExportPrompt = false
    @State private var showChecklistExportSheet = false
    @State private var checklistExportCandidates: [ChecklistPlannerExportCandidate] = []
    @State private var didPresentChecklistExportPrompt = false

    private var availableResultTabs: [PlanTab] {
        var tabs: [PlanTab] = [.plan]
        if modePresentation.showsNDLCurveTab { tabs.append(.curve) }
        if modePresentation.showsChartsTab { tabs.append(.charts) }
        return tabs
    }

    private var planShareText: String {
        var lines: [String] = []
        lines.append(
            String(
                format: DIRIOSLocalizer.string("planner.export.mode_line"),
                store.mode.localizedTabTitle
            )
        )
        switch store.mode {
        case .base:
            lines.append(DIRIOSLocalizer.string("planner.export.mode_disclaimer.base"))
        case .deco:
            lines.append(DIRIOSLocalizer.string("planner.export.mode_disclaimer.deco"))
        case .technical:
            lines.append(DIRIOSLocalizer.string("planner.export.mode_disclaimer.technical"))
        case .ccr:
            lines.append(DIRIOSLocalizer.string("ccr.safety.disclaimer"))
        }
        lines.append(DIRIOSLocalizer.string("planner.export.header"))
        lines.append(DIRIOSLocalizer.formatted("planner.export.tts_line", store.plan.ttsMinutes))
        lines.append(DIRIOSLocalizer.formatted("planner.export.runtime_line", store.plan.totalRuntimeMinutes))
        lines.append("NDL: \(Formatters.one(store.plan.ndlMinutes)) min")
        lines.append(
            String(
                format: DIRIOSLocalizer.string("planner.export.cns_full_plan_line"),
                Formatters.zero(store.plan.cnsPercent)
            )
        )
        lines.append(
            String(
                format: DIRIOSLocalizer.string("planner.export.cns_descent_bottom_line"),
                Formatters.zero(store.plan.gasAnalysis.cnsDescentBottomPercent)
            )
        )
        lines.append(
            String(
                format: DIRIOSLocalizer.string("planner.export.cns_ascent_deco_line"),
                Formatters.zero(store.plan.gasAnalysis.cnsAscentDecoEstimatePercent)
            )
        )
        lines.append(
            String(
                format: DIRIOSLocalizer.string("planner.export.otu_line"),
                Formatters.zero(store.plan.otu)
            )
        )
        lines.append(DIRIOSLocalizer.string("planner.runtime.title"))
        if store.plan.ascentTableRows.isEmpty, store.plan.decoStops.isEmpty {
            lines.append(DIRIOSLocalizer.string("planner.export.no_deco_stops"))
        } else if !store.plan.ascentTableRows.isEmpty {
            for row in store.plan.ascentTableRows {
                lines.append("  \(row.kind.localizedTitle) · \(row.depthLabel) / \(row.timeLabel) · \(row.gas) · PPO₂ \(row.ppO2Label)")
            }
        } else {
            lines.append(DIRIOSLocalizer.string("planner.export.deco_stops"))
            for stop in store.plan.decoStops {
                lines.append(
                    DIRIOSLocalizer.formatted(
                        "planner.export.deco_stop_line",
                        "\(PlannerAscentRowKind.decoStop.localizedTitle) · \(depthText(stop.depthMeters))",
                        stop.minutes,
                        stop.gas,
                        Formatters.one(stop.ppO2)
                    )
                )
            }
        }
        lines.append(DIRIOSLocalizer.string("planner.export.indicative_footer"))
        return lines.joined(separator: "\n")
    }

    var body: some View {
        DIRScreenContainer {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    resultHeaderBadge
                        dashboardHeroGrid
                        tissueAnalyticsEntry
                        resultTabs
                    modValidationSection
                    resultWarningsSection
                    bailoutScheduleHint
                    switch tab {
                    case .plan:
                        if store.decompressionMethod != .buhlmann, store.mode != .base {
                            RatioDecoComparisonSection(unitPreference: unitPreference)
                        }
                        if modePresentation.showsGasLedger {
                            gasLedgerCard
                        }
                        if showsDecoStopsSection {
                            DecoStopsSectionView(rows: decoStopsPresentationRows)
                        } else if showsNoDecoStopsNote {
                            plannerResultMutedFootnote(DIRIOSLocalizer.string("planner.deco_stops.none"))
                        }
                        if modePresentation.showsFullAscentTable || modePresentation.showsSimplifiedAscentTable {
                            ascentTable
                        }
                        secondaryMetricsSection
                        if let guidance = store.plan.modeGuidanceMessage {
                            modeGuidanceCard(guidance)
                        }
                        if modePresentation.showsContingency {
                            contingencyCard
                        }
                        if modePresentation.showsBriefing {
                            briefingCard
                        }
                        if store.mode == .base {
                            baseCompatibilitySummary
                        }
                        plannerLegalFootnotes
                        if canSendWatchBriefing {
                            sendWatchBriefingSection
                        }
                        if canExportPlanPDF {
                            shareDivePackButton
                        }
                    case .curve:
                        buhlmannSection
                    case .charts:
                        depthProfileChart
                        segmentTimeline
                        if modePresentation.showsGFComparison {
                            gfComparisonCard
                        }
                    }
                }
                .padding(.horizontal, DIRTheme.screenPadding)
                .padding(.top, 10)
                .padding(.bottom, 18)
            }
            .dirCompanionScrollSurface()
        }
        .onAppear {
            if !availableResultTabs.contains(tab) {
                tab = .plan
            }
            presentChecklistExportPromptIfNeeded()
        }
        .confirmationDialog(
            DIRIOSLocalizer.string("checklist_planner.sync.export_prompt"),
            isPresented: $showChecklistExportPrompt,
            titleVisibility: .visible
        ) {
            Button(DIRIOSLocalizer.string("checklist_planner.sync.add_all")) {
                addAllPlannerGasesToChecklist()
            }
            Button(DIRIOSLocalizer.string("checklist_planner.sync.choose_add")) {
                openChecklistExportSheet()
            }
            Button(DIRIOSLocalizer.string("checklist_planner.sync.do_not_add"), role: .cancel) {}
        }
        .sheet(isPresented: $showChecklistExportSheet) {
            ChecklistPlannerSyncSheet(
                flow: .exportToChecklist,
                importCandidates: .constant([]),
                exportCandidates: $checklistExportCandidates,
                onConfirm: { confirmChecklistExport() },
                onCancel: { showChecklistExportSheet = false }
            )
        }
        .navigationTitle(store.mode.localizedResultTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showResultPDFMenu = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(DIRTheme.cyan)
                }
                .accessibilityLabel(Text(DIRIOSLocalizer.string("pdf.export.share.a11y")))
            }
        }
        .confirmationDialog(
            DIRIOSLocalizer.string("pdf.export.share.a11y"),
            isPresented: $showResultPDFMenu,
            titleVisibility: .visible
        ) {
            Button(DIRIOSLocalizer.string("pdf.export.share.plan")) {
                shareResultPDF(kind: .plan)
            }
            Button(DIRIOSLocalizer.string("pdf.export.share.briefing")) {
                shareResultPDF(kind: .briefing)
            }
            Button(DIRIOSLocalizer.string("pdf.export.share.dive_pack")) {
                shareResultPDF(kind: .divePack)
            }
            Button(DIRIOSLocalizer.string("pdf.export.cancel"), role: .cancel) {}
        }
        .sheet(item: $shareablePDF) { item in
            ShareSheetView(activityItems: [item.url])
        }
        .alert(DIRIOSLocalizer.string("pdf.export.error.title"), isPresented: Binding(
            get: { pdfExportAlertMessage != nil },
            set: { if !$0 { pdfExportAlertMessage = nil } }
        )) {
            Button(DIRIOSLocalizer.string("common.ok"), role: .cancel) {}
        } message: {
            Text(pdfExportAlertMessage ?? "")
        }
    }

    private var sendWatchBriefingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                sendPlannerBriefingToWatch()
            } label: {
                Text(DIRIOSLocalizer.string("planner.watch_briefing.send"))
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(DIRTheme.cyan)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan.opacity(0.75), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .disabled(isWatchBriefingActionDisabled)

            Text(DIRIOSLocalizer.string("planner.watch_briefing.ref_only"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)

            if let watchBriefingStatusMessage {
                Text(watchBriefingStatusMessage)
                    .font(.caption)
                    .foregroundStyle(watchBriefingStatusColor)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func sendPlannerBriefingToWatch() {
        guard canSendWatchBriefing else { return }
        let input = PlannerBriefingImageExportInput(
            modeLabel: store.mode.localizedTabTitle,
            plannerSessionId: nil,
            decoStopRows: PlannerBriefingImageExportService.decoRows(from: decoStopsPresentationRows),
            runtimeRows: PlannerBriefingImageExportService.runtimeRows(from: store.plan.ascentTableRows),
            includesDecoStopsInRuntime: runtimeIncludesDecoStops
        )
        plannerBriefingTransfer.exportAndSend(input: input)
    }

    private var shareDivePackButton: some View {
        Button {
            shareResultPDF(kind: .divePack)
        } label: {
            Text(DIRIOSLocalizer.string("pdf.export.share.dive_pack_button"))
                .font(.callout.weight(.semibold))
                .foregroundStyle(DIRTheme.cyan)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan.opacity(0.75), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private enum ResultPDFShareKind {
        case plan, briefing, divePack
    }

    private func resultPDFContext() -> PDFExportPlannerContext {
        PDFShareActions.plannerContext(
            store: store,
            safetyAcknowledged: plannerSafetyAcknowledged,
            unitPreference: unitPreference,
            pressureUnitPreference: pressureUnitPreference,
            modIssues: liveMODIssues
        )
    }

    private func shareResultPDF(kind: ResultPDFShareKind) {
        let context = resultPDFContext()
        guard PDFExportService.canExportPlan(context) else {
            pdfExportAlertMessage = PDFShareActions.invalidPlanMessage()
            return
        }
        do {
            let url: URL
            switch kind {
            case .plan:
                url = try PDFExportService.exportPlan(context: context)
            case .briefing:
                url = try PDFExportService.exportBriefing(context: context)
            case .divePack:
                url = try PDFExportService.exportDivePack(
                    plannerContext: context,
                    checklistProfile: equipment.profile
                )
            }
            shareablePDF = ShareablePDFItem(url: url)
        } catch {
            pdfExportAlertMessage = PDFShareActions.invalidPlanMessage()
        }
    }

    private func presentChecklistExportPromptIfNeeded() {
        guard pendingChecklistExportPrompt, !didPresentChecklistExportPrompt else { return }
        let missing = ChecklistPlannerSyncMapper.cylindersMissingFromChecklist(
            plannerCylinders: store.input.plannerCylinders,
            checklist: equipment.profile.checklistItems
        )
        guard !missing.isEmpty else { return }
        didPresentChecklistExportPrompt = true
        showChecklistExportPrompt = true
    }

    private func openChecklistExportSheet() {
        checklistExportCandidates = ChecklistPlannerSyncMapper.exportCandidates(
            plannerCylinders: ChecklistPlannerSyncMapper.cylindersMissingFromChecklist(
                plannerCylinders: store.input.plannerCylinders,
                checklist: equipment.profile.checklistItems
            ),
            checklist: equipment.profile.checklistItems
        )
        showChecklistExportSheet = true
    }

    private func addAllPlannerGasesToChecklist() {
        checklistExportCandidates = ChecklistPlannerSyncMapper.exportCandidates(
            plannerCylinders: ChecklistPlannerSyncMapper.cylindersMissingFromChecklist(
                plannerCylinders: store.input.plannerCylinders,
                checklist: equipment.profile.checklistItems
            ),
            checklist: equipment.profile.checklistItems
        )
        confirmChecklistExport()
    }

    private func confirmChecklistExport() {
        ChecklistPlannerSyncMapper.applyExport(
            candidates: checklistExportCandidates,
            to: &equipment.profile.checklistItems
        )
        showChecklistExportSheet = false
    }

    private var referenceDepthSummary: String? {
        guard store.mode == .technical else { return nil }
        let active = PlannerModePolicy.activePlanInput(from: store.input, mode: store.mode)
        let label = active.averageDepthGasConsumptionEnabled
            ? DIRIOSLocalizer.string("planner.technical.gas_consumption.reference.average")
            : DIRIOSLocalizer.string("planner.technical.gas_consumption.reference.max")
        return DIRIOSLocalizer.formatted("planner.result.gas_consumption_reference", label)
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
                Text(DIRIOSLocalizer.string("planner.repetitive.result_badge"))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(DIRTheme.yellow)
            }
            if let referenceDepthSummary {
                Text(referenceDepthSummary)
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
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
            Text(DIRIOSLocalizer.string("planner.result.calculation_incomplete"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(DIRTheme.red)
                .fixedSize(horizontal: false, vertical: true)
            Text(DIRIOSLocalizer.string("planner.result.calculation_incomplete.detail"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
            Text(DIRIOSLocalizer.string("planner.result.calculation_incomplete.recovery"))
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
            "\(DIRIOSLocalizer.string("planner.result.calculation_incomplete")) \(DIRIOSLocalizer.string("planner.result.calculation_incomplete.detail"))"
        )
    }

    @ViewBuilder
    private var resultWarningsSection: some View {
        let blocking = store.plan.userFacingWarnings.filter { $0.severity == .blocking }
        let caution = store.plan.userFacingWarnings.filter { $0.severity == .warning }

        if !blocking.isEmpty {
            DIRCard(DIRIOSLocalizer.string("planner.result.warnings.blocking.title"), icon: "exclamationmark.octagon.fill", accent: DIRTheme.red) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(blocking) { warning in
                        plannerWarningRow(warning, accent: DIRTheme.red)
                    }
                }
            }
        }

        if !caution.isEmpty {
            DIRCard(DIRIOSLocalizer.string("planner.result.warnings.caution.title"), icon: "exclamationmark.triangle.fill", accent: DIRTheme.yellow) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(caution) { warning in
                        plannerWarningRow(warning, accent: DIRTheme.yellow)
                    }
                }
            }
        }
    }

    private func plannerWarningRow(_ warning: PlannerUserFacingMessage, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: warning.severity == .blocking ? "exclamationmark.octagon.fill" : "exclamationmark.triangle.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(accent)
                Text(warning.title)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(accent)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text(warning.message)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.92))
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

    private var dashboardHeroGrid: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                DIRMetricTile(title: DIRIOSLocalizer.string("planner.metric.tts"), value: "\(store.plan.ttsMinutes)", unit: "min", color: DIRTheme.cyan)
                Divider().overlay(DIRTheme.hairline)
                DIRMetricTile(title: DIRIOSLocalizer.string("planner.metric.runtime"), value: "\(store.plan.totalRuntimeMinutes)", unit: "min", color: DIRTheme.cyan)
                Divider().overlay(DIRTheme.hairline)
                DIRMetricTile(
                    title: DIRIOSLocalizer.string("planner.result.deco_stops"),
                    value: "\(store.plan.decoStops.count)",
                    color: store.plan.decoStops.isEmpty ? DIRTheme.green : DIRTheme.yellow
                )
            }
            Divider().overlay(DIRTheme.hairline)
            HStack(spacing: 0) {
                DIRMetricTile(
                    title: DIRIOSLocalizer.string("planner.result.max_depth"),
                    value: Formatters.depth(store.input.plannedDepthMeters, units: unitPreference).value,
                    unit: Formatters.depth(store.input.plannedDepthMeters, units: unitPreference).unit,
                    color: DIRTheme.cyan
                )
                Divider().overlay(DIRTheme.hairline)
                DIRMetricTile(
                    title: DIRIOSLocalizer.string("planner.result.bottom_time"),
                    value: Formatters.zero(store.input.plannedBottomMinutes),
                    unit: "min",
                    color: DIRTheme.cyan
                )
                Divider().overlay(DIRTheme.hairline)
                DIRMetricTile(
                    title: DIRIOSLocalizer.string("planner.metric.cns_full_plan"),
                    value: store.plan.gasAnalysis.cnsPercentDisplay,
                    unit: "%",
                    color: fullPlanCNSWarningActive ? DIRTheme.yellow : DIRTheme.green,
                    icon: fullPlanCNSWarningActive ? "exclamationmark.triangle.fill" : nil
                )
                .accessibilityLabel(fullPlanCNSTileAccessibilityLabel)
            }
            if fullPlanCNSWarningActive {
                fullPlanCNSWarningBanner
            }
        }
        .background(
            RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                .fill(DIRTheme.surface.opacity(0.88))
                .overlay(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).stroke(DIRTheme.cyan.opacity(0.35), lineWidth: 1))
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel(DIRIOSLocalizer.string("planner.result.dashboard.a11y"))
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
        store.mode != .base && !store.plan.tissueHistory.isEmpty && store.plan.buhlmannState != .invalidInput
    }

    private var tissueAnalyticsPresentation: TissueAnalyticsPresentation? {
        TissueAnalyticsService.presentationForPlanner(plan: store.plan, input: store.input, mode: store.mode)
    }

    private var secondaryMetricsSection: some View {
        DisclosureGroup {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    DIRMetricTile(title: "OTU", value: Formatters.zero(store.plan.otu), color: DIRTheme.cyan)
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "NDL", value: Formatters.one(store.plan.ndlMinutes), unit: "min", color: DIRTheme.cyan)
                }
                if store.plan.gasAnalysis.showsWeeklyOTUMetric {
                    Divider().overlay(DIRTheme.hairline)
                    HStack(spacing: 0) {
                        DIRMetricTile(
                            title: DIRIOSLocalizer.string("planner.metric.otu_weekly"),
                            value: Formatters.zero(store.plan.gasAnalysis.otuWeekly),
                            color: weeklyOTUWarningActive ? DIRTheme.yellow : DIRTheme.cyan,
                            icon: weeklyOTUWarningActive ? "exclamationmark.triangle.fill" : nil
                        )
                        .accessibilityLabel(weeklyOTUTileAccessibilityLabel)
                    }
                    if weeklyOTUWarningActive {
                        weeklyOTUWarningBanner
                    }
                    plannerResultMutedFootnote(DIRIOSLocalizer.string("planner.metric.otu_weekly.footnote"))
                }
                Divider().overlay(DIRTheme.hairline)
                HStack(spacing: 0) {
                    DIRMetricTile(
                        title: DIRIOSLocalizer.string("planner.metric.cns_descent_bottom"),
                        value: Formatters.zero(store.plan.gasAnalysis.cnsDescentBottomPercent),
                        unit: "%",
                        color: cnsDescentBottomWarningActive ? DIRTheme.red : DIRTheme.cyan,
                        icon: cnsDescentBottomWarningActive ? "exclamationmark.triangle.fill" : nil
                    )
                    .accessibilityLabel(cnsDescentBottomTileAccessibilityLabel)
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(
                        title: DIRIOSLocalizer.string("planner.metric.cns_ascent_deco_estimate"),
                        value: Formatters.zero(store.plan.gasAnalysis.cnsAscentDecoEstimatePercent),
                        unit: "%",
                        color: DIRTheme.cyan
                    )
                }
                if cnsDescentBottomWarningActive {
                    cnsDescentBottomWarningBanner
                } else {
                    cnsThresholdResultFootnote
                }
                Divider().overlay(DIRTheme.hairline)
                let endMeasurement = Formatters.depth(store.analysis.endMeters, units: unitPreference)
                HStack(spacing: 0) {
                    DIRMetricTile(
                        title: DIRIOSLocalizer.string("planner.metric.density"),
                        value: Formatters.one(store.analysis.densityAtDepth),
                        unit: "g/L",
                        color: store.analysis.densityRating == .red ? DIRTheme.red : DIRTheme.cyan
                    )
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "END", value: endMeasurement.value, unit: endMeasurement.unit, color: DIRTheme.yellow)
                    Divider().overlay(DIRTheme.hairline)
                    let turnPressure = Formatters.pressure(fromBar: store.analysis.turnPressureBar, unit: pressureUnitPreference)
                    DIRMetricTile(
                        title: DIRIOSLocalizer.string("planner.metric.turn_pressure"),
                        value: turnPressure.value,
                        unit: turnPressure.unit,
                        color: DIRTheme.cyan
                    )
                }
                VStack(alignment: .leading, spacing: 4) {
                    plannerResultMutedFootnote(DIRIOSLocalizer.string("planner.metric.cns_full_plan.footnote"))
                    plannerResultMutedFootnote(DIRIOSLocalizer.string("planner.ndl.reference_ascent_footnote"))
                    plannerResultMutedFootnote(DIRIOSLocalizer.string("planner.metric.cns_descent_bottom.footnote"))
                    plannerResultMutedFootnote(DIRIOSLocalizer.string("planner.metric.cns_ascent_deco_estimate.footnote"))
                    Text(
                        String(
                            format: DIRIOSLocalizer.string("planner.oxygen_exposure.daily_summary"),
                            Formatters.zero(store.plan.gasAnalysis.cnsDailyPercent),
                            Formatters.zero(store.plan.gasAnalysis.otuDaily24h)
                        )
                    )
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
                    if store.plan.gasAnalysis.airBreakRecoveryApplied {
                        Text(DIRIOSLocalizer.string("planner.oxygen_exposure.air_break_applied"))
                            .font(.caption2)
                            .foregroundStyle(DIRTheme.yellow)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.top, 8)
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.doc.horizontal")
                    .foregroundStyle(DIRTheme.cyan)
                Text(DIRIOSLocalizer.string("planner.result.secondary_metrics.title"))
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white)
            }
        }
        .tint(DIRTheme.cyan)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                .fill(DIRTheme.surface.opacity(0.72))
                .overlay(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).stroke(DIRTheme.hairline, lineWidth: 1))
        )
    }

    private var plannerLegalFootnotes: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(DIRIOSLocalizer.string("planner.oxygen_exposure.disclaimer"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted.opacity(0.88))
                .fixedSize(horizontal: false, vertical: true)
            Text(DIRIOSLocalizer.string("planner.header.reference_only.hint"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted.opacity(0.75))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 4)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var bailoutScheduleHint: some View {
        let travelLimitationWarnings = PlannerGasSchedule.travelToBottomSwitchLimitationWarnings(input: store.input)
        let bailoutWarnings = PlannerGasSchedule.bailoutAvailabilityWarnings(input: store.input)
        if !travelLimitationWarnings.isEmpty || !PlannerGasSchedule.bailoutCylinders(from: store.input).isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                if !PlannerGasSchedule.bailoutCylinders(from: store.input).isEmpty {
                    DIRWarningBox(text: DIRIOSLocalizer.string("planner.bailout.schedule_hint"))
                }
                ForEach(travelLimitationWarnings + bailoutWarnings, id: \.self) { warning in
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
            DIRCard(DIRIOSLocalizer.string("planner.available_gas.title"), icon: "fuelpump", accent: DIRTheme.red) {
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
            DIRCard(DIRIOSLocalizer.string("planner.available_gas.title"), icon: "fuelpump", accent: DIRTheme.cyan) {
                VStack(spacing: 10) {
                    Text(DIRIOSLocalizer.string("planner.gas_ledger.subtitle"))
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                    ForEach(ledger.entries, id: \.cylinderId) { entry in
                        gasLedgerEntryRow(entry, ledger: ledger)
                        Divider().overlay(DIRTheme.hairline)
                    }
                    if !ledger.unusedPlannedEntries.isEmpty {
                        Text(DIRIOSLocalizer.string("planner.gas_ledger.unused_title"))
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
        let cylinderVolume = GasLedgerDisplayFormatter.cylinderVolumeLiters(for: entry.cylinderId, input: store.input)
        let availableLiters = entry.consumedLiters + entry.remainingLiters
        let availableBar = cylinderVolume > 0 ? availableLiters / cylinderVolume : entry.remainingBar
        let consumedBar = cylinderVolume > 0 ? entry.consumedLiters / cylinderVolume : nil
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
                    Text(DIRIOSLocalizer.string("planner.gas_ledger.reserve_flag"))
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(DIRTheme.red)
                }
            }
            HStack(spacing: 0) {
                GasQuantityMetricTile(
                    title: DIRIOSLocalizer.string("planner.gas_ledger.available_gas"),
                    display: GasLedgerDisplayFormatter.displayValue(
                        liters: availableLiters,
                        pressureBar: availableBar,
                        cylinderVolumeLiters: cylinderVolume,
                        pressureUnit: pressureUnitPreference
                    ),
                    color: DIRTheme.cyan
                )
                Divider().overlay(DIRTheme.hairline)
                GasQuantityMetricTile(
                    title: DIRIOSLocalizer.string("planner.gas_ledger.estimated_consumption"),
                    display: GasLedgerDisplayFormatter.displayValue(
                        liters: entry.consumedLiters,
                        pressureBar: consumedBar,
                        cylinderVolumeLiters: cylinderVolume,
                        pressureUnit: pressureUnitPreference
                    ),
                    color: DIRTheme.yellow
                )
                Divider().overlay(DIRTheme.hairline)
                GasQuantityMetricTile(
                    title: DIRIOSLocalizer.string("planner.metric.remaining"),
                    display: GasLedgerDisplayFormatter.displayValue(
                        liters: entry.remainingLiters,
                        pressureBar: entry.remainingBar,
                        cylinderVolumeLiters: cylinderVolume,
                        pressureUnit: pressureUnitPreference
                    ),
                    color: entry.remainingLiters < 0 || reserveBreached ? DIRTheme.red : DIRTheme.green
                )
            }
            if lostGasFailed {
                Text(DIRIOSLocalizer.string("planner.gas_ledger.warning.lost_gas.message"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.yellow)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            String(
                format: DIRIOSLocalizer.string("planner.gas_ledger.entry.a11y"),
                entry.gasLabel,
                Formatters.zero(entry.consumedLiters),
                Formatters.zero(entry.remainingBar)
            )
        )
    }

    private func unusedGasLedgerEntryRow(_ entry: GasConsumptionLedger.UnusedPlannedEntry) -> some View {
        let cylinderLabel = store.input.plannerCylinders.first(where: { $0.id == entry.cylinderId })?.tankSize.rawValue
            ?? store.input.primaryCylinder.name
        let cylinderVolume = GasLedgerDisplayFormatter.cylinderVolumeLiters(for: entry.cylinderId, input: store.input)
        let subtitle = entry.isStandbyOrBailout
            ? DIRIOSLocalizer.string("planner.gas_ledger.unused_standby")
            : DIRIOSLocalizer.string("planner.gas_ledger.unused_planned")
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
                GasQuantityMetricTile(
                    title: DIRIOSLocalizer.string("planner.gas_ledger.available_gas"),
                    display: GasLedgerDisplayFormatter.displayValue(
                        liters: entry.availableLiters,
                        pressureBar: entry.availableBar,
                        cylinderVolumeLiters: cylinderVolume,
                        pressureUnit: pressureUnitPreference
                    ),
                    color: DIRTheme.cyan
                )
            }
            Text(DIRIOSLocalizer.string("planner.gas_ledger.not_consumed_note"))
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
            switch store.mode {
            case .base:
                DIRCard(DIRIOSLocalizer.string("planner.base.gas_depth.title"), icon: "exclamationmark.triangle.fill", accent: DIRTheme.red) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(DIRIOSLocalizer.string("planner.base.gas_depth.message"))
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(DIRTheme.red)
                            .fixedSize(horizontal: false, vertical: true)
                        ForEach(store.plan.modValidationIssues) { issue in
                            Text(
                                DIRIOSLocalizer.formatted(
                                    "planner.base.gas_depth.detail_format",
                                    issue.gasLabel,
                                    depthText(issue.switchDepthMeters),
                                    depthText(issue.modMeters)
                                )
                            )
                            .font(.caption)
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)
                        }
                        Text(DIRIOSLocalizer.string("planner.base.gas_depth.hint"))
                            .font(.caption2)
                            .foregroundStyle(DIRTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            case .deco, .technical:
                DIRCard(DIRIOSLocalizer.string("planner.mod.validation.title"), icon: "exclamationmark.triangle.fill", accent: DIRTheme.red) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(store.plan.modValidationIssues) { issue in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(DIRIOSLocalizer.string("planner.mod.exceeds_allowed"))
                                    .font(.callout.weight(.semibold))
                                    .foregroundStyle(DIRTheme.red)
                                Text(
                                    DIRIOSLocalizer.formatted(
                                        "planner.mod.detail_format",
                                        issue.gasLabel,
                                        depthText(issue.switchDepthMeters),
                                        depthText(issue.modMeters)
                                    )
                                )
                                .font(.caption)
                                .foregroundStyle(.white)
                            }
                        }
                        Text(DIRIOSLocalizer.string("planner.mod.incompatible"))
                            .font(.caption)
                            .foregroundStyle(DIRTheme.muted)
                        Text(DIRIOSLocalizer.string("planner.mod.hint"))
                            .font(.caption2)
                            .foregroundStyle(DIRTheme.muted)
                    }
                }
            case .ccr:
                EmptyView()
            }
        }
    }

    private var resultTabs: some View {
        HStack(spacing: 8) {
            ForEach(availableResultTabs) { item in
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        tab = item
                    }
                } label: {
                    Text(item.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(tab == item ? DIRTheme.cyan : .white.opacity(0.72))
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 11)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, minHeight: DIRTheme.buttonMinHeight)
                        .background(
                            RoundedRectangle(cornerRadius: DIRTheme.compactRadius)
                                .fill(tab == item ? DIRTheme.cyan.opacity(0.14) : DIRTheme.surface.opacity(0.55))
                                .overlay(
                                    RoundedRectangle(cornerRadius: DIRTheme.compactRadius)
                                        .stroke(tab == item ? DIRTheme.cyan.opacity(0.75) : DIRTheme.hairline, lineWidth: tab == item ? 1.5 : 1)
                                )
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tabAccessibilityLabel(for: item))
                .accessibilityAddTraits(tab == item ? .isSelected : [])
            }
        }
    }

    private func tabAccessibilityLabel(for item: PlanTab) -> String {
        if tab == item {
            return DIRIOSLocalizer.formatted("planner.tab.a11y.selected", item.title)
        }
        return DIRIOSLocalizer.formatted("planner.tab.a11y.unselected", item.title)
    }

    private var ascentTable: some View {
        DIRCard(DIRIOSLocalizer.string("planner.runtime.title"), icon: "timer", accent: DIRTheme.cyan) {
            Text(DIRIOSLocalizer.string("planner.runtime.subtitle"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(DIRIOSLocalizer.string("planner.table.briefing_order.footnote"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            if store.plan.calculationCompleteness == .incompletePartialStops {
                incompleteCalculationBanner
            } else if store.mode == .base {
                Text(DIRIOSLocalizer.string("planner.buhlmann.hidden_in_base"))
                    .font(.caption)
                    .foregroundStyle(DIRTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            } else if store.plan.ascentTableRows.isEmpty {
                Text(DIRIOSLocalizer.string("planner.export.no_deco_stops"))
                    .font(.caption)
                    .foregroundStyle(DIRTheme.muted)
            } else {
                VStack(spacing: 0) {
                    tableRow([
                        DIRIOSLocalizer.string("planner.table.phase"),
                        DIRIOSLocalizer.string("planner.table.depth"),
                        DIRIOSLocalizer.string("planner.table.time"),
                        DIRIOSLocalizer.string("planner.table.gas"),
                        "PPO₂"
                    ], isHeader: true)
                    ForEach(store.plan.ascentTableRows) { row in
                        tableRow(
                            [
                                row.kind.localizedTitle,
                                row.depthLabel,
                                row.timeLabel,
                                row.gas,
                                row.ppO2Label
                            ],
                            isSurface: row.kind == .surface,
                            columnHeaders: [
                                DIRIOSLocalizer.string("planner.table.phase"),
                                DIRIOSLocalizer.string("planner.table.depth"),
                                DIRIOSLocalizer.string("planner.table.time"),
                                DIRIOSLocalizer.string("planner.table.gas"),
                                "PPO₂"
                            ]
                        )
                        if row.id != store.plan.ascentTableRows.last?.id {
                            Divider().overlay(DIRTheme.hairline)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: DIRTheme.compactRadius)
                        .fill(DIRTheme.surface2.opacity(0.45))
                )
                .accessibilityElement(children: .contain)
                .accessibilityLabel(DIRIOSLocalizer.string("planner.runtime.table.a11y"))
            }
        }
    }

    private func modeGuidanceCard(_ guidance: PlannerUserFacingMessage) -> some View {
        DIRCard(guidance.title, icon: "exclamationmark.triangle.fill", accent: DIRTheme.yellow) {
            Text(guidance.message)
                .font(.caption)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var baseCompatibilitySummary: some View {
        DIRCard(DIRIOSLocalizer.string("planner.result.base.summary"), icon: "checkmark.seal", accent: DIRTheme.cyan) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 0) {
                    Group {
                        let modMeasurement = Formatters.depth(
                            store.input.bottomGas.modMeters(environment: store.input.plannerEnvironment),
                            units: unitPreference
                        )
                        DIRMetricTile(title: "MOD", value: modMeasurement.value, unit: modMeasurement.unit)
                    }
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "PPO2", value: Formatters.one(store.analysis.ppO2AtDepth), color: store.analysis.ppO2AtDepth > store.input.bottomGas.maxPPO2 ? DIRTheme.red : DIRTheme.green)
                    Divider().overlay(DIRTheme.hairline)
                    DIRMetricTile(title: "NDL", value: Formatters.one(store.plan.ndlMinutes), unit: "min")
                }
                Text(DIRIOSLocalizer.string("planner.buhlmann.hidden_in_base"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var segmentTimeline: some View {
        DIRCard(DIRIOSLocalizer.string("planner.result.timeline"), icon: "list.bullet.rectangle", accent: DIRTheme.cyan) {
            VStack(spacing: 8) {
                tableRow([
                    DIRIOSLocalizer.string("planner.table.type"),
                    DIRIOSLocalizer.string("planner.table.depth_short"),
                    DIRIOSLocalizer.string("planner.table.min"),
                    DIRIOSLocalizer.string("planner.table.gas")
                ], isHeader: true)
                ForEach(store.plan.segments) { segment in
                    tableRow(
                        [
                            segment.kind.rawValue,
                            depthText(segment.depthMeters),
                            Formatters.one(segment.minutes),
                            segment.gas
                        ],
                        columnHeaders: [
                            DIRIOSLocalizer.string("planner.table.type"),
                            DIRIOSLocalizer.string("planner.table.depth_short"),
                            DIRIOSLocalizer.string("planner.table.min"),
                            DIRIOSLocalizer.string("planner.table.gas")
                        ]
                    )
                }
            }
        }
    }

    private var gfComparisonCard: some View {
        DIRCard(DIRIOSLocalizer.string("planner.result.gf_compare"), icon: "chart.line.uptrend.xyaxis", accent: DIRTheme.green) {
            VStack(spacing: 8) {
                tableRow([
                    "GF",
                    "TTS",
                    DIRIOSLocalizer.string("planner.table.stops"),
                    DIRIOSLocalizer.string("planner.table.note")
                ], isHeader: true)
                ForEach(store.plan.gfComparisons) { comparison in
                    tableRow(
                        [
                            comparison.label,
                            "\(comparison.ttsMinutes) min",
                            "\(comparison.stopCount)",
                            comparison.conservatismNote
                        ],
                        columnHeaders: [
                            "GF",
                            "TTS",
                            DIRIOSLocalizer.string("planner.table.stops"),
                            DIRIOSLocalizer.string("planner.table.note")
                        ]
                    )
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(DIRIOSLocalizer.string("planner.result.gf_compare.a11y"))
        }
    }

    private var contingencyCard: some View {
        DIRCard(DIRIOSLocalizer.string("planner.result.contingencies"), icon: "exclamationmark.triangle", accent: DIRTheme.yellow) {
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

    private var briefingCard: some View {
        DIRCard(DIRIOSLocalizer.string("planner.briefing.title"), icon: "doc.text", accent: DIRTheme.green) {
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
                Text(DIRIOSLocalizer.string("planner.briefing.share_note"))
                    .font(.caption)
                    .foregroundStyle(DIRTheme.muted)
            }
        }
    }

    private func tableColumnAccessibilityLabel(index: Int, value: String, headers: [String]?) -> String {
        guard let headers, index < headers.count else { return value }
        return "\(headers[index]): \(value)"
    }

    private func tableRowSummary(_ values: [String]) -> String {
        switch values.count {
        case 2:
            return DIRIOSLocalizer.formatted("planner.table.row.a11y.two", values[0], values[1])
        case 3:
            return DIRIOSLocalizer.formatted("planner.table.row.a11y.three", values[0], values[1], values[2])
        case 4:
            return DIRIOSLocalizer.formatted("planner.table.row.a11y", values[0], values[1], values[2], values[3])
        default:
            return values.joined(separator: ", ")
        }
    }

    private func tableRow(
        _ values: [String],
        isHeader: Bool = false,
        isSurface: Bool = false,
        columnHeaders: [String]? = nil
    ) -> some View {
        HStack(spacing: 6) {
            ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                Text(value)
                    .font(isHeader ? .caption.weight(.semibold) : .caption.monospacedDigit())
                    .foregroundStyle(isHeader ? DIRTheme.muted : (isSurface ? DIRTheme.green : .white))
                    .frame(maxWidth: .infinity, alignment: index == 0 ? .leading : (index == values.count - 1 ? .trailing : .center))
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                    .accessibilityLabel(
                        isHeader || columnHeaders == nil
                            ? value
                            : tableColumnAccessibilityLabel(index: index, value: value, headers: columnHeaders)
                    )
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, isHeader ? 8 : 10)
        .background(isHeader ? DIRTheme.surface2.opacity(0.65) : (isSurface ? DIRTheme.green.opacity(0.08) : Color.clear))
        .accessibilityElement(children: isHeader ? .combine : .contain)
        .accessibilityAddTraits(isHeader ? .isHeader : [])
        .accessibilityHint(isHeader ? "" : tableRowSummary(values))
    }

    @ViewBuilder
    private var buhlmannSection: some View {
        switch modePresentation.buhlmannPresentation {
        case .hidden:
            EmptyView()
        case .simplifiedSummary, .fullCurve:
            tissueLoadingChartSection(showNDLReference: modePresentation.buhlmannPresentation == .fullCurve)
        }
    }

    private func tissueGroupLabel(_ group: String) -> String {
        switch group {
        case "1-4": return DIRIOSLocalizer.string("planner.buhlmann.group_1_4")
        case "5-8": return DIRIOSLocalizer.string("planner.buhlmann.group_5_8")
        case "9-12": return DIRIOSLocalizer.string("planner.buhlmann.group_9_12")
        default: return DIRIOSLocalizer.string("planner.buhlmann.group_13_16")
        }
    }

    private func tissueGroupColor(_ group: String) -> Color {
        switch group {
        case "1-4": return DIRTheme.cyan
        case "5-8": return DIRTheme.green
        case "9-12": return DIRTheme.yellow
        default: return DIRTheme.red
        }
    }

    private var buhlmannChartAccessibilitySummary: String {
        guard !store.plan.tissueHistory.isEmpty else {
            return DIRIOSLocalizer.string("planner.buhlmann.tissue_curve_empty")
        }
        let peak = store.plan.tissueHistory.groupedPoints.map(\.loadPercent).max() ?? 0
        return String(
            format: DIRIOSLocalizer.string("planner.buhlmann.tissue_chart.a11y.summary"),
            Formatters.zero(peak)
        )
    }

    @ViewBuilder
    private func tissueLoadingChartSection(showNDLReference: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if store.input.buhlmannUsesTrimixBackGas {
                DIRWarningBox(text: DIRIOSLocalizer.string("planner.gas.trimix_buhlmann_disclaimer"))
            }
            DIRCard(DIRIOSLocalizer.string("planner.buhlmann.tissue_curve_title"), icon: "waveform.path.ecg", accent: DIRTheme.cyan) {
                Text(DIRIOSLocalizer.string("planner.buhlmann.tissue_curve_disclaimer"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)

                if store.plan.tissueHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.title2)
                            .foregroundStyle(DIRTheme.muted)
                        Text(DIRIOSLocalizer.string("planner.buhlmann.tissue_curve_empty"))
                            .font(.callout.weight(.medium))
                            .foregroundStyle(.white.opacity(0.86))
                            .fixedSize(horizontal: false, vertical: true)
                        Text(DIRIOSLocalizer.string("planner.buhlmann.tissue_curve_empty.detail"))
                            .font(.caption)
                            .foregroundStyle(DIRTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(DIRIOSLocalizer.string("planner.buhlmann.tissue_curve_empty"))
                } else {
                    tissueLoadingLegend
                    Chart(store.plan.tissueHistory.groupedPoints) { point in
                        LineMark(
                            x: .value(DIRIOSLocalizer.string("planner.buhlmann.axis.time"), point.elapsedMinutes),
                            y: .value(DIRIOSLocalizer.string("planner.buhlmann.axis.load"), point.loadPercent),
                            series: .value("Group", tissueGroupLabel(point.compartmentGroup))
                        )
                        .foregroundStyle(by: .value("Group", tissueGroupLabel(point.compartmentGroup)))
                        .lineStyle(StrokeStyle(lineWidth: 2))
                    }
                    .chartForegroundStyleScale([
                        tissueGroupLabel("1-4"): DIRTheme.cyan,
                        tissueGroupLabel("5-8"): DIRTheme.green,
                        tissueGroupLabel("9-12"): DIRTheme.yellow,
                        tissueGroupLabel("13-16"): DIRTheme.red
                    ])
                    .chartXAxis {
                        AxisMarks { AxisGridLine().foregroundStyle(DIRTheme.faint); AxisValueLabel().foregroundStyle(DIRTheme.muted) }
                    }
                    .chartXAxisLabel(DIRIOSLocalizer.string("planner.buhlmann.axis.time"))
                    .chartYAxis {
                        AxisMarks { AxisGridLine().foregroundStyle(DIRTheme.faint); AxisValueLabel().foregroundStyle(DIRTheme.muted) }
                    }
                    .chartYScale(domain: 0...100)
                    .chartYAxisLabel(DIRIOSLocalizer.string("planner.buhlmann.axis.load"))
                    .frame(minHeight: 180, maxHeight: 320)
                    .padding(.vertical, 4)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(buhlmannChartAccessibilitySummary)
                    .accessibilityHint(DIRIOSLocalizer.string("planner.buhlmann.tissue_chart.a11y.hint"))
                }
            }

            if showNDLReference, !store.buhlmann.curve.isEmpty {
                ndlReferenceChart
            }
        }
    }

    private var tissueLoadingLegend: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 8) {
            ForEach(["1-4", "5-8", "9-12", "13-16"], id: \.self) { group in
                HStack(spacing: 8) {
                    Circle()
                        .fill(tissueGroupColor(group))
                        .frame(width: 10, height: 10)
                    Text(tissueGroupLabel(group))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.88))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(tissueGroupLabel(group))
            }
        }
        .padding(.vertical, 6)
    }

    private var ndlReferenceChart: some View {
        DIRCard(DIRIOSLocalizer.string("planner.buhlmann.ndl_reference_title"), icon: nil, accent: DIRTheme.cyan) {
            Text(DIRIOSLocalizer.string("planner.buhlmann.curve_disclaimer"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
            Text(DIRIOSLocalizer.string("planner.buhlmann.ndl_depth_band_note"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
            Chart(store.buhlmann.curve) { point in
                LineMark(
                    x: .value(DIRIOSLocalizer.string("planner.buhlmann.axis.depth"), point.depthMeters),
                    y: .value(DIRIOSLocalizer.string("planner.buhlmann.axis.ndl"), point.ndlMinutes)
                )
                .lineStyle(StrokeStyle(lineWidth: 1.5))
                .foregroundStyle(DIRTheme.muted)
            }
            .chartXAxis {
                AxisMarks { AxisGridLine().foregroundStyle(DIRTheme.faint); AxisValueLabel().foregroundStyle(DIRTheme.muted) }
            }
            .chartXAxisLabel(DIRIOSLocalizer.string("planner.buhlmann.axis.depth"))
            .chartYAxis {
                AxisMarks { AxisGridLine().foregroundStyle(DIRTheme.faint); AxisValueLabel().foregroundStyle(DIRTheme.muted) }
            }
            .chartYAxisLabel(DIRIOSLocalizer.string("planner.buhlmann.axis.ndl"))
            .frame(minHeight: 140, maxHeight: 260)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(DIRIOSLocalizer.string("planner.buhlmann.ndl_reference.a11y"))
            .accessibilityHint(DIRIOSLocalizer.string("planner.buhlmann.ndl_reference.a11y.hint"))
        }
    }

    private var depthProfileYAxisLabel: String {
        unitPreference == .metric
            ? DIRIOSLocalizer.string("planner.charts.depth_axis_unit_metric")
            : DIRIOSLocalizer.string("planner.charts.depth_axis_unit_imperial")
    }

    private func depthProfileDisplayDepth(meters: Double) -> Double {
        -Formatters.depthValue(meters, units: unitPreference)
    }

    private var depthProfileChart: some View {
        DIRCard(DIRIOSLocalizer.string("planner.charts.depth_profile"), icon: "chart.xyaxis.line", accent: DIRTheme.cyan) {
            if store.plan.depthProfilePoints.isEmpty {
                Text(DIRIOSLocalizer.string("planner.charts.depth_profile_empty"))
                    .font(.caption)
                    .foregroundStyle(DIRTheme.muted)
            } else {
                Chart(store.plan.depthProfilePoints) { point in
                    LineMark(
                        x: .value(DIRIOSLocalizer.string("planner.buhlmann.axis.time"), point.elapsedMinutes),
                        y: .value(depthProfileYAxisLabel, depthProfileDisplayDepth(meters: point.depthMeters))
                    )
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .foregroundStyle(DIRTheme.cyan)
                }
                .chartXAxis {
                    AxisMarks { AxisGridLine().foregroundStyle(DIRTheme.faint); AxisValueLabel().foregroundStyle(DIRTheme.muted) }
                }
                .chartXAxisLabel(DIRIOSLocalizer.string("planner.buhlmann.axis.time"))
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine().foregroundStyle(DIRTheme.faint)
                        AxisValueLabel {
                            if let depth = value.as(Double.self) {
                                Text(Formatters.one(abs(depth)))
                            }
                        }
                        .foregroundStyle(DIRTheme.muted)
                    }
                }
                .chartYAxisLabel(depthProfileYAxisLabel)
                .frame(minHeight: 160, maxHeight: 280)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(DIRIOSLocalizer.string("planner.charts.depth_profile.a11y"))
                .accessibilityHint(DIRIOSLocalizer.string("planner.charts.depth_profile.a11y.hint"))
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
        case .plan: return DIRIOSLocalizer.string("planner.tab.plan")
        case .curve: return DIRIOSLocalizer.string("planner.tab.curve")
        case .charts: return DIRIOSLocalizer.string("planner.tab.charts")
        }
    }
}
