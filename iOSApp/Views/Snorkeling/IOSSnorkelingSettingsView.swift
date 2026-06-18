import SwiftUI

struct IOSSnorkelingSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        DIRScreenContainer {
            Form {
                Section(DIRIOSLocalizer.string("snorkeling.ios.settings.companion")) {
                    NavigationLink(DIRIOSLocalizer.string("snorkeling.ios.equipment.title")) {
                        IOSSnorkelingEquipmentView()
                    }
                    NavigationLink(DIRIOSLocalizer.string("snorkeling.ios.buddy.nav_title")) {
                        IOSSnorkelingBuddySafetyView()
                    }
                }

                Section(DIRIOSLocalizer.string("snorkeling.ios.settings.privacy")) {
                    Text(DIRIOSLocalizer.string("snorkeling.ios.settings.privacy_note"))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(DIRIOSLocalizer.string("snorkeling.ios.settings.title"))
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(DIRIOSLocalizer.string("common.close")) {
                    dismiss()
                }
            }
        }
    }
}
