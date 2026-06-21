import Foundation

/// Synthetic datasets and lightweight row models for shared-activity logbook scalability tests.
enum LogbookScalabilitySupport {
    struct LightweightRow: Identifiable, Hashable, Sendable {
        let id: UUID
        let title: String
        let subtitle: String
        let sortDate: Date
    }

    static func makeSyntheticApneaSessions(count: Int, baseDate: Date = Date(timeIntervalSince1970: 1_700_000_000)) -> [ApneaSession] {
        guard count > 0 else { return [] }
        var sessions: [ApneaSession] = []
        sessions.reserveCapacity(count)
        for index in 0..<count {
            let dive = ApneaDive(
                startedAtMonotonicSeconds: 0,
                durationSeconds: 60 + Double(index % 120),
                maxDepthMeters: Double(index % 20),
                averageDepthMeters: Double(index % 12)
            )
            sessions.append(
                ApneaSession(
                    startMode: .watch,
                    state: .completed,
                    createdAt: baseDate.addingTimeInterval(TimeInterval(-index * 1_800)),
                    dives: [dive]
                )
            )
        }
        return sessions
    }

    static func makeSyntheticSnorkelingSessions(count: Int, baseDate: Date = Date(timeIntervalSince1970: 1_700_000_000)) -> [SnorkelingSession] {
        guard count > 0 else { return [] }
        var sessions: [SnorkelingSession] = []
        sessions.reserveCapacity(count)
        for index in 0..<count {
            sessions.append(
                SnorkelingSession(
                    startMode: .watch,
                    state: .completed,
                    createdAt: baseDate.addingTimeInterval(TimeInterval(-index * 2_400))
                )
            )
        }
        return sessions
    }

    static func encodeApneaSessions(_ sessions: [ApneaSession]) throws -> Data {
        try ApneaLogbookPersistence.exportData(for: sessions)
    }

    static func decodeApneaSessions(from data: Data) throws -> [ApneaSession] {
        try ApneaLogbookPersistence.decodeSessionsResiliently(from: data)
    }

    static func encodeSnorkelingSessions(_ sessions: [SnorkelingSession]) throws -> Data {
        try SnorkelingLogbookPersistence.exportData(for: sessions)
    }

    static func decodeSnorkelingSessions(from data: Data) throws -> [SnorkelingSession] {
        try SnorkelingLogbookPersistence.decodeSessionsResiliently(from: data)
    }

    static func sortedByDate<T>(_ items: [T], date: (T) -> Date) -> [T] {
        items.sorted { date($0) > date($1) }
    }
}

#if os(iOS)
enum IOSDiveLogbookScalabilitySupport {
    static func makeSyntheticSessions(count: Int, baseDate: Date = Date(timeIntervalSince1970: 1_700_000_000)) -> [DiveSession] {
        guard count > 0 else { return [] }
        var sessions: [DiveSession] = []
        sessions.reserveCapacity(count)
        for index in 0..<count {
            let start = baseDate.addingTimeInterval(TimeInterval(-index * 3_600))
            let end = start.addingTimeInterval(2_700)
            sessions.append(
                DiveSession(
                    startDate: start,
                    endDate: end,
                    durationSeconds: 2_700,
                    maxDepthMeters: Double(12 + (index % 30)),
                    avgDepthMeters: Double(8 + (index % 15)),
                    avgWaterTemperatureCelsius: 20,
                    ttv: 1.0,
                    entryGPS: nil,
                    exitGPS: nil,
                    samples: []
                )
            )
        }
        return sessions
    }

    static func encodeSessions(_ sessions: [DiveSession]) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        return try encoder.encode(sessions)
    }

    static func decodeSessions(from data: Data) throws -> [DiveSession] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return try decoder.decode([DiveSession].self, from: data)
    }

    static func lightweightRows(from sessions: [DiveSession]) -> [LogbookScalabilitySupport.LightweightRow] {
        sessions.map { session in
            LogbookScalabilitySupport.LightweightRow(
                id: session.id,
                title: session.startDate.formatted(date: .abbreviated, time: .shortened),
                subtitle: String(format: "%.0fm", session.maxDepthMeters),
                sortDate: session.startDate
            )
        }
    }

    static func filteredSessions(_ sessions: [DiveSession], minimumDepth: Double) -> [DiveSession] {
        sessions.filter { $0.maxDepthMeters >= minimumDepth }
    }
}
#endif

#if os(watchOS)
enum WatchDiveLogbookScalabilitySupport {
    static func makeSyntheticSessions(count: Int, baseDate: Date = Date(timeIntervalSince1970: 1_700_000_000)) -> [DiveSession] {
        guard count > 0 else { return [] }
        var sessions: [DiveSession] = []
        sessions.reserveCapacity(count)
        for index in 0..<count {
            let start = baseDate.addingTimeInterval(TimeInterval(-index * 3_600))
            let end = start.addingTimeInterval(2_700)
            sessions.append(
                DiveSession(
                    startDate: start,
                    endDate: end,
                    durationSeconds: 2_700,
                    maxDepthMeters: Double(12 + (index % 30)),
                    avgDepthMeters: Double(8 + (index % 15)),
                    avgWaterTemperatureCelsius: 20,
                    minWaterTemperatureCelsius: 18,
                    maxWaterTemperatureCelsius: 22,
                    ttv: 1.0,
                    entryGPS: nil,
                    exitGPS: nil,
                    samples: []
                )
            )
        }
        return sessions
    }

    static func encodeSessions(_ sessions: [DiveSession]) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        return try encoder.encode(sessions)
    }

    static func decodeSessions(from data: Data) throws -> [DiveSession] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return try decoder.decode([DiveSession].self, from: data)
    }
}
#endif
