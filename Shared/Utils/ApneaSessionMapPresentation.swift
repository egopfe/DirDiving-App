import Foundation

struct ApneaMapCoordinate: Equatable, Identifiable, Hashable, Sendable {
    let id: UUID
    var latitude: Double
    var longitude: Double
    var capturedAt: Date
}

struct ApneaSessionMapModel: Equatable, Hashable, Sendable {
    var coordinates: [ApneaMapCoordinate]
    var sessionStartText: String?
    var sessionEndText: String?
    var accuracyMeters: Double?
    var isAvailable: Bool
    var unavailableReasonKey: String?

    static let unavailable = ApneaSessionMapModel(
        coordinates: [],
        sessionStartText: nil,
        sessionEndText: nil,
        accuracyMeters: nil,
        isAvailable: false,
        unavailableReasonKey: "apnea.ios.map.unavailable"
    )
}

enum ApneaMapFixQuality: String, Codable, Hashable, Sendable {
    case none
    case poor
    case fair
    case good
}

enum ApneaMapPermissionState: String, Codable, Hashable, Sendable {
    case authorized
    case denied
    case restricted
    case notDetermined
}

extension ApneaSessionMapModel {
    var fixQuality: ApneaMapFixQuality {
        guard isAvailable else { return .none }
        guard let accuracy = accuracyMeters else { return .fair }
        if accuracy <= 10 { return .good }
        if accuracy <= 30 { return .fair }
        return .poor
    }

    var privacyNoticeKey: String {
        "apnea.ios.map.privacy_notice"
    }
}

enum ApneaSessionMapPresentation {
    static func make(
        from session: ApneaSession,
        permission: ApneaMapPermissionState = .authorized,
        calendar: Calendar = .current,
        locale: Locale = .current
    ) -> ApneaSessionMapModel {
        if permission == .denied || permission == .restricted {
            return ApneaSessionMapModel(
                coordinates: [],
                sessionStartText: nil,
                sessionEndText: nil,
                accuracyMeters: nil,
                isAvailable: false,
                unavailableReasonKey: "apnea.ios.map.permission_denied"
            )
        }

        let points = session.surfaceGPSPoints.filter { $0.latitude.isFinite && $0.longitude.isFinite }
        guard points.count >= 2 else {
            if session.warnings.contains(.gpsUnavailable) {
                return ApneaSessionMapModel(
                    coordinates: [],
                    sessionStartText: nil,
                    sessionEndText: nil,
                    accuracyMeters: nil,
                    isAvailable: false,
                    unavailableReasonKey: "apnea.ios.map.gps_unavailable"
                )
            }
            return .unavailable
        }

        let coordinates = points.map {
            ApneaMapCoordinate(
                id: UUID(),
                latitude: $0.latitude,
                longitude: $0.longitude,
                capturedAt: $0.capturedAt
            )
        }
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        formatter.timeStyle = .short
        formatter.dateStyle = .none

        let sorted = points.sorted { $0.capturedAt < $1.capturedAt }
        let worstAccuracy = points.compactMap(\.horizontalAccuracyMeters).max()

        return ApneaSessionMapModel(
            coordinates: coordinates,
            sessionStartText: formatter.string(from: sorted.first?.capturedAt ?? session.createdAt),
            sessionEndText: formatter.string(from: sorted.last?.capturedAt ?? session.createdAt),
            accuracyMeters: worstAccuracy,
            isAvailable: true,
            unavailableReasonKey: nil
        )
    }
}
