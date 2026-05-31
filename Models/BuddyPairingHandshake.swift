import Foundation

struct BuddyPairingHandshake: Codable, Equatable {
    enum Phase: String, Codable {
        case offer
        case response
    }

    static let protocolVersion = 1

    let version: Int
    let deviceId: String
    let publicKey: Data
    let phase: Phase

    init(deviceId: String, publicKey: Data, phase: Phase) {
        version = Self.protocolVersion
        self.deviceId = deviceId
        self.publicKey = publicKey
        self.phase = phase
    }
}
