import Combine
import Foundation

@MainActor
final class IOSApneaBuddySafetyStore: ObservableObject {
    static var testHook_defaults: UserDefaults?

    @Published var profile: ApneaBuddySafetyProfile

    private let storageKey = "dirdiving_ios_apnea_buddy_safety_v1"
    private var defaults: UserDefaults { Self.testHook_defaults ?? .standard }

    init() {
        if let data = (Self.testHook_defaults ?? UserDefaults.standard).data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(ApneaBuddySafetyProfile.self, from: data) {
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
        profile.preSessionConfirmation = ApneaPreSessionConfirmation(isConfirmed: true, confirmedAt: date, note: note)
        persist()
    }

    func resetConfirmation() {
        profile.preSessionConfirmation = ApneaPreSessionConfirmation()
        persist()
    }

    func applyToSession(_ session: inout ApneaSession) {
        session.buddy = ApneaBuddyInfo(
            name: profile.buddyName.isEmpty ? nil : profile.buddyName,
            contactNotes: profile.buddyContactNotes.isEmpty ? nil : profile.buddyContactNotes,
            isSafetyDiverPresent: profile.isSafetyDiverPresent
        )
    }

    func shareablePlanText(sessionTitle: String) -> String {
        var lines = [sessionTitle]
        if !profile.buddyName.isEmpty {
            lines.append("Buddy: \(profile.buddyName)")
        }
        if profile.isSafetyDiverPresent {
            lines.append("Safety diver present")
        }
        if !profile.shareablePlanNote.isEmpty {
            lines.append(profile.shareablePlanNote)
        }
        lines.append("No remote rescue monitoring is provided by this app.")
        return lines.joined(separator: "\n")
    }
}
