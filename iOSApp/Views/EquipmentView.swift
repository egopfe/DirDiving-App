import SwiftUI

struct EquipmentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                DIRBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        DIRSectionHeader(title: "Attrezzatura", subtitle: "Configurazione futura")
                        DIRCard("Set principale", icon: "shippingbox.fill") {
                            equipmentRow("Bombole", "2 x 12 L")
                            equipmentRow("Configurazione", "Backmount DIR")
                            equipmentRow("Gas default", "Trimix / EAN50 / EAN80")
                            equipmentRow("SAC default", "18 l/min")
                        }
                        DIRWarningBox(text: "Sezione predisposta per configurazioni, checklist e consumi reali.")
                    }.padding()
                }
            }.navigationTitle("Attrezzatura").navigationBarTitleDisplayMode(.inline)
        }
    }
    private func equipmentRow(_ title: String, _ value: String) -> some View {
        HStack { Text(title).foregroundStyle(DIRTheme.muted); Spacer(); Text(value).foregroundStyle(.white).bold() }.padding(.vertical, 5)
    }
}
