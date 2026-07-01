import Foundation

enum DivingImportUnitParser {
    static func parseDepthMeters(_ raw: String) -> Double? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return nil }
        let numeric = trimmed
            .replacingOccurrences(of: "meters", with: "")
            .replacingOccurrences(of: "meter", with: "")
            .replacingOccurrences(of: "feet", with: "")
            .replacingOccurrences(of: "foot", with: "")
            .replacingOccurrences(of: "ft", with: "")
            .replacingOccurrences(of: "m", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard let value = Double(numeric), value.isFinite else { return nil }
        if trimmed.contains("ft") || trimmed.contains("feet") || trimmed.contains("foot") {
            return value * 0.3048
        }
        return DiveProfileMath.sanitizedDepthMeters(
            value,
            maxDepthMeters: IOSAlgorithmConfiguration.maxImportExportDepthMeters
        )
    }

    static func parseTemperatureCelsius(_ raw: String) -> Double? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return nil }
        let isFahrenheit = trimmed.contains("f")
        let numeric = trimmed
            .replacingOccurrences(of: "°c", with: "")
            .replacingOccurrences(of: "celsius", with: "")
            .replacingOccurrences(of: "°f", with: "")
            .replacingOccurrences(of: "fahrenheit", with: "")
            .replacingOccurrences(of: "c", with: "")
            .replacingOccurrences(of: "f", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard let value = Double(numeric), value.isFinite else { return nil }
        let celsius = isFahrenheit ? (value - 32) * 5 / 9 : value
        return DiveProfileMath.sanitizedTemperatureCelsius(celsius)
    }

    static func parseDurationSeconds(_ raw: String) -> TimeInterval? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return nil }
        if let seconds = Double(trimmed.replacingOccurrences(of: "sec", with: "").replacingOccurrences(of: "s", with: "").trimmingCharacters(in: .whitespaces)), seconds.isFinite {
            if trimmed.contains("min") && !trimmed.contains(":") {
                return seconds * 60
            }
            if !trimmed.contains(":") && !trimmed.contains("min") {
                return seconds
            }
        }
        let withoutUnit = trimmed
            .replacingOccurrences(of: "min", with: "")
            .replacingOccurrences(of: "minutes", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = withoutUnit.split(separator: ":").map(String.init)
        switch parts.count {
        case 2:
            guard let minutes = Double(parts[0]), let seconds = Double(parts[1]) else { return nil }
            return minutes * 60 + seconds
        case 3:
            guard let hours = Double(parts[0]), let minutes = Double(parts[1]), let seconds = Double(parts[2]) else { return nil }
            return hours * 3600 + minutes * 60 + seconds
        default:
            return nil
        }
    }

    static func parseDateTime(date: String?, time: String?) -> Date? {
        let datePart = (date ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let timePart = (time ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if datePart.isEmpty && timePart.isEmpty { return nil }
        let combined = [datePart, timePart].filter { !$0.isEmpty }.joined(separator: " ")
        if let parsed = ISO8601DateFormatter().date(from: combined) { return parsed }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        for format in [
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd",
            "dd/MM/yyyy HH:mm:ss",
            "dd/MM/yyyy"
        ] {
            formatter.dateFormat = format
            if let parsed = formatter.date(from: combined) { return parsed }
        }
        return nil
    }

    static func parseSampleOffsetSeconds(_ raw: String) -> TimeInterval? {
        parseDurationSeconds(raw)
    }
}
