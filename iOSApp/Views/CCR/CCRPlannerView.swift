import SwiftUI
import Charts

struct CCRPlannerView: View {
    @EnvironmentObject private var store: PlannerStore
    @EnvironmentObject private var equipment: EquipmentStore
    @AppStorage(PlannerSafetyAcknowledgment.storageKey) private var plannerSafetyAckRevision = ""
    @AppStorage(IOSUnitPreference.storageKey) private var unitsRaw = IOSUnitPreference.metric.rawValue
    @State private var showPlan = false
    @State private var pendingChecklistExportAfterCalculate = false
    @State private var showChecklistImportPrompt = false
    @State private var showChecklistImportSheet = false
    @State private var ccrChecklistImportCandidates: [CCRChecklistImportCandidate] = []

    private var unitPreference: IOSUnitPreference { IOSUnitPreference.fromStorage(unitsRaw) }
    private var plannerSafetyAcknowledged: Bool {
        plannerSafetyAckRevision == PlannerSafetyAcknowledgment.currentRevision
    }

    var body: some View {
        NavigationStack {
            DIRScreenContainer {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        plannerSafetySection
                        DIRWarningBox(text: DIRIOSLocalizer.string("ccr.safety.disclaimer"))
                        profileCard
                        setpointCard
                        diluentCard
                        bailoutCard
                        gfCard
                        warningsCard
                        calculateButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 18)
                    .disabled(!plannerSafetyAcknowledged)
                    .opacity(plannerSafetyAcknowledged ? 1 : 0.45)
                }
                .dirCompanionScrollSurface()
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
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showPlan) {
                CCRPlanResultView(pendingChecklistExportPrompt: pendingChecklistExportAfterCalculate)
                    .environmentObject(store)
                    .environmentObject(equipment)
            }
            .confirmationDialog(
                DIRIOSLocalizer.string("checklist_planner.sync.import_prompt"),
                isPresented: $showChecklistImportPrompt,
                titleVisibility: .visible
            ) {
                Button(DIRIOSLocalizer.string("checklist_planner.sync.import_all")) {
                    CCRChecklistImportCoordinator.importAll(
                        checklist: equipment.profile.checklistItems,
                        to: &store.ccrInput
                    )
                }
                Button(DIRIOSLocalizer.string("checklist_planner.sync.choose_import")) {
                    openCCRChecklistImportSheet()
                }
                Button(DIRIOSLocalizer.string("checklist_planner.sync.cancel"), role: .cancel) {}
            }
            .sheet(isPresented: $showChecklistImportSheet) {
                CCRChecklistImportSheet(
                    candidates: $ccrChecklistImportCandidates,
                    onConfirm: { confirmCCRChecklistImport() },
                    onCancel: { showChecklistImportSheet = false }
                )
            }
        }
        .dirCompanionTabRoot()
    }

    private var ccrChecklistGasItems: [EquipmentChecklistItem] {
        ChecklistPlannerSyncMapper.ccrChecklistGasItems(from: equipment.profile.checklistItems)
    }

    private func openCCRChecklistImportSheet() {
        ccrChecklistImportCandidates = ChecklistPlannerSyncMapper.ccrImportCandidates(
            checklist: equipment.profile.checklistItems,
            input: store.ccrInput
        )
        showChecklistImportSheet = true
    }

    private func confirmCCRChecklistImport() {
        CCRChecklistImportCoordinator.importSelected(
            candidates: ccrChecklistImportCandidates,
            to: &store.ccrInput
        )
        showChecklistImportSheet = false
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(DIRIOSLocalizer.string("planner.mode.ccr"))
                .dirScreenTitleStyle()
            Text(DIRIOSLocalizer.string("ccr.planner.subtitle"))
                .dirScreenSubtitleStyle()
        }
    }

    private var plannerSafetySection: some View {
        Group {
            if !plannerSafetyAcknowledged {
                DIRWarningBox(text: DIRIOSLocalizer.string("planner.safety.ack.required"))
            }
        }
    }

    private var profileCard: some View {
        DIRCard(DIRIOSLocalizer.string("planner.profile.header"), icon: "arrow.down.to.line", accent: DIRTheme.cyan) {
            VStack(spacing: 10) {
                depthRow(title: DIRIOSLocalizer.string("planner.field.max_depth"), value: $store.ccrInput.maxDepthMeters, range: 5...120)
                depthRow(title: DIRIOSLocalizer.string("planner.field.avg_depth"), value: $store.ccrInput.averageDepthMeters, range: 5...120)
                Text(DIRIOSLocalizer.string("ccr.avg_depth.reference_only"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
                minutesRow(title: DIRIOSLocalizer.string("planner.field.bottom_time"), value: $store.ccrInput.bottomTimeMinutes, range: 1...180)
                TextField(DIRIOSLocalizer.string("ccr.rebreather_model"), text: $store.ccrInput.rebreatherModel)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }

    private var setpointCard: some View {
        DIRCard(DIRIOSLocalizer.string("ccr.setpoint.header"), icon: "lungs", accent: DIRTheme.orange) {
            VStack(spacing: 10) {
                setpointRow(title: DIRIOSLocalizer.string("ccr.setpoint.low"), value: $store.ccrInput.setpointProfile.lowSetpoint)
                setpointRow(title: DIRIOSLocalizer.string("ccr.setpoint.high"), value: $store.ccrInput.setpointProfile.highSetpoint)
                depthRow(
                    title: DIRIOSLocalizer.string("ccr.setpoint.switch_depth"),
                    value: $store.ccrInput.setpointProfile.switchDepthMeters,
                    range: 0...60
                )
                Picker(DIRIOSLocalizer.string("ccr.setpoint.mode"), selection: $store.ccrInput.setpointProfile.mode) {
                    ForEach(CCRSetpointMode.allCases) { mode in
                        Text(mode.localizedTitle).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                if store.ccrInput.setpointProfile.mode == .manual {
                    Toggle(DIRIOSLocalizer.string("ccr.setpoint.shallow_ascent.toggle"), isOn: $store.ccrInput.setpointProfile.useLowSetpointOnShallowAscent)
                        .font(.caption)
                        .tint(DIRTheme.orange)
                    if store.ccrInput.setpointProfile.useLowSetpointOnShallowAscent {
                        depthRow(
                            title: DIRIOSLocalizer.string("ccr.setpoint.shallow_ascent"),
                            value: $store.ccrInput.setpointProfile.shallowAscentSetpointDepthMeters,
                            range: 0...30
                        )
                    }
                }
            }
        }
    }

    private var diluentCard: some View {
        DIRCard(DIRIOSLocalizer.string("ccr.diluent"), icon: "wind", accent: DIRTheme.cyan) {
            VStack(spacing: 10) {
                if !ccrChecklistGasItems.isEmpty {
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
                    Text(DIRIOSLocalizer.string("ccr.checklist.import.disclaimer"))
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                    Divider().overlay(DIRTheme.hairline)
                }
                CCRDiluentEditorView(diluent: $store.ccrInput.diluent)
            }
        }
    }

    private var bailoutCard: some View {
        DIRCard(DIRIOSLocalizer.string("ccr.bailout"), icon: "exclamationmark.triangle", accent: DIRTheme.yellow) {
            CCRBailoutListEditorView(bailoutGases: $store.ccrInput.bailoutGases)
        }
    }

    private var gfCard: some View {
        DIRCard(DIRIOSLocalizer.string("planner.gf.header"), icon: "slider.horizontal.3", accent: DIRTheme.yellow) {
            HStack {
                gfField(title: DIRIOSLocalizer.string("ccr.gf.low.label"), value: $store.ccrInput.gfLow)
                gfField(title: DIRIOSLocalizer.string("ccr.gf.high.label"), value: $store.ccrInput.gfHigh)
            }
        }
    }

    private var warningsCard: some View {
        Group {
            if !store.ccrPlan.validationResult.isValid {
                DIRCard(DIRIOSLocalizer.string("ccr.validation.header"), icon: "exclamationmark.circle", accent: DIRTheme.orange) {
                    ForEach(Array(store.ccrPlan.validationResult.issues.enumerated()), id: \.offset) { _, issue in
                        Text(issue.localizedMessage)
                            .font(.caption)
                            .foregroundStyle(DIRTheme.yellow)
                    }
                }
            }
        }
    }

    private var calculateButton: some View {
        Button {
            store.calculate()
            let planIsValid = store.ccrPlan.validationResult.isValid
            pendingChecklistExportAfterCalculate = CCRChecklistExportCoordinator.shouldPromptExport(
                input: store.ccrInput,
                checklist: equipment.profile.checklistItems,
                planIsValid: planIsValid
            )
            showPlan = planIsValid
        } label: {
            Text(DIRIOSLocalizer.string("planner.calculate"))
                .font(.callout.weight(.semibold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 8).fill(DIRTheme.cyan))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(DIRIOSLocalizer.string("planner.calculate"))
    }

    private func depthRow(title: String, value: Binding<Double>, range: ClosedRange<Double>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundStyle(DIRTheme.muted)
            Stepper(
                Formatters.depth(value.wrappedValue, units: unitPreference).text,
                value: value,
                in: range,
                step: 1
            )
        }
    }

    private func minutesRow(title: String, value: Binding<Double>, range: ClosedRange<Double>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundStyle(DIRTheme.muted)
            Stepper("\(Int(value.wrappedValue)) min", value: value, in: range, step: 1)
        }
    }

    private func setpointRow(title: String, value: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundStyle(DIRTheme.muted)
            Stepper(String(format: "%.1f bar", value.wrappedValue), value: value, in: 0.4...1.6, step: 0.1)
        }
    }

    private func gfField(title: String, value: Binding<Double>) -> some View {
        VStack(alignment: .leading) {
            Text(title).font(.caption2).foregroundStyle(DIRTheme.muted)
            TextField(title, value: value, format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
        }
    }
}

struct CCRDiluentEditorView: View {
    @Binding var diluent: CCRDiluent

    private var diluentMixKindBinding: Binding<GasMixKind> {
        Binding(
            get: { diluent.mixKind },
            set: { newKind in
                Task { @MainActor in
                    diluent.applyMixKind(newKind)
                }
            }
        )
    }

    var body: some View {
        VStack(spacing: 10) {
            Picker(DIRIOSLocalizer.string("gas.mix.header"), selection: diluentMixKindBinding) {
                ForEach([GasMixKind.air, .ean, .trimix], id: \.self) { kind in
                    Text(kind.localizedTitle).tag(kind)
                }
            }
            .pickerStyle(.segmented)

            if diluent.mixKind == .ean || diluent.mixKind == .trimix {
                Stepper(
                    DIRIOSLocalizer.formatted("gas.oxygen.percent_stepper", diluent.oxygenPercent),
                    value: $diluent.oxygenPercent,
                    in: 10...100,
                    step: 1
                )
            }
            if diluent.mixKind == .trimix {
                Stepper(
                    DIRIOSLocalizer.formatted("gas.helium.percent_stepper", diluent.heliumPercent),
                    value: $diluent.heliumPercent,
                    in: 0...90,
                    step: 1
                )
            }
            Text(diluent.label)
                .font(.caption)
                .foregroundStyle(DIRTheme.cyan)
        }
    }
}

struct CCRBailoutListEditorView: View {
    @Binding var bailoutGases: [CCRBailoutGas]

    var body: some View {
        VStack(spacing: 8) {
            ForEach($bailoutGases) { $gas in
                VStack(alignment: .leading, spacing: 6) {
                    Picker(DIRIOSLocalizer.string("gas.mix.header"), selection: $gas.mixKind) {
                        ForEach(GasMixKind.allCases, id: \.self) { kind in
                            Text(kind.plannerPickerTitle).tag(kind)
                        }
                    }
                    .pickerStyle(.menu)
                    if gas.mixKind != .air {
                        Stepper(
                            DIRIOSLocalizer.formatted("gas.oxygen.percent_stepper", gas.oxygenPercent),
                            value: $gas.oxygenPercent,
                            in: 16...100,
                            step: 1
                        )
                    }
                    if gas.mixKind == .trimix {
                        Stepper(
                            DIRIOSLocalizer.formatted("gas.helium.percent_stepper", gas.heliumPercent),
                            value: $gas.heliumPercent,
                            in: 0...90,
                            step: 1
                        )
                    }
                    Picker(DIRIOSLocalizer.string("equipment.tank_size"), selection: $gas.tankSize) {
                        ForEach(TankSize.allCases) { size in
                            Text(size.rawValue).tag(size)
                        }
                    }
                    Stepper(
                        DIRIOSLocalizer.formatted("ccr.bailout.switch_depth", Int(gas.switchDepthMeters)),
                        value: $gas.switchDepthMeters,
                        in: 0...120,
                        step: 3
                    )
                }
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 8).fill(DIRTheme.surface2))
            }
            Button(DIRIOSLocalizer.string("ccr.bailout.add")) {
                bailoutGases.append(CCRBailoutGas())
            }
            .foregroundStyle(DIRTheme.cyan)
            if bailoutGases.count > 1 {
                Button(DIRIOSLocalizer.string("ccr.bailout.remove_last"), role: .destructive) {
                    _ = bailoutGases.popLast()
                }
            }
        }
    }
}
