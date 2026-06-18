import Foundation

enum SnorkelingExportFormat: String, CaseIterable, Codable, Hashable, Sendable {
    case pdf
    case csv
    case json
    case gpx
    case chartImage
}

enum SnorkelingExportFileNaming {
    static func sanitizedComponent(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "session" }
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let cleaned = trimmed
            .replacingOccurrences(of: " ", with: "_")
            .unicodeScalars
            .filter { allowed.contains($0) }
            .map { String($0) }
            .joined()
        return cleaned.isEmpty ? "session" : String(cleaned.prefix(48))
    }

    static func filename(
        for session: SnorkelingSession,
        format: SnorkelingExportFormat,
        referenceDate: Date = Date()
    ) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.string(from: session.createdAt)
        let suffix = sanitizedComponent("snorkeling_\(date)_\(session.id.uuidString.prefix(8))")
        switch format {
        case .pdf: return "DIRDiving_Snorkeling_\(suffix).pdf"
        case .csv: return "DIRDiving_Snorkeling_\(suffix).csv"
        case .json: return "DIRDiving_Snorkeling_\(suffix).json"
        case .gpx: return "DIRDiving_Snorkeling_\(suffix).gpx"
        case .chartImage: return "DIRDiving_Snorkeling_Chart_\(suffix).png"
        }
    }
}
