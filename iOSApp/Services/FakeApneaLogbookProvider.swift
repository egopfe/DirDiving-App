import Foundation

enum DemoApneaSessionCatalog {
    // Stable demo-apnea-* UUIDs for reviewer/QA sessions (not persisted as real logs).
    private static let rawSessionIDStrings = [
        "A1000001-0001-4001-8001-000000000001",
        "A1000002-0002-4002-8002-000000000002",
        "A1000003-0003-4003-8003-000000000003",
        "A1000004-0004-4004-8004-000000000004",
        "A1000005-0005-4005-8005-000000000005",
        "A1000006-0006-4006-8006-000000000006",
        "A1000007-0007-4007-8007-000000000007"
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
        return UUID(uuid: (0xA1, 0, 0, suffix, 0, suffix, 0x40, suffix, 0x80, suffix, 0, 0, 0, 0, 0, suffix))
    }
}

enum FakeApneaLogbookProvider {
    static let minimumEntryCount = 5

    static func entries(referenceDate: Date = Date()) -> [ApneaSession] {
        let calendar = Calendar(identifier: .gregorian)
        let specs: [(daysAgo: Int, dives: [(duration: TimeInterval, maxDepth: Double, label: String)])] = [
            (2, [(192, 0, "Static hold"), (165, 0, "Static hold")]),
            (5, [(78, 18, "Depth apnea")]),
            (9, [(42, 0, "Dynamic apnea")]),
            (14, [(120, 12, "Training"), (95, 10, "Training"), (88, 9, "Training")]),
            (21, [(180, 0, "Static hold")]),
            (28, [(60, 8, "Recovery session"), (55, 7, "Recovery session")]),
            (35, [(35, 0, "Dynamic apnea")])
        ]

        return zip(DemoApneaSessionCatalog.sessionIDs, specs).map { sessionID, spec in
            let createdAt = calendar.date(byAdding: .day, value: -spec.daysAgo, to: referenceDate) ?? referenceDate
            let dives = spec.dives.enumerated().map { index, diveSpec in
                let startOffset = TimeInterval(index * 600)
                let endOffset = startOffset + diveSpec.duration
                return ApneaDive(
                    id: UUID(uuidString: "A200000\(index + 1)-000\(index + 1)-400\(index + 1)-800\(index + 1)-00000000000\(index + 1)") ?? UUID(),
                    startedAtMonotonicSeconds: startOffset,
                    endedAtMonotonicSeconds: endOffset,
                    startedAtWallClock: createdAt.addingTimeInterval(startOffset),
                    endedAtWallClock: createdAt.addingTimeInterval(endOffset),
                    durationSeconds: diveSpec.duration,
                    maxDepthMeters: diveSpec.maxDepth,
                    averageDepthMeters: diveSpec.maxDepth > 0 ? diveSpec.maxDepth * 0.6 : 0
                )
            }
            let statistics = ApneaSessionStatistics.aggregate(from: dives, sessionDurationSeconds: dives.reduce(0) { $0 + $1.durationSeconds } + 300)
            return ApneaSession(
                id: sessionID,
                startMode: .manual,
                state: .completed,
                createdAt: createdAt,
                startedAtMonotonicSeconds: 0,
                endedAtMonotonicSeconds: statistics.sessionDurationSeconds,
                dives: dives,
                statistics: statistics,
                surfaceGPSPoints: [],
                warnings: [],
                depthSampleSource: "demo-apnea-provider",
                depthCapabilityMode: "simulated"
            )
        }
    }
}
