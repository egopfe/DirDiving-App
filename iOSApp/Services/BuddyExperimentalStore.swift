import Foundation
import Combine

@MainActor
final class BuddyExperimentalStore: ObservableObject {
    @Published var status = BuddyExperimentalStatus.preview
    @Published var selectedMessage: BuddyPresetMessage = .ok
    @Published var preparedMessages: [BuddyPresetMessage] = BuddyPresetMessage.allCases
    @Published var lastAction = "Pronto per sincronizzazione Watch"

    var canPrepareMessages: Bool {
        status.pairingState == .trusted
    }

    func markPairingForReview() {
        status.pairingState = .verify
        status.linkState = .lost
        status.signalState = .lost
        lastAction = "Verifica codice richiesta su Apple Watch"
    }

    func markTrusted() {
        status.pairingState = .trusted
        status.linkState = .online
        status.signalState = .near
        lastAction = "Buddy trusted importato da Apple Watch"
    }

    func simulateLostLink() {
        status.linkState = .lost
        status.signalState = .lost
        status.lastRSSI = -95
        lastAction = "Buddy link perso nell'ultimo sync"
    }

    func prepare(_ message: BuddyPresetMessage) {
        selectedMessage = message
        status.lastMessage = message
        lastAction = "Messaggio \(message.rawValue) pronto per invio dal Watch"
    }
}
