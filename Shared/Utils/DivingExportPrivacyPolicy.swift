import Foundation

/// Diving-specific export location precision (SEC-P2-002).
enum DivingExportLocationPrecision: String, Codable, CaseIterable, Hashable, Sendable {
    case omitted
    case approximate
    case precise
}

struct DivingExportPrivacyOptions: Equatable, Hashable, Sendable {
    var locationPrecision: DivingExportLocationPrecision
    var locationSharingAcknowledged: Bool

    static let `default` = DivingExportPrivacyOptions(
        locationPrecision: .omitted,
        locationSharingAcknowledged: false
    )

    static let legacyPreciseMigration = DivingExportPrivacyOptions(
        locationPrecision: .precise,
        locationSharingAcknowledged: true
    )
}

enum DivingExportPrivacyPreferences {
    static let preferenceKey = "dirdiving_diving_export_location_precision_v1"
    static let migrationVersionKey = "dirdiving_diving_export_privacy_migration_v1"
    static let legacyHadExportsKey = "dirdiving_diving_export_had_prior_exports"

    static func currentOptions() -> DivingExportPrivacyOptions {
        migrateLegacyPreferenceIfNeeded()
        guard let raw = UserDefaults.standard.string(forKey: preferenceKey),
              let precision = DivingExportLocationPrecision(rawValue: raw) else {
            return .default
        }
        return DivingExportPrivacyOptions(
            locationPrecision: precision,
            locationSharingAcknowledged: precision != .omitted
        )
    }

    static func persist(_ options: DivingExportPrivacyOptions) {
        UserDefaults.standard.set(options.locationPrecision.rawValue, forKey: preferenceKey)
    }

    static func markExportPerformed() {
        UserDefaults.standard.set(true, forKey: legacyHadExportsKey)
    }

    private static func migrateLegacyPreferenceIfNeeded() {
        let defaults = UserDefaults.standard
        guard defaults.integer(forKey: migrationVersionKey) < 1 else { return }
        if defaults.object(forKey: preferenceKey) == nil,
           defaults.bool(forKey: legacyHadExportsKey) {
            persist(.legacyPreciseMigration)
        }
        defaults.set(1, forKey: migrationVersionKey)
    }
}

enum DivingExportPrivacyPolicy {
    static let approximateDecimalPlaces = 3

    static func requiresLocationConfirmation(entry: GPSPoint?, exit: GPSPoint?) -> Bool {
        entry != nil || exit != nil
    }

    static func canExportLocation(options: DivingExportPrivacyOptions, entry: GPSPoint?, exit: GPSPoint?) -> Bool {
        guard requiresLocationConfirmation(entry: entry, exit: exit) else { return true }
        switch options.locationPrecision {
        case .omitted:
            return false
        case .approximate, .precise:
            return options.locationSharingAcknowledged
        }
    }

    static func exportCoordinateStrings(
        point: GPSPoint?,
        precision: DivingExportLocationPrecision
    ) -> (latitude: String, longitude: String) {
        guard let point else { return ("", "") }
        switch precision {
        case .omitted:
            return ("", "")
        case .approximate:
            let lat = reducedCoordinate(point.latitude)
            let lon = reducedCoordinate(point.longitude)
            return (String(format: "%.\(approximateDecimalPlaces)f", lat),
                    String(format: "%.\(approximateDecimalPlaces)f", lon))
        case .precise:
            return (String(format: "%.6f", point.latitude),
                    String(format: "%.6f", point.longitude))
        }
    }

    static func reducedCoordinate(_ value: Double) -> Double {
        let factor = pow(10.0, Double(approximateDecimalPlaces))
        return (value * factor).rounded() / factor
    }

    static func privacySummaryKey(for options: DivingExportPrivacyOptions) -> String {
        switch options.locationPrecision {
        case .omitted: return "export.privacy.location.omitted"
        case .approximate: return "export.privacy.location.approximate"
        case .precise: return "export.privacy.location.precise"
        }
    }
}
