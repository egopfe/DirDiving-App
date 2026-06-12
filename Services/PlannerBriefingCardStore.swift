import Foundation

extension Notification.Name {
    static let plannerBriefingPackageDidUpdate = Notification.Name("dirdiving_planner_briefing_package_did_update")
}

@MainActor
final class PlannerBriefingCardStore: ObservableObject {
    @Published private(set) var manifest: PlannerBriefingCardManifest?
    @Published private(set) var imagePaths: [UUID: String] = [:]

    private let fileManager = FileManager.default

    static func storageDirectory() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent("PlannerBriefing", isDirectory: true)
    }

    init() {
        reload()
    }

    func reload() {
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
        let data = try Data(contentsOf: sourceURL)
        guard fileName.lowercased().hasSuffix(".png") else {
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
        let destination = directory.appendingPathComponent(fileName)
        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }
        try data.write(to: destination, options: [.atomic])
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
        try fileManager.createDirectory(at: finalDirectory, withIntermediateDirectories: true)

        var totalBytes = data.count
        for card in decoded.cards {
            let staged = staging.appendingPathComponent(card.fileName)
            guard fileManager.fileExists(atPath: staged.path) else {
                throw PlannerBriefingValidationError.manifestCardMismatch
            }
            let cardData = try Data(contentsOf: staged)
            totalBytes += cardData.count
            guard PlannerBriefingTransferSupport.sha256Hex(data: cardData) == card.contentHashSHA256 else {
                throw PlannerBriefingValidationError.hashMismatch
            }
        }
        guard totalBytes <= PlannerBriefingTransferSupport.maxPackageBytes else {
            throw PlannerBriefingValidationError.oversizedPackage
        }

        if fileManager.fileExists(atPath: finalDirectory.path) {
            let existing = (try? fileManager.contentsOfDirectory(at: finalDirectory, includingPropertiesForKeys: nil)) ?? []
            for url in existing {
                try? fileManager.removeItem(at: url)
            }
        } else {
            try fileManager.createDirectory(at: finalDirectory, withIntermediateDirectories: true)
        }

        for card in decoded.cards {
            let staged = staging.appendingPathComponent(card.fileName)
            let destination = finalDirectory.appendingPathComponent(card.fileName)
            try fileManager.copyItem(at: staged, to: destination)
        }
        try data.write(to: finalDirectory.appendingPathComponent(PlannerBriefingTransferSupport.manifestFileName), options: [.atomic])
        try? fileManager.removeItem(at: staging)

        reload()
        NotificationCenter.default.post(name: .plannerBriefingPackageDidUpdate, object: nil)
    }

    private static func stagingDirectory(packageId: UUID) -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("planner_briefing_stage_\(packageId.uuidString)", isDirectory: true)
    }

}
