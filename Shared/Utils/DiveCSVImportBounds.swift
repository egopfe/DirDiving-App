import Foundation

/// Bounded CSV import helpers (SEC-P3-003).
enum DiveCSVImportBounds {
    static let maxBytes = 10 * 1_024 * 1_024
    static let maxRows = 200_000
    static let maxFieldCharacters = 4_096
    static let readChunkSize = 65_536

    enum PreflightResult: Equatable {
        case allowed
        case fileTooLarge
        case unreadable
    }

    static func preflightFileSize(at url: URL) -> PreflightResult {
        guard let values = try? url.resourceValues(forKeys: [.fileSizeKey]),
              let size = values.fileSize else {
            return .unreadable
        }
        if size > maxBytes { return .fileTooLarge }
        return .allowed
    }

    static func readBoundedUTF8(from url: URL) throws -> String {
        switch preflightFileSize(at: url) {
        case .fileTooLarge:
            throw DiveCSVImportBoundsError.fileTooLarge
        case .unreadable:
            throw DiveCSVImportBoundsError.unreadable
        case .allowed:
            break
        }

        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        var collected = Data()
        while true {
            let chunk = try handle.read(upToCount: readChunkSize) ?? Data()
            if chunk.isEmpty { break }
            collected.append(chunk)
            if collected.count > maxBytes {
                throw DiveCSVImportBoundsError.fileTooLarge
            }
        }
        guard let text = String(data: collected, encoding: .utf8) else {
            throw DiveCSVImportBoundsError.unreadable
        }
        if text.contains("\0") {
            throw DiveCSVImportBoundsError.unreadable
        }
        return text
    }

    static func maxLineLength(in contents: String) -> Int {
        contents.split(separator: "\n", omittingEmptySubsequences: false)
            .map(\.count)
            .max() ?? 0
    }

    static func validateRowCount(_ rowCount: Int) -> Bool {
        rowCount <= maxRows
    }
}

enum DiveCSVImportBoundsError: Error, Equatable {
    case fileTooLarge
    case unreadable
    case tooManyRows
}
