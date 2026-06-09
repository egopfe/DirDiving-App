import SwiftUI

struct EquipmentView: View {
    @EnvironmentObject private var equipment: EquipmentStore
    @State private var showResetConfirmation = false
    @State private var savedFeedback: String?
    @State private var showTemplatesSheet = false
    @AppStorage("dirdiving_ios_units") private var units = IOSUnitPreference.metric.rawValue

    var body: some View {
        NavigationStack {
            DIRScreenContainer {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 7) {
                            Text(String(localized: "equipment.title"))
                                .dirScreenTitleStyle()
                            Text(String(localized: "equipment.subtitle"))
                                .dirScreenSubtitleStyle()
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
                        DIRCard(String(localized: "equipment.card.planning"), icon: "shippingbox.fill", accent: DIRTheme.cyan) {
                            Text(String(localized: "equipment.card.planning.informational"))
                                .font(.caption2)
                                .foregroundStyle(DIRTheme.muted)
                                .fixedSize(horizontal: false, vertical: true)
                            editableRow(String(localized: "equipment.row.cylinders"), text: $equipment.profile.cylinders)
                            editableRow(String(localized: "equipment.row.configuration"), text: $equipment.profile.configuration)
                            editableRow(String(localized: "equipment.row.bottom_gas"), text: $equipment.profile.bottomGas)
                            editableRow(String(localized: "equipment.row.deco1"), text: $equipment.profile.decoGas1)
                            editableRow(String(localized: "equipment.row.deco2"), text: $equipment.profile.decoGas2)
                            sacRow
                        }
                        DIRCard(String(localized: "equipment.card.saved_setups"), icon: "square.stack.3d.up.fill", accent: DIRTheme.green) {
                            Text(String(localized: "equipment.saved_setups.hint"))
                                .font(.caption2)
                                .foregroundStyle(DIRTheme.muted)
                                .fixedSize(horizontal: false, vertical: true)
                            Button {
                                showTemplatesSheet = true
                            } label: {
                                Text(String(localized: "equipment.my_equipment.button"))
                                    .font(.callout.weight(.semibold))
                                    .foregroundStyle(DIRTheme.cyan)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan.opacity(0.7), lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(String(localized: "equipment.my_equipment.button"))
                        }
                        DIRCard(String(localized: "equipment.images.section"), icon: "photo.on.rectangle.angled", accent: DIRTheme.cyan) {
                            Text(String(localized: "equipment.images.hint"))
                                .font(.caption2)
                                .foregroundStyle(DIRTheme.muted)
                                .fixedSize(horizontal: false, vertical: true)
                            WatchPhotoTransferPanel()
                        }
                        .accessibilityElement(children: .contain)
                        Button {
                            showResetConfirmation = true
                        } label: {
                            Text(String(localized: "equipment.reset_profile"))
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(DIRTheme.cyan)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 11)
                                .background(RoundedRectangle(cornerRadius: 8).stroke(DIRTheme.cyan.opacity(0.75), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        DIRWarningBox(text: String(localized: "equipment.save_notice"))
                    }
                    .padding(16)
                }
                .dirCompanionScrollSurface()
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .confirmationDialog(String(localized: "equipment.reset.confirm.title"), isPresented: $showResetConfirmation, titleVisibility: .visible) {
                Button(String(localized: "equipment.reset.confirm.action"), role: .destructive) {
                    equipment.reset()
                    showSavedFeedback()
                }
                Button(String(localized: "equipment.reset.cancel"), role: .cancel) {}
            } message: {
                Text(String(localized: "equipment.reset.confirm.message"))
            }
            .onChange(of: equipment.profile) { _, _ in
                showSavedFeedback()
            }
            .sheet(isPresented: $showTemplatesSheet) {
                EquipmentTemplatesSheet()
                    .environmentObject(equipment)
            }
        }
        .dirCompanionTabRoot()
    }

    private var equipmentHero: some View {
        HStack(spacing: 12) {
            equipmentBadge(
                "DIR",
                equipment.profile.isDIRConfigurationComplete ? DIRTheme.green : DIRTheme.red,
                accessibilityLabel: String(
                    localized: equipment.profile.isDIRConfigurationComplete
                        ? "equipment.badge.dir.complete.a11y"
                        : "equipment.badge.dir.incomplete.a11y"
                )
            )
        }
    }

    private func equipmentBadge(_ text: String, _ color: Color, accessibilityLabel: String? = nil) -> some View {
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
            .accessibilityLabel(accessibilityLabel ?? text)
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
            Text(String(localized: "equipment.sac_default")).foregroundStyle(DIRTheme.muted)
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
        savedFeedback = String(localized: "Profilo attrezzatura salvato.")
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            savedFeedback = nil
        }
    }
}
