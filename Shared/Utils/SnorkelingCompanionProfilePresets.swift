import Foundation

enum SnorkelingCompanionProfilePolicy {
    static func mergePresetsWithUserProfiles(_ userProfiles: [SnorkelingCompanionProfile]) -> [SnorkelingCompanionProfile] {
        let presets = SnorkelingCompanionProfilePresets.bundledPresets()
        var byID = Dictionary(uniqueKeysWithValues: presets.map { ($0.id, $0) })
        for profile in userProfiles where !profile.isPreset {
            byID[profile.id] = profile
        }
        return byID.values.sorted {
            if $0.isPreset != $1.isPreset { return $0.isPreset && !$1.isPreset }
            return $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
        }
    }

    static func canDelete(_ profile: SnorkelingCompanionProfile) -> Bool {
        !profile.isPreset
    }

    static func canEditInPlace(_ profile: SnorkelingCompanionProfile) -> Bool {
        !profile.isPreset
    }
}

enum SnorkelingCompanionProfilePresets {
    private static let recreationalID = UUID(uuidString: "B1000001-0000-4000-8000-000000000001")!
    private static let photographicID = UUID(uuidString: "B1000002-0000-4000-8000-000000000002")!
    private static let reefID = UUID(uuidString: "B1000003-0000-4000-8000-000000000003")!
    private static let coastalID = UUID(uuidString: "B1000004-0000-4000-8000-000000000004")!
    private static let boatID = UUID(uuidString: "B1000005-0000-4000-8000-000000000005")!
    private static let childrenID = UUID(uuidString: "B1000006-0000-4000-8000-000000000006")!
    private static let faunaID = UUID(uuidString: "B1000007-0000-4000-8000-000000000007")!

    static func bundledPresets() -> [SnorkelingCompanionProfile] {
        [
            recreational(),
            photographic(),
            reef(),
            coastal(),
            boat(),
            children(),
            fauna(),
        ]
    }

    static func recreational() -> SnorkelingCompanionProfile {
        SnorkelingCompanionProfile(
            id: recreationalID,
            displayName: "snorkeling.preset.recreational.name",
            discipline: .recreational,
            isPreset: true,
            targetDurationSeconds: 45 * 60,
            maxDistanceMeters: 800,
            maxDepthMeters: 5,
            alarms: [depthAlarm(depth: 5), distanceAlarm(meters: 800)]
        )
    }

    static func photographic() -> SnorkelingCompanionProfile {
        SnorkelingCompanionProfile(
            id: photographicID,
            displayName: "snorkeling.preset.photographic.name",
            discipline: .photographic,
            isPreset: true,
            targetDurationSeconds: 60 * 60,
            maxDistanceMeters: 500,
            maxDepthMeters: 4,
            missionModeEnabled: true,
            alarms: [depthAlarm(depth: 4), durationAlarm(seconds: 60 * 60)]
        )
    }

    static func reef() -> SnorkelingCompanionProfile {
        SnorkelingCompanionProfile(
            id: reefID,
            displayName: "snorkeling.preset.reef.name",
            discipline: .reef,
            isPreset: true,
            targetDurationSeconds: 50 * 60,
            maxDistanceMeters: 600,
            maxDepthMeters: 6,
            alarms: [depthAlarm(depth: 6)]
        )
    }

    static func coastal() -> SnorkelingCompanionProfile {
        SnorkelingCompanionProfile(
            id: coastalID,
            displayName: "snorkeling.preset.coastal.name",
            discipline: .coastal,
            isPreset: true,
            targetDurationSeconds: 40 * 60,
            maxDistanceMeters: 1_000,
            maxDepthMeters: 3,
            alarms: [distanceAlarm(meters: 1_000)]
        )
    }

    static func boat() -> SnorkelingCompanionProfile {
        SnorkelingCompanionProfile(
            id: boatID,
            displayName: "snorkeling.preset.boat.name",
            discipline: .boat,
            isPreset: true,
            targetDurationSeconds: 55 * 60,
            maxDistanceMeters: 1_200,
            maxDepthMeters: 8,
            alarms: [depthAlarm(depth: 8), distanceAlarm(meters: 1_200)]
        )
    }

    static func children() -> SnorkelingCompanionProfile {
        SnorkelingCompanionProfile(
            id: childrenID,
            displayName: "snorkeling.preset.children.name",
            discipline: .children,
            isPreset: true,
            targetDurationSeconds: 25 * 60,
            maxDistanceMeters: 300,
            maxDepthMeters: 2,
            alarms: [depthAlarm(depth: 2), durationAlarm(seconds: 25 * 60)]
        )
    }

    static func fauna() -> SnorkelingCompanionProfile {
        SnorkelingCompanionProfile(
            id: faunaID,
            displayName: "snorkeling.preset.fauna.name",
            discipline: .fauna,
            isPreset: true,
            targetDurationSeconds: 70 * 60,
            maxDistanceMeters: 900,
            maxDepthMeters: 5,
            missionModeEnabled: true,
            alarms: [depthAlarm(depth: 5), durationAlarm(seconds: 70 * 60)]
        )
    }

    private static func depthAlarm(depth: Double) -> SnorkelingAlarm {
        SnorkelingAlarm(
            kind: .maxDepth,
            label: "snorkeling.preset.alarm.depth",
            thresholdDepthMeters: depth
        )
    }

    private static func distanceAlarm(meters: Double) -> SnorkelingAlarm {
        SnorkelingAlarm(
            kind: .maxDistance,
            label: "snorkeling.preset.alarm.distance",
            thresholdDistanceMeters: meters
        )
    }

    private static func durationAlarm(seconds: TimeInterval) -> SnorkelingAlarm {
        SnorkelingAlarm(
            kind: .maxDuration,
            label: "snorkeling.preset.alarm.duration",
            thresholdDurationSeconds: seconds
        )
    }
}
