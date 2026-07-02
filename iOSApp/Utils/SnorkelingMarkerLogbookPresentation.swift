import Foundation

struct SnorkelingMarkerCategoryCount: Equatable, Identifiable {
    var category: SnorkelingMarkerCategory
    var count: Int

    var id: String { category.rawValue }
}

struct SnorkelingMarkerLogbookRowPresentation: Equatable, Identifiable {
    var id: UUID
    var categoryKey: String
    var categoryLabel: String
    var timestampText: String
    var gpsQualityText: String?
    var distanceFromEntryText: String?
    var note: String?
}

enum SnorkelingMarkerLogbookPresentationPolicy {
    static func categoryCounts(markers: [SnorkelingMarker]) -> [SnorkelingMarkerCategoryCount] {
        var counts: [SnorkelingMarkerCategory: Int] = [:]
        for marker in markers {
            counts[marker.category, default: 0] += 1
        }
        return SnorkelingMarkerCategory.allCases.compactMap { category in
            guard let count = counts[category], count > 0 else { return nil }
            return SnorkelingMarkerCategoryCount(category: category, count: count)
        }
    }

    static func makeRows(markers: [SnorkelingMarker]) -> [SnorkelingMarkerLogbookRowPresentation] {
        markers
            .sorted { $0.monotonicRelativeTimestampSeconds < $1.monotonicRelativeTimestampSeconds }
            .map(makeRow(marker:))
    }

    static func makeRow(marker: SnorkelingMarker) -> SnorkelingMarkerLogbookRowPresentation {
        SnorkelingMarkerLogbookRowPresentation(
            id: marker.id,
            categoryKey: marker.category.rawValue,
            categoryLabel: categoryLabel(for: marker),
            timestampText: timestampText(for: marker),
            gpsQualityText: gpsQualityText(for: marker),
            distanceFromEntryText: distanceFromEntryText(for: marker),
            note: marker.note
        )
    }

    private static func categoryLabel(for marker: SnorkelingMarker) -> String {
        if marker.category == .custom, let label = marker.customCategoryLabel, !label.isEmpty {
            return label
        }
        switch marker.category {
        case .marineLife: return DIRIOSLocalizer.string("snorkeling.ios.marker.marine_life")
        case .reef: return DIRIOSLocalizer.string("snorkeling.ios.marker.reef")
        case .wreck: return DIRIOSLocalizer.string("snorkeling.ios.marker.wreck")
        case .photoSpot: return DIRIOSLocalizer.string("snorkeling.ios.marker.photo_spot")
        case .buoy: return DIRIOSLocalizer.string("snorkeling.ios.marker.buoy")
        case .custom: return DIRIOSLocalizer.string("snorkeling.ios.marker.custom")
        }
    }

    private static func timestampText(for marker: SnorkelingMarker) -> String {
        if let wallClock = marker.wallClockTimestamp {
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            formatter.dateStyle = .none
            return formatter.string(from: wallClock)
        }
        let total = max(0, Int(marker.monotonicRelativeTimestampSeconds))
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "+%02d:%02d", minutes, seconds)
    }

    private static func gpsQualityText(for marker: SnorkelingMarker) -> String? {
        switch marker.positionQuality {
        case .measured: return DIRIOSLocalizer.string("snorkeling.logbook.markers.gps_measured")
        case .degraded: return DIRIOSLocalizer.string("snorkeling.logbook.markers.gps_stale")
        case .unavailable, .noFix: return DIRIOSLocalizer.string("snorkeling.logbook.markers.gps_unavailable")
        }
    }

    private static func distanceFromEntryText(for marker: SnorkelingMarker) -> String? {
        guard let distance = marker.distanceFromEntryMeters, distance.isFinite, distance >= 0 else { return nil }
        return String(format: DIRIOSLocalizer.string("snorkeling.logbook.markers.distance_from_entry"), Int(distance.rounded()))
    }
}
