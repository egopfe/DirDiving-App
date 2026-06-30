import Foundation

enum ApneaCompanionProfilePresets {
    private static let recreationalID = UUID(uuidString: "A1000001-0000-4000-8000-000000000001")!
    private static let depthTrainingID = UUID(uuidString: "A1000002-0000-4000-8000-000000000002")!
    private static let constantWeightID = UUID(uuidString: "A1000003-0000-4000-8000-000000000003")!
    private static let freeImmersionID = UUID(uuidString: "A1000004-0000-4000-8000-000000000004")!
    private static let dynamicID = UUID(uuidString: "A1000005-0000-4000-8000-000000000005")!
    private static let photoID = UUID(uuidString: "A1000006-0000-4000-8000-000000000006")!

    static func bundledPresets() -> [ApneaCompanionProfile] {
        [
            recreational(),
            depthTraining(),
            constantWeight(),
            freeImmersion(),
            dynamicTraining(),
            photoSession(),
        ]
    }

    static func recreational() -> ApneaCompanionProfile {
        ApneaCompanionProfile(
            id: recreationalID,
            displayName: "preset.recreational.name",
            discipline: .recreational,
            isPreset: true,
            recoveryPolicy: ApneaRecoveryPolicy(
                mode: .ratio1to1,
                minimumSurfaceSeconds: 60,
                recommendedSurfaceSeconds: 90,
                phases: [.surfaceRest],
                allowEarlyDiveWhenIncomplete: false
            ),
            targetDepthMeters: 15,
            alarms: [depthAlarm(depth: 20, label: "preset.alarm.basic")],
            profileKind: .freeTraining
        )
    }

    static func depthTraining() -> ApneaCompanionProfile {
        ApneaCompanionProfile(
            id: depthTrainingID,
            displayName: "preset.depth_training.name",
            discipline: .depthTraining,
            isPreset: true,
            recoveryPolicy: ApneaRecoveryPolicy(
                mode: .ratio2to1,
                minimumSurfaceSeconds: 90,
                recommendedSurfaceSeconds: 120,
                phases: [.surfaceRest],
                allowEarlyDiveWhenIncomplete: false
            ),
            targetDepthMeters: 25,
            alarms: [depthAlarm(depth: 25, label: "preset.alarm.advanced"), depthAlarm(depth: 30, label: "preset.alarm.depth")],
            profileKind: .depthConstantWeight
        )
    }

    static func constantWeight() -> ApneaCompanionProfile {
        ApneaCompanionProfile(
            id: constantWeightID,
            displayName: "preset.constant_weight.name",
            discipline: .constantWeight,
            isPreset: true,
            recoveryPolicy: .default,
            targetDepthMeters: 20,
            markers: [ApneaDepthMarker(label: "preset.marker.plate", depthMeters: 20)],
            profileKind: .depthConstantWeight
        )
    }

    static func freeImmersion() -> ApneaCompanionProfile {
        ApneaCompanionProfile(
            id: freeImmersionID,
            displayName: "preset.free_immersion.name",
            discipline: .freeImmersion,
            isPreset: true,
            recoveryPolicy: ApneaRecoveryPolicy(
                mode: .ratio2to1,
                minimumSurfaceSeconds: 90,
                recommendedSurfaceSeconds: 120,
                phases: [.surfaceRest],
                allowEarlyDiveWhenIncomplete: false
            ),
            targetDepthMeters: 30,
            profileKind: .depthConstantWeight
        )
    }

    static func dynamicTraining() -> ApneaCompanionProfile {
        ApneaCompanionProfile(
            id: dynamicID,
            displayName: "preset.dynamic.name",
            discipline: .dynamic,
            isPreset: true,
            recoveryPolicy: ApneaRecoveryPolicy(mode: .ratio1to1, minimumSurfaceSeconds: 45, recommendedSurfaceSeconds: 60, phases: [.surfaceRest], allowEarlyDiveWhenIncomplete: false),
            targetDurationSeconds: 90,
            profileKind: .dynamicApnea
        )
    }

    static func photoSession() -> ApneaCompanionProfile {
        ApneaCompanionProfile(
            id: photoID,
            displayName: "preset.photo.name",
            discipline: .photo,
            isPreset: true,
            recoveryPolicy: ApneaRecoveryPolicy(mode: .informationalOnly, minimumSurfaceSeconds: 30, recommendedSurfaceSeconds: 45, phases: [.surfaceRest], allowEarlyDiveWhenIncomplete: true),
            targetDepthMeters: 12,
            profileKind: .freeTraining
        )
    }

    private static func depthAlarm(depth: Double, label: String) -> ApneaAlarm {
        ApneaAlarm(kind: .depth, label: label, thresholdDepthMeters: depth)
    }
}

enum ApneaCompanionProfilePolicy {
    static func mergePresetsWithUserProfiles(_ userProfiles: [ApneaCompanionProfile]) -> [ApneaCompanionProfile] {
        let presets = ApneaCompanionProfilePresets.bundledPresets()
        var byID = Dictionary(uniqueKeysWithValues: presets.map { ($0.id, $0) })
        for profile in userProfiles where !profile.isPreset {
            byID[profile.id] = profile
        }
        return byID.values.sorted {
            if $0.isPreset != $1.isPreset { return $0.isPreset && !$1.isPreset }
            return $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
        }
    }

    static func canDelete(_ profile: ApneaCompanionProfile) -> Bool {
        !profile.isPreset
    }

    static func canEditInPlace(_ profile: ApneaCompanionProfile) -> Bool {
        !profile.isPreset
    }
}
