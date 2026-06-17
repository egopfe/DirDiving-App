import Foundation
import WatchConnectivity

struct ApneaWatchTransferConnectivityContext: Equatable {
    var isSupported: Bool
    var activationState: WCSessionActivationState
    var isPaired: Bool
    var isWatchAppInstalled: Bool
    var isReachable: Bool
}

@MainActor
final class IOSApneaWatchTransferService: ObservableObject {
    @Published private(set) var lastTransferState: ApneaWatchPlanTransferState = .draft
    @Published private(set) var lastErrorMessage: String?

    func send(plan: ApneaSessionPlan, connectivity: ApneaWatchTransferConnectivityContext) -> Bool {
        lastErrorMessage = nil
        guard ApneaSessionPlanValidator.isValid(plan) else {
            lastTransferState = .failed
            lastErrorMessage = "apnea.ios.planner.validation_failed"
            return false
        }
        guard connectivity.isSupported else {
            lastTransferState = .failed
            lastErrorMessage = "apnea.ios.watch.unsupported"
            return false
        }
        guard connectivity.activationState == .activated else {
            lastTransferState = .queued
            lastErrorMessage = "apnea.ios.watch.not_active"
            return false
        }
        guard connectivity.isPaired, connectivity.isWatchAppInstalled else {
            lastTransferState = .failed
            lastErrorMessage = "apnea.ios.watch.not_paired"
            return false
        }

        var sendingPlan = plan
        sendingPlan.transferState = .sending
        let payload = ApneaSessionPlanTransferPayload(plan: sendingPlan, profileID: plan.profileID, sentAt: Date())
        guard let data = try? JSONEncoder().encode(payload),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            lastTransferState = .failed
            lastErrorMessage = "apnea.ios.watch.encode_failed"
            return false
        }

        let message: [String: Any] = [
            ApneaSessionPlanTransferPayload.messageKey: json
        ]
        let session = WCSession.default

        if connectivity.isReachable {
            lastTransferState = .awaitingAck
            session.sendMessage(message, replyHandler: { [weak self] _ in
                Task { @MainActor in
                    self?.lastTransferState = .delivered
                }
            }, errorHandler: { [weak self] _ in
                Task { @MainActor in
                    self?.queueTransfer(message, session: session)
                }
            })
        } else {
            queueTransfer(message, session: session)
        }
        return true
    }

    private func queueTransfer(_ message: [String: Any], session: WCSession) {
        session.transferUserInfo(message)
        lastTransferState = .queued
    }
}
