import Foundation
import SwiftUI

enum BuddyLinkState: String, CaseIterable, Identifiable {
    case online = "ONLINE"
    case lost = "LOST"

    var id: String { rawValue }
}

enum BuddySignalState: String, CaseIterable, Identifiable {
    case near = "VICINO"
    case distant = "DISTANTE"
    case lost = "NO LINK"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .near: return DIRTheme.green
        case .distant: return DIRTheme.yellow
        case .lost: return DIRTheme.red
        }
    }
}

enum BuddyTrustedPairingState: String, CaseIterable, Identifiable {
    case notPaired = "NOT PAIRED"
    case verify = "VERIFY"
    case trusted = "TRUSTED"
    case locked = "LOCKED"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .trusted: return DIRTheme.green
        case .verify: return DIRTheme.yellow
        case .notPaired, .locked: return DIRTheme.red
        }
    }
}

enum BuddyPresetMessage: String, CaseIterable, Identifiable {
    case ok = "OK"
    case ascend = "RISALI"
    case problem = "HO UN PROBLEMA"
    case whereAreYou = "DOVE SEI?"
    case turnBack = "TORNA INDIETRO"
    case lowGas = "LOW GAS"

    var id: String { rawValue }
    var isCritical: Bool { self == .problem || self == .lowGas }
}

struct BuddyExperimentalStatus: Hashable {
    var pairingState: BuddyTrustedPairingState
    var linkState: BuddyLinkState
    var signalState: BuddySignalState
    var buddyName: String
    var confirmationCode: String
    var keyFingerprint: String
    var lastPingSeconds: Int
    var lastRSSI: Int
    var headingDegrees: Int
    var sharedBearingDegrees: Int
    var plausibleDirectionDegrees: Int
    var lastMessage: BuddyPresetMessage

    static let preview = BuddyExperimentalStatus(
        pairingState: .trusted,
        linkState: .online,
        signalState: .near,
        buddyName: "ULTRA WATCH 2",
        confirmationCode: "482-913",
        keyFingerprint: "B7:42:9C:18",
        lastPingSeconds: 15,
        lastRSSI: -58,
        headingDegrees: 126,
        sharedBearingDegrees: 118,
        plausibleDirectionDegrees: 118,
        lastMessage: .ok
    )
}
