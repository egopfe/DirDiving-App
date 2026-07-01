import Foundation

enum DivingExportFormat: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case csv
    case subsurfaceXML
    case uddf

    var id: String { rawValue }

    var localizationKey: String {
        switch self {
        case .csv: return "diving.export.format.csv"
        case .subsurfaceXML: return "diving.export.format.xml"
        case .uddf: return "diving.export.format.uddf"
        }
    }
}

struct DivingExportCandidate: Identifiable, Hashable, Sendable {
    let id: UUID
    let session: DiveSession
    var isSelected: Bool
    var isExportable: Bool
    var warnings: [DivingExportWarning]
}

enum DivingExportWarning: String, Codable, CaseIterable, Hashable, Sendable {
    case missingSamples
    case demoDive
    case missingTemperature
    case missingGPS
    case privacyCoordinatesReduced
    case csvSingleSessionOnly
}

struct DivingExportReport: Hashable, Sendable {
    let format: DivingExportFormat
    let exportedCount: Int
    let skippedCount: Int
    let warningsCount: Int
    let url: URL?
    let message: String?
}

enum DivingExportError: LocalizedError, Equatable, Sendable {
    case emptySelection
    case emptySamples
    case unsupportedMultiCSV
    case writeFailed(String)
    case invalidSession(String)

    var errorDescription: String? {
        switch self {
        case .emptySelection:
            return DIRIOSLocalizer.string("diving.export.error.empty_selection")
        case .emptySamples:
            return DIRIOSLocalizer.string("diving.export.error.empty_samples")
        case .unsupportedMultiCSV:
            return DIRIOSLocalizer.string("diving.export.error.unsupported_multi_csv")
        case .writeFailed(let detail):
            return DIRIOSLocalizer.formatted("diving.export.error.write_failed", detail)
        case .invalidSession(let detail):
            return detail
        }
    }
}

enum DivingExportFormatHelpers {
    static func xmlEscape(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }

    static func formatDepthMeters(_ meters: Double) -> String {
        String(format: "%.1f m", meters)
    }

    static func formatTemperatureCelsius(_ celsius: Double) -> String {
        String(format: "%.1f C", celsius)
    }

    static func formatDurationAttribute(_ seconds: TimeInterval) -> String {
        let total = max(0, Int(seconds.rounded()))
        let minutes = total / 60
        let remainder = total % 60
        return String(format: "%d:%02d min", minutes, remainder)
    }

    static func formatSampleTime(_ offsetSeconds: TimeInterval) -> String {
        formatDurationAttribute(offsetSeconds)
    }

    static func formatDateParts(_ date: Date) -> (date: String, time: String) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        let datePart = formatter.string(from: date)
        formatter.dateFormat = "HH:mm:ss"
        let timePart = formatter.string(from: date)
        return (datePart, timePart)
    }

    static func formatISO8601(_ date: Date) -> String {
        ISO8601DateFormatter().string(from: date)
    }
}
