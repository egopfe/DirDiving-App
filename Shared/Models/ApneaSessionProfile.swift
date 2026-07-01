import Foundation

/// Structured apnea training profile kind (iOS companion configuration).
enum ApneaProfileKind: String, Codable, CaseIterable, Hashable, Sendable, Identifiable {
    case staticApnea
    case dynamicApnea
    case depthConstantWeight
    case trainingIntervals
    case recoverySession
    case freeTraining

    var id: String { rawValue }

    var localizationKey: String {
        switch self {
        case .staticApnea: return "apnea.profile.static"
        case .dynamicApnea: return "apnea.profile.dynamic"
        case .depthConstantWeight: return "apnea.profile.depth_constant_weight"
        case .trainingIntervals: return "apnea.profile.training_intervals"
        case .recoverySession: return "apnea.profile.recovery_session"
        case .freeTraining: return "apnea.profile.free_training"
        }
    }
}

enum ApneaWatchRuntimeLayout: String, Codable, CaseIterable, Hashable, Sendable {
    case staticHoldRecovery
    case dynamicHoldReps
    case depthMetrics
    case freeTrainingCompact
    case trainingTableCoaching
}

/// Configurable apnea session profile for iOS companion (non safety-critical).
struct ApneaSessionProfile: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var kind: ApneaProfileKind
    var displayName: String
    var profileDescription: String
    var targetHoldSeconds: TimeInterval?
    var targetDepthMeters: Double?
    var maxRepetitions: Int?
    var minimumRecoveryPolicy: ApneaRecoveryPolicy
    var watchRuntimeLayout: ApneaWatchRuntimeLayout
    var enabledAlerts: Bool

    init(
        id: UUID = UUID(),
        kind: ApneaProfileKind,
        displayName: String,
        profileDescription: String = "",
        targetHoldSeconds: TimeInterval? = nil,
        targetDepthMeters: Double? = nil,
        maxRepetitions: Int? = nil,
        minimumRecoveryPolicy: ApneaRecoveryPolicy = .default,
        watchRuntimeLayout: ApneaWatchRuntimeLayout? = nil,
        enabledAlerts: Bool = true
    ) {
        self.id = id
        self.kind = kind
        self.displayName = displayName
        self.profileDescription = profileDescription
        self.targetHoldSeconds = targetHoldSeconds
        self.targetDepthMeters = targetDepthMeters
        self.maxRepetitions = maxRepetitions
        self.minimumRecoveryPolicy = minimumRecoveryPolicy
        self.watchRuntimeLayout = watchRuntimeLayout ?? Self.defaultLayout(for: kind)
        self.enabledAlerts = enabledAlerts
    }

    static func defaultLayout(for kind: ApneaProfileKind) -> ApneaWatchRuntimeLayout {
        switch kind {
        case .staticApnea, .recoverySession: return .staticHoldRecovery
        case .dynamicApnea, .trainingIntervals: return .dynamicHoldReps
        case .depthConstantWeight: return .depthMetrics
        case .freeTraining: return .freeTrainingCompact
        }
    }

    static let freeTrainingDefault = ApneaSessionProfile(
        kind: .freeTraining,
        displayName: "Free Training",
        profileDescription: "Minimal constraints for open training and logging.",
        minimumRecoveryPolicy: .default
    )
}

enum ApneaSessionProfileBridge {
    static func profileKind(for discipline: ApneaDiscipline) -> ApneaProfileKind {
        switch discipline {
        case .recreational, .photo: return .freeTraining
        case .depthTraining, .constantWeight, .freeImmersion: return .depthConstantWeight
        case .dynamic: return .dynamicApnea
        case .custom: return .freeTraining
        }
    }

    static func fromCompanion(_ profile: ApneaCompanionProfile) -> ApneaSessionProfile {
        let kind = profile.profileKind ?? profileKind(for: profile.discipline)
        return ApneaSessionProfile(
            id: profile.id,
            kind: kind,
            displayName: profile.displayName,
            targetHoldSeconds: profile.targetDurationSeconds,
            targetDepthMeters: profile.targetDepthMeters,
            maxRepetitions: profile.maxRepetitions,
            minimumRecoveryPolicy: profile.recoveryPolicy,
            enabledAlerts: profile.alarms.contains(where: \.isEnabled)
        )
    }

    static func bundledPresets() -> [ApneaSessionProfile] {
        [
            ApneaSessionProfile(
                kind: .staticApnea,
                displayName: "Static Apnea",
                profileDescription: "Timer hold plus structured recovery.",
                targetHoldSeconds: 120,
                minimumRecoveryPolicy: ApneaRecoveryPolicy(mode: .ratio2to1, minimumSurfaceSeconds: 60, recommendedSurfaceSeconds: 120, phases: [.surfaceRest], allowEarlyDiveWhenIncomplete: false)
            ),
            ApneaSessionProfile(
                kind: .dynamicApnea,
                displayName: "Dynamic Apnea",
                profileDescription: "Hold, repetitions, optional distance notes.",
                targetHoldSeconds: 90,
                maxRepetitions: 8,
                minimumRecoveryPolicy: ApneaRecoveryPolicy(mode: .ratio1to1, minimumSurfaceSeconds: 45, recommendedSurfaceSeconds: 60, phases: [.surfaceRest], allowEarlyDiveWhenIncomplete: false)
            ),
            ApneaSessionProfile(
                kind: .depthConstantWeight,
                displayName: "Depth / Constant Weight",
                profileDescription: "Depth, max depth, hold time, recovery.",
                targetHoldSeconds: 90,
                targetDepthMeters: 20,
                minimumRecoveryPolicy: .default
            ),
            ApneaSessionProfile(
                kind: .trainingIntervals,
                displayName: "Training Intervals",
                profileDescription: "Repeated holds with structured recovery.",
                targetHoldSeconds: 60,
                maxRepetitions: 10,
                minimumRecoveryPolicy: .default
            ),
            ApneaSessionProfile(
                kind: .recoverySession,
                displayName: "Recovery Session",
                profileDescription: "Conservative short holds with longer recovery.",
                targetHoldSeconds: 45,
                minimumRecoveryPolicy: ApneaRecoveryPolicy(mode: .ratio2to1, minimumSurfaceSeconds: 90, recommendedSurfaceSeconds: 120, phases: [.surfaceRest], allowEarlyDiveWhenIncomplete: false)
            ),
            .freeTrainingDefault
        ]
    }
}
