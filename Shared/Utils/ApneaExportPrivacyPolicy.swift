import Foundation

struct ApneaExportPrivacyOptions: Equatable, Hashable, Sendable {
    var includeSurfaceGPS: Bool
    var includeBuddyContactDetails: Bool
    var includeEmergencyContact: Bool
    var locationSharingAcknowledged: Bool

    static let redacted = ApneaExportPrivacyOptions(
        includeSurfaceGPS: false,
        includeBuddyContactDetails: false,
        includeEmergencyContact: false,
        locationSharingAcknowledged: false
    )
}

enum ApneaExportPrivacyPolicy {
    static func requiresLocationConfirmation(for session: ApneaSession) -> Bool {
        !session.surfaceGPSPoints.isEmpty
    }

    static func requiresSensitiveDataConfirmation(for session: ApneaSession) -> Bool {
        session.buddy?.contactNotes?.isEmpty == false
            || session.buddy?.name?.isEmpty == false
    }

    static func canExportLocation(options: ApneaExportPrivacyOptions, session: ApneaSession) -> Bool {
        guard requiresLocationConfirmation(for: session) else { return true }
        return options.includeSurfaceGPS && options.locationSharingAcknowledged
    }

    static func redactedSession(
        _ session: ApneaSession,
        options: ApneaExportPrivacyOptions
    ) -> ApneaSession {
        var redacted = session
        if !options.includeSurfaceGPS {
            redacted.surfaceGPSPoints = []
        }
        if var buddy = redacted.buddy {
            if !options.includeBuddyContactDetails {
                buddy.contactNotes = nil
            }
            redacted.buddy = buddy
        }
        if !options.includeEmergencyContact {
            redacted.buddy = redacted.buddy.map {
                var copy = $0
                copy.contactNotes = nil
                return copy
            }
        }
        return redacted
    }
}
