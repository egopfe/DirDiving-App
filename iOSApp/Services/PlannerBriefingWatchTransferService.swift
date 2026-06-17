import Foundation
import WatchConnectivity

enum PlannerBriefingTransferState: Equatable {
    case idle
    case generating
    case sending
    case queued(packageId: UUID)
    case sent(packageId: UUID)
    case failed(message: String)
}

@MainActor
final class PlannerBriefingWatchTransferService: ObservableObject {
    @Published private(set) var state: PlannerBriefingTransferState = .idle

    private var pendingPackageIds: Set<UUID> = []

    func exportAndSend(input: PlannerBriefingImageExportInput) {
        state = .generating
        do {
            let package = try PlannerBriefingImageExportService.export(input: input)
            send(package: package)
        } catch {
            state = .failed(message: DIRIOSLocalizer.string("planner.watch_briefing.failed"))
        }
    }

    func send(package: PlannerBriefingExportPackage) {
        guard WCSession.isSupported() else {
            state = .failed(message: DIRIOSLocalizer.string("planner.watch_briefing.failed"))
            return
        }
        let session = WCSession.default
        guard session.isPaired, session.isWatchAppInstalled else {
            state = .failed(message: DIRIOSLocalizer.string("planner.watch_briefing.failed"))
            return
        }

        state = .sending
        let packageId = package.manifest.id

        do {
            let filesByName = Dictionary(
                uniqueKeysWithValues: package.imageFiles.map { ($0.lastPathComponent, $0) }
            )
            for card in package.manifest.cards.sorted(by: { $0.order < $1.order }) {
                guard let fileURL = filesByName[card.fileName] else {
                    throw PlannerBriefingValidationError.manifestCardMismatch
                }
                let data = try Data(contentsOf: fileURL)
                guard data.count <= PlannerBriefingTransferSupport.maxImageBytes else {
                    throw PlannerBriefingValidationError.oversizedCard
                }
                _ = session.transferFile(
                    fileURL,
                    metadata: PlannerBriefingTransferSupport.makeCardTransferMetadata(
                        packageId: packageId,
                        card: card
                    )
                )
            }

            let manifestURL = try writeManifest(package.manifest)
            _ = session.transferFile(
                manifestURL,
                metadata: PlannerBriefingTransferSupport.makeManifestTransferMetadata(packageId: packageId)
            )

            pendingPackageIds.insert(packageId)
            state = .queued(packageId: packageId)
        } catch {
            state = .failed(message: DIRIOSLocalizer.string("planner.watch_briefing.failed"))
        }
    }

    func handleAck(packageId: UUID, status: String) {
        guard pendingPackageIds.contains(packageId) else { return }
        if status == PlannerBriefingTransferSupport.ackStatusImported {
            pendingPackageIds.remove(packageId)
            state = .sent(packageId: packageId)
        } else {
            pendingPackageIds.remove(packageId)
            state = .failed(message: DIRIOSLocalizer.string("planner.watch_briefing.failed"))
        }
    }

    func resetStatus() {
        if case .failed = state {
            state = .idle
        }
    }

    #if DEBUG
    func testing_simulateQueued(packageId: UUID) {
        pendingPackageIds.insert(packageId)
        state = .queued(packageId: packageId)
    }
    #endif

    private func writeManifest(_ manifest: PlannerBriefingCardManifest) throws -> URL {
        let data = try PlannerBriefingTransferSupport.encodeManifest(manifest)
        guard data.count <= PlannerBriefingTransferSupport.maxImageBytes else {
            throw PlannerBriefingValidationError.oversizedCard
        }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("planner_briefing_manifest_\(manifest.id.uuidString).json")
        try data.write(to: url, options: [.atomic])
        return url
    }
}
