import Foundation
import Combine
import CoreBluetooth
import CryptoKit
import Security

@MainActor
final class BuddyAssistService: NSObject, ObservableObject {
    enum ConnectionState: String {
        case idle = "IDLE"
        case bluetoothUnavailable = "BLE OFF"
        case scanning = "PAIRING"
        case connected = "CONNECTED"
        case unsupported = "LIMITED"
    }

    enum SecurePairingState: String {
        case unpaired = "NOT PAIRED"
        case scanning = "SCANNING"
        case confirming = "VERIFY"
        case trusted = "TRUSTED"
        case blocked = "LOCKED"
    }

    enum ProximityState: String {
        case near = "NEAR"
        case distant = "DISTANT"
        case disconnected = "NO LINK"
    }

    static let serviceUUID = CBUUID(string: "A1C4D7B0-8C4A-4D74-9C0F-0C38D87D1A01")
    static let messageCharacteristicUUID = CBUUID(string: "E02B806D-3B9C-49A4-A8EF-6A96CB2D56E1")

    @Published private(set) var state: ConnectionState = .idle
    @Published private(set) var proximityState: ProximityState = .disconnected
    @Published private(set) var lastRSSI: Int?
    @Published private(set) var lastPingDate: Date?
    @Published private(set) var lastKnownDirectionDegrees: Double?
    @Published private(set) var sharedBearingDegrees: Double?
    @Published private(set) var plausibleDirectionDegrees: Double?
    @Published private(set) var lastErrorMessage: String?
    @Published private(set) var activeReceivedMessage: BuddyAssistEvent?
    @Published private(set) var events: [BuddyAssistEvent] = []
    @Published private(set) var pairedBuddyIdentifier: String?
    @Published private(set) var pairedBuddyName: String?
    @Published private(set) var securePairingState: SecurePairingState = .unpaired
    @Published private(set) var pairingConfirmationCode: String?
    @Published private(set) var trustedBuddyFingerprint: String?

    private var centralManager: CBCentralManager?
    private var connectedPeripheral: CBPeripheral?
    private var messageCharacteristic: CBCharacteristic?
    private var pingTimer: Timer?
    private let defaults: UserDefaults
    private let secureStore = SecureBuddyStore()
    private let pairedBuddyIdentifierKey = "dirdiving_paired_buddy_identifier"
    private let pairedBuddyNameKey = "dirdiving_paired_buddy_name"
    private let pairingSessionIdKey = "dirdiving_secure_pairing_session_id"
    private let trustedBuddyFingerprintKey = "dirdiving_secure_buddy_fingerprint"
    private let outgoingSequenceKey = "dirdiving_secure_buddy_outgoing_sequence"
    private let allowedClockSkew: TimeInterval = 300
    private var trustedKeyData: Data?
    private var pendingPairing: PendingSecurePairing?
    private var pairingSessionId: String?
    private var outgoingSequence: Int = 0
    private var receivedEnvelopeKeys: Set<String> = []

    var canSend: Bool { state == .connected && messageCharacteristic != nil && isTrusted }
    var isBuddyOnline: Bool { state == .connected }
    var buddyLinkStatus: String { isBuddyOnline ? "ONLINE" : "LOST" }
    var isPaired: Bool { pairedBuddyIdentifier != nil }
    var isTrusted: Bool { pairedBuddyIdentifier != nil && trustedKeyData != nil }
    var canConfirmPairing: Bool { pendingPairing != nil && !isTrusted }
    var pairingStatusText: String { securePairingState.rawValue }
    var pairedBuddyDisplayName: String { pairedBuddyName ?? pendingPairing?.buddyName ?? "DIRDIVING WATCH" }
    var securityStatusText: String {
        switch securePairingState {
        case .trusted:
            return "Authenticated link ready"
        case .confirming:
            return "Verify the same code on both watches"
        case .scanning:
            return "Searching for a DIR DIVING buddy"
        case .blocked:
            return "Pairing disabled during active dive"
        case .unpaired:
            return "Pair before dive to unlock messages"
        }
    }

    var limitationText: String {
        "Direct Watch-to-Watch BLE pairing is experimental. watchOS apps cannot advertise BLE peripheral services, so a reliable production path may need a companion device or external BLE relay."
    }

    var preDivePairingDisclaimer: String {
        "Buddy pairing must be completed before entering the water. Pairing is disabled while a dive is active."
    }

    override init() {
        defaults = .standard
        pairedBuddyIdentifier = defaults.string(forKey: pairedBuddyIdentifierKey)
        pairedBuddyName = defaults.string(forKey: pairedBuddyNameKey)
        pairingSessionId = defaults.string(forKey: pairingSessionIdKey)
        trustedBuddyFingerprint = defaults.string(forKey: trustedBuddyFingerprintKey)
        outgoingSequence = defaults.integer(forKey: outgoingSequenceKey)
        if let pairedBuddyIdentifier {
            trustedKeyData = secureStore.loadBuddyKey(for: pairedBuddyIdentifier)
        }
        super.init()
        securePairingState = trustedKeyData == nil ? .unpaired : .trusted
    }

    func startPairing(isDiveActive: Bool) {
        guard !isDiveActive else {
            lastErrorMessage = preDivePairingDisclaimer
            state = .idle
            securePairingState = .blocked
            return
        }

        if centralManager == nil {
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }

        guard let centralManager else { return }
        startScanningIfReady(centralManager)
    }

    func stopPairing() {
        centralManager?.stopScan()
        if let connectedPeripheral {
            centralManager?.cancelPeripheralConnection(connectedPeripheral)
        }
        connectedPeripheral = nil
        messageCharacteristic = nil
        stopPinging()
        proximityState = .disconnected
        lastRSSI = nil
        state = .idle
        if !isTrusted {
            securePairingState = .unpaired
        }
    }

    func cancelPairingForActiveDive() {
        guard state == .scanning else { return }
        centralManager?.stopScan()
        lastErrorMessage = preDivePairingDisclaimer
        state = .idle
        securePairingState = .blocked
    }

    func forgetBuddy() {
        stopPairing()
        if let pairedBuddyIdentifier {
            secureStore.deleteBuddyKey(for: pairedBuddyIdentifier)
        }
        pairedBuddyIdentifier = nil
        pairedBuddyName = nil
        pendingPairing = nil
        pairingConfirmationCode = nil
        pairingSessionId = nil
        trustedBuddyFingerprint = nil
        trustedKeyData = nil
        outgoingSequence = 0
        securePairingState = .unpaired
        defaults.removeObject(forKey: pairedBuddyIdentifierKey)
        defaults.removeObject(forKey: pairedBuddyNameKey)
        defaults.removeObject(forKey: pairingSessionIdKey)
        defaults.removeObject(forKey: trustedBuddyFingerprintKey)
        defaults.removeObject(forKey: outgoingSequenceKey)
    }

    func confirmSecurePairing() {
        guard let pendingPairing else {
            lastErrorMessage = "No buddy pairing waiting for confirmation."
            return
        }

        do {
            try secureStore.saveBuddyKey(pendingPairing.keyData, for: pendingPairing.peripheralIdentifier)
            pairedBuddyIdentifier = pendingPairing.peripheralIdentifier
            pairedBuddyName = pendingPairing.buddyName
            pairingSessionId = pendingPairing.sessionId
            trustedBuddyFingerprint = pendingPairing.fingerprint
            trustedKeyData = pendingPairing.keyData
            pairingConfirmationCode = nil
            self.pendingPairing = nil
            securePairingState = .trusted
            defaults.set(pendingPairing.peripheralIdentifier, forKey: pairedBuddyIdentifierKey)
            defaults.set(pendingPairing.buddyName, forKey: pairedBuddyNameKey)
            defaults.set(pendingPairing.sessionId, forKey: pairingSessionIdKey)
            defaults.set(pendingPairing.fingerprint, forKey: trustedBuddyFingerprintKey)
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = "Secure buddy key could not be saved."
        }
    }

    func send(_ message: BuddyAssistMessage) {
        guard let connectedPeripheral, let messageCharacteristic else {
            lastErrorMessage = "No buddy connected."
            return
        }

        guard let data = authenticatedPayload(for: message) else {
            return
        }

        connectedPeripheral.writeValue(data, for: messageCharacteristic, type: .withResponse)
        append(message, direction: .sent)
    }

    func updateCompassContext(headingDegrees: Double, bearingDegrees: Double?) {
        lastKnownDirectionDegrees = headingDegrees
        if let bearingDegrees {
            sharedBearingDegrees = bearingDegrees
        }
        plausibleDirectionDegrees = sharedBearingDegrees ?? lastKnownDirectionDegrees
    }

    func clearActiveReceivedMessage() {
        activeReceivedMessage = nil
    }

    private func startScanningIfReady(_ centralManager: CBCentralManager) {
        switch centralManager.state {
        case .poweredOn:
            lastErrorMessage = nil
            state = .scanning
            securePairingState = .scanning
            centralManager.scanForPeripherals(withServices: [Self.serviceUUID], options: nil)
        case .unsupported, .unauthorized:
            state = .unsupported
            lastErrorMessage = limitationText
        case .poweredOff, .resetting, .unknown:
            state = .bluetoothUnavailable
            lastErrorMessage = "Bluetooth is not ready."
        @unknown default:
            state = .bluetoothUnavailable
            lastErrorMessage = "Unknown Bluetooth state."
        }
    }

    private func append(_ message: BuddyAssistMessage, direction: BuddyAssistEvent.Direction) {
        let event = BuddyAssistEvent(message: message, direction: direction, timestamp: Date())
        events.insert(event, at: 0)
        events = Array(events.prefix(8))
        if direction == .received {
            activeReceivedMessage = event
            HapticService.shared.buddyMessageReceived(isCritical: message.isCritical)
        }
    }

    private func establishSecurePairing(from peripheral: CBPeripheral) {
        let identifier = peripheral.identifier.uuidString
        let buddyName = peripheral.name ?? "DIRDIVING WATCH"

        if pairedBuddyIdentifier == identifier,
           let existingKey = secureStore.loadBuddyKey(for: identifier) {
            pairedBuddyName = buddyName
            trustedKeyData = existingKey
            securePairingState = .trusted
            lastErrorMessage = nil
            return
        }

        do {
            let keyData = try SecureBuddyStore.randomKeyData(byteCount: 32)
            let sessionId = UUID().uuidString
            pendingPairing = PendingSecurePairing(
                peripheralIdentifier: identifier,
                buddyName: buddyName,
                keyData: keyData,
                sessionId: sessionId,
                code: Self.confirmationCode(identifier: identifier, keyData: keyData),
                fingerprint: Self.fingerprint(for: keyData)
            )
            pairingConfirmationCode = pendingPairing?.code
            trustedBuddyFingerprint = pendingPairing?.fingerprint
            securePairingState = .confirming
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = "Secure pairing key could not be generated."
            securePairingState = .unpaired
        }
    }

    private func authenticatedPayload(for message: BuddyAssistMessage) -> Data? {
        guard let trustedKeyData, let pairingSessionId else {
            lastErrorMessage = "Secure pairing required before sending buddy messages."
            return nil
        }

        outgoingSequence += 1
        defaults.set(outgoingSequence, forKey: outgoingSequenceKey)
        let envelope = SecureBuddyEnvelope(
            sessionId: pairingSessionId,
            sequence: outgoingSequence,
            timestamp: Date().timeIntervalSince1970,
            message: message.payload,
            mac: ""
        )
        let signedEnvelope = envelope.signed(with: SymmetricKey(data: trustedKeyData))

        do {
            return try JSONEncoder().encode(signedEnvelope)
        } catch {
            lastErrorMessage = "Cannot encode secure buddy message."
            return nil
        }
    }

    private func authenticatedMessage(from data: Data) -> BuddyAssistMessage? {
        guard let trustedKeyData else {
            lastErrorMessage = "Received buddy message before secure pairing."
            return nil
        }

        do {
            let envelope = try JSONDecoder().decode(SecureBuddyEnvelope.self, from: data)
            guard envelope.sessionId == pairingSessionId else {
                lastErrorMessage = "Rejected message from another buddy session."
                return nil
            }

            guard envelope.isAuthentic(with: SymmetricKey(data: trustedKeyData)) else {
                lastErrorMessage = "Rejected unauthenticated buddy message."
                return nil
            }

            guard abs(Date().timeIntervalSince1970 - envelope.timestamp) <= allowedClockSkew else {
                lastErrorMessage = "Rejected stale buddy message."
                return nil
            }

            let replayKey = "\(envelope.sessionId):\(envelope.sequence)"
            guard !receivedEnvelopeKeys.contains(replayKey) else {
                lastErrorMessage = "Rejected repeated buddy message."
                return nil
            }

            receivedEnvelopeKeys.insert(replayKey)
            return BuddyAssistMessage.allCases.first { $0.payload == envelope.message }
        } catch {
            lastErrorMessage = "Rejected non-secure buddy message."
            return nil
        }
    }

    private static func confirmationCode(identifier: String, keyData: Data) -> String {
        var material = Data(identifier.utf8)
        material.append(keyData)
        let digest = SHA256.hash(data: material)
        let value = digest.prefix(4).reduce(UInt32(0)) { ($0 << 8) | UInt32($1) } % 1_000_000
        return String(format: "%03d-%03d", value / 1000, value % 1000)
    }

    private static func fingerprint(for keyData: Data) -> String {
        let digest = SHA256.hash(data: keyData)
        return digest.prefix(4).map { String(format: "%02X", $0) }.joined(separator: ":")
    }

    private func startPinging() {
        stopPinging()
        pingBuddy()
        pingTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.pingBuddy()
            }
        }
    }

    private func stopPinging() {
        pingTimer?.invalidate()
        pingTimer = nil
    }

    private func pingBuddy() {
        guard let connectedPeripheral, state == .connected else {
            proximityState = .disconnected
            return
        }

        lastPingDate = Date()
        connectedPeripheral.readRSSI()
    }

    private func updateProximity(rssi: Int) {
        lastRSSI = rssi
        if rssi >= -70 {
            proximityState = .near
            HapticService.shared.buddyNearPulseIfNeeded()
        } else {
            proximityState = .distant
            HapticService.shared.buddyDistantPulseIfNeeded()
        }
    }
}

extension BuddyAssistService: CBCentralManagerDelegate {
    nonisolated func centralManagerDidUpdateState(_ central: CBCentralManager) {
        Task { @MainActor in
            startScanningIfReady(central)
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        Task { @MainActor in
            updateProximity(rssi: RSSI.intValue)
            connectedPeripheral = peripheral
            connectedPeripheral?.delegate = self
            central.stopScan()
            central.connect(peripheral, options: nil)
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        Task { @MainActor in
            establishSecurePairing(from: peripheral)
            state = .connected
            proximityState = .distant
            startPinging()
            peripheral.discoverServices([Self.serviceUUID])
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        Task { @MainActor in
            state = .scanning
            lastErrorMessage = error?.localizedDescription ?? "Could not connect to buddy."
            central.scanForPeripherals(withServices: [Self.serviceUUID], options: nil)
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        Task { @MainActor in
            connectedPeripheral = nil
            messageCharacteristic = nil
            stopPinging()
            proximityState = .disconnected
            state = .idle
            if !isTrusted {
                securePairingState = .unpaired
            }
            lastErrorMessage = error?.localizedDescription
        }
    }
}

extension BuddyAssistService: CBPeripheralDelegate {
    nonisolated func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        Task { @MainActor in
            if let error {
                lastErrorMessage = error.localizedDescription
                return
            }

            peripheral.services?
                .filter { $0.uuid == Self.serviceUUID }
                .forEach { peripheral.discoverCharacteristics([Self.messageCharacteristicUUID], for: $0) }
        }
    }

    nonisolated func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        Task { @MainActor in
            if let error {
                lastErrorMessage = error.localizedDescription
                return
            }

            messageCharacteristic = service.characteristics?.first { $0.uuid == Self.messageCharacteristicUUID }
            if let messageCharacteristic,
               messageCharacteristic.properties.contains(.notify) || messageCharacteristic.properties.contains(.indicate) {
                peripheral.setNotifyValue(true, for: messageCharacteristic)
            }
        }
    }

    nonisolated func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        Task { @MainActor in
            guard error == nil,
                  characteristic.uuid == Self.messageCharacteristicUUID,
                  let value = characteristic.value,
                  let message = authenticatedMessage(from: value) else { return }

            append(message, direction: .received)
        }
    }

    nonisolated func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        Task { @MainActor in
            if let error {
                lastErrorMessage = error.localizedDescription
                proximityState = .disconnected
                return
            }

            updateProximity(rssi: RSSI.intValue)
        }
    }
}

private struct PendingSecurePairing {
    let peripheralIdentifier: String
    let buddyName: String
    let keyData: Data
    let sessionId: String
    let code: String
    let fingerprint: String
}

private struct SecureBuddyEnvelope: Codable {
    let sessionId: String
    let sequence: Int
    let timestamp: TimeInterval
    let message: String
    let mac: String

    func signed(with key: SymmetricKey) -> SecureBuddyEnvelope {
        let signature = HMAC<SHA256>.authenticationCode(for: Data(canonicalString.utf8), using: key)
        return SecureBuddyEnvelope(
            sessionId: sessionId,
            sequence: sequence,
            timestamp: timestamp,
            message: message,
            mac: Data(signature).base64EncodedString()
        )
    }

    func isAuthentic(with key: SymmetricKey) -> Bool {
        guard let expected = Data(base64Encoded: mac) else { return false }
        let signature = HMAC<SHA256>.authenticationCode(for: Data(canonicalString.utf8), using: key)
        return Data(signature).constantTimeEquals(expected)
    }

    private var canonicalString: String {
        "\(sessionId)|\(sequence)|\(timestamp)|\(message)"
    }
}

private extension Data {
    func constantTimeEquals(_ other: Data) -> Bool {
        guard count == other.count else { return false }
        return zip(self, other).reduce(UInt8(0)) { result, pair in
            result | (pair.0 ^ pair.1)
        } == 0
    }
}
