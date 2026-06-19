import Combine
import Foundation
import SwiftUI

/// Cross-activity iOS Companion preferences — single source for language, units, backup scope.
@MainActor
final class SharedIOSSettingsStore: ObservableObject {
    static let namespace = "dirdiving.settings.shared.v1"
    static var testHook_defaults: UserDefaults?

    @Published var language: DIRIOSAppLanguage {
        didSet { persistLanguage() }
    }

    @Published var units: IOSUnitPreference {
        didSet { persistUnits() }
    }

    @Published var pressureUnit: PressureUnit {
        didSet { persistPressureUnit() }
    }

    @Published var cloudBackupEnabled: Bool {
        didSet { CloudBackupSettings.setEnabled(cloudBackupEnabled) }
    }

    private var defaults: UserDefaults { Self.testHook_defaults ?? .standard }

    init() {
        let defaults = Self.testHook_defaults ?? UserDefaults.standard
        language = DIRIOSAppLanguage.fromStorage(defaults.string(forKey: DIRIOSAppLanguage.storageKey) ?? DIRIOSAppLanguage.system.rawValue)
        units = IOSUnitPreference.fromStorage(defaults.string(forKey: IOSUnitPreference.storageKey) ?? IOSUnitPreference.metric.rawValue)
        pressureUnit = IOSPressureUnitPreference.fromStorage(defaults.string(forKey: IOSPressureUnitPreference.storageKey) ?? IOSPressureUnitPreference.storageValue(for: .bar))
        cloudBackupEnabled = CloudBackupSettings.isEnabled
    }

    var locale: Locale { language.locale }

    func syncFromDefaults() {
        let defaults = self.defaults
        language = DIRIOSAppLanguage.fromStorage(defaults.string(forKey: DIRIOSAppLanguage.storageKey) ?? DIRIOSAppLanguage.system.rawValue)
        units = IOSUnitPreference.fromStorage(defaults.string(forKey: IOSUnitPreference.storageKey) ?? IOSUnitPreference.metric.rawValue)
        pressureUnit = IOSPressureUnitPreference.fromStorage(defaults.string(forKey: IOSPressureUnitPreference.storageKey) ?? IOSPressureUnitPreference.storageValue(for: .bar))
        cloudBackupEnabled = CloudBackupSettings.isEnabled
    }

    #if DEBUG
    func resetForTesting() {
        defaults.removeObject(forKey: DIRIOSAppLanguage.storageKey)
        defaults.removeObject(forKey: IOSUnitPreference.storageKey)
        defaults.removeObject(forKey: IOSPressureUnitPreference.storageKey)
        defaults.removeObject(forKey: CloudBackupSettings.enabledKey)
        language = .system
        units = .metric
        pressureUnit = .bar
        cloudBackupEnabled = false
    }
    #endif

    private func persistLanguage() {
        defaults.set(language.rawValue, forKey: DIRIOSAppLanguage.storageKey)
    }

    private func persistUnits() {
        defaults.set(units.rawValue, forKey: IOSUnitPreference.storageKey)
    }

    private func persistPressureUnit() {
        defaults.set(IOSPressureUnitPreference.storageValue(for: pressureUnit), forKey: IOSPressureUnitPreference.storageKey)
    }
}
