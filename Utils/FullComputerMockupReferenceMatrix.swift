import Foundation

enum FullComputerMockupPlatform: String, Codable, Hashable {
    case watch
    case ios
}

/// Maps the 25 external FC_UI PNG references to implementation surfaces (Command 12).
/// Raster mockups are **not** embedded in the app; this matrix is the audit index only.
struct FullComputerMockupReference: Identifiable, Equatable, Hashable {
    let id: String
    let fileName: String
    let platform: FullComputerMockupPlatform
    let implementationReference: String
    let fixtureKey: String?
    let hasExecutableFixture: Bool

    init(
        id: String,
        fileName: String,
        platform: FullComputerMockupPlatform,
        implementationReference: String,
        fixtureKey: String? = nil,
        hasExecutableFixture: Bool
    ) {
        self.id = id
        self.fileName = fileName
        self.platform = platform
        self.implementationReference = implementationReference
        self.fixtureKey = fixtureKey
        self.hasExecutableFixture = hasExecutableFixture
    }
}

enum FullComputerMockupReferenceMatrix {
    static let all: [FullComputerMockupReference] = [
        .init(
            id: "FC_UI_01",
            fileName: "FC_UI_01_ACTIVITY_SELECTION.png",
            platform: .watch,
            implementationReference: "Views/ActivitySelectionView.swift",
            fixtureKey: "activity_selection",
            hasExecutableFixture: true
        ),
        .init(
            id: "FC_UI_02",
            fileName: "FC_UI_02_DIVING_MODE_SELECTION.png",
            platform: .watch,
            implementationReference: "Views/DivingModeSelectionView.swift",
            fixtureKey: "diving_mode_selection",
            hasExecutableFixture: true
        ),
        .init(
            id: "FC_UI_03",
            fileName: "FC_UI_03_FULL_COMPUTER_PREDIVE_CONFIRMATION.png",
            platform: .watch,
            implementationReference: "Views/FullComputerPrediveConfirmationView.swift",
            fixtureKey: "fc_predive_valid",
            hasExecutableFixture: true
        ),
        .init(
            id: "FC_UI_04",
            fileName: "FC_UI_04_SETTINGS_ACTIVITY_DEFAULT.png",
            platform: .watch,
            implementationReference: "Views/SettingsView.swift (activity default)",
            fixtureKey: WatchSettingsMockupFixtures.fixtureKey,
            hasExecutableFixture: true
        ),
        .init(
            id: "FC_UI_05",
            fileName: "FC_UI_05_SETTINGS_DIVING_MODE_AND_TTV.png",
            platform: .watch,
            implementationReference: "Views/SettingsView.swift (diving mode + TTV)",
            fixtureKey: "gauge_ttv_off",
            hasExecutableFixture: true
        ),
        .init(
            id: "FC_UI_06",
            fileName: "FC_UI_06_PREDIVE_GAS_CONFIGURATION.png",
            platform: .watch,
            implementationReference: "Views/FullComputerPrediveGasConfigurationView.swift",
            fixtureKey: "fc_predive_invalid",
            hasExecutableFixture: true
        ),
        .init(
            id: "FC_UI_07",
            fileName: "FC_UI_07_IOS_DECO_PLAN_TRANSFER.png",
            platform: .ios,
            implementationReference: "iOSApp/Views/DivePlanPackageTransferView.swift",
            fixtureKey: IOSDivePlanTransferMockupFixtures.fixtureKey,
            hasExecutableFixture: true
        ),
        .init(
            id: "FC_UI_08",
            fileName: "FC_UI_08_DECO_GAS_LIST.png",
            platform: .watch,
            implementationReference: "Views/FullComputerGasSwitchViews.swift (deco gas list)",
            fixtureKey: "gas_lost",
            hasExecutableFixture: true
        ),
        .init(
            id: "FC_UI_09",
            fileName: "FC_UI_09_GAS_SWITCH_AVAILABLE.png",
            platform: .watch,
            implementationReference: "Views/FullComputerGasSwitchViews.swift (switch overlay)",
            fixtureKey: "gas_switch_available",
            hasExecutableFixture: true
        ),
        .init(
            id: "FC_UI_10",
            fileName: "FC_UI_10_GAS_SWITCH_MISSED.png",
            platform: .watch,
            implementationReference: "Views/FullComputerGasSwitchViews.swift (missed switch)",
            fixtureKey: "gas_switch_ignored",
            hasExecutableFixture: true
        ),
        .init(
            id: "FC_UI_11",
            fileName: "FC_UI_11_NDL_GREEN.png",
            platform: .watch,
            implementationReference: "Views/FullComputerLivePanels.swift",
            fixtureKey: "ndl_green",
            hasExecutableFixture: true
        ),
        .init(
            id: "FC_UI_12",
            fileName: "FC_UI_12_NDL_YELLOW_10_MIN.png",
            platform: .watch,
            implementationReference: "Views/FullComputerLivePanels.swift",
            fixtureKey: "ndl_yellow_10",
            hasExecutableFixture: true
        ),
        .init(
            id: "FC_UI_13",
            fileName: "FC_UI_13_NDL_RED_5_MIN.png",
            platform: .watch,
            implementationReference: "Views/FullComputerLivePanels.swift",
            fixtureKey: "ndl_red_5",
            hasExecutableFixture: true
        ),
        .init(
            id: "FC_UI_14",
            fileName: "FC_UI_14_DECO_APPROACH_STOP.png",
            platform: .watch,
            implementationReference: "Views/FullComputerLivePanels.swift",
            fixtureKey: "deco_approaching",
            hasExecutableFixture: true
        ),
        .init(
            id: "FC_UI_15",
            fileName: "FC_UI_15_CEILING_VIOLATION.png",
            platform: .watch,
            implementationReference: "Views/FullComputerLivePanels.swift",
            fixtureKey: "ceiling_violation",
            hasExecutableFixture: true
        ),
        .init(
            id: "FC_UI_16",
            fileName: "FC_UI_16_DECO_HOLD_GREEN.png",
            platform: .watch,
            implementationReference: "Views/FullComputerLivePanels.swift",
            fixtureKey: "holding_stop",
            hasExecutableFixture: true
        ),
        .init(
            id: "FC_UI_17",
            fileName: "FC_UI_17_DECO_HOLD_GREEN_LEFT_ARROW.png",
            platform: .watch,
            implementationReference: "Views/FullComputerLivePanels.swift (hold direction arrow)",
            fixtureKey: "holding_stop",
            hasExecutableFixture: true
        ),
        .init(
            id: "FC_UI_18",
            fileName: "FC_UI_18_TOO_DEEP_ASCEND_TO_STOP.png",
            platform: .watch,
            implementationReference: "Views/FullComputerLivePanels.swift",
            fixtureKey: "too_deep",
            hasExecutableFixture: true
        ),
        .init(
            id: "FC_UI_19",
            fileName: "FC_UI_19_TOO_SHALLOW_DESCEND_TO_STOP.png",
            platform: .watch,
            implementationReference: "Views/FullComputerLivePanels.swift",
            fixtureKey: "too_shallow",
            hasExecutableFixture: true
        ),
        .init(
            id: "FC_UI_20",
            fileName: "FC_UI_20_DECO_COMPLETED.png",
            platform: .watch,
            implementationReference: "Views/FullComputerLivePanels.swift",
            fixtureKey: "deco_completed",
            hasExecutableFixture: true
        ),
        .init(
            id: "FC_UI_21",
            fileName: "FC_UI_21_DECO_COMPLETED_ALT.png",
            platform: .watch,
            implementationReference: "Views/FullComputerLivePanels.swift (deco completed alt layout)",
            fixtureKey: "deco_completed",
            hasExecutableFixture: true
        ),
        .init(
            id: "FC_UI_22",
            fileName: "FC_UI_22_FULL_DECO_SCREEN_REFERENCE.png",
            platform: .watch,
            implementationReference: "Views/DiveLiveView.swift + FullComputerLivePanels.swift",
            fixtureKey: "holding_stop",
            hasExecutableFixture: true
        ),
        .init(
            id: "FC_UI_23",
            fileName: "FC_UI_23_NO_DECO_WITH_CONTROLS.png",
            platform: .watch,
            implementationReference: "Views/DiveLiveView.swift (gauge TTV + FC NDL)",
            fixtureKey: "ndl_green",
            hasExecutableFixture: true
        ),
        .init(
            id: "FC_UI_24",
            fileName: "FC_UI_24_DECO_WITH_STOP_TABLE.png",
            platform: .watch,
            implementationReference: "Views/FullComputerLivePanels.swift (stop table)",
            fixtureKey: "holding_stop",
            hasExecutableFixture: true
        ),
        .init(
            id: "FC_UI_25",
            fileName: "FC_UI_25_DECO_WITH_PROGRESS_PANEL.png",
            platform: .watch,
            implementationReference: "Views/FullComputerLivePanels.swift (deco progress panel)",
            fixtureKey: "holding_stop",
            hasExecutableFixture: true
        ),
    ]

    static var count: Int { all.count }

    static func fixtureKeysReferencedByMockups() -> Set<String> {
        Set(all.compactMap(\.fixtureKey))
    }
}
