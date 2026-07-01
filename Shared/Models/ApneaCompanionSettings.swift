import Foundation

struct ApneaCompanionSettings: Codable, Hashable, Sendable {
    static let currentSchemaVersion = 2

    var schemaVersion: Int
    var descentDetectionDepthMeters: Double
    var surfaceDetectionDepthMeters: Double
    var minimumRecoverySeconds: TimeInterval
    var useMetricUnits: Bool
    var missionModeEnabled: Bool
    var hapticsEnabled: Bool
    var soundsEnabled: Bool
    var preApneaChecklist: [ApneaChecklistItem]

    static let `default` = ApneaCompanionSettings(
        schemaVersion: currentSchemaVersion,
        descentDetectionDepthMeters: 0.8,
        surfaceDetectionDepthMeters: 0.5,
        minimumRecoverySeconds: 60,
        useMetricUnits: true,
        missionModeEnabled: false,
        hapticsEnabled: true,
        soundsEnabled: true,
        preApneaChecklist: ApneaChecklistCatalog.defaultItems()
    )

    init(
        schemaVersion: Int,
        descentDetectionDepthMeters: Double,
        surfaceDetectionDepthMeters: Double,
        minimumRecoverySeconds: TimeInterval,
        useMetricUnits: Bool,
        missionModeEnabled: Bool,
        hapticsEnabled: Bool,
        soundsEnabled: Bool,
        preApneaChecklist: [ApneaChecklistItem]
    ) {
        self.schemaVersion = schemaVersion
        self.descentDetectionDepthMeters = descentDetectionDepthMeters
        self.surfaceDetectionDepthMeters = surfaceDetectionDepthMeters
        self.minimumRecoverySeconds = minimumRecoverySeconds
        self.useMetricUnits = useMetricUnits
        self.missionModeEnabled = missionModeEnabled
        self.hapticsEnabled = hapticsEnabled
        self.soundsEnabled = soundsEnabled
        self.preApneaChecklist = preApneaChecklist
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decodeIfPresent(Int.self, forKey: .schemaVersion) ?? Self.currentSchemaVersion
        descentDetectionDepthMeters = try container.decodeIfPresent(Double.self, forKey: .descentDetectionDepthMeters) ?? Self.default.descentDetectionDepthMeters
        surfaceDetectionDepthMeters = try container.decodeIfPresent(Double.self, forKey: .surfaceDetectionDepthMeters) ?? Self.default.surfaceDetectionDepthMeters
        minimumRecoverySeconds = try container.decodeIfPresent(TimeInterval.self, forKey: .minimumRecoverySeconds) ?? Self.default.minimumRecoverySeconds
        useMetricUnits = try container.decodeIfPresent(Bool.self, forKey: .useMetricUnits) ?? Self.default.useMetricUnits
        missionModeEnabled = try container.decodeIfPresent(Bool.self, forKey: .missionModeEnabled) ?? Self.default.missionModeEnabled
        hapticsEnabled = try container.decodeIfPresent(Bool.self, forKey: .hapticsEnabled) ?? Self.default.hapticsEnabled
        soundsEnabled = try container.decodeIfPresent(Bool.self, forKey: .soundsEnabled) ?? Self.default.soundsEnabled
        preApneaChecklist = try container.decodeIfPresent([ApneaChecklistItem].self, forKey: .preApneaChecklist)
            ?? ApneaChecklistCatalog.defaultItems()
    }
}

enum ApneaChecklistProgress {
    static func completedCount(in items: [ApneaChecklistItem]) -> Int {
        items.filter(\.isChecked).count
    }

    static func totalCount(in items: [ApneaChecklistItem]) -> Int {
        items.count
    }

    static func isComplete(_ items: [ApneaChecklistItem]) -> Bool {
        !items.isEmpty && items.allSatisfy(\.isChecked)
    }

    static func buddyConfirmed(in items: [ApneaChecklistItem]) -> Bool {
        items.first(where: { $0.localizationKey == "apnea.checklist.buddy" })?.isChecked == true
    }
}
