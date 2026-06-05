import Foundation

enum CompanionPhotoImportSupport {
    static let ackStatusImported = "imported"
    static let ackStatusRejected = "rejected"

    static func uniqueDestinationURL(in directory: URL, preferredFileName: String) -> URL {
        let base = directory.appendingPathComponent(preferredFileName)
        guard FileManager.default.fileExists(atPath: base.path) else { return base }

        let pathExtension = base.pathExtension
        let stem = base.deletingPathExtension().lastPathComponent
        var suffix = 2
        while suffix < 1_000 {
            let candidateName = pathExtension.isEmpty ? "\(stem)-\(suffix)" : "\(stem)-\(suffix).\(pathExtension)"
            let candidate = directory.appendingPathComponent(candidateName)
            if !FileManager.default.fileExists(atPath: candidate.path) {
                return candidate
            }
            suffix += 1
        }
        let fallback = pathExtension.isEmpty
            ? "\(stem)-\(UUID().uuidString)"
            : "\(stem)-\(UUID().uuidString).\(pathExtension)"
        return directory.appendingPathComponent(fallback)
    }

    static func makeAckPayload(
        photoID: String,
        status: String,
        storedFileName: String? = nil,
        errorCode: String? = nil
    ) -> [String: Any] {
        var payload: [String: Any] = [
            "type": WatchSyncKeys.companionPhotoAckType,
            WatchSyncKeys.companionPhotoIDKey: photoID,
            WatchSyncKeys.companionPhotoAckStatusKey: status,
        ]
        if let storedFileName {
            payload[WatchSyncKeys.companionPhotoAckStoredFileNameKey] = storedFileName
        }
        if let errorCode {
            payload[WatchSyncKeys.companionPhotoAckErrorCodeKey] = errorCode
        }
        return payload
    }

    static func errorCode(for error: Error) -> String {
        if let importError = error as? UserImageStore.ImportError {
            switch importError {
            case .invalidFileName:
                return "unsupportedFormat"
            case .invalidFileSize:
                return "tooLarge"
            case .invalidImageContent:
                return "invalidImage"
            }
        }
        if let validationError = error as? WatchCompanionPhotoValidationError {
            switch validationError {
            case .invalidFileName, .undecodableImage:
                return "invalidImage"
            case .invalidFileSize, .dimensionsTooLarge:
                return "tooLarge"
            case .reencodeFailed:
                return "storageFailed"
            }
        }
        return "unknown"
    }
}
