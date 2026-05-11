import Foundation
import Combine
import CoreBluetooth

@MainActor
final class BuddyAssistService: NSObject, ObservableObject {
    enum ConnectionState: String {
        case idle = "IDLE"
        case bluetoothUnavailable = "BLE OFF"
        case scanning = "PAIRING"
        case connected = "CONNECTED"
        case unsupported = "LIMITED"
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

    private var centralManager: CBCentralManager?
    private var connectedPeripheral: CBPeripheral?
    private var messageCharacteristic: CBCharacteristic?
    private var pingTimer: Timer?
    private let defaults: UserDefaults
    private let pairedBuddyIdentifierKey = "dirdiving_paired_buddy_identifier"
    private let pairedBuddyNameKey = "dirdiving_paired_buddy_name"

    var canSend: Bool { state == .connected && messageCharacteristic != nil }
    var isBuddyOnline: Bool { state == .connected }
    var buddyLinkStatus: String { isBuddyOnline ? "ONLINE" : "LOST" }
    var isPaired: Bool { pairedBuddyIdentifier != nil }
    var pairingStatusText: String { isPaired ? "PAIRED" : "NOT PAIRED" }
    var pairedBuddyDisplayName: String { pairedBuddyName ?? "DIRDIVING WATCH" }

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
        super.init()
    }

    func startPairing(isDiveActive: Bool) {
        guard !isDiveActive else {
            lastErrorMessage = preDivePairingDisclaimer
            state = .idle
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
    }

    func cancelPairingForActiveDive() {
        guard state == .scanning else { return }
        centralManager?.stopScan()
        lastErrorMessage = preDivePairingDisclaimer
        state = .idle
    }

    func forgetBuddy() {
        stopPairing()
        pairedBuddyIdentifier = nil
        pairedBuddyName = nil
        defaults.removeObject(forKey: pairedBuddyIdentifierKey)
        defaults.removeObject(forKey: pairedBuddyNameKey)
    }

    func send(_ message: BuddyAssistMessage) {
        guard let connectedPeripheral, let messageCharacteristic else {
            lastErrorMessage = "No buddy connected."
            append(message, direction: .sent)
            return
        }

        guard let data = message.payload.data(using: .utf8) else {
            lastErrorMessage = "Cannot encode message."
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

    private func persistPairedBuddy(from peripheral: CBPeripheral) {
        pairedBuddyIdentifier = peripheral.identifier.uuidString
        pairedBuddyName = peripheral.name ?? "DIRDIVING WATCH"
        defaults.set(peripheral.identifier.uuidString, forKey: pairedBuddyIdentifierKey)
        defaults.set(pairedBuddyName ?? "DIRDIVING WATCH", forKey: pairedBuddyNameKey)
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
            persistPairedBuddy(from: peripheral)
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
                  let payload = String(data: value, encoding: .utf8),
                  let message = BuddyAssistMessage.allCases.first(where: { $0.payload == payload }) else { return }

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
