import Foundation
import Combine

@MainActor
final class BuddyExperimentalStore: ObservableObject {
    @Published var status = BuddyExperimentalStatus.preview
    @Published var selectedMessage: BuddyPresetMessage = .ok {
        didSet { saveIfReady() }
    }
    @Published var preparedMessages: [BuddyPresetMessage] = BuddyPresetMessage.allCases
    @Published var lastAction = "Pronto per sincronizzazione Watch"

    private let cloudSync: CloudSyncStore?
    private let key = "dirdiving_ios_buddy_lab_state"
    private var isReady = false

    init(cloudSync: CloudSyncStore? = nil) {
        self.cloudSync = cloudSync
        if let saved = cloudSync?.load(BuddyLabState.self, forKey: key) {
            status = saved.status
            selectedMessage = saved.selectedMessage
            preparedMessages = saved.preparedMessages
            lastAction = saved.lastAction
        }
        isReady = true
        saveIfReady()
    }

    var canPrepareMessages: Bool {
        status.pairingState == .trusted
    }

    func markPairingForReview() {
        status.pairingState = .verify
        status.linkState = .lost
        status.signalState = .lost
        lastAction = "Verifica codice richiesta su Apple Watch"
        saveIfReady()
    }

    func markTrusted() {
        status.pairingState = .trusted
        status.linkState = .online
        status.signalState = .near
        lastAction = "Buddy trusted importato da Apple Watch"
        saveIfReady()
    }

    func simulateLostLink() {
        status.linkState = .lost
        status.signalState = .lost
        status.lastRSSI = -95
        lastAction = "Buddy link perso nell'ultimo sync"
        saveIfReady()
    }

    func prepare(_ message: BuddyPresetMessage) {
        selectedMessage = message
        status.lastMessage = message
        lastAction = "Messaggio \(message.rawValue) pronto per invio dal Watch"
        saveIfReady()
    }

    private func saveIfReady() {
        guard isReady else { return }
        cloudSync?.save(
            BuddyLabState(
                status: status,
                selectedMessage: selectedMessage,
                preparedMessages: preparedMessages,
                lastAction: lastAction
            ),
            forKey: key
        )
    }
}

private struct BuddyLabState: Codable {
    var status: BuddyExperimentalStatus
    var selectedMessage: BuddyPresetMessage
    var preparedMessages: [BuddyPresetMessage]
    var lastAction: String
}
