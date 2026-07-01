import SwiftUI

struct IOSActivityLogbookVisibilitySettingsSection: View {
    let activity: DIRActivityMode

    @EnvironmentObject private var logbookVisibility: IOSActivityLogbookVisibilitySettingsStore

    var body: some View {
        DIRCard(DIRIOSLocalizer.string("logbook.visibility.title"), icon: "books.vertical", accent: accent) {
            IOSCompanionSettingsToggleRow(
                title: DIRIOSLocalizer.string("logbook.visibility.show_all_activities"),
                isOn: toggleBinding,
                identifier: "\(activity.rawValue).settings.logbook.show_all_activities"
            )
            IOSCompanionSettingsFootnoteText(text: descriptionText)
        }
    }

    private var accent: Color {
        CompanionActivityPresentation.accent(for: activity)
    }

    private var descriptionText: String {
        switch activity {
        case .diving:
            return DIRIOSLocalizer.string("logbook.visibility.show_all_activities.description.diving")
        case .snorkeling:
            return DIRIOSLocalizer.string("logbook.visibility.show_all_activities.description.snorkeling")
        case .apnea:
            return DIRIOSLocalizer.string("logbook.visibility.show_all_activities.description.apnea")
        }
    }

    private var toggleBinding: Binding<Bool> {
        Binding(
            get: { logbookVisibility.showAllActivitiesInLogbook(for: activity) },
            set: { logbookVisibility.setShowAllActivitiesInLogbook($0, for: activity) }
        )
    }
}
