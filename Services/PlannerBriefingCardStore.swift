import Foundation

extension Notification.Name {
    static let plannerBriefingPackageDidUpdate = Notification.Name("dirdiving_planner_briefing_package_did_update")
}

@MainActor
final class PlannerBriefingCardStore: ObservableObject {
    @Published private(set) var manifest: PlannerBriefingCardManifest?
    @Published private(set) var imagePaths: [UUID: String] = [:]

    private let fileManager = FileManager.default
    static let stagingDirectoryPrefix = "planner_briefing_stage_"
    static let orphanStagingMaxAge: TimeInterval = 86_400

    var loadedCardCount: Int { imagePaths.count }
    var expectedCardCount: Int { manifest?.cards.count ?? 0 }
    var missingCardCount: Int {
        max(0, expectedCardCount - loadedCardCount)
    }
    var isPackageIncomplete: Bool {
        guard manifest != nil else { return false }
        return missingCardCount > 0
    }

    static func storageDirectory() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent("PlannerBriefing", isDirectory: true)
    }

    init() {
        Self.cleanupOrphanStagingDirectories()
        reload()
    }

    func reload() {
        Self.cleanupOrphanStagingDirectories()
        let directory = Self.storageDirectory()
        let manifestURL = directory.appendingPathComponent(PlannerBriefingTransferSupport.manifestFileName)
        guard let data = try? Data(contentsOf: manifestURL),
              let decoded = try? PlannerBriefingTransferSupport.decodeManifest(data) else {
            manifest = nil
            imagePaths = [:]
            return
        }
        manifest = decoded
        var paths: [UUID: String] = [:]
        for card in decoded.cards {
            let path = directory.appendingPathComponent(card.fileName).path
            if fileManager.fileExists(atPath: path) {
                paths[card.id] = path
            }
        }
        imagePaths = paths
    }

    func deleteBriefing() throws {
        let directory = Self.storageDirectory()
        if fileManager.fileExists(atPath: directory.path) {
            try fileManager.removeItem(at: directory)
        }
        manifest = nil
        imagePaths = [:]
        NotificationCenter.default.post(name: .plannerBriefingPackageDidUpdate, object: nil)
    }

    func importStagedCard(
        packageId: UUID,
        cardId: UUID,
        order: Int,
        expectedHash: String,
        fileName: String,
        sourceURL: URL
    ) throws {
        guard let sanitizedFileName = PlannerBriefingFilenameSanitizer.sanitizedFileName(fileName) else {
            throw PlannerBriefingValidationError.invalidFileType
        }
        guard PlannerBriefingFilenameSanitizer.isConfinedToStorageDirectory(
            sanitizedFileName,
            storageDirectory: Self.stagingDirectory(packageId: packageId)
        ) else {
            throw PlannerBriefingValidationError.invalidFileType
        }
        let data = try Data(contentsOf: sourceURL)
        guard sanitizedFileName.lowercased().hasSuffix(".png") else {
            throw PlannerBriefingValidationError.invalidFileType
        }
        guard data.count <= PlannerBriefingTransferSupport.maxImageBytes else {
            throw PlannerBriefingValidationError.oversizedCard
        }
        guard PlannerBriefingTransferSupport.sha256Hex(data: data) == expectedHash else {
            throw PlannerBriefingValidationError.hashMismatch
        }

        let directory = Self.stagingDirectory(packageId: packageId)
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        let destination = directory.appendingPathComponent(sanitizedFileName)
        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }
        try data.write(to: destination, options: [.atomic, .completeFileProtection])
        _ = cardId
        _ = order
    }

    func importManifest(_ manifest: PlannerBriefingCardManifest, from sourceURL: URL) throws {
        let data = try Data(contentsOf: sourceURL)
        let decoded = try PlannerBriefingTransferSupport.decodeManifest(data)
        guard decoded.id == manifest.id else {
            throw PlannerBriefingValidationError.manifestCardMismatch
        }

        let staging = Self.stagingDirectory(packageId: manifest.id)
        let finalDirectory = Self.storageDirectory()
        let incomingDirectory = Self.incomingDirectory(packageId: manifest.id)

        var totalBytes = data.count
        var sanitizedCards: [(card: PlannerBriefingCardMetadata, stagedURL: URL, sanitizedName: String)] = []
        for card in decoded.cards {
            guard let sanitizedName = PlannerBriefingFilenameSanitizer.sanitizedFileName(card.fileName) else {
                throw PlannerBriefingValidationError.invalidFileType
            }
            let staged = staging.appendingPathComponent(sanitizedName)
            guard fileManager.fileExists(atPath: staged.path) else {
                throw PlannerBriefingValidationError.manifestCardMismatch
            }
            let cardData = try Data(contentsOf: staged)
            totalBytes += cardData.count
            guard PlannerBriefingTransferSupport.sha256Hex(data: cardData) == card.contentHashSHA256 else {
                throw PlannerBriefingValidationError.hashMismatch
            }
            sanitizedCards.append((card, staged, sanitizedName))
        }
        guard totalBytes <= PlannerBriefingTransferSupport.maxPackageBytes else {
            throw PlannerBriefingValidationError.oversizedPackage
        }

        if fileManager.fileExists(atPath: incomingDirectory.path) {
            try fileManager.removeItem(at: incomingDirectory)
        }
        try fileManager.createDirectory(at: incomingDirectory, withIntermediateDirectories: true)

        for entry in sanitizedCards {
            let destination = incomingDirectory.appendingPathComponent(entry.sanitizedName)
            try fileManager.copyItem(at: entry.stagedURL, to: destination)
        }
        try data.write(
            to: incomingDirectory.appendingPathComponent(PlannerBriefingTransferSupport.manifestFileName),
            options: [.atomic, .completeFileProtection]
        )

        if fileManager.fileExists(atPath: finalDirectory.path) {
            _ = try fileManager.replaceItemAt(finalDirectory, withItemAt: incomingDirectory)
        } else {
            try fileManager.createDirectory(
                at: finalDirectory.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try fileManager.moveItem(at: incomingDirectory, to: finalDirectory)
        }
        try? fileManager.removeItem(at: staging)

        reload()
        NotificationCenter.default.post(name: .plannerBriefingPackageDidUpdate, object: nil)
    }

    private static func stagingDirectory(packageId: UUID) -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("\(stagingDirectoryPrefix)\(packageId.uuidString)", isDirectory: true)
    }

    private static func incomingDirectory(packageId: UUID) -> URL {
        storageDirectory().deletingLastPathComponent()
            .appendingPathComponent("PlannerBriefingIncoming_\(packageId.uuidString)", isDirectory: true)
    }

    static func cleanupOrphanStagingDirectories(
        maxAge: TimeInterval = orphanStagingMaxAge,
        now: Date = Date(),
        fileManager: FileManager = .default
    ) {
        let temporaryDirectory = fileManager.temporaryDirectory
        guard let entries = try? fileManager.contentsOfDirectory(
            at: temporaryDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey]
        ) else {
            return
        }
        for url in entries where url.lastPathComponent.hasPrefix(stagingDirectoryPrefix) {
            guard let values = try? url.resourceValues(forKeys: [.contentModificationDateKey]),
                  let modified = values.contentModificationDate else {
                continue
            }
            guard now.timeIntervalSince(modified) > maxAge else { continue }
            try? fileManager.removeItem(at: url)
        }
    }

}
