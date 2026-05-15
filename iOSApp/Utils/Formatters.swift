import Foundation

enum Formatters {
    private static let clockFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private static let detailFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy - HH:mm"
        return formatter
    }()

    static func clock(_ date: Date) -> String {
        clockFormatter.string(from: date)
    }

    static func detailTitle(_ date: Date) -> String {
        detailFormatter.string(from: date)
    }

    static func time(_ interval: TimeInterval) -> String {
        let total = Int(interval)
        let m = (total % 3600) / 60
        return String(format: "%02d", m)
    }
    static func stopwatch(_ interval: TimeInterval) -> String {
        let total = Int(interval)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return h > 0 ? String(format: "%02d:%02d:%02d", h, m, s) : String(format: "%02d:%02d", m, s)
    }
    static func one(_ value: Double) -> String { String(format: "%.1f", value) }
    static func zero(_ value: Double) -> String { String(format: "%.0f", value) }
}
