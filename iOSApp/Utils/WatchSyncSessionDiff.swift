import Foundation

enum WatchSyncSessionDiff {
    struct FieldDifference: Hashable {
        let field: String
        let localSummary: String
        let incomingSummary: String
    }

    static func significantDifferences(local: DiveSession, incoming: DiveSession) -> [FieldDifference] {
        var differences: [FieldDifference] = []

        if !approximatelyEqual(local.maxDepthMeters, incoming.maxDepthMeters) {
            differences.append(.init(field: "maxDepthMeters", localSummary: formatDepth(local.maxDepthMeters), incomingSummary: formatDepth(incoming.maxDepthMeters)))
        }
        if !approximatelyEqual(local.avgDepthMeters, incoming.avgDepthMeters) {
            differences.append(.init(field: "avgDepthMeters", localSummary: formatDepth(local.avgDepthMeters), incomingSummary: formatDepth(incoming.avgDepthMeters)))
        }
        if abs(local.durationSeconds - incoming.durationSeconds) > 1 {
            differences.append(.init(field: "durationSeconds", localSummary: formatDuration(local.durationSeconds), incomingSummary: formatDuration(incoming.durationSeconds)))
        }
        if local.samples.count != incoming.samples.count {
            differences.append(.init(field: "samples", localSummary: "\(local.samples.count)", incomingSummary: "\(incoming.samples.count)"))
        }
        if local.gasLabel != incoming.gasLabel {
            differences.append(.init(field: "gasLabel", localSummary: local.gasLabel.rawValue, incomingSummary: incoming.gasLabel.rawValue))
        }
        if local.startDate != incoming.startDate {
            differences.append(.init(field: "startDate", localSummary: local.startDate.ISO8601Format(), incomingSummary: incoming.startDate.ISO8601Format()))
        }
        if local.endDate != incoming.endDate {
            differences.append(.init(field: "endDate", localSummary: local.endDate.ISO8601Format(), incomingSummary: incoming.endDate.ISO8601Format()))
        }
        if gpsChanged(local.entryGPS, incoming.entryGPS) {
            differences.append(.init(field: "entryGPS", localSummary: gpsSummary(local.entryGPS), incomingSummary: gpsSummary(incoming.entryGPS)))
        }
        if gpsChanged(local.exitGPS, incoming.exitGPS) {
            differences.append(.init(field: "exitGPS", localSummary: gpsSummary(local.exitGPS), incomingSummary: gpsSummary(incoming.exitGPS)))
        }
        if (local.sacLitersMinute ?? 0) != (incoming.sacLitersMinute ?? 0) {
            differences.append(.init(field: "sacLitersMinute", localSummary: formatOptional(local.sacLitersMinute), incomingSummary: formatOptional(incoming.sacLitersMinute)))
        }

        return differences
    }

    static func hasSignificantDifference(local: DiveSession, incoming: DiveSession) -> Bool {
        !significantDifferences(local: local, incoming: incoming).isEmpty
    }

    static func conflictSummary(local: DiveSession, incoming: DiveSession) -> String {
        let fields = significantDifferences(local: local, incoming: incoming).map(\.field)
        guard !fields.isEmpty else {
            return "\(formatDepth(local.maxDepthMeters)) m / \(formatDuration(local.durationSeconds))"
        }
        return "\(formatDepth(local.maxDepthMeters)) m / \(formatDuration(local.durationSeconds)) · \(fields.joined(separator: ", "))"
    }

    private static func formatDepth(_ value: Double) -> String {
        String(format: "%.1f", value)
    }

    private static func formatDuration(_ seconds: TimeInterval) -> String {
        String(format: "%.0f s", seconds)
    }

    private static func formatOptional(_ value: Double?) -> String {
        guard let value else { return "—" }
        return formatDepth(value)
    }

    private static func approximatelyEqual(_ lhs: Double, _ rhs: Double, tolerance: Double = 0.05) -> Bool {
        abs(lhs - rhs) <= tolerance
    }

    private static func gpsChanged(_ lhs: GPSPoint?, _ rhs: GPSPoint?) -> Bool {
        switch (lhs, rhs) {
        case (nil, nil):
            return false
        case let (left?, right?):
            return abs(left.latitude - right.latitude) > 0.000_01
                || abs(left.longitude - right.longitude) > 0.000_01
        default:
            return true
        }
    }

    private static func gpsSummary(_ point: GPSPoint?) -> String {
        guard let point else { return "—" }
        return String(format: "%.5f, %.5f", point.latitude, point.longitude)
    }
}

enum WatchSyncBoundedIDStore {
    static let maxImportedSessionIDs = 512
    static let maxPushedToWatchSessionIDs = 512

    static func merge(_ id: UUID, into existing: Set<UUID>, maxCount: Int) -> Set<UUID> {
        var ordered = Array(existing)
        ordered.removeAll { $0 == id }
        ordered.append(id)
        if ordered.count > maxCount {
            ordered.removeFirst(ordered.count - maxCount)
        }
        return Set(ordered)
    }

    static func mergeBatch(_ ids: Set<UUID>, into existing: Set<UUID>, maxCount: Int) -> Set<UUID> {
        var ordered = Array(existing)
        for id in ids where !ordered.contains(id) {
            ordered.append(id)
        }
        if ordered.count > maxCount {
            ordered.removeFirst(ordered.count - maxCount)
        }
        return Set(ordered)
    }
}
