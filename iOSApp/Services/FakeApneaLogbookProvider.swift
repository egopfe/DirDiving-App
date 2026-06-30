import Foundation

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
