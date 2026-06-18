import Foundation

struct SnorkelingMarker: Identifiable, Codable, Hashable, Sendable {
    static let maximumNoteLength = 120

    let id: UUID
    var category: SnorkelingMarkerCategory
    var customCategoryLabel: String?
    var monotonicRelativeTimestampSeconds: TimeInterval
    var wallClockTimestamp: Date?
    var positionQuality: SnorkelingMarkerPositionQuality
    var latitude: Double?
    var longitude: Double?
    var horizontalAccuracyMeters: Double?
    var depthMeters: Double?
    var temperatureCelsius: Double?
    var headingDegrees: Double?
    var distanceFromEntryMeters: Double?
    var bearingFromEntryDegrees: Double?
    var relatedWaypointID: UUID?
    var sessionID: UUID?
    var photoReferenceID: UUID?
    var isEnriched: Bool
    var note: String?

    init(
        id: UUID = UUID(),
        category: SnorkelingMarkerCategory,
        customCategoryLabel: String? = nil,
        monotonicRelativeTimestampSeconds: TimeInterval,
        wallClockTimestamp: Date? = nil,
        positionQuality: SnorkelingMarkerPositionQuality? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        horizontalAccuracyMeters: Double? = nil,
        depthMeters: Double? = nil,
        temperatureCelsius: Double? = nil,
        headingDegrees: Double? = nil,
        distanceFromEntryMeters: Double? = nil,
        bearingFromEntryDegrees: Double? = nil,
        relatedWaypointID: UUID? = nil,
        sessionID: UUID? = nil,
        photoReferenceID: UUID? = nil,
        isEnriched: Bool = false,
        note: String? = nil
    ) {
        self.id = id
        self.category = category
        self.customCategoryLabel = customCategoryLabel
        self.monotonicRelativeTimestampSeconds = monotonicRelativeTimestampSeconds
        self.wallClockTimestamp = wallClockTimestamp
        if let positionQuality {
            self.positionQuality = positionQuality
        } else if let latitude, let longitude,
                  SnorkelingDomainSupport.isValidCoordinate(latitude: latitude, longitude: longitude) {
            self.positionQuality = .measured
        } else {
            self.positionQuality = .noFix
        }
        self.latitude = latitude
        self.longitude = longitude
        self.horizontalAccuracyMeters = horizontalAccuracyMeters
        self.depthMeters = depthMeters
        self.temperatureCelsius = temperatureCelsius
        self.headingDegrees = headingDegrees
        self.distanceFromEntryMeters = distanceFromEntryMeters
        self.bearingFromEntryDegrees = bearingFromEntryDegrees
        self.relatedWaypointID = relatedWaypointID
        self.sessionID = sessionID
        self.photoReferenceID = photoReferenceID
        self.isEnriched = isEnriched
        self.note = note
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        category = try container.decode(SnorkelingMarkerCategory.self, forKey: .category)
        customCategoryLabel = try container.decodeIfPresent(String.self, forKey: .customCategoryLabel)
        monotonicRelativeTimestampSeconds = try container.decode(TimeInterval.self, forKey: .monotonicRelativeTimestampSeconds)
        wallClockTimestamp = try container.decodeIfPresent(Date.self, forKey: .wallClockTimestamp)
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        positionQuality = try container.decodeIfPresent(SnorkelingMarkerPositionQuality.self, forKey: .positionQuality)
            ?? ((latitude != nil && longitude != nil) ? .measured : .noFix)
        horizontalAccuracyMeters = try container.decodeIfPresent(Double.self, forKey: .horizontalAccuracyMeters)
        depthMeters = try container.decodeIfPresent(Double.self, forKey: .depthMeters)
        temperatureCelsius = try container.decodeIfPresent(Double.self, forKey: .temperatureCelsius)
        headingDegrees = try container.decodeIfPresent(Double.self, forKey: .headingDegrees)
        distanceFromEntryMeters = try container.decodeIfPresent(Double.self, forKey: .distanceFromEntryMeters)
        bearingFromEntryDegrees = try container.decodeIfPresent(Double.self, forKey: .bearingFromEntryDegrees)
        relatedWaypointID = try container.decodeIfPresent(UUID.self, forKey: .relatedWaypointID)
        sessionID = try container.decodeIfPresent(UUID.self, forKey: .sessionID)
        photoReferenceID = try container.decodeIfPresent(UUID.self, forKey: .photoReferenceID)
        isEnriched = try container.decodeIfPresent(Bool.self, forKey: .isEnriched) ?? false
        note = try container.decodeIfPresent(String.self, forKey: .note)
    }

    private enum CodingKeys: String, CodingKey {
        case id, category, customCategoryLabel, monotonicRelativeTimestampSeconds, wallClockTimestamp
        case positionQuality, latitude, longitude, horizontalAccuracyMeters, depthMeters
        case temperatureCelsius, headingDegrees, distanceFromEntryMeters, bearingFromEntryDegrees
        case relatedWaypointID, sessionID, photoReferenceID, isEnriched, note
    }
}
