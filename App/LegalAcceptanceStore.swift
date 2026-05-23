import Combine
import Foundation

struct LegalAcceptanceRecord {
    let timestamp: Date?
    let appVersion: String
    let appMajorVersion: String
    let deviceType: String
    let languageCode: String
    let legalRevision: String
}

final class LegalAcceptanceStore: ObservableObject {
    static let legalRevision = "2026-05-23"

    @Published private(set) var record: LegalAcceptanceRecord?

    private let defaults: UserDefaults

    private enum Key {
        static let timestamp = "dirdiving_legal_acceptance_timestamp"
        static let appVersion = "dirdiving_legal_acceptance_app_version"
        static let appMajorVersion = "dirdiving_legal_acceptance_major_version"
        static let deviceType = "dirdiving_legal_acceptance_device_type"
        static let languageCode = "dirdiving_legal_acceptance_language_code"
        static let legalRevision = "dirdiving_legal_acceptance_revision"
        static let depthLimitsAcknowledged = "dirdiving_legal_depth_limits_acknowledged"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.record = Self.loadRecord(from: defaults)
    }

    var requiresAcceptance: Bool {
        guard let record else { return true }
        return record.appMajorVersion != Self.currentMajorVersion
            || record.legalRevision != Self.legalRevision
            || !defaults.bool(forKey: Key.depthLimitsAcknowledged)
    }

    var acceptedVersionText: String {
        record?.appVersion ?? String(localized: "Not accepted")
    }

    var acceptedTimestampText: String {
        guard let timestamp = record?.timestamp else {
            return String(localized: "Not accepted")
        }
        return Self.timestampFormatter.string(from: timestamp)
    }

    var acceptedLanguageText: String {
        record?.languageCode.uppercased() ?? String(localized: "Not accepted")
    }

    func accept(languageCode: String, acknowledgedDepthOperatingLimits: Bool) {
        guard acknowledgedDepthOperatingLimits else { return }
        let now = Date()
        defaults.set(now.timeIntervalSince1970, forKey: Key.timestamp)
        defaults.set(Self.currentAppVersion, forKey: Key.appVersion)
        defaults.set(Self.currentMajorVersion, forKey: Key.appMajorVersion)
        defaults.set(Self.deviceType, forKey: Key.deviceType)
        defaults.set(languageCode, forKey: Key.languageCode)
        defaults.set(Self.legalRevision, forKey: Key.legalRevision)
        defaults.set(true, forKey: Key.depthLimitsAcknowledged)
        record = Self.loadRecord(from: defaults)
    }

    func disclaimerText(languageCode: String) -> String {
        let code = languageCode == "en" ? "en" : "it"
        if let url = Bundle.main.url(
            forResource: "LegalDisclaimer",
            withExtension: "txt",
            subdirectory: nil,
            localization: code
        ),
           let text = try? String(contentsOf: url, encoding: .utf8),
           !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return text
        }
        return String(localized: "DIR Diving is NOT a dive computer.")
    }

    private static func loadRecord(from defaults: UserDefaults) -> LegalAcceptanceRecord? {
        guard defaults.object(forKey: Key.timestamp) != nil else { return nil }
        let timestamp = Date(timeIntervalSince1970: defaults.double(forKey: Key.timestamp))
        return LegalAcceptanceRecord(
            timestamp: timestamp,
            appVersion: defaults.string(forKey: Key.appVersion) ?? "",
            appMajorVersion: defaults.string(forKey: Key.appMajorVersion) ?? "",
            deviceType: defaults.string(forKey: Key.deviceType) ?? deviceType,
            languageCode: defaults.string(forKey: Key.languageCode) ?? "it",
            legalRevision: defaults.string(forKey: Key.legalRevision) ?? ""
        )
    }

    private static var currentAppVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    private static var currentMajorVersion: String {
        currentAppVersion.split(separator: ".").first.map(String.init) ?? currentAppVersion
    }

    private static var deviceType: String {
        "Apple Watch"
    }

    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}
