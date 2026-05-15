import SwiftUI

struct EquipmentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                DIRBackground()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Attrezzatura")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        DIRCard("PIANIFICAZIONE COMPLETA", icon: "shippingbox.fill") {
                            equipmentRow("Bombole", "2 x 12 L")
                            equipmentRow("Configurazione", "Backmount DIR")
                            equipmentRow("Gas default", "TRIMIX / EAN50 / EAN80")
                            equipmentRow("SAC default", "18 l/min")
                        }
                        DIRCard("CHECKLIST", icon: "checklist") {
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

    private func equipmentRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(DIRTheme.muted)
            Spacer()
            Text(value).foregroundStyle(.white).bold()
        }
        .font(.callout)
        .padding(.vertical, 5)
    }
}
