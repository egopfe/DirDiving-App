import Foundation

struct SnorkelingMapCoordinate: Equatable, Identifiable, Hashable, Sendable {
    let id: UUID
    var latitude: Double
    var longitude: Double
    var capturedAt: Date?
    var horizontalAccuracyMeters: Double?
    var gpsQuality: SnorkelingGPSQuality
}

struct SnorkelingMapTrackSegment: Equatable, Identifiable, Hashable, Sendable {
    let id: UUID
    var coordinates: [SnorkelingMapCoordinate]
    var hasGapBefore: Bool
}

struct SnorkelingSessionMapModel: Equatable, Hashable, Sendable {
    var segments: [SnorkelingMapTrackSegment]
    var measuredPointCount: Int
    var gapCount: Int
    var sessionStartText: String?
    var sessionEndText: String?
    var accuracyMeters: Double?
    var fixQualityKey: String?
    var isAvailable: Bool
    var unavailableReasonKey: String?
    var showsSparseTrackWarning: Bool

    static let unavailable = SnorkelingSessionMapModel(
        segments: [],
        measuredPointCount: 0,
        gapCount: 0,
        sessionStartText: nil,
        sessionEndText: nil,
        accuracyMeters: nil,
        fixQualityKey: nil,
        isAvailable: false,
        unavailableReasonKey: "snorkeling.ios.map.unavailable",
        showsSparseTrackWarning: false
    )
}

enum SnorkelingSessionMapPresentation {
    static let maxGapSecondsForContinuousSegment: TimeInterval = 30

    static func make(
        from session: SnorkelingSession,
        permission: ApneaMapPermissionState = .authorized,
        calendar: Calendar = .current,
        locale: Locale = .current
    ) -> SnorkelingSessionMapModel {
        if permission == .denied || permission == .restricted {
            return SnorkelingSessionMapModel(
                segments: [],
                measuredPointCount: 0,
                gapCount: 0,
                sessionStartText: nil,
                sessionEndText: nil,
                accuracyMeters: nil,
                fixQualityKey: nil,
                isAvailable: false,
                unavailableReasonKey: "snorkeling.ios.map.permission_denied",
                showsSparseTrackWarning: false
            )
        }

        let measuredPoints = downsampledMeasuredPoints(from: session.trackPoints)
        guard measuredPoints.count >= 2 else {
            if session.warnings.contains(.incompleteGPS) || session.warnings.contains(.sparseTrack) {
                return SnorkelingSessionMapModel(
                    segments: [],
                    measuredPointCount: measuredPoints.count,
                    gapCount: 0,
                    sessionStartText: nil,
                    sessionEndText: nil,
                    accuracyMeters: nil,
                    fixQualityKey: "snorkeling.ios.map.fix.none",
                    isAvailable: false,
                    unavailableReasonKey: "snorkeling.ios.map.gps_unavailable",
                    showsSparseTrackWarning: session.warnings.contains(.sparseTrack)
                )
            }
            return .unavailable
        }

        let segments = buildSegments(from: measuredPoints)
        let gapCount = segments.filter(\.hasGapBefore).count
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        formatter.timeStyle = .short
        formatter.dateStyle = .none

        let sorted = measuredPoints.sorted { $0.monotonicRelativeTimestampSeconds < $1.monotonicRelativeTimestampSeconds }
        let worstAccuracy = measuredPoints.compactMap(\.horizontalAccuracyMeters).max()
        let fixQualityKey = fixQualityKey(for: worstAccuracy)

        return SnorkelingSessionMapModel(
            segments: segments,
            measuredPointCount: measuredPoints.count,
            gapCount: gapCount,
            sessionStartText: sorted.first?.wallClockTimestamp.map { formatter.string(from: $0) }
                ?? formatter.string(from: session.createdAt),
            sessionEndText: sorted.last?.wallClockTimestamp.map { formatter.string(from: $0) },
            accuracyMeters: worstAccuracy,
            fixQualityKey: fixQualityKey,
            isAvailable: true,
            unavailableReasonKey: nil,
            showsSparseTrackWarning: session.warnings.contains(.sparseTrack)
        )
    }

    private static func measuredSurfacePoints(from trackPoints: [SnorkelingTrackPoint]) -> [SnorkelingTrackPoint] {
        SnorkelingDomainSupport.normalizedTrackPoints(trackPoints).filter { point in
            guard !point.isUnderwater,
                  point.gpsQuality.isMeasuredSurfaceFix,
                  let lat = point.latitude,
                  let lon = point.longitude else { return false }
            return SnorkelingDomainSupport.isValidCoordinate(latitude: lat, longitude: lon)
        }
    }

    private static func downsampledMeasuredPoints(from trackPoints: [SnorkelingTrackPoint]) -> [SnorkelingTrackPoint] {
        let signpost = DIRPerformanceSignpost.begin(.snorkelingGPSProcessing)
        defer { signpost.end() }
        let measured = measuredSurfacePoints(from: trackPoints)
        return SnorkelingRoutePresentationSampling.downsampleTrackPointsForPresentation(measured)
    }

    private static func buildSegments(from points: [SnorkelingTrackPoint]) -> [SnorkelingMapTrackSegment] {
        guard !points.isEmpty else { return [] }
        var segments: [SnorkelingMapTrackSegment] = []
        var current: [SnorkelingMapCoordinate] = []
        var hasGapBefore = false
        var previousTimestamp: TimeInterval?

        for point in points {
            if let previousTimestamp,
               point.monotonicRelativeTimestampSeconds - previousTimestamp > maxGapSecondsForContinuousSegment,
               !current.isEmpty {
                segments.append(
                    SnorkelingMapTrackSegment(id: UUID(), coordinates: current, hasGapBefore: hasGapBefore)
                )
                current = []
                hasGapBefore = true
            }

            current.append(
                SnorkelingMapCoordinate(
                    id: point.id,
                    latitude: point.latitude!,
                    longitude: point.longitude!,
                    capturedAt: point.wallClockTimestamp,
                    horizontalAccuracyMeters: point.horizontalAccuracyMeters,
                    gpsQuality: point.gpsQuality
                )
            )
            previousTimestamp = point.monotonicRelativeTimestampSeconds
        }

        if !current.isEmpty {
            segments.append(
                SnorkelingMapTrackSegment(id: UUID(), coordinates: current, hasGapBefore: hasGapBefore)
            )
        }
        return segments
    }

    private static func fixQualityKey(for accuracy: Double?) -> String {
        guard let accuracy else { return "snorkeling.ios.map.fix.fair" }
        if accuracy <= 10 { return "snorkeling.ios.map.fix.good" }
        if accuracy <= 30 { return "snorkeling.ios.map.fix.fair" }
        return "snorkeling.ios.map.fix.poor"
    }
}
