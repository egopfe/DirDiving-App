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
            if status.pairingState == .trusted {
                status.pairingState = .verify
                status.linkState = .lost
                status.signalState = .distant
            }
            selectedMessage = saved.selectedMessage
            preparedMessages = saved.preparedMessages
            lastAction = saved.lastAction
        }
        isReady = true
        saveIfReady()
    }

    var canPrepareMessages: Bool {
        false
    }

    func markPairingForReview() {
        status.pairingState = .verify
        status.linkState = .lost
        status.signalState = .lost
        lastAction = "Verifica codice richiesta su Apple Watch"
        saveIfReady()
    }

    func markTrusted() {
        status.pairingState = .verify
        status.linkState = .lost
        status.signalState = .distant
        lastAction = "Mock UI: trusted pairing non implementato"
    }

    func simulateLostLink() {
        status.linkState = .lost
        status.signalState = .lost
        status.lastRSSI = -95
        lastAction = "Buddy link perso nell'ultimo sync"
        saveIfReady()
    }

    func prepare(_ message: BuddyPresetMessage) {
        guard canPrepareMessages else {
            lastAction = "Mock UI: invio messaggi non implementato"
            return
        }
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
