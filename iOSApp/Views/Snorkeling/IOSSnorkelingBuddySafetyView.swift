import SwiftUI

struct IOSSnorkelingBuddySafetyView: View {
    @EnvironmentObject private var buddyStore: IOSSnorkelingBuddySafetyStore

    var body: some View {
        DIRScreenContainer {
            Form {
                Section(DIRIOSLocalizer.string("snorkeling.ios.buddy.title")) {
                    TextField(DIRIOSLocalizer.string("snorkeling.ios.buddy.name"), text: $buddyStore.profile.buddyName)
                    TextField(DIRIOSLocalizer.string("snorkeling.ios.buddy.contact"), text: $buddyStore.profile.buddyContactNotes, axis: .vertical)
                    Toggle(DIRIOSLocalizer.string("snorkeling.ios.buddy.present"), isOn: $buddyStore.profile.isBuddyPresent)
                    Text(DIRIOSLocalizer.string("snorkeling.ios.buddy.disclaimer"))
                        .font(.caption)
                        .foregroundStyle(DIRTheme.muted)
                }

                Section(DIRIOSLocalizer.string("snorkeling.ios.buddy.group")) {
                    ForEach($buddyStore.profile.groupMembers) { $member in
                        TextField(DIRIOSLocalizer.string("snorkeling.ios.buddy.member_name"), text: $member.name)
                        TextField(DIRIOSLocalizer.string("snorkeling.ios.buddy.member_role"), text: $member.role)
                        TextField(DIRIOSLocalizer.string("snorkeling.ios.buddy.member_contact"), text: $member.contactNotes)
                    }
                    Button(DIRIOSLocalizer.string("snorkeling.ios.buddy.add_member")) {
                        buddyStore.profile.groupMembers.append(SnorkelingGroupMember())
                    }
                    .foregroundStyle(DIRTheme.cyan)
                }

                Section(DIRIOSLocalizer.string("snorkeling.ios.buddy.meeting")) {
                    TextField(DIRIOSLocalizer.string("snorkeling.ios.buddy.meeting_point"), text: $buddyStore.profile.meetingPointNotes, axis: .vertical)
                    DatePicker(
                        DIRIOSLocalizer.string("snorkeling.ios.buddy.expected_return"),
                        selection: Binding(
                            get: { buddyStore.profile.expectedReturnAt ?? Date().addingTimeInterval(3_600) },
                            set: { buddyStore.profile.expectedReturnAt = $0 }
                        ),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }

                Section(DIRIOSLocalizer.string("snorkeling.ios.buddy.emergency")) {
                    TextField(DIRIOSLocalizer.string("snorkeling.ios.buddy.emergency_name"), text: $buddyStore.profile.emergencyContact.name)
                    TextField(DIRIOSLocalizer.string("snorkeling.ios.buddy.emergency_phone"), text: $buddyStore.profile.emergencyContact.phone)
                        .keyboardType(.phonePad)
                    TextField(DIRIOSLocalizer.string("snorkeling.ios.buddy.emergency_relation"), text: $buddyStore.profile.emergencyContact.relationship)
                }

                Section(DIRIOSLocalizer.string("snorkeling.ios.buddy.checklist")) {
                    ForEach($buddyStore.profile.checklist) { $item in
                        Toggle(item.title, isOn: $item.isCompleted)
                    }
                }

                Section(DIRIOSLocalizer.string("snorkeling.ios.buddy.confirmation")) {
                    if buddyStore.profile.preSessionConfirmation.isConfirmed,
                       let confirmedAt = buddyStore.profile.preSessionConfirmation.confirmedAt {
                        Label(
                            confirmedAt.formatted(date: .abbreviated, time: .shortened),
                            systemImage: "checkmark.seal.fill"
                        )
                        .foregroundStyle(DIRTheme.green)
                    } else {
                        Text(DIRIOSLocalizer.string("snorkeling.ios.buddy.not_confirmed"))
                            .foregroundStyle(DIRTheme.orange)
                    }
                    Button(DIRIOSLocalizer.string("snorkeling.ios.buddy.confirm_action")) {
                        buddyStore.confirmPreSession()
                    }
                    .foregroundStyle(DIRTheme.cyan)
                    if buddyStore.profile.preSessionConfirmation.isConfirmed {
                        Button(DIRIOSLocalizer.string("snorkeling.ios.buddy.reset_confirmation"), role: .destructive) {
                            buddyStore.resetConfirmation()
                        }
                    }
                }

                Section(DIRIOSLocalizer.string("snorkeling.ios.buddy.shareable_plan")) {
                    TextField(DIRIOSLocalizer.string("snorkeling.ios.buddy.plan_note"), text: $buddyStore.profile.shareablePlanNote, axis: .vertical)
                    ShareLink(item: buddyStore.shareablePlanText(sessionTitle: DIRIOSLocalizer.string("snorkeling.ios.dashboard.title"))) {
                        Label(DIRIOSLocalizer.string("snorkeling.ios.buddy.share_plan"), systemImage: "square.and.arrow.up")
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(DIRIOSLocalizer.string("snorkeling.ios.buddy.nav_title"))
        .onChange(of: buddyStore.profile) { _, _ in
            buddyStore.persist()
        }
    }
}
