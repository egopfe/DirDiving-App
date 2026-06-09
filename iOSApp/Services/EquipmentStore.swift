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
        isReady = true
        saveIfReady()
        saveTemplatesIfReady()
        saveSelectionIfReady()
    }

    var selectedChecklistSetupDisplayName: String {
        if let id = selectedChecklistTemplateID,
           let template = templates.first(where: { $0.id == id }) {
            return template.name
        }
        return String(localized: "checklist.setup.current_profile")
    }

    var selectedChecklistSetupSummary: String {
        if let id = selectedChecklistTemplateID,
           let template = templates.first(where: { $0.id == id }) {
            let gasCount = template.checklistItems.filter(\.usesGas).count
            return String(
                format: String(localized: "checklist.setup.summary.template"),
                template.checklistItems.count,
                gasCount
            )
        }
        return String(
            format: String(localized: "checklist.setup.summary.profile"),
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
                name: String(localized: "equipment.template.rec"),
                checklistItems: [
                    EquipmentChecklistItem(title: "Mask", isReady: false),
                    EquipmentChecklistItem(title: "Fins", isReady: false),
                    EquipmentChecklistItem(title: "Regulator", isReady: false, usesGas: true, tankSize: .s80)
                ]
            ),
            EquipmentTemplate(
                name: String(localized: "equipment.template.tec"),
                checklistItems: [
                    EquipmentChecklistItem(title: "Backup mask", isReady: false),
                    EquipmentChecklistItem(title: "Spool", isReady: false),
                    EquipmentChecklistItem(title: "Back gas", isReady: false, usesGas: true, tankSize: .liters12),
                    EquipmentChecklistItem(title: "Deco stage", isReady: false, usesGas: true, tankSize: .liters12)
                ]
            ),
            EquipmentTemplate(
                name: String(localized: "equipment.template.ccr"),
                checklistItems: [
                    EquipmentChecklistItem(title: String(localized: "equipment.ccr.rebreather"), isReady: false),
                    EquipmentChecklistItem(title: String(localized: "equipment.ccr.loop"), isReady: false),
                    EquipmentChecklistItem(title: String(localized: "equipment.ccr.counterlungs"), isReady: false),
                    EquipmentChecklistItem(title: String(localized: "equipment.ccr.adv"), isReady: false),
                    EquipmentChecklistItem(title: String(localized: "equipment.ccr.mav_o2"), isReady: false),
                    EquipmentChecklistItem(title: String(localized: "equipment.ccr.mav_diluent"), isReady: false),
                    EquipmentChecklistItem(title: String(localized: "equipment.ccr.o2_cylinder"), isReady: false, usesGas: true, tankSize: .s40),
                    EquipmentChecklistItem(title: String(localized: "equipment.ccr.diluent_cylinder"), isReady: false, usesGas: true, tankSize: .liters12, gasRole: .ccrDiluent),
                    EquipmentChecklistItem(title: String(localized: "equipment.ccr.o2_sensors"), isReady: false),
                    EquipmentChecklistItem(title: String(localized: "equipment.ccr.hud"), isReady: false),
                    EquipmentChecklistItem(title: String(localized: "equipment.ccr.controller"), isReady: false),
                    EquipmentChecklistItem(title: String(localized: "equipment.ccr.bov"), isReady: false),
                    EquipmentChecklistItem(title: String(localized: "equipment.ccr.scrubber"), isReady: false),
                    EquipmentChecklistItem(title: String(localized: "equipment.ccr.wet_notes"), isReady: false),
                    EquipmentChecklistItem(title: String(localized: "equipment.ccr.smb"), isReady: false),
                    EquipmentChecklistItem(title: String(localized: "equipment.ccr.spool"), isReady: false),
                    EquipmentChecklistItem(title: String(localized: "equipment.ccr.bailout_1"), isReady: false, usesGas: true, tankSize: .liters12, gasRole: .ccrBailout),
                    EquipmentChecklistItem(title: String(localized: "equipment.ccr.bailout_2"), isReady: false, usesGas: true, tankSize: .liters12, gasRole: .ccrBailout),
                    EquipmentChecklistItem(title: String(localized: "equipment.ccr.bailout_3"), isReady: false, usesGas: true, tankSize: .liters12, gasRole: .ccrBailout)
                ]
            )
        ]
    }
}
