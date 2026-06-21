import Foundation

/// Unified mockup fixture registry for all 59 canonical references (Command 14).
enum MockupVisualRegressionRegistry {
    struct Entry: Equatable {
        let mockupID: String
        let path: String
        let platform: String
        let activity: String
        let implementationView: String
        let fixtureKey: String?
        let hasExecutableFixture: Bool
        let iosRasterSnapshot: Bool
    }

    static var all: [Entry] {
        var entries: [Entry] = []
        for reference in FullComputerMockupReferenceMatrix.all {
            entries.append(
                Entry(
                    mockupID: reference.id,
                    path: MockupCanonicalPaths.fullComputerPNG(fileName: reference.fileName),
                    platform: reference.platform == .watch ? "watchOS" : "iOS",
                    activity: reference.platform == .ios ? "Diving FC" : "Diving FC",
                    implementationView: reference.implementationReference,
                    fixtureKey: reference.fixtureKey,
                    hasExecutableFixture: reference.hasExecutableFixture,
                    iosRasterSnapshot: reference.platform == .ios
                )
            )
        }
        for reference in ApneaMockupReferenceMatrix.all {
            entries.append(
                Entry(
                    mockupID: reference.id,
                    path: MockupCanonicalPaths.apneaPNG(fileName: reference.fileName, platform: reference.platform),
                    platform: reference.platform == .watch ? "watchOS" : "iOS",
                    activity: "Apnea",
                    implementationView: reference.implementationReference,
                    fixtureKey: reference.presentationStage ?? reference.id,
                    hasExecutableFixture: reference.hasExecutableFixture,
                    iosRasterSnapshot: reference.platform == .ios
                )
            )
        }
        for reference in SnorkelingMockupReferenceMatrix.all {
            entries.append(
                Entry(
                    mockupID: reference.id,
                    path: MockupCanonicalPaths.snorkelingPNG(fileName: reference.fileName),
                    platform: reference.platform == .watch ? "watchOS" : "iOS",
                    activity: "Snorkeling",
                    implementationView: reference.implementationReference,
                    fixtureKey: reference.presentationStage ?? reference.id,
                    hasExecutableFixture: reference.hasExecutableFixture,
                    iosRasterSnapshot: reference.platform == .ios
                )
            )
        }
        entries.append(
            Entry(
                mockupID: "IOS_COMPANION_ACTIVITY_SELECTION",
                path: MockupCanonicalPaths.iosCompanionSelection,
                platform: "iOS",
                activity: "Companion",
                implementationView: "iOSApp/Views/IOSCompanionActivitySelectionView.swift",
                fixtureKey: "companion_activity_selection",
                hasExecutableFixture: true,
                iosRasterSnapshot: true
            )
        )
        return entries
    }

    static var count: Int { all.count }

    static var iosRasterEntries: [Entry] {
        all.filter(\.iosRasterSnapshot)
    }

    static var allFixtureKeys: Set<String> {
        Set(all.compactMap(\.fixtureKey))
    }

    static func resolveFixtureKey(_ key: String) -> Bool {
        if fullComputerLivePanelFixtureKeys.contains(key) {
            return true
        }
        if key == WatchSettingsMockupFixtures.fixtureKey {
            return true
        }
        if key == IOSDivePlanTransferMockupFixtures.fixtureKey {
            return true
        }
        if key == "companion_activity_selection" {
            return true
        }
        if key.hasPrefix("APNEA_IOS_") || key.hasPrefix("SNORKELING_IOS_") {
            return true
        }
        if ApneaMockupReferenceMatrix.all.contains(where: { ($0.presentationStage ?? $0.id) == key }) {
            return true
        }
        if SnorkelingMockupReferenceMatrix.all.contains(where: { ($0.presentationStage ?? $0.id) == key }) {
            return true
        }
        return false
    }

    private static let fullComputerLivePanelFixtureKeys: Set<String> = [
        "activity_selection",
        "diving_mode_selection",
        "fc_predive_valid",
        "fc_predive_invalid",
        "gauge_ttv_off",
        "gauge_ttv_on",
        "ndl_green",
        "ndl_yellow_10",
        "ndl_red_5",
        "deco_approaching",
        "holding_stop",
        "too_shallow",
        "too_deep",
        "ceiling_violation",
        "gas_switch_available",
        "gas_switch_ignored",
        "gas_lost",
        "deco_completed",
        "sensor_degraded",
        "recovery_after_restart",
    ]
}
