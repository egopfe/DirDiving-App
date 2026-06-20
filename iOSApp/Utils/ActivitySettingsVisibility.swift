import Foundation

/// Registry of which settings belong to which activity scope (audit Command 14).
enum ActivitySettingsScope: String, Codable, CaseIterable, Sendable {
    case shared
    case diving
    case apnea
    case snorkeling
}

struct ActivitySettingDescriptor: Equatable, Sendable {
    let key: String
    let scope: ActivitySettingsScope
    let visibleInDiving: Bool
    let visibleInApnea: Bool
    let visibleInSnorkeling: Bool
}

enum ActivitySettingsVisibility {
    static let registry: [ActivitySettingDescriptor] = [
        .init(key: "dirdiving_app_language", scope: .shared, visibleInDiving: true, visibleInApnea: true, visibleInSnorkeling: true),
        .init(key: "dirdiving_ios_units", scope: .shared, visibleInDiving: true, visibleInApnea: true, visibleInSnorkeling: true),
        .init(key: "dirdiving.settings.diving.v1", scope: .diving, visibleInDiving: true, visibleInApnea: false, visibleInSnorkeling: false),
        .init(key: "dirdiving_ios_pressure_unit", scope: .diving, visibleInDiving: true, visibleInApnea: false, visibleInSnorkeling: false),
        .init(key: PlannerCNSDescentBottomCheckSettings.thresholdStorageKey, scope: .diving, visibleInDiving: true, visibleInApnea: false, visibleInSnorkeling: false),
        .init(key: "dirdiving_ascent_rate_limits", scope: .diving, visibleInDiving: true, visibleInApnea: false, visibleInSnorkeling: false),
        .init(key: CloudBackupCapability.divingEnabledKey, scope: .diving, visibleInDiving: true, visibleInApnea: false, visibleInSnorkeling: false),
        .init(key: "dirdiving_ios_planner_cns_descent_bottom_check_enabled", scope: .diving, visibleInDiving: true, visibleInApnea: false, visibleInSnorkeling: false),
        .init(key: "planner.ascentSpeedSettings.v1", scope: .diving, visibleInDiving: true, visibleInApnea: false, visibleInSnorkeling: false),
        .init(key: "dirdiving_ios_apnea_settings_v1", scope: .apnea, visibleInDiving: false, visibleInApnea: true, visibleInSnorkeling: false),
        .init(key: "dirdiving.settings.snorkeling.v1", scope: .snorkeling, visibleInDiving: false, visibleInApnea: false, visibleInSnorkeling: true),
    ]

    static func descriptors(for activity: DIRActivityMode) -> [ActivitySettingDescriptor] {
        registry.filter { descriptor in
            switch activity {
            case .diving: return descriptor.visibleInDiving
            case .apnea: return descriptor.visibleInApnea
            case .snorkeling: return descriptor.visibleInSnorkeling
            }
        }
    }

    static func forbiddenIn(activity: DIRActivityMode, scope: ActivitySettingsScope) -> Bool {
        switch activity {
        case .diving: return scope == .apnea || scope == .snorkeling
        case .apnea: return scope == .diving || scope == .snorkeling
        case .snorkeling: return scope == .diving || scope == .apnea
        }
    }

    static func verifyNoCrossScopeLeakage() -> [String] {
        var violations: [String] = []
        for descriptor in registry {
            if descriptor.scope == .diving, descriptor.visibleInApnea || descriptor.visibleInSnorkeling {
                violations.append("\(descriptor.key) diving-only but visible outside Diving")
            }
            if descriptor.scope == .apnea, descriptor.visibleInDiving || descriptor.visibleInSnorkeling {
                violations.append("\(descriptor.key) apnea-only but visible outside Apnea")
            }
            if descriptor.scope == .snorkeling, descriptor.visibleInDiving || descriptor.visibleInApnea {
                violations.append("\(descriptor.key) snorkeling-only but visible outside Snorkeling")
            }
        }
        return violations
    }
}
