import Foundation

enum DemoSnorkelingSessionCatalog {
    private static let rawSessionIDStrings = [
        "S1000001-0001-4001-8001-000000000001",
        "S1000002-0002-4002-8002-000000000002",
        "S1000003-0003-4003-8003-000000000003",
        "S1000004-0004-4004-8004-000000000004",
        "S1000005-0005-4005-8005-000000000005",
        "S1000006-0006-4006-8006-000000000006",
        "S1000007-0007-4007-8007-000000000007"
    ]

    static let sessionIDs: [UUID] = rawSessionIDStrings.enumerated().map { index, rawValue in
        UUID(uuidString: rawValue) ?? fallbackSessionID(index: index)
    }

    static let idSet = Set(sessionIDs)

    static func isDemoSession(id: UUID) -> Bool {
        idSet.contains(id)
    }

    private static func fallbackSessionID(index: Int) -> UUID {
        let suffix = UInt8(max(0, min(index + 1, 255)))
        return UUID(uuid: (0x51, 0, 0, suffix, 0, suffix, 0x40, suffix, 0x80, suffix, 0, 0, 0, 0, 0, suffix))
    }
}

enum FakeSnorkelingLogbookProvider {
    static let minimumEntryCount = 5

    static func entries(referenceDate: Date = Date()) -> [SnorkelingSession] {
        let calendar = Calendar(identifier: .gregorian)
        let baseLatitude = 44.405
        let baseLongitude = 8.946

        let specs: [(daysAgo: Int, title: String, dipCount: Int, distance: Double, duration: TimeInterval)] = [
            (1, "Coastal snorkeling route", 2, 420, 1800),
            (4, "Bay exploration", 1, 280, 1200),
            (8, "Reef waypoint session", 3, 510, 2100),
            (12, "Entry/exit return route", 2, 360, 1500),
            (18, "Training swim with waypoints", 4, 640, 2400),
            (25, "Shallow cove session", 1, 190, 900),
            (32, "Harbor loop demo", 2, 300, 1350)
        ]

        return zip(DemoSnorkelingSessionCatalog.sessionIDs, specs).map { sessionID, spec in
            makeDemoSession(
                id: sessionID,
                spec: spec,
                referenceDate: referenceDate,
                calendar: calendar,
                baseLatitude: baseLatitude,
                baseLongitude: baseLongitude
            )
        }
    }

    private static func makeDemoSession(
        id sessionID: UUID,
        spec: (daysAgo: Int, title: String, dipCount: Int, distance: Double, duration: TimeInterval),
        referenceDate: Date,
        calendar: Calendar,
        baseLatitude: Double,
        baseLongitude: Double
    ) -> SnorkelingSession {
        let createdAt = calendar.date(byAdding: .day, value: -spec.daysAgo, to: referenceDate) ?? referenceDate
        let trackPoints = demoTrack(
            baseLatitude: baseLatitude,
            baseLongitude: baseLongitude,
            distanceMeters: spec.distance,
            createdAt: createdAt
        )
        let dips = (0..<spec.dipCount).map { index in
            let startOffset = TimeInterval(index * 300)
            let endOffset = startOffset + 45
            return SnorkelingDip(
                id: UUID(),
                startedAtMonotonicSeconds: startOffset,
                endedAtMonotonicSeconds: endOffset,
                startedAtWallClock: createdAt.addingTimeInterval(startOffset),
                endedAtWallClock: createdAt.addingTimeInterval(endOffset),
                durationSeconds: 45,
                maxDepthMeters: Double(3 + index),
                averageDepthMeters: Double(2 + index)
            )
        }
        let markers = demoMarkers(for: trackPoints)
        let statistics = SnorkelingSessionStatistics.aggregate(
            from: dips,
            trackPoints: trackPoints,
            markers: markers,
            events: [],
            sessionDurationSeconds: spec.duration
        )
        return SnorkelingSession(
            id: sessionID,
            startMode: .manual,
            state: .completed,
            createdAt: createdAt,
            startedAtMonotonicSeconds: 0,
            endedAtMonotonicSeconds: spec.duration,
            entryPoint: trackPoints.first,
            trackPoints: trackPoints,
            dips: dips,
            markers: markers,
            alarms: [],
            events: [],
            routePlans: [],
            activeRoutePlanID: nil,
            statistics: statistics,
            warnings: [],
            depthSampleSource: "demo-snorkeling-provider",
            depthCapabilityMode: "simulated"
        )
    }

    private static func demoTrack(
        baseLatitude: Double,
        baseLongitude: Double,
        distanceMeters: Double,
        createdAt: Date
    ) -> [SnorkelingTrackPoint] {
        let pointCount = 6
        return (0..<pointCount).map { index in
            let fraction = Double(index) / Double(max(1, pointCount - 1))
            let latOffset = (distanceMeters / 111_000) * fraction * 0.3
            let lonOffset = (distanceMeters / 85_000) * fraction * 0.2
            return SnorkelingTrackPoint(
                monotonicRelativeTimestampSeconds: fraction * 600,
                wallClockTimestamp: createdAt.addingTimeInterval(fraction * 600),
                latitude: baseLatitude + latOffset,
                longitude: baseLongitude + lonOffset,
                horizontalAccuracyMeters: 8,
                speedMetersPerSecond: 0.6,
                gpsQuality: .measured,
                depthMeters: index == 0 || index == pointCount - 1 ? 0 : nil,
                depthQuality: .unavailable,
                isUnderwater: index > 0 && index < pointCount - 1
            )
        }
    }

    private static func demoMarkers(for track: [SnorkelingTrackPoint]) -> [SnorkelingMarker] {
        guard let mid = track.dropFirst().first else { return [] }
        return [
            SnorkelingMarker(
                category: .custom,
                customCategoryLabel: "DEMO waypoint",
                monotonicRelativeTimestampSeconds: mid.monotonicRelativeTimestampSeconds,
                wallClockTimestamp: mid.wallClockTimestamp,
                latitude: mid.latitude,
                longitude: mid.longitude,
                note: "DEMO snorkeling marker"
            )
        ]
    }
}
