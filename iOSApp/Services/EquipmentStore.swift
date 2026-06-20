import Foundation
import Combine

@MainActor
final class EquipmentStore: ObservableObject {
    @Published var profile: EquipmentProfile {
        didSet { saveIfReady() }
    }
    @Published var templates: [EquipmentTemplate] {
        didSet { saveTemplatesIfReady() }
    }
    @Published var selectedChecklistTemplateID: UUID? {
        didSet { saveSelectionIfReady() }
    }

    private let cloudSync: CloudSyncStore?
    private let profileKey = "dirdiving_ios_equipment_profile"
    private let templatesKey = "dirdiving_ios_equipment_templates"
    private let checklistSelectionKey = "dirdiving_ios_equipment_checklist_selection"
    private var isReady = false

    init(cloudSync: CloudSyncStore? = nil) {
        self.cloudSync = cloudSync
        profile = cloudSync?.load(EquipmentProfile.self, forKey: profileKey) ?? EquipmentProfile()
        templates = cloudSync?.load([EquipmentTemplate].self, forKey: templatesKey) ?? Self.defaultTemplates()
        selectedChecklistTemplateID = cloudSync?.load(UUID.self, forKey: checklistSelectionKey)
        migrateChecklistGasRolesIfNeeded()
        isReady = true
        deferInitialPersistence()
    }

    private func deferInitialPersistence() {
        Task { @MainActor in
            await Task.yield()
            saveIfReady()
            saveTemplatesIfReady()
            saveSelectionIfReady()
        }
    }

    var selectedChecklistSetupDisplayName: String {
        if let id = selectedChecklistTemplateID,
           let template = templates.first(where: { $0.id == id }) {
            return template.name
        }
        return DIRIOSLocalizer.string("checklist.setup.current_profile")
    }

    var selectedChecklistSetupSummary: String {
        if let id = selectedChecklistTemplateID,
           let template = templates.first(where: { $0.id == id }) {
            let gasCount = template.checklistItems.filter(\.usesGas).count
            return String(
                format: DIRIOSLocalizer.string("checklist.setup.summary.template"),
                template.checklistItems.count,
                gasCount
            )
        }
        return String(
            format: DIRIOSLocalizer.string("checklist.setup.summary.profile"),
            profile.cylinders,
            profile.configuration,
            profile.migratedChecklistItems.count
        )
    }

    var needsChecklistSetupSelection: Bool {
        selectedChecklistTemplateID == nil
            && profile.checklistItems.isEmpty
            && !profile.isDIRConfigurationComplete
    }

    func selectChecklistSetup(template: EquipmentTemplate) {
        selectedChecklistTemplateID = template.id
        applyTemplate(template)
    }

    func clearChecklistSetupSelection() {
        selectedChecklistTemplateID = nil
    }

    func reset() {
        profile = EquipmentProfile()
    }

    func addCylinder(_ cylinder: EquipmentGasCylinder) {
        profile.structuredCylinders.append(cylinder)
        applyStructuredSetupToLegacySummaryIfNeeded()
    }

    func updateCylinder(_ cylinder: EquipmentGasCylinder) {
        guard let index = profile.structuredCylinders.firstIndex(where: { $0.id == cylinder.id }) else { return }
        profile.structuredCylinders[index] = cylinder
        applyStructuredSetupToLegacySummaryIfNeeded()
    }

    func deleteCylinder(id: UUID) {
        profile.structuredCylinders.removeAll { $0.id == id }
        applyStructuredSetupToLegacySummaryIfNeeded()
    }

    func resetStructuredCylindersFromLegacy() {
        profile.structuredCylinders = EquipmentStructuredSupport.legacyDerivedCylinders(from: profile)
        applyStructuredSetupToLegacySummaryIfNeeded()
    }

    func applyStructuredSetupToLegacySummaryIfNeeded() {
        EquipmentStructuredSupport.syncLegacySummary(from: &profile)
    }

    func addMaintenanceItem(_ item: EquipmentMaintenanceItem) {
        profile.maintenanceItems.append(item)
    }

    func updateMaintenanceItem(_ item: EquipmentMaintenanceItem) {
        guard let index = profile.maintenanceItems.firstIndex(where: { $0.id == item.id }) else { return }
        profile.maintenanceItems[index] = item
    }

    func deleteMaintenanceItem(id: UUID) {
        profile.maintenanceItems.removeAll { $0.id == id }
    }

    func markMaintenanceItem(id: UUID, completed: Bool) {
        guard let index = profile.maintenanceItems.firstIndex(where: { $0.id == id }) else { return }
        profile.maintenanceItems[index].isCompleted = completed
        if completed {
            profile.maintenanceItems[index].lastCheckedAt = Date()
        }
    }

    @discardableResult
    func generateChecklistFromCurrentSetup(mergeStrategy: ChecklistMergeStrategy = .appendMissing) -> Int {
        let generated = EquipmentChecklistGenerator.generate(from: profile)
        let before = profile.checklistItems.count
        profile.checklistItems = EquipmentChecklistGenerator.merge(
            generated: generated,
            into: profile.checklistItems,
            strategy: mergeStrategy
        )
        return profile.checklistItems.count - before
    }

    @discardableResult
    func addDueMaintenanceToChecklist() -> Int {
        let dueItems = profile.maintenanceItems.filter {
            !$0.isCompleted && EquipmentStructuredSupport.maintenanceStatus(for: $0) != .ok
        }
        guard !dueItems.isEmpty else { return 0 }
        var appended = 0
        let existingKeys = Set(profile.checklistItems.map {
            EquipmentStructuredSupport.normalizedChecklistKey(title: $0.title, kind: $0.kind)
        })
        for maintenance in dueItems {
            let title = String(format: DIRIOSLocalizer.string("equipment.checklist.maintenance_task"), maintenance.title)
            let key = EquipmentStructuredSupport.normalizedChecklistKey(title: title, kind: .task)
            guard !existingKeys.contains(key) else { continue }
            profile.checklistItems.append(
                EquipmentChecklistItem(title: title, isReady: false, kind: .task, isRequired: true)
            )
            appended += 1
        }
        return appended
    }

    func applyTemplate(_ template: EquipmentTemplate) {
        profile.checklistItems = template.checklistItems
    }

    func saveTemplate(named name: String, fromCurrentChecklist: Bool = true) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let items = fromCurrentChecklist ? profile.checklistItems : []
        if let index = templates.firstIndex(where: { $0.name == trimmed }) {
            templates[index].checklistItems = items
        } else {
            templates.append(EquipmentTemplate(name: trimmed, checklistItems: items))
        }
    }

    func deleteTemplate(id: UUID) {
        templates.removeAll { $0.id == id }
    }

    func updateTemplate(id: UUID, name: String, checklistItems: [EquipmentChecklistItem]) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let index = templates.firstIndex(where: { $0.id == id }) else { return }
        templates[index].name = trimmed
        templates[index].checklistItems = checklistItems
    }

    private func migrateChecklistGasRolesIfNeeded() {
        ChecklistRoleMigration.migrateLegacyRoles(in: &profile.checklistItems)
        for index in templates.indices {
            ChecklistRoleMigration.migrateLegacyRoles(in: &templates[index].checklistItems)
        }
    }

    private func saveIfReady() {
        guard isReady else { return }
        cloudSync?.save(profile, forKey: profileKey)
    }

    private func saveTemplatesIfReady() {
        guard isReady else { return }
        cloudSync?.save(templates, forKey: templatesKey)
    }

    private func saveSelectionIfReady() {
        guard isReady else { return }
        cloudSync?.save(selectedChecklistTemplateID, forKey: checklistSelectionKey)
    }

    private static func defaultTemplates() -> [EquipmentTemplate] {
        [
            EquipmentTemplate(
                name: DIRIOSLocalizer.string("equipment.template.rec"),
                checklistItems: [
                    EquipmentChecklistItem(title: "Mask", isReady: false, kind: .equipment),
                    EquipmentChecklistItem(title: "Fins", isReady: false, kind: .equipment),
                    EquipmentChecklistItem(title: "Regulator", isReady: false, usesGas: true, tankSize: .s80, gasRole: .bottom, kind: .equipment),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("checklist.quick.analyze_gas"), isReady: false, kind: .gas),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("checklist.quick.check_pressure"), isReady: false, kind: .gas),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("checklist.template.buddy_check"), isReady: false, kind: .safety),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("checklist.template.confirm_dive_plan"), isReady: false, kind: .task),
                ]
            ),
            EquipmentTemplate(
                name: DIRIOSLocalizer.string("equipment.template.tec"),
                checklistItems: [
                    EquipmentChecklistItem(title: "Backup mask", isReady: false, kind: .equipment),
                    EquipmentChecklistItem(title: "Spool", isReady: false, kind: .equipment),
                    EquipmentChecklistItem(title: "Back gas", isReady: false, usesGas: true, tankSize: .liters12, gasRole: .bottom, kind: .equipment),
                    EquipmentChecklistItem(title: "Deco stage", isReady: false, usesGas: true, tankSize: .liters12, gasRole: .deco, kind: .equipment),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("checklist.template.analyze_back_gas"), isReady: false, kind: .gas),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("checklist.template.analyze_deco_gas"), isReady: false, kind: .gas),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("checklist.quick.verify_mod"), isReady: false, kind: .gas),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("checklist.quick.check_pressure"), isReady: false, kind: .gas),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("checklist.template.confirm_gas_switches"), isReady: false, kind: .task),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("checklist.quick.confirm_rock_bottom"), isReady: false, kind: .task),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("checklist.template.confirm_deco_plan"), isReady: false, kind: .task),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("checklist.quick.send_watch_briefing"), isReady: false, kind: .task, isRequired: false),
                ]
            ),
            EquipmentTemplate(
                name: DIRIOSLocalizer.string("equipment.template.ccr"),
                checklistItems: [
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("equipment.ccr.rebreather"), isReady: false, kind: .equipment),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("equipment.ccr.loop"), isReady: false, kind: .equipment),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("equipment.ccr.counterlungs"), isReady: false, kind: .equipment),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("equipment.ccr.adv"), isReady: false, kind: .equipment),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("equipment.ccr.mav_o2"), isReady: false, kind: .equipment),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("equipment.ccr.mav_diluent"), isReady: false, kind: .equipment),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("equipment.ccr.o2_cylinder"), isReady: false, usesGas: true, tankSize: .s40, kind: .equipment),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("equipment.ccr.diluent_cylinder"), isReady: false, usesGas: true, tankSize: .liters12, gasRole: .ccrDiluent, kind: .equipment),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("equipment.ccr.o2_sensors"), isReady: false, kind: .equipment),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("equipment.ccr.hud"), isReady: false, kind: .equipment),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("equipment.ccr.controller"), isReady: false, kind: .equipment),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("equipment.ccr.bov"), isReady: false, kind: .equipment),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("equipment.ccr.scrubber"), isReady: false, kind: .equipment),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("equipment.ccr.wet_notes"), isReady: false, kind: .equipment),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("equipment.ccr.smb"), isReady: false, kind: .equipment),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("equipment.ccr.spool"), isReady: false, kind: .equipment),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("equipment.ccr.bailout_1"), isReady: false, usesGas: true, tankSize: .liters12, gasRole: .ccrBailout, kind: .equipment),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("equipment.ccr.bailout_2"), isReady: false, usesGas: true, tankSize: .liters12, gasRole: .ccrBailout, kind: .equipment),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("equipment.ccr.bailout_3"), isReady: false, usesGas: true, tankSize: .liters12, gasRole: .ccrBailout, kind: .equipment),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("checklist.template.analyze_diluent"), isReady: false, kind: .gas),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("checklist.template.analyze_bailout_gas"), isReady: false, kind: .gas),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("checklist.template.verify_o2_pressure"), isReady: false, kind: .gas),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("checklist.template.verify_diluent_pressure"), isReady: false, kind: .gas),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("checklist.template.verify_o2_sensors"), isReady: false, kind: .gas),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("checklist.template.pre_breathe"), isReady: false, kind: .safety),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("checklist.template.verify_scrubber_time"), isReady: false, kind: .task),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("checklist.template.verify_setpoints"), isReady: false, kind: .task),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("checklist.template.confirm_bailout_plan"), isReady: false, kind: .task),
                    EquipmentChecklistItem(title: DIRIOSLocalizer.string("checklist.quick.send_watch_briefing"), isReady: false, kind: .task, isRequired: false),
                ]
            )
        ]
    }
}
