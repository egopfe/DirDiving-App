import Foundation

enum DivingSubsurfaceXMLExportService {
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

    static func makeXML(
        for session: DiveSession,
        privacyOptions: DivingExportPrivacyOptions = DivingExportPrivacyPreferences.currentOptions()
    ) -> String? {
        makeXML(for: [session], privacyOptions: privacyOptions)
    }

    static func makeXML(
        for sessions: [DiveSession],
        privacyOptions: DivingExportPrivacyOptions = DivingExportPrivacyPreferences.currentOptions()
    ) -> String? {
        let exportable = sessions.compactMap { normalizedExportSession($0) }
        guard !exportable.isEmpty else { return nil }
        var lines = ["<?xml version=\"1.0\" encoding=\"UTF-8\"?>", "<divelog program=\"DirDiving\">", "  <dives>"]
        for session in exportable {
            lines.append(contentsOf: diveLines(for: session, privacyOptions: privacyOptions))
        }
        lines.append("  </dives>")
        lines.append("</divelog>")
        return lines.joined(separator: "\n")
    }

    static func writeXML(
        for session: DiveSession,
        privacyOptions: DivingExportPrivacyOptions = DivingExportPrivacyPreferences.currentOptions()
    ) -> Result<URL, ExportError> {
        writeXML(for: [session], privacyOptions: privacyOptions)
    }

    static func writeXML(
        for sessions: [DiveSession],
        privacyOptions: DivingExportPrivacyOptions = DivingExportPrivacyPreferences.currentOptions()
    ) -> Result<URL, ExportError> {
        cleanupTemporaryExports()
        guard let xml = makeXML(for: sessions, privacyOptions: privacyOptions),
              let data = xml.data(using: .utf8) else {
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
        let parts = DivingExportFormatHelpers.formatDateParts(session.startDate)
        let duration = DivingExportFormatHelpers.formatDurationAttribute(session.durationSeconds)
        let maxDepth = DivingExportFormatHelpers.formatDepthMeters(session.maxDepthMeters)
        var attrs = [
            "id=\"\(DivingExportFormatHelpers.xmlEscape(session.id.uuidString))\"",
            "date=\"\(parts.date)\"",
            "time=\"\(parts.time)\"",
            "duration=\"\(duration)\"",
            "maxdepth=\"\(maxDepth)\""
        ]
        if session.isDemoDive {
            attrs.append("notes=\"Demo dive\"")
        }
        var lines = ["    <dive \(attrs.joined(separator: " "))>"]
        if let site = session.siteName, !site.isEmpty {
            lines.append("      <location>\(DivingExportFormatHelpers.xmlEscape(site))</location>")
        }
        if let buddy = session.buddy, !buddy.isEmpty {
            lines.append("      <buddy>\(DivingExportFormatHelpers.xmlEscape(buddy))</buddy>")
        }
        if let notes = session.notes, !notes.isEmpty {
            lines.append("      <notes>\(DivingExportFormatHelpers.xmlEscape(String(notes.prefix(DivingImportLimits.maxImportedNotesLength))))</notes>")
        }
        let model = session.isDemoDive ? "DirDiving Demo" : "DirDiving"
        lines.append("      <divecomputer model=\"\(DivingExportFormatHelpers.xmlEscape(model))\">")
        var previousSeconds = 0
        for sample in samples {
            let elapsed = sample.timestamp.timeIntervalSince(first)
            let seconds = max(previousSeconds, Int(elapsed.rounded()))
            previousSeconds = seconds
            let time = DivingExportFormatHelpers.formatSampleTime(TimeInterval(seconds))
            let depth = DivingExportFormatHelpers.formatDepthMeters(sample.depthMeters)
            var sampleAttrs = "time=\"\(time)\" depth=\"\(depth)\""
            if let temp = sample.temperatureCelsius {
                sampleAttrs += " temp=\"\(DivingExportFormatHelpers.formatTemperatureCelsius(temp))\""
            }
            lines.append("        <sample \(sampleAttrs) />")
        }
        lines.append("      </divecomputer>")
        if DivingExportPrivacyPolicy.canExportLocation(
            options: privacyOptions,
            entry: session.entryGPS,
            exit: session.exitGPS
        ) {
            if let entry = session.entryGPS, privacyOptions.locationPrecision != .omitted {
                let coords = DivingExportPrivacyPolicy.exportCoordinateStrings(
                    point: entry,
                    precision: privacyOptions.locationPrecision
                )
                if !coords.latitude.isEmpty {
                    lines.append("      <geo entry_lat=\"\(coords.latitude)\" entry_lon=\"\(coords.longitude)\" />")
                }
            }
        }
        lines.append("    </dive>")
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
