import Foundation

enum DivingImportFormatDetector {
    private static let sniffBytes = 16_384

    static func detect(url: URL) -> DivingImportSourceFormat {
        let didAccess = url.startAccessingSecurityScopedResource()
        defer { if didAccess { url.stopAccessingSecurityScopedResource() } }

        if DiveCSVImportBounds.preflightFileSize(at: url) == .fileTooLarge {
            return .unknown
        }

        let ext = url.pathExtension.lowercased()
        guard let prefix = readPrefix(from: url) else { return .unknown }
        let lowered = prefix.lowercased()

        if lowered.contains("<uddf") || lowered.contains("xmlns=\"http://www.uwss.de/uddf") {
            return .uddf
        }
        if lowered.contains("<divelog") || (lowered.contains("<dives") && lowered.contains("<dive")) {
            return .subsurfaceXML
        }
        if ext == "csv" || ext == "txt" || lowered.contains("time_seconds") {
            if lowered.contains("# dirdiving_") {
                return .dirDivingCSV
            }
            if lowered.contains("time_seconds") && lowered.contains("depth_m") {
                return .subsurfaceCSV
            }
        }
        return .unknown
    }

    static func makeSource(from url: URL) -> DivingImportSource {
        let format = detect(url: url)
        let size = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize
        return DivingImportSource(
            url: url,
            fileName: url.lastPathComponent,
            format: format,
            fileSizeBytes: size
        )
    }

    private static func readPrefix(from url: URL) -> String? {
        guard let handle = try? FileHandle(forReadingFrom: url) else { return nil }
        defer { try? handle.close() }
        let data = (try? handle.read(upToCount: sniffBytes)) ?? Data()
        guard !data.contains(0) else { return nil }
        return String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1)
    }
}
