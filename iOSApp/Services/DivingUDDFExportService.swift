import Foundation

enum DivingUDDFExportService {
    enum ExportError: LocalizedError, Equatable {
        case emptySamples
        case writeFailed(String)

        var errorDescription: String? {
            switch self {
            case .emptySamples:
                return DIRIOSLocalizer.string("diving.export.error.empty_samples")
            case .writeFailed(let reason):
                return DIRIOSLocalizer.formatted("diving.export.error.write_failed", reason)
            }
        }
    }

    static func makeUDDF(
        for session: DiveSession,
        privacyOptions: DivingExportPrivacyOptions = DivingExportPrivacyPreferences.currentOptions()
    ) -> String? {
        makeUDDF(for: [session], privacyOptions: privacyOptions)
    }

    static func makeUDDF(
        for sessions: [DiveSession],
        privacyOptions: DivingExportPrivacyOptions = DivingExportPrivacyPreferences.currentOptions()
    ) -> String? {
        let exportable = sessions.compactMap { normalizedExportSession($0) }
        guard !exportable.isEmpty else { return nil }
        var lines = [
            "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
            "<uddf version=\"3.2.0\">",
            "  <profiledata>",
            "    <repetitiongroup>"
        ]
        for session in exportable {
            lines.append(contentsOf: diveLines(for: session, privacyOptions: privacyOptions))
        }
        lines.append("    </repetitiongroup>")
        lines.append("  </profiledata>")
        lines.append("</uddf>")
        return lines.joined(separator: "\n")
    }

    static func writeUDDF(
        for session: DiveSession,
        privacyOptions: DivingExportPrivacyOptions = DivingExportPrivacyPreferences.currentOptions()
    ) -> Result<URL, ExportError> {
        writeUDDF(for: [session], privacyOptions: privacyOptions)
    }

    static func writeUDDF(
        for sessions: [DiveSession],
        privacyOptions: DivingExportPrivacyOptions = DivingExportPrivacyPreferences.currentOptions()
    ) -> Result<URL, ExportError> {
        cleanupTemporaryExports()
        guard let uddf = makeUDDF(for: sessions, privacyOptions: privacyOptions),
              let data = uddf.data(using: .utf8) else {
            return .failure(.emptySamples)
        }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("DIRDiving_Export_\(UUID().uuidString).xml")
        do {
            DivingExportPrivacyPreferences.markExportPerformed()
            try data.write(to: url, options: [.atomic, .completeFileProtection])
            return .success(url)
        } catch {
            return .failure(.writeFailed(error.localizedDescription))
        }
    }

    private static func normalizedExportSession(_ session: DiveSession) -> DiveSession? {
        guard session.hasDepthProfile, !session.samples.isEmpty else { return nil }
        return try? DiveSessionAlgorithmValidator.normalizedForStorage(
            session,
            allowEmptySamples: false,
            maxDepthMeters: IOSAlgorithmConfiguration.maxImportExportDepthMeters
        )
    }

    private static func diveLines(
        for session: DiveSession,
        privacyOptions: DivingExportPrivacyOptions
    ) -> [String] {
        let samples = DiveProfileMath.sanitizedSamples(
            session.samples,
            maxDepthMeters: IOSAlgorithmConfiguration.maxImportExportDepthMeters
        )
        guard let first = samples.first?.timestamp else { return [] }
        var lines = ["      <dive id=\"\(DivingExportFormatHelpers.xmlEscape(session.id.uuidString))\">"]
        lines.append("        <datetime>\(DivingExportFormatHelpers.formatISO8601(session.startDate))</datetime>")
        if let site = session.siteName, !site.isEmpty {
            lines.append("        <site>\(DivingExportFormatHelpers.xmlEscape(site))</site>")
        }
        if let buddy = session.buddy, !buddy.isEmpty {
            lines.append("        <buddy>\(DivingExportFormatHelpers.xmlEscape(buddy))</buddy>")
        }
        if let notes = session.notes, !notes.isEmpty {
            lines.append("        <notes>\(DivingExportFormatHelpers.xmlEscape(String(notes.prefix(DivingImportLimits.maxImportedNotesLength))))</notes>")
        }
        lines.append("        <informationafterdive>")
        lines.append("          <greatestdepth><depth>\(String(format: "%.1f", session.maxDepthMeters))</depth></greatestdepth>")
        lines.append("          <diveduration>\(Int(session.durationSeconds.rounded()))</diveduration>")
        lines.append("        </informationafterdive>")
        lines.append("        <samples>")
        var previousSeconds = 0
        for sample in samples {
            let elapsed = sample.timestamp.timeIntervalSince(first)
            let seconds = max(previousSeconds, Int(elapsed.rounded()))
            previousSeconds = seconds
            lines.append("          <waypoint>")
            lines.append("            <divetime>\(seconds)</divetime>")
            lines.append("            <depth>\(String(format: "%.1f", sample.depthMeters))</depth>")
            if let temp = sample.temperatureCelsius {
                lines.append("            <temperature>\(String(format: "%.1f", temp))</temperature>")
            }
            lines.append("          </waypoint>")
        }
        lines.append("        </samples>")
        if session.isDemoDive {
            lines.append("        <equipment><model>DirDiving Demo</model></equipment>")
        } else {
            lines.append("        <equipment><model>DirDiving</model></equipment>")
        }
        _ = privacyOptions
        lines.append("      </dive>")
        return lines
    }

    private static func cleanupTemporaryExports() {
        let directory = FileManager.default.temporaryDirectory
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) else { return }
        let expiration = Date().addingTimeInterval(-86_400)
        for file in files where file.lastPathComponent.hasPrefix("DIRDiving_Export_") && file.pathExtension == "xml" {
            let values = try? file.resourceValues(forKeys: [.contentModificationDateKey])
            if (values?.contentModificationDate ?? .distantPast) < expiration {
                try? FileManager.default.removeItem(at: file)
            }
        }
    }
}
