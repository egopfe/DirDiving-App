import Foundation

enum IOSExportCancellation {
    static func check() throws {
        try Task.checkCancellation()
    }
}

extension IOSApneaSessionExportService {
    static func exportAsync(
        session: ApneaSession,
        format: ApneaExportFormat,
        options: ApneaExportPrivacyOptions
    ) async throws -> URL {
        try await Task.detached(priority: .userInitiated) {
            try IOSExportCancellation.check()
            return try await MainActor.run {
                try export(session: session, format: format, options: options)
            }
        }.value
    }
}

extension IOSSnorkelingSessionExportService {
    static func exportAsync(
        session: SnorkelingSession,
        format: SnorkelingExportFormat,
        options: SnorkelingExportPrivacyOptions
    ) async throws -> URL {
        try await Task.detached(priority: .userInitiated) {
            try IOSExportCancellation.check()
            return try await MainActor.run {
                try export(session: session, format: format, options: options)
            }
        }.value
    }
}

extension SubsurfaceExportService {
    static func makeCSVAsync(
        for session: DiveSession,
        privacyOptions: DivingExportPrivacyOptions = DivingExportPrivacyPreferences.currentOptions()
    ) async throws -> String? {
        try await Task.detached(priority: .userInitiated) {
            try IOSExportCancellation.check()
            return try await MainActor.run {
                makeCSV(for: session, privacyOptions: privacyOptions)
            }
        }.value
    }
}
