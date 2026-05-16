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
    static let pairingCharacteristicUUID = CBUUID(string: "F3A91C2E-8B4D-4F6A-9E1C-7D2B5A8E4C90")
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
    @Published private(set) var discoveredBuddyName: String?

    private var centralManager: CBCentralManager?
    private var candidatePeripheral: CBPeripheral?
    private var connectedPeripheral: CBPeripheral?
    private var messageCharacteristic: CBCharacteristic?
    private var pairingCharacteristic: CBCharacteristic?
    private var handshakePrivateKey: P256.KeyAgreement.PrivateKey?
    private var handshakeBuddyName: String?
    private let peripheralRelay = BuddyAssistPeripheralService()
    private var pingTimer: Timer?
    private let defaults: UserDefaults
    private let secureStore = SecureBuddyStore()
    private let pairedBuddyIdentifierKey = "dirdiving_paired_buddy_identifier"
    private let pairedBuddyNameKey = "dirdiving_paired_buddy_name"
    private let pairingSessionIdKey = "dirdiving_secure_pairing_session_id"
    private let trustedBuddyFingerprintKey = "dirdiving_secure_buddy_fingerprint"
    private let outgoingSequenceKey = "dirdiving_secure_buddy_outgoing_sequence"
    private let replayEnvelopeKeysKey = "dirdiving_secure_buddy_replay_keys"
    private let localDeviceIdKey = "dirdiving_local_device_id"
    private let allowedClockSkew: TimeInterval = 300
    private var trustedKeyData: Data?
    private var pendingPairing: PendingSecurePairing?
    private var pairingSessionId: String?
    private var outgoingSequence: Int = 0
    private var receivedEnvelopeKeys: Set<String> = []

    var canSend: Bool {
        ExperimentalFeatures.buddyAssistEnabled && state == .connected && messageCharacteristic != nil && isTrusted
    }
    var hasDiscoveredBuddy: Bool { candidatePeripheral != nil }
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
            return "Verify ECDH pairing code on both watches"
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
        let loadedPairedBuddyIdentifier = defaults.string(forKey: pairedBuddyIdentifierKey)
        pairedBuddyIdentifier = loadedPairedBuddyIdentifier
        pairedBuddyName = defaults.string(forKey: pairedBuddyNameKey)
        pairingSessionId = defaults.string(forKey: pairingSessionIdKey)
        trustedBuddyFingerprint = defaults.string(forKey: trustedBuddyFingerprintKey)
        outgoingSequence = defaults.integer(forKey: outgoingSequenceKey)
        receivedEnvelopeKeys = Set(defaults.stringArray(forKey: replayEnvelopeKeysKey) ?? [])
        if let loadedPairedBuddyIdentifier {
            trustedKeyData = secureStore.loadBuddyKey(for: loadedPairedBuddyIdentifier)
        }
        super.init()
        peripheralRelay.delegate = self
        securePairingState = trustedKeyData == nil ? .unpaired : .trusted
    }

    func startPairing(isDiveActive: Bool) {
        guard ExperimentalFeatures.buddyAssistEnabled else {
            lastErrorMessage = "Buddy Assist is disabled until a production relay is available."
            state = .idle
            securePairingState = .unpaired
            return
        }
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
        peripheralRelay.start()
        startScanningIfReady(centralManager)
    }

    func connectToDiscoveredBuddy() {
        guard ExperimentalFeatures.buddyAssistEnabled,
              let peripheral = candidatePeripheral,
              let centralManager else {
            lastErrorMessage = "No buddy discovered yet."
            return
        }
        connectedPeripheral = peripheral
        connectedPeripheral?.delegate = self
        candidatePeripheral = nil
        discoveredBuddyName = nil
        centralManager.connect(peripheral, options: nil)
    }

    func stopPairing() {
        peripheralRelay.stop()
        centralManager?.stopScan()
        if let connectedPeripheral {
            centralManager?.cancelPeripheralConnection(connectedPeripheral)
        }
        candidatePeripheral = nil
        discoveredBuddyName = nil
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
        handshakePrivateKey = nil
        handshakeBuddyName = nil
        outgoingSequence = 0
        securePairingState = .unpaired
        defaults.removeObject(forKey: pairedBuddyIdentifierKey)
        defaults.removeObject(forKey: pairedBuddyNameKey)
        defaults.removeObject(forKey: pairingSessionIdKey)
        defaults.removeObject(forKey: trustedBuddyFingerprintKey)
        defaults.removeObject(forKey: outgoingSequenceKey)
        defaults.removeObject(forKey: replayEnvelopeKeysKey)
        receivedEnvelopeKeys.removeAll()
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
        guard ExperimentalFeatures.buddyAssistEnabled else {
            lastErrorMessage = "Buddy Assist is disabled until a production relay is available."
            return
        }
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

        handshakeBuddyName = buddyName
        securePairingState = .scanning
        lastErrorMessage = nil
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
            persistReplayKeys()
            pruneReplayKeysIfNeeded()
            return BuddyAssistMessage.allCases.first { $0.payload == envelope.message }
        } catch {
            lastErrorMessage = "Rejected non-secure buddy message."
            return nil
        }
    }

    private func localDeviceId() -> String {
        if let existing = defaults.string(forKey: localDeviceIdKey) {
            return existing
        }
        let generated = UUID().uuidString
        defaults.set(generated, forKey: localDeviceIdKey)
        return generated
    }

    private func beginCentralHandshake(with peripheral: CBPeripheral) {
        guard !isTrusted, pendingPairing == nil, let pairingCharacteristic else { return }

        let remotePeripheralId = peripheral.identifier.uuidString
        if handshakePrivateKey == nil {
            handshakePrivateKey = BuddyPairingKeyAgreement.makeEphemeralKeyPair()
        }

        if BuddyPairingKeyAgreement.shouldSendOffer(localDeviceId: localDeviceId(), remoteDeviceId: remotePeripheralId) {
            sendCentralHandshake(
                peripheral: peripheral,
                characteristic: pairingCharacteristic,
                phase: .offer
            )
        }

        if pairingCharacteristic.properties.contains(.notify) || pairingCharacteristic.properties.contains(.indicate) {
            peripheral.setNotifyValue(true, for: pairingCharacteristic)
        }
    }

    private func sendCentralHandshake(
        peripheral: CBPeripheral,
        characteristic: CBCharacteristic,
        phase: BuddyPairingHandshake.Phase
    ) {
        guard let privateKey = handshakePrivateKey else { return }
        let handshake = BuddyPairingHandshake(
            deviceId: localDeviceId(),
            publicKey: privateKey.publicKey.x963Representation,
            phase: phase
        )
        guard let data = try? JSONEncoder().encode(handshake) else { return }
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }

    private func handlePairingHandshake(
        _ data: Data,
        peripheral: CBPeripheral?,
        remotePeripheralId overridePeripheralId: String? = nil
    ) {
        guard pendingPairing == nil else { return }
        guard let handshake = try? JSONDecoder().decode(BuddyPairingHandshake.self, from: data),
              handshake.version == BuddyPairingHandshake.protocolVersion,
              handshake.publicKey.count == 65 else {
            lastErrorMessage = "Invalid buddy pairing handshake."
            return
        }

        if handshakePrivateKey == nil {
            handshakePrivateKey = BuddyPairingKeyAgreement.makeEphemeralKeyPair()
        }

        guard let privateKey = handshakePrivateKey else { return }

        switch handshake.phase {
        case .offer:
            let response = BuddyPairingHandshake(
                deviceId: localDeviceId(),
                publicKey: privateKey.publicKey.x963Representation,
                phase: .response
            )
            if let encoded = try? JSONEncoder().encode(response) {
                peripheralRelay.sendHandshake(encoded)
                if let peripheral, let pairingCharacteristic {
                    peripheral.writeValue(encoded, for: pairingCharacteristic, type: .withResponse)
                }
            }
            finalizePairingHandshake(
                remoteDeviceId: handshake.deviceId,
                remotePeripheralId: overridePeripheralId ?? peripheral?.identifier.uuidString ?? handshake.deviceId,
                buddyName: handshakeBuddyName ?? peripheral?.name ?? "DIRDIVING WATCH",
                privateKey: privateKey,
                peerPublicKey: handshake.publicKey
            )
        case .response:
            finalizePairingHandshake(
                remoteDeviceId: handshake.deviceId,
                remotePeripheralId: overridePeripheralId ?? peripheral?.identifier.uuidString ?? handshake.deviceId,
                buddyName: handshakeBuddyName ?? peripheral?.name ?? "DIRDIVING WATCH",
                privateKey: privateKey,
                peerPublicKey: handshake.publicKey
            )
        }
    }

    private func finalizePairingHandshake(
        remoteDeviceId: String,
        remotePeripheralId: String,
        buddyName: String,
        privateKey: P256.KeyAgreement.PrivateKey,
        peerPublicKey: Data
    ) {
        let sessionId = BuddyPairingKeyAgreement.pairingSessionId(
            localId: localDeviceId(),
            remoteId: remoteDeviceId
        )

        do {
            let keyData = try BuddyPairingKeyAgreement.deriveSessionKey(
                privateKey: privateKey,
                peerPublicKeyData: peerPublicKey,
                sessionId: sessionId
            )
            pendingPairing = PendingSecurePairing(
                peripheralIdentifier: remotePeripheralId,
                buddyName: buddyName,
                keyData: keyData,
                sessionId: sessionId,
                code: BuddyPairingKeyAgreement.confirmationCode(sessionId: sessionId, keyData: keyData),
                fingerprint: BuddyPairingKeyAgreement.fingerprint(for: keyData)
            )
            pairingConfirmationCode = pendingPairing?.code
            trustedBuddyFingerprint = pendingPairing?.fingerprint
            securePairingState = .confirming
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = "Buddy key exchange failed."
        }
    }

    private func pruneReplayKeysIfNeeded() {
        guard receivedEnvelopeKeys.count > 128 else { return }
        receivedEnvelopeKeys = Set(receivedEnvelopeKeys.suffix(64))
        persistReplayKeys()
    }

    private func persistReplayKeys() {
        defaults.set(Array(receivedEnvelopeKeys), forKey: replayEnvelopeKeysKey)
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
            let remoteId = peripheral.identifier.uuidString
            if let pairedBuddyIdentifier {
                guard pairedBuddyIdentifier == remoteId else { return }
                updateProximity(rssi: RSSI.intValue)
                connectedPeripheral = peripheral
                connectedPeripheral?.delegate = self
                central.stopScan()
                central.connect(peripheral, options: nil)
                return
            }

            guard candidatePeripheral == nil || candidatePeripheral?.identifier == peripheral.identifier else { return }
            candidatePeripheral = peripheral
            discoveredBuddyName = peripheral.name ?? "DIRDIVING WATCH"
            updateProximity(rssi: RSSI.intValue)
            central.stopScan()
            state = .scanning
            securePairingState = .scanning
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
                .forEach {
                    peripheral.discoverCharacteristics(
                        [Self.pairingCharacteristicUUID, Self.messageCharacteristicUUID],
                        for: $0
                    )
                }
        }
    }

    nonisolated func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        Task { @MainActor in
            if let error {
                lastErrorMessage = error.localizedDescription
                return
            }

            pairingCharacteristic = service.characteristics?.first { $0.uuid == Self.pairingCharacteristicUUID }
            messageCharacteristic = service.characteristics?.first { $0.uuid == Self.messageCharacteristicUUID }
            if pairingCharacteristic != nil {
                beginCentralHandshake(with: peripheral)
            }
            if let messageCharacteristic,
               messageCharacteristic.properties.contains(.notify) || messageCharacteristic.properties.contains(.indicate) {
                peripheral.setNotifyValue(true, for: messageCharacteristic)
            }
        }
    }

    nonisolated func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        Task { @MainActor in
            guard error == nil, let value = characteristic.value else { return }

            if characteristic.uuid == Self.pairingCharacteristicUUID {
                handlePairingHandshake(value, peripheral: peripheral)
                return
            }

            guard characteristic.uuid == Self.messageCharacteristicUUID,
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

extension BuddyAssistService: BuddyAssistPeripheralDelegate {
    func peripheralServiceDidBecomeReady(_ service: BuddyAssistPeripheralService) {
        _ = service
    }

    func peripheralService(_ service: BuddyAssistPeripheralService, didReceiveHandshake data: Data, from central: CBCentral) {
        _ = service
        handlePairingHandshake(
            data,
            peripheral: connectedPeripheral,
            remotePeripheralId: central.identifier.uuidString
        )
    }

    func peripheralService(_ service: BuddyAssistPeripheralService, didReceiveMessage data: Data, from central: CBCentral) {
        _ = service
        _ = central
        guard let message = authenticatedMessage(from: data) else { return }
        append(message, direction: .received)
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
