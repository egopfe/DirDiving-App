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

    static let serviceUUID = CBUUID(string: "A1C4D7B0-8C4A-4D74-9C0F-0C38D87D1A01")
    static let messageCharacteristicUUID = CBUUID(string: "E02B806D-3B9C-49A4-A8EF-6A96CB2D56E1")

    @Published private(set) var state: ConnectionState = .idle
    @Published private(set) var lastErrorMessage: String?
    @Published private(set) var events: [BuddyAssistEvent] = []

    private var centralManager: CBCentralManager?
    private var connectedPeripheral: CBPeripheral?
    private var messageCharacteristic: CBCharacteristic?

    var canSend: Bool { state == .connected && messageCharacteristic != nil }

    var limitationText: String {
        "Direct Watch-to-Watch BLE pairing is experimental. watchOS apps cannot advertise BLE peripheral services, so a reliable production path may need a companion device or external BLE relay."
    }

    func startPairing() {
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
        state = .idle
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
        events.insert(BuddyAssistEvent(message: message, direction: direction, timestamp: Date()), at: 0)
        events = Array(events.prefix(8))
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
            connectedPeripheral = peripheral
            connectedPeripheral?.delegate = self
            central.stopScan()
            central.connect(peripheral, options: nil)
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        Task { @MainActor in
            state = .connected
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
}
