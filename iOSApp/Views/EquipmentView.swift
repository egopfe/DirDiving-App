import SwiftUI

struct EquipmentView: View {
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
                            Text("Configuration, checklist and field-ready equipment overview")
                                .font(.callout)
                                .foregroundStyle(DIRTheme.muted)
                        }
                        equipmentHero
                        DIRCard("PIANIFICAZIONE COMPLETA", icon: "shippingbox.fill", accent: DIRTheme.cyan) {
                            equipmentRow("Bombole", "2 x 12 L")
                            equipmentRow("Configurazione", "Backmount DIR")
                            equipmentRow("Gas default", "TRIMIX / EAN50 / EAN80")
                            equipmentRow("SAC default", "18 l/min")
                        }
                        DIRCard("CHECKLIST", icon: "checklist", accent: DIRTheme.green) {
                            equipmentRow("Backup mask", "Ready")
                            equipmentRow("Spool / SMB", "Ready")
                            equipmentRow("Computer backup", "Ready")
                        }
                        DIRWarningBox(text: "Sezione predisposta per configurazioni, checklist e consumi reali.")
                    }
                    .padding(16)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var equipmentHero: some View {
        HStack(spacing: 12) {
            equipmentBadge("DIR", DIRTheme.cyan)
            equipmentBadge("READY", DIRTheme.green)
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
}
