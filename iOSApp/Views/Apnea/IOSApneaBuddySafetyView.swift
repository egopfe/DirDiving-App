import SwiftUI

struct IOSApneaBuddySafetyView: View {
    @EnvironmentObject private var buddyStore: IOSApneaBuddySafetyStore

    var body: some View {
        DIRScreenContainer {
            Form {
                Section(DIRIOSLocalizer.string("apnea.ios.buddy.title")) {
                    TextField(DIRIOSLocalizer.string("apnea.ios.buddy.name"), text: $buddyStore.profile.buddyName)
                    TextField(DIRIOSLocalizer.string("apnea.ios.buddy.contact"), text: $buddyStore.profile.buddyContactNotes, axis: .vertical)
                    Toggle(DIRIOSLocalizer.string("apnea.ios.buddy.safety_diver"), isOn: $buddyStore.profile.isSafetyDiverPresent)
                    Text(DIRIOSLocalizer.string("apnea.ios.buddy.disclaimer"))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                }

                Section(DIRIOSLocalizer.string("apnea.ios.buddy.emergency")) {
                    TextField(DIRIOSLocalizer.string("apnea.ios.buddy.emergency_name"), text: $buddyStore.profile.emergencyContact.name)
                    TextField(DIRIOSLocalizer.string("apnea.ios.buddy.emergency_phone"), text: $buddyStore.profile.emergencyContact.phone)
                        .keyboardType(.phonePad)
                    TextField(DIRIOSLocalizer.string("apnea.ios.buddy.emergency_relation"), text: $buddyStore.profile.emergencyContact.relationship)
                }

                Section(DIRIOSLocalizer.string("apnea.ios.buddy.checklist")) {
                    ForEach($buddyStore.profile.checklist) { $item in
                        Toggle(item.title, isOn: $item.isCompleted)
                    }
                }

                Section(DIRIOSLocalizer.string("apnea.ios.buddy.confirmation")) {
                    if buddyStore.profile.preSessionConfirmation.isConfirmed,
                       let confirmedAt = buddyStore.profile.preSessionConfirmation.confirmedAt {
                        Label(
                            confirmedAt.formatted(date: .abbreviated, time: .shortened),
                            systemImage: "checkmark.seal.fill"
                        )
                        .foregroundStyle(DIRTheme.green)
                    } else {
                        Text(DIRIOSLocalizer.string("apnea.ios.buddy.not_confirmed"))
                            .foregroundStyle(DIRTheme.orange)
                    }
                    Button(DIRIOSLocalizer.string("apnea.ios.buddy.confirm_action")) {
                        buddyStore.confirmPreSession()
                    }
                    .foregroundStyle(DIRTheme.cyan)
                    if buddyStore.profile.preSessionConfirmation.isConfirmed {
                        Button(DIRIOSLocalizer.string("apnea.ios.buddy.reset_confirmation"), role: .destructive) {
                            buddyStore.resetConfirmation()
                        }
                    }
                }

                Section(DIRIOSLocalizer.string("apnea.ios.buddy.shareable_plan")) {
                    TextField(DIRIOSLocalizer.string("apnea.ios.buddy.plan_note"), text: $buddyStore.profile.shareablePlanNote, axis: .vertical)
                    ShareLink(item: buddyStore.shareablePlanText(sessionTitle: DIRIOSLocalizer.string("apnea.ios.planner.title"))) {
                        Label(DIRIOSLocalizer.string("apnea.ios.buddy.share_plan"), systemImage: "square.and.arrow.up")
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(DIRIOSLocalizer.string("apnea.ios.buddy.nav_title"))
        .onChange(of: buddyStore.profile) { _, _ in
            buddyStore.persist()
        }
    }
}
