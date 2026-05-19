import SwiftUI

struct EquipmentView: View {
    @EnvironmentObject private var equipment: EquipmentStore
    @State private var showResetConfirmation = false
    @State private var savedFeedback: String?
    @AppStorage("dirdiving_ios_units") private var units = IOSUnitPreference.metric.rawValue

    var body: some View {
        NavigationStack {
            ZStack {
                DIRBackground()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 7) {
                            Text("Attrezzatura")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text("Configurazione, checklist e panoramica attrezzatura sul campo.")
                                .font(.callout)
                                .foregroundStyle(DIRTheme.muted)
                        }
                        equipmentHero
                        if let savedFeedback {
                            Text(savedFeedback)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(DIRTheme.green)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background(RoundedRectangle(cornerRadius: 8).fill(DIRTheme.green.opacity(0.10)))
                        }
                        DIRCard("PIANIFICAZIONE COMPLETA", icon: "shippingbox.fill", accent: DIRTheme.cyan) {
                            editableRow("Bombole", text: $equipment.profile.cylinders)
                            editableRow("Configurazione", text: $equipment.profile.configuration)
                            editableRow("Gas fondo", text: $equipment.profile.bottomGas)
                            editableRow("Deco 1", text: $equipment.profile.decoGas1)
                            editableRow("Deco 2", text: $equipment.profile.decoGas2)
                            sacRow
                        }
                        DIRCard("CHECKLIST", icon: "checklist", accent: DIRTheme.green) {
                            Toggle("Backup mask", isOn: $equipment.profile.backupMaskReady).tint(DIRTheme.cyan)
                            Toggle("Spool / SMB", isOn: $equipment.profile.spoolReady).tint(DIRTheme.cyan)
                            Toggle("Computer backup", isOn: $equipment.profile.backupComputerReady).tint(DIRTheme.cyan)
                        }
                        Button {
                            showResetConfirmation = true
                        } label: {
                            Text("Reset profilo standard")
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(DIRTheme.cyan)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 11)
                                .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan.opacity(0.75), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        DIRWarningBox(text: "Profilo attrezzatura salvato localmente e in iCloud KVS quando disponibile.")
                    }
                    .padding(16)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .confirmationDialog("Resettare il profilo attrezzatura?", isPresented: $showResetConfirmation, titleVisibility: .visible) {
                Button("Reset profilo", role: .destructive) {
                    equipment.reset()
                    showSavedFeedback()
                }
                Button("Annulla", role: .cancel) {}
            } message: {
                Text("Bombole, gas, SAC e checklist torneranno ai valori standard salvati localmente.")
            }
            .onChange(of: equipment.profile) { _, _ in
                showSavedFeedback()
            }
        }
    }

    private var equipmentHero: some View {
        HStack(spacing: 12) {
            equipmentBadge("DIR", DIRTheme.cyan)
            equipmentBadge("\(equipment.profile.checklistReadyCount)/3 READY", equipment.profile.checklistReadyCount == 3 ? DIRTheme.green : DIRTheme.yellow)
            equipmentBadge("FIELD", DIRTheme.yellow)
        }
    }

    private func equipmentBadge(_ text: String, _ color: Color) -> some View {
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

    private func equipmentRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(DIRTheme.muted)
            Spacer()
            Text(value).foregroundStyle(.white).bold()
        }
        .font(.callout)
        .padding(.vertical, 7)
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
            Text("SAC default").foregroundStyle(DIRTheme.muted)
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

    private var unitPreference: IOSUnitPreference {
        IOSUnitPreference.fromStorage(units)
    }

    private func showSavedFeedback() {
        savedFeedback = "Salvato"
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            savedFeedback = nil
        }
    }
}
