import Combine
import Foundation

@MainActor
final class IOSSnorkelingBuddySafetyStore: ObservableObject {
    static var testHook_defaults: UserDefaults?

    @Published var profile: SnorkelingBuddySafetyProfile

    private let storageKey = "dirdiving_ios_snorkeling_buddy_safety_v1"
    private var defaults: UserDefaults { Self.testHook_defaults ?? .standard }

    init() {
        if let data = (Self.testHook_defaults ?? UserDefaults.standard).data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(SnorkelingBuddySafetyProfile.self, from: data) {
            profile = decoded
        } else {
            profile = .default
        }
    }

    func persist() {
        if let data = try? JSONEncoder().encode(profile) {
            defaults.set(data, forKey: storageKey)
        }
    }

    func confirmPreSession(at date: Date = Date(), note: String = "") {
        profile.preSessionConfirmation = SnorkelingPreSessionConfirmation(isConfirmed: true, confirmedAt: date, note: note)
        persist()
    }

    func resetConfirmation() {
        profile.preSessionConfirmation = SnorkelingPreSessionConfirmation()
        persist()
    }

    func applyToSession(_ session: inout SnorkelingSession) {
        session.buddy = SnorkelingBuddyInfo(
            name: profile.buddyName.isEmpty ? nil : profile.buddyName,
            contactNotes: profile.buddyContactNotes.isEmpty ? nil : profile.buddyContactNotes,
            isBuddyPresent: profile.isBuddyPresent
        )
    }

    func shareablePlanText(sessionTitle: String) -> String {
        var lines = [sessionTitle]
        if !profile.buddyName.isEmpty {
            lines.append("Buddy: \(profile.buddyName)")
        }
        if profile.isBuddyPresent {
            lines.append("Buddy present")
        }
        if !profile.meetingPointNotes.isEmpty {
            lines.append("Meeting point: \(profile.meetingPointNotes)")
        }
        if let expectedReturn = profile.expectedReturnAt {
            lines.append("Expected return: \(expectedReturn.formatted(date: .abbreviated, time: .shortened))")
        }
        for member in profile.groupMembers where !member.name.isEmpty {
            lines.append("Group: \(member.name)\(member.role.isEmpty ? "" : " (\(member.role))")")
        }
        if !profile.shareablePlanNote.isEmpty {
            lines.append(profile.shareablePlanNote)
        }
        lines.append("No real-time buddy tracking or remote rescue monitoring is provided by this app.")
        return lines.joined(separator: "\n")
    }
}
