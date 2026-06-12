import SwiftUI

struct EquipmentView: View {
    @EnvironmentObject private var equipment: EquipmentStore
    @EnvironmentObject private var navigation: IOSNavigationStore
    @EnvironmentObject private var plannerStore: PlannerStore
    @State private var showResetConfirmation = false
    @State private var savedFeedback: String?
    @State private var showTemplatesSheet = false
    @State private var shareablePDF: ShareablePDFItem?
    @State private var editingCylinder: EquipmentGasCylinder?
    @State private var editingMaintenance: EquipmentMaintenanceItem?
    @State private var showAddCylinder = false
    @State private var showAddMaintenance = false
    @AppStorage("dirdiving_ios_units") private var units = IOSUnitPreference.metric.rawValue

    var body: some View {
        NavigationStack {
            DIRScreenContainer {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        headerSection
                        if let savedFeedback {
                            feedbackBanner(savedFeedback)
                        }
                        equipmentHero
                        setupCard
                        cylindersCard
                        gasesCard
                        consumptionCard
                        savedSetupsCard
                        checklistIntegrationCard
                        plannerIntegrationCard
                        watchAssetsCard
                        maintenanceCard
                        resetButton
                        DIRWarningBox(text: DIRIOSLocalizer.string("equipment.save_notice"))
                    }
                    .padding(16)
                }
                .dirCompanionScrollSurface()
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        exportEquipmentPDF()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel(DIRIOSLocalizer.string("equipment.export.sheet"))
                }
            }
            .confirmationDialog(DIRIOSLocalizer.string("equipment.reset.confirm.title"), isPresented: $showResetConfirmation, titleVisibility: .visible) {
                Button(DIRIOSLocalizer.string("equipment.reset.confirm.action"), role: .destructive) {
                    equipment.reset()
                    showSavedFeedback()
                }
                Button(DIRIOSLocalizer.string("equipment.reset.cancel"), role: .cancel) {}
            } message: {
                Text(DIRIOSLocalizer.string("equipment.reset.confirm.message"))
            }
            .onChange(of: equipment.profile) { _, _ in
                showSavedFeedback()
            }
            .sheet(isPresented: $showTemplatesSheet) {
                EquipmentTemplatesSheet()
                    .environmentObject(equipment)
            }
            .sheet(item: $editingCylinder) { cylinder in
                EquipmentCylinderEditorSheet(
                    cylinder: cylinder,
                    onSave: { equipment.updateCylinder($0) },
                    unitPreference: unitPreference
                )
            }
            .sheet(isPresented: $showAddCylinder) {
                EquipmentCylinderEditorSheet(
                    cylinder: defaultNewCylinder(),
                    onSave: { equipment.addCylinder($0) },
                    unitPreference: unitPreference
                )
            }
            .sheet(item: $editingMaintenance) { item in
                EquipmentMaintenanceEditorSheet(
                    item: item,
                    onSave: { equipment.updateMaintenanceItem($0) }
                )
            }
            .sheet(isPresented: $showAddMaintenance) {
                EquipmentMaintenanceEditorSheet(
                    item: EquipmentMaintenanceItem(
                        title: "",
                        kind: .regulatorService
                    ),
                    onSave: { equipment.addMaintenanceItem($0) }
                )
            }
            .sheet(item: $shareablePDF) { item in
                ShareSheetView(activityItems: [item.url])
            }
        }
        .dirCompanionTabRoot()
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(DIRIOSLocalizer.string("equipment.title"))
                .dirScreenTitleStyle()
            Text(DIRIOSLocalizer.string("equipment.subtitle"))
                .dirScreenSubtitleStyle()
        }
    }

    private var equipmentHero: some View {
        HStack(spacing: 12) {
            equipmentBadge(
                "DIR",
                equipment.profile.isDIRConfigurationComplete ? DIRTheme.green : DIRTheme.red,
                accessibilityLabel: equipment.profile.isDIRConfigurationComplete
                    ? DIRIOSLocalizer.string("equipment.badge.dir.complete.a11y")
                    : DIRIOSLocalizer.string("equipment.badge.dir.incomplete.a11y")
            )
            equipmentBadge(
                equipment.profile.setupCompletenessNeedsAttention
                    ? DIRIOSLocalizer.string("equipment.badge.needs_attention")
                    : DIRIOSLocalizer.string("equipment.badge.complete"),
                equipment.profile.setupCompletenessNeedsAttention ? DIRTheme.orange : DIRTheme.green,
                accessibilityLabel: equipment.profile.setupCompletenessNeedsAttention
                    ? DIRIOSLocalizer.string("equipment.badge.needs_attention.a11y")
                    : DIRIOSLocalizer.string("equipment.badge.complete.a11y")
            )
        }
    }

    private var setupCard: some View {
        DIRCard(DIRIOSLocalizer.string("equipment.card.setup"), icon: "wrench.and.screwdriver.fill", accent: DIRTheme.cyan) {
            editableRow(DIRIOSLocalizer.string("equipment.setup.name"), text: $equipment.profile.activeSetupName)
            Picker(DIRIOSLocalizer.string("equipment.setup.mode"), selection: $equipment.profile.setupMode) {
                ForEach(EquipmentSetupMode.allCases, id: \.self) { mode in
                    Text(mode.localizedTitle).tag(mode)
                }
            }
            .pickerStyle(.menu)
            .tint(DIRTheme.cyan)
            editableRow(DIRIOSLocalizer.string("equipment.row.configuration"), text: $equipment.profile.configuration)
            if !equipment.profile.hasStructuredSetup {
                legacySummarySection
            }
        }
    }

    private var legacySummarySection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(DIRIOSLocalizer.string("equipment.legacy.summary"))
                .font(.caption2.weight(.semibold))
                .foregroundStyle(DIRTheme.muted)
            editableRow(DIRIOSLocalizer.string("equipment.row.cylinders"), text: $equipment.profile.cylinders)
            editableRow(DIRIOSLocalizer.string("equipment.row.bottom_gas"), text: $equipment.profile.bottomGas)
            editableRow(DIRIOSLocalizer.string("equipment.row.deco1"), text: $equipment.profile.decoGas1)
            editableRow(DIRIOSLocalizer.string("equipment.row.deco2"), text: $equipment.profile.decoGas2)
            Button {
                equipment.resetStructuredCylindersFromLegacy()
            } label: {
                Text(DIRIOSLocalizer.string("equipment.import_from_legacy"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DIRTheme.cyan)
            }
            .buttonStyle(.plain)
        }
    }

    private var cylindersCard: some View {
        DIRCard(DIRIOSLocalizer.string("equipment.card.cylinders"), icon: "cylinder.fill", accent: DIRTheme.green) {
            let cylinders = equipment.profile.structuredCylinders.isEmpty
                ? equipment.profile.effectiveCylinders
                : equipment.profile.structuredCylinders
            if cylinders.isEmpty {
                Text(DIRIOSLocalizer.string("equipment.cylinder.empty"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
            } else {
                ForEach(cylinders) { cylinder in
                    cylinderRow(cylinder, editable: equipment.profile.hasStructuredSetup)
                }
            }
            Button {
                showAddCylinder = true
            } label: {
                Text(DIRIOSLocalizer.string("equipment.cylinder.add"))
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(DIRTheme.cyan)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan.opacity(0.7), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }

    private func cylinderRow(_ cylinder: EquipmentGasCylinder, editable: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(cylinder.name)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                if editable {
                    Toggle("", isOn: bindingForCylinderEnabled(cylinder.id))
                        .labelsHidden()
                        .tint(DIRTheme.cyan)
                } else {
                    Text(cylinder.isEnabled
                        ? DIRIOSLocalizer.string("equipment.cylinder.enabled")
                        : DIRIOSLocalizer.string("equipment.cylinder.disabled"))
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.muted)
                }
            }
            Text("\(cylinder.role.localizedTitle) · \(cylinder.tankSize.rawValue)")
                .font(.caption)
                .foregroundStyle(DIRTheme.muted)
            Text(
                String(
                    format: DIRIOSLocalizer.string("equipment.cylinder.pressure_summary"),
                    Formatters.zero(cylinder.startPressureBar),
                    Formatters.zero(cylinder.reservePressureBar)
                )
            )
            .font(.caption2.monospacedDigit())
            .foregroundStyle(DIRTheme.muted)
            if editable {
                HStack {
                    Button {
                        editingCylinder = cylinder
                    } label: {
                        Text(DIRIOSLocalizer.string("equipment.cylinder.edit"))
                            .font(.caption.weight(.semibold))
                    }
                    Spacer()
                    Button(role: .destructive) {
                        equipment.deleteCylinder(id: cylinder.id)
                    } label: {
                        Text(DIRIOSLocalizer.string("equipment.cylinder.delete"))
                            .font(.caption.weight(.semibold))
                    }
                }
                .buttonStyle(.plain)
                .foregroundStyle(DIRTheme.cyan)
            }
        }
        .padding(.vertical, 6)
    }

    private func bindingForCylinderEnabled(_ id: UUID) -> Binding<Bool> {
        Binding(
            get: {
                equipment.profile.structuredCylinders.first(where: { $0.id == id })?.isEnabled ?? true
            },
            set: { newValue in
                guard var cylinder = equipment.profile.structuredCylinders.first(where: { $0.id == id }) else { return }
                cylinder.isEnabled = newValue
                equipment.updateCylinder(cylinder)
            }
        )
    }

    private var gasesCard: some View {
        DIRCard(DIRIOSLocalizer.string("equipment.card.gases"), icon: "aqi.medium", accent: DIRTheme.cyan) {
            ForEach(equipment.profile.enabledCylinders) { cylinder in
                VStack(alignment: .leading, spacing: 4) {
                    Text(cylinder.displayGasLabel)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white)
                    Text("\(cylinder.role.localizedTitle) · O₂ \(Formatters.zero(cylinder.gas.oxygen * 100))%")
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                    if cylinder.gas.helium > 0.001 {
                        Text("He \(Formatters.zero(cylinder.gas.helium * 100))%")
                            .font(.caption)
                            .foregroundStyle(DIRTheme.muted)
                    }
                    if let switchDepth = cylinder.switchDepthMeters, switchDepth > 0 {
                        Text(
                            String(
                                format: DIRIOSLocalizer.string("equipment.gas.switch_depth_value"),
                                Formatters.depth(switchDepth, units: unitPreference).text
                            )
                        )
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.muted)
                    }
                    let mod = cylinder.gas.modMeters(environment: .seaLevelSaltWater)
                    if mod.isFinite, mod > 0 {
                        Text(
                            String(
                                format: DIRIOSLocalizer.string("equipment.gas.mod_reference"),
                                Formatters.depth(mod, units: unitPreference).text
                            )
                        )
                        .font(.caption2)
                        .foregroundStyle(DIRTheme.muted)
                    }
                }
                .padding(.vertical, 4)
            }
            if equipment.profile.enabledCylinders.isEmpty {
                legacyGasSummary
            }
        }
    }

    private var legacyGasSummary: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(DIRIOSLocalizer.string("equipment.legacy.gas_summary"))
                .font(.caption2.weight(.semibold))
                .foregroundStyle(DIRTheme.muted)
            Text(equipment.profile.activeGasSummary)
                .font(.callout)
                .foregroundStyle(.white)
        }
    }

    private var consumptionCard: some View {
        DIRCard(DIRIOSLocalizer.string("equipment.card.consumption"), icon: "wind", accent: DIRTheme.green) {
            sacRow
            Text(DIRIOSLocalizer.string("equipment.consumption.hint"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var savedSetupsCard: some View {
        DIRCard(DIRIOSLocalizer.string("equipment.card.saved_setups"), icon: "square.stack.3d.up.fill", accent: DIRTheme.green) {
            Text(DIRIOSLocalizer.string("equipment.saved_setups.hint"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                showTemplatesSheet = true
            } label: {
                Text(DIRIOSLocalizer.string("equipment.my_equipment.button"))
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(DIRTheme.cyan)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan.opacity(0.7), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }

    private var checklistIntegrationCard: some View {
        DIRCard(DIRIOSLocalizer.string("equipment.card.checklist_link"), icon: "checklist", accent: DIRTheme.cyan) {
            Text(
                String(
                    format: DIRIOSLocalizer.string("equipment.checklist.task_count"),
                    equipment.profile.migratedChecklistItems.count
                )
            )
            .font(.caption2)
            .foregroundStyle(DIRTheme.muted)
            Button {
                let added = equipment.generateChecklistFromCurrentSetup()
                savedFeedback = String(format: DIRIOSLocalizer.string("equipment.generate_checklist.success"), added)
            } label: {
                actionButtonLabel(DIRIOSLocalizer.string("equipment.generate_checklist"))
            }
            .buttonStyle(.plain)
            Button {
                navigation.selectedTab = .checklist
            } label: {
                actionButtonLabel(DIRIOSLocalizer.string("equipment.open_checklist"), secondary: true)
            }
            .buttonStyle(.plain)
        }
    }

    private var plannerIntegrationCard: some View {
        DIRCard(DIRIOSLocalizer.string("equipment.card.planner_link"), icon: "map.fill", accent: DIRTheme.green) {
            Text(DIRIOSLocalizer.string("equipment.use_in_planner.hint"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                useInPlanner()
            } label: {
                actionButtonLabel(DIRIOSLocalizer.string("equipment.use_in_planner"))
            }
            .buttonStyle(.plain)
        }
    }

    private var watchAssetsCard: some View {
        DIRCard(DIRIOSLocalizer.string("equipment.card.watch_assets"), icon: "photo.on.rectangle.angled", accent: DIRTheme.cyan) {
            Text(DIRIOSLocalizer.string("equipment.images.hint"))
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
            WatchPhotoTransferPanel()
        }
        .accessibilityElement(children: .contain)
    }

    private var maintenanceCard: some View {
        DIRCard(DIRIOSLocalizer.string("equipment.card.maintenance"), icon: "calendar.badge.clock", accent: DIRTheme.orange) {
            if equipment.profile.maintenanceItems.isEmpty {
                Text(DIRIOSLocalizer.string("equipment.maintenance.empty"))
                    .font(.caption2)
                    .foregroundStyle(DIRTheme.muted)
            } else {
                ForEach(equipment.profile.maintenanceItems) { item in
                    maintenanceRow(item)
                }
            }
            Button {
                showAddMaintenance = true
            } label: {
                actionButtonLabel(DIRIOSLocalizer.string("equipment.maintenance.add"))
            }
            .buttonStyle(.plain)
            if equipment.profile.maintenanceItems.contains(where: {
                !$0.isCompleted && EquipmentStructuredSupport.maintenanceStatus(for: $0) != .ok
            }) {
                Button {
                    let added = equipment.addDueMaintenanceToChecklist()
                    savedFeedback = String(format: DIRIOSLocalizer.string("equipment.maintenance.added_to_checklist"), added)
                } label: {
                    actionButtonLabel(DIRIOSLocalizer.string("equipment.maintenance.add_due_to_checklist"), secondary: true)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func maintenanceRow(_ item: EquipmentMaintenanceItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(item.title.isEmpty ? item.kind.localizedTitle : item.title)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                maintenanceStatusBadge(item)
            }
            if let dueDate = item.dueDate {
                Text(
                    String(
                        format: DIRIOSLocalizer.string("equipment.maintenance.due_date_value"),
                        dueDate.formatted(date: .abbreviated, time: .omitted)
                    )
                )
                .font(.caption2)
                .foregroundStyle(DIRTheme.muted)
            }
            HStack {
                Button {
                    equipment.markMaintenanceItem(id: item.id, completed: !item.isCompleted)
                } label: {
                    Text(item.isCompleted
                        ? DIRIOSLocalizer.string("equipment.maintenance.mark_incomplete")
                        : DIRIOSLocalizer.string("equipment.maintenance.mark_complete"))
                        .font(.caption.weight(.semibold))
                }
                Spacer()
                Button {
                    editingMaintenance = item
                } label: {
                    Text(DIRIOSLocalizer.string("equipment.maintenance.edit"))
                        .font(.caption.weight(.semibold))
                }
                Button(role: .destructive) {
                    equipment.deleteMaintenanceItem(id: item.id)
                } label: {
                    Text(DIRIOSLocalizer.string("equipment.maintenance.delete"))
                        .font(.caption.weight(.semibold))
                }
            }
            .buttonStyle(.plain)
            .foregroundStyle(DIRTheme.cyan)
        }
        .padding(.vertical, 4)
    }

    private func maintenanceStatusBadge(_ item: EquipmentMaintenanceItem) -> some View {
        let status = EquipmentStructuredSupport.maintenanceStatus(for: item)
        let (text, color): (String, Color) = {
            if item.isCompleted {
                return (DIRIOSLocalizer.string("equipment.maintenance.completed"), DIRTheme.green)
            }
            switch status {
            case .overdue: return (DIRIOSLocalizer.string("equipment.maintenance.overdue"), DIRTheme.red)
            case .dueSoon: return (DIRIOSLocalizer.string("equipment.maintenance.due_soon"), DIRTheme.orange)
            case .ok: return (DIRIOSLocalizer.string("equipment.maintenance.status.ok"), DIRTheme.muted)
            }
        }()
        return Text(text)
            .font(.caption2.weight(.bold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(color.opacity(0.12)))
    }

    private var resetButton: some View {
        Button {
            showResetConfirmation = true
        } label: {
            Text(DIRIOSLocalizer.string("equipment.reset_profile"))
                .font(.callout.weight(.semibold))
                .foregroundStyle(DIRTheme.cyan)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan.opacity(0.75), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func equipmentBadge(_ text: String, _ color: Color, accessibilityLabel: String) -> some View {
        Text(text)
            .font(.caption.weight(.bold))
            .foregroundStyle(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: DIRTheme.cardRadius)
                    .fill(color.opacity(0.10))
                    .overlay(RoundedRectangle(cornerRadius: DIRTheme.cardRadius).stroke(color.opacity(0.34), lineWidth: 1))
            )
            .accessibilityLabel(accessibilityLabel)
    }

    private func feedbackBanner(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(DIRTheme.green)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(RoundedRectangle(cornerRadius: 8).fill(DIRTheme.green.opacity(0.10)))
    }

    private func editableRow(_ title: String, text: Binding<String>) -> some View {
        HStack {
            Text(title).foregroundStyle(DIRTheme.muted)
            TextField(title, text: text)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(.white)
                .tint(DIRTheme.cyan)
        }
        .font(.callout)
        .padding(.vertical, 7)
    }

    private var sacRow: some View {
        HStack {
            Text(DIRIOSLocalizer.string("equipment.sac_default")).foregroundStyle(DIRTheme.muted)
            Spacer()
            Button { equipment.profile.sacLitersMinute = max(5, equipment.profile.sacLitersMinute - 0.5) } label: {
                Image(systemName: "minus").frame(width: 28, height: 26)
            }
            Text(Formatters.sac(equipment.profile.sacLitersMinute, units: unitPreference).text)
                .font(.callout.monospacedDigit().weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 104)
            Button { equipment.profile.sacLitersMinute = min(40, equipment.profile.sacLitersMinute + 0.5) } label: {
                Image(systemName: "plus").frame(width: 28, height: 26)
            }
        }
        .foregroundStyle(DIRTheme.cyan)
        .padding(.vertical, 7)
    }

    private func actionButtonLabel(_ title: String, secondary: Bool = false) -> some View {
        Text(title)
            .font(.callout.weight(.semibold))
            .foregroundStyle(DIRTheme.cyan)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(DIRTheme.cyan.opacity(secondary ? 0.45 : 0.7), lineWidth: 1)
            )
    }

    private var unitPreference: IOSUnitPreference {
        IOSUnitPreference.fromStorage(units)
    }

    private func defaultNewCylinder() -> EquipmentGasCylinder {
        EquipmentGasCylinder(
            name: DIRIOSLocalizer.string("equipment.cylinder.default_name"),
            role: .deco,
            tankSize: .liters12,
            gas: EquipmentStructuredSupport.defaultDecoGas(named: "EAN50", oxygen: 0.5),
            startPressureBar: 200,
            reservePressureBar: 50,
            switchDepthMeters: 21
        )
    }

    private func useInPlanner() {
        var input = plannerStore.input
        let result = EquipmentPlannerMapper.apply(
            profile: equipment.profile,
            to: &input,
            plannerMode: plannerStore.mode
        )
        plannerStore.input = input
        navigation.selectedTab = .planner
        if result.ignoredRoles.isEmpty {
            savedFeedback = DIRIOSLocalizer.string("equipment.use_in_planner.success")
        } else {
            savedFeedback = DIRIOSLocalizer.string("equipment.use_in_planner.success_partial")
        }
    }

    private func exportEquipmentPDF() {
        do {
            let url = try PDFExportService.exportEquipmentSetup(
                profile: equipment.profile,
                unitPreference: unitPreference
            )
            shareablePDF = ShareablePDFItem(url: url)
        } catch {
            savedFeedback = DIRIOSLocalizer.string("equipment.export.failed")
        }
    }

    private func showSavedFeedback() {
        savedFeedback = DIRIOSLocalizer.string("equipment.profile.saved_notice")
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            if savedFeedback == DIRIOSLocalizer.string("equipment.profile.saved_notice") {
                savedFeedback = nil
            }
        }
    }
}

// MARK: - Cylinder editor

private struct EquipmentCylinderEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: EquipmentGasCylinder
    let onSave: (EquipmentGasCylinder) -> Void
    let unitPreference: IOSUnitPreference

    init(cylinder: EquipmentGasCylinder, onSave: @escaping (EquipmentGasCylinder) -> Void, unitPreference: IOSUnitPreference) {
        _draft = State(initialValue: cylinder)
        self.onSave = onSave
        self.unitPreference = unitPreference
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField(DIRIOSLocalizer.string("equipment.cylinder.name"), text: $draft.name)
                Picker(DIRIOSLocalizer.string("equipment.cylinder.role"), selection: $draft.role) {
                    ForEach(GasRole.allCases) { role in
                        Text(role.localizedTitle).tag(role)
                    }
                }
                Picker(DIRIOSLocalizer.string("equipment.cylinder.tank_size"), selection: $draft.tankSize) {
                    ForEach(TankSize.allCases) { size in
                        Text(size.rawValue).tag(size)
                    }
                }
                TextField(DIRIOSLocalizer.string("equipment.cylinder.gas_name"), text: $draft.gas.name)
                Stepper(
                    value: $draft.startPressureBar,
                    in: 0...300,
                    step: 10
                ) {
                    Text("\(DIRIOSLocalizer.string("equipment.cylinder.start_pressure")): \(Formatters.zero(draft.startPressureBar)) bar")
                }
                Stepper(
                    value: $draft.reservePressureBar,
                    in: 0...draft.startPressureBar,
                    step: 10
                ) {
                    Text("\(DIRIOSLocalizer.string("equipment.cylinder.reserve_pressure")): \(Formatters.zero(draft.reservePressureBar)) bar")
                }
                if draft.role == .deco || draft.role == .travel {
                    Stepper(
                        value: Binding(
                            get: { draft.switchDepthMeters ?? 21 },
                            set: { draft.switchDepthMeters = $0 }
                        ),
                        in: 0...60,
                        step: 3
                    ) {
                        Text("\(DIRIOSLocalizer.string("equipment.gas.switch_depth")): \(Formatters.depth(draft.switchDepthMeters ?? 21, units: unitPreference).text)")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(DIRBackground())
            .navigationTitle(DIRIOSLocalizer.string("equipment.cylinder.edit"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(DIRIOSLocalizer.string("equipment.template.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(DIRIOSLocalizer.string("equipment.template.done")) {
                        onSave(draft)
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Maintenance editor

private struct EquipmentMaintenanceEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: EquipmentMaintenanceItem
    let onSave: (EquipmentMaintenanceItem) -> Void

    init(item: EquipmentMaintenanceItem, onSave: @escaping (EquipmentMaintenanceItem) -> Void) {
        _draft = State(initialValue: item)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField(DIRIOSLocalizer.string("equipment.maintenance.title"), text: $draft.title)
                Picker(DIRIOSLocalizer.string("equipment.maintenance.kind"), selection: $draft.kind) {
                    ForEach(EquipmentMaintenanceKind.allCases, id: \.self) { kind in
                        Text(kind.localizedTitle).tag(kind)
                    }
                }
                Toggle(DIRIOSLocalizer.string("equipment.maintenance.has_due_date"), isOn: Binding(
                    get: { draft.dueDate != nil },
                    set: { hasDue in draft.dueDate = hasDue ? (draft.dueDate ?? Date()) : nil }
                ))
                if draft.dueDate != nil {
                    DatePicker(
                        DIRIOSLocalizer.string("equipment.maintenance.due_date"),
                        selection: Binding(
                            get: { draft.dueDate ?? Date() },
                            set: { draft.dueDate = $0 }
                        ),
                        displayedComponents: .date
                    )
                }
                TextField(DIRIOSLocalizer.string("equipment.maintenance.notes"), text: $draft.notes, axis: .vertical)
            }
            .scrollContentBackground(.hidden)
            .background(DIRBackground())
            .navigationTitle(DIRIOSLocalizer.string("equipment.maintenance.edit"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(DIRIOSLocalizer.string("equipment.template.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(DIRIOSLocalizer.string("equipment.template.done")) {
                        if draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            draft.title = draft.kind.localizedTitle
                        }
                        onSave(draft)
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
