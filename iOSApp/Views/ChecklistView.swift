import SwiftUI

struct ChecklistView: View {
    @EnvironmentObject private var equipment: EquipmentStore
    @EnvironmentObject private var navigation: IOSNavigationStore
    @State private var savedFeedback: String?
    @State private var newChecklistTitle = ""
    @State private var showSetupPicker = false
    @State private var shareablePDF: ShareablePDFItem?
    @State private var pdfExportAlertMessage: String?
    @AppStorage("dirdiving_ios_units") private var units = IOSUnitPreference.metric.rawValue

    var body: some View {
        NavigationStack {
            DIRScreenContainer {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        if let savedFeedback {
                            Text(savedFeedback)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(DIRTheme.green)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background(RoundedRectangle(cornerRadius: 8).fill(DIRTheme.green.opacity(0.10)))
                        }
                        setupSelectionCard
                        if equipment.needsChecklistSetupSelection {
                            emptySetupState
                        } else {
                            checklistHero
                            checklistCard
                        }
                    }
                    .padding(16)
                }
                .dirCompanionScrollSurface()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        shareChecklistPDF()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(DIRTheme.cyan)
                    }
                    .accessibilityLabel(Text(DIRIOSLocalizer.string("pdf.export.share.a11y")))
                    .disabled(equipment.needsChecklistSetupSelection)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
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
            .sheet(isPresented: $showSetupPicker) {
                ChecklistSetupPickerSheet()
                    .environmentObject(equipment)
            }
            .task {
                var profile = equipment.profile
                let beforeCount = profile.checklistItems.count
                profile.syncLegacyChecklistFlags()
                if profile.checklistItems.count != beforeCount {
                    equipment.profile = profile
                }
            }
            .onChange(of: equipment.profile) { _, _ in
                showSavedFeedback()
            }
        }
        .dirCompanionTabRoot()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(DIRIOSLocalizer.string("checklist.title"))
                .dirScreenTitleStyle()
            Text(DIRIOSLocalizer.string("checklist.subtitle"))
                .dirScreenSubtitleStyle()
        }
        .accessibilityElement(children: .combine)
    }

    private var setupSelectionCard: some View {
        DIRCard(DIRIOSLocalizer.string("checklist.setup.title"), icon: "shippingbox.fill", accent: DIRTheme.cyan) {
            VStack(alignment: .leading, spacing: 8) {
                Text(equipment.selectedChecklistSetupDisplayName)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white)
                Text(equipment.selectedChecklistSetupSummary)
                    .font(.caption)
                    .foregroundStyle(DIRTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
                Button {
                    showSetupPicker = true
                } label: {
                    Text(DIRIOSLocalizer.string("checklist.setup.change"))
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(DIRTheme.cyan)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan.opacity(0.7), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(DIRIOSLocalizer.string("checklist.setup.change"))
                .accessibilityHint(DIRIOSLocalizer.string("checklist.setup.change.a11y"))
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var emptySetupState: some View {
        DIRCard(DIRIOSLocalizer.string("checklist.empty.title"), icon: "exclamationmark.circle", accent: DIRTheme.yellow) {
            VStack(alignment: .leading, spacing: 12) {
                Text(DIRIOSLocalizer.string("checklist.empty.message"))
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.92))
                    .fixedSize(horizontal: false, vertical: true)
                Button {
                    navigation.selectedTab = .gear
                } label: {
                    Text(DIRIOSLocalizer.string("checklist.empty.open_gear"))
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(DIRTheme.cyan)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan.opacity(0.75), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(DIRIOSLocalizer.string("checklist.empty.open_gear"))
            }
        }
    }

    private var checklistHero: some View {
        HStack(spacing: 12) {
            checklistBadge(
                String(
                    format: DIRIOSLocalizer.string("checklist.status.ready_badge_format"),
                    equipment.profile.checklistReadyCount,
                    max(1, equipment.profile.migratedChecklistItems.count)
                ),
                equipment.profile.checklistReadyCount == equipment.profile.migratedChecklistItems.count ? DIRTheme.green : DIRTheme.yellow
            )
        }
        .accessibilityLabel(
            String(
                format: DIRIOSLocalizer.string("checklist.progress.a11y"),
                equipment.profile.checklistReadyCount,
                equipment.profile.migratedChecklistItems.count
            )
        )
    }

    private var checklistCard: some View {
        DIRCard(DIRIOSLocalizer.string("equipment.card.checklist"), icon: "checklist", accent: DIRTheme.green) {
            ForEach($equipment.profile.checklistItems) { $item in
                VStack(alignment: .leading, spacing: 6) {
                    Toggle(item.title, isOn: $item.isReady)
                        .tint(DIRTheme.cyan)
                        .accessibilityLabel(checklistReadyAccessibilityLabel(for: item))
                        .accessibilityHint(DIRIOSLocalizer.string("a11y.checklist.item.toggle.hint"))
                    Toggle(DIRIOSLocalizer.string("equipment.checklist.gas_flag"), isOn: $item.usesGas)
                        .tint(DIRTheme.yellow)
                        .accessibilityLabel(checklistGasFlagAccessibilityLabel(for: item))
                        .accessibilityHint(DIRIOSLocalizer.string("a11y.checklist.item.toggle.hint"))
                    EquipmentChecklistGasSection(item: $item)
                        .animation(.easeInOut(duration: 0.2), value: item.usesGas)
                    Button(role: .destructive) {
                        equipment.profile.checklistItems.removeAll { $0.id == item.id }
                    } label: {
                        Text(DIRIOSLocalizer.string("equipment.checklist.remove"))
                            .font(.caption.weight(.semibold))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 4)
            }
            HStack(spacing: 8) {
                TextField(DIRIOSLocalizer.string("equipment.checklist.new_item"), text: $newChecklistTitle)
                    .foregroundStyle(.white)
                Button(DIRIOSLocalizer.string("equipment.checklist.add")) {
                    let title = newChecklistTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !title.isEmpty else { return }
                    equipment.profile.checklistItems.append(EquipmentChecklistItem(title: title))
                    newChecklistTitle = ""
                }
                .font(.caption.weight(.bold))
                .foregroundStyle(DIRTheme.cyan)
                .buttonStyle(.plain)
            }
        }
    }

    private func checklistBadge(_ text: String, _ color: Color) -> some View {
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
    }

    private func showSavedFeedback() {
        savedFeedback = DIRIOSLocalizer.string("equipment.profile.saved_notice")
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            savedFeedback = nil
        }
    }

    private func shareChecklistPDF() {
        guard PDFExportService.hasExportableChecklist(equipment.profile) else {
            pdfExportAlertMessage = PDFShareActions.emptyChecklistMessage()
            return
        }
        do {
            let url = try PDFExportService.exportChecklist(
                profile: equipment.profile,
                unitPreference: IOSUnitPreference.fromStorage(units)
            )
            shareablePDF = ShareablePDFItem(url: url)
        } catch PDFExportError.emptyChecklist {
            pdfExportAlertMessage = PDFShareActions.emptyChecklistMessage()
        } catch {
            pdfExportAlertMessage = DIRIOSLocalizer.string("pdf.export.error.generation")
        }
    }

    private func checklistReadyAccessibilityLabel(for item: EquipmentChecklistItem) -> String {
        let state = item.isReady
            ? DIRIOSLocalizer.string("a11y.checklist.item.checked")
            : DIRIOSLocalizer.string("a11y.checklist.item.unchecked")
        return "\(item.title). \(state)"
    }

    private func checklistGasFlagAccessibilityLabel(for item: EquipmentChecklistItem) -> String {
        var parts = [item.title]
        parts.append(
            item.usesGas
                ? DIRIOSLocalizer.string("a11y.checklist.item.gas_linked")
                : DIRIOSLocalizer.string("a11y.checklist.item.gas_not_linked")
        )
        if item.usesGas, let role = item.gasRole ?? ChecklistPlannerSyncMapper.resolvedRole(for: item) {
            parts.append(role.localizedTitle)
        }
        return parts.joined(separator: ". ")
    }
}

struct ChecklistSetupPickerSheet: View {
    @EnvironmentObject private var equipment: EquipmentStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            DIRScreenContainer {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(equipment.templates) { template in
                            DIRCard(template.name, icon: "shippingbox", accent: DIRTheme.cyan) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(DIRIOSLocalizer.formatted("equipment.template.items_count", template.checklistItems.count))
                                        .font(.caption)
                                        .foregroundStyle(DIRTheme.muted)
                                    Button(DIRIOSLocalizer.string("checklist.setup.select_template")) {
                                        equipment.selectChecklistSetup(template: template)
                                        dismiss()
                                    }
                                    .font(.callout.weight(.semibold))
                                    .foregroundStyle(DIRTheme.cyan)
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        DIRCard(DIRIOSLocalizer.string("checklist.setup.current_profile"), icon: "person.crop.circle", accent: DIRTheme.green) {
                            Text(equipment.selectedChecklistSetupSummary)
                                .font(.caption)
                                .foregroundStyle(DIRTheme.muted)
                            Button(DIRIOSLocalizer.string("checklist.setup.use_current_profile")) {
                                equipment.clearChecklistSetupSelection()
                                dismiss()
                            }
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(DIRTheme.cyan)
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
                .dirCompanionScrollSurface()
            }
            .navigationTitle(DIRIOSLocalizer.string("checklist.setup.change"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(DIRIOSLocalizer.string("equipment.template.done")) { dismiss() }
                        .foregroundStyle(DIRTheme.cyan)
                }
            }
        }
    }
}
