import Foundation

enum SnorkelingExportLocationPrecision: String, Codable, CaseIterable, Hashable, Sendable {
    case removed
    case reduced
    case exact
}

struct SnorkelingExportPrivacyOptions: Equatable, Hashable, Sendable {
    var locationPrecision: SnorkelingExportLocationPrecision
    var includeBuddyContactDetails: Bool
    var includeEmergencyContact: Bool
    var includeGroupContacts: Bool
    var locationSharingAcknowledged: Bool

    static let redacted = SnorkelingExportPrivacyOptions(
        locationPrecision: .removed,
        includeBuddyContactDetails: false,
        includeEmergencyContact: false,
        includeGroupContacts: false,
        locationSharingAcknowledged: false
    )
}

enum SnorkelingExportPrivacyPolicy {
    static func requiresLocationConfirmation(for session: SnorkelingSession) -> Bool {
        measuredSurfacePoints(from: session).count >= 1
    }

    static func requiresSensitiveDataConfirmation(for session: SnorkelingSession) -> Bool {
        session.buddy?.contactNotes?.isEmpty == false
            || session.buddy?.name?.isEmpty == false
    }

    static func canExportLocation(options: SnorkelingExportPrivacyOptions, session: SnorkelingSession) -> Bool {
        guard requiresLocationConfirmation(for: session) else { return true }
        guard options.locationPrecision != .removed else { return false }
        return options.locationSharingAcknowledged
    }

    static func redactedSession(
        _ session: SnorkelingSession,
        options: SnorkelingExportPrivacyOptions
    ) -> SnorkelingSession {
        var redacted = session
        redacted.trackPoints = redactedTrackPoints(session.trackPoints, precision: options.locationPrecision)
        if var buddy = redacted.buddy {
            if !options.includeBuddyContactDetails {
                buddy.contactNotes = nil
            }
            redacted.buddy = buddy
        }
        if !options.includeEmergencyContact, !options.includeBuddyContactDetails {
            redacted.buddy = redacted.buddy.map {
                var copy = $0
                copy.contactNotes = nil
                return copy
            }
        }
        redacted.markers = redacted.markers.map { marker in
            var copy = marker
            if options.locationPrecision == .removed {
                copy.latitude = nil
                copy.longitude = nil
                copy.horizontalAccuracyMeters = nil
            } else if options.locationPrecision == .reduced {
                copy.latitude = copy.latitude.map { reducedCoordinate($0) }
                copy.longitude = copy.longitude.map { reducedCoordinate($0) }
            }
            return copy
        }
        if let entry = redacted.entryPoint {
            var point = entry
            if options.locationPrecision == .removed {
                point.latitude = nil
                point.longitude = nil
            } else if options.locationPrecision == .reduced {
                point.latitude = point.latitude.map { reducedCoordinate($0) }
                point.longitude = point.longitude.map { reducedCoordinate($0) }
            }
            redacted.entryPoint = point
        }
        return redacted
    }

    static func measuredSurfacePoints(from session: SnorkelingSession) -> [SnorkelingTrackPoint] {
        SnorkelingDomainSupport.normalizedTrackPoints(session.trackPoints).filter { point in
            guard !point.isUnderwater,
                  point.gpsQuality.isMeasuredSurfaceFix,
                  let lat = point.latitude,
                  let lon = point.longitude else { return false }
            return SnorkelingDomainSupport.isValidCoordinate(latitude: lat, longitude: lon)
        }
    }

    private static func redactedTrackPoints(
        _ trackPoints: [SnorkelingTrackPoint],
        precision: SnorkelingExportLocationPrecision
    ) -> [SnorkelingTrackPoint] {
        trackPoints.map { point in
            var copy = point
            switch precision {
            case .removed:
                if !point.isUnderwater {
                    copy.latitude = nil
                    copy.longitude = nil
                    copy.horizontalAccuracyMeters = nil
                    copy.speedMetersPerSecond = nil
                    copy.courseDegrees = nil
                }
            case .reduced:
                if !point.isUnderwater {
                    copy.latitude = copy.latitude.map { reducedCoordinate($0) }
                    copy.longitude = copy.longitude.map { reducedCoordinate($0) }
                }
            case .exact:
                break
            }
            return copy
        }
    }

    static func reducedCoordinate(_ value: Double) -> Double {
        (value * 1_000).rounded() / 1_000
    }
}
