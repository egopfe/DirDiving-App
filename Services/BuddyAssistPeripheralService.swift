import Foundation
import CoreBluetooth

@MainActor
protocol BuddyAssistPeripheralDelegate: AnyObject {
    func peripheralService(_ service: BuddyAssistPeripheralService, didReceiveHandshake data: Data, from central: CBCentral)
    func peripheralService(_ service: BuddyAssistPeripheralService, didReceiveMessage data: Data, from central: CBCentral)
    func peripheralServiceDidBecomeReady(_ service: BuddyAssistPeripheralService)
}

#if os(watchOS)
@MainActor
final class BuddyAssistPeripheralService {
    weak var delegate: BuddyAssistPeripheralDelegate?

    var isReady: Bool { false }

    func start() {}
    func stop() {}
    func sendHandshake(_ data: Data) {
        _ = data
    }
}
#else
@MainActor
final class BuddyAssistPeripheralService: NSObject {
    private var peripheralManager: CBPeripheralManager?
    private var pairingCharacteristic: CBMutableCharacteristic?
    private var subscribedCentrals: [CBCentral] = []
    weak var delegate: BuddyAssistPeripheralDelegate?

    var isReady: Bool { peripheralManager?.state == .poweredOn }

    func start() {
        if peripheralManager == nil {
            peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        }
        publishServiceIfReady()
    }

    func stop() {
        peripheralManager?.stopAdvertising()
        peripheralManager?.removeAllServices()
        subscribedCentrals.removeAll()
    }

    func sendHandshake(_ data: Data) {
        guard let pairingCharacteristic, !subscribedCentrals.isEmpty else { return }
        _ = peripheralManager?.updateValue(data, for: pairingCharacteristic, onSubscribedCentrals: nil)
    }

    private func publishServiceIfReady() {
        guard let peripheralManager, peripheralManager.state == .poweredOn else { return }

        let pairing = CBMutableCharacteristic(
            type: BuddyAssistService.pairingCharacteristicUUID,
            properties: [.write, .notify],
            value: nil,
            permissions: [.writeable, .readable]
        )
        let message = CBMutableCharacteristic(
            type: BuddyAssistService.messageCharacteristicUUID,
            properties: [.write, .notify, .read],
            value: nil,
            permissions: [.writeable, .readable]
        )
        pairingCharacteristic = pairing

        let service = CBMutableService(type: BuddyAssistService.serviceUUID, primary: true)
        service.characteristics = [pairing, message]
        peripheralManager.removeAllServices()
        peripheralManager.add(service)
        peripheralManager.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [BuddyAssistService.serviceUUID],
            CBAdvertisementDataLocalNameKey: "DIRDIVING"
        ])
        delegate?.peripheralServiceDidBecomeReady(self)
    }
}

extension BuddyAssistPeripheralService: CBPeripheralManagerDelegate {
    nonisolated func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        Task { @MainActor in
            if peripheral.state == .poweredOn {
                publishServiceIfReady()
            }
        }
    }

    nonisolated func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        Task { @MainActor in
            if characteristic.uuid == BuddyAssistService.pairingCharacteristicUUID,
               !subscribedCentrals.contains(where: { $0.identifier == central.identifier }) {
                subscribedCentrals.append(central)
            }
        }
    }

    nonisolated func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        Task { @MainActor in
            subscribedCentrals.removeAll { $0.identifier == central.identifier }
        }
    }

    nonisolated func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        Task { @MainActor in
            for request in requests {
                guard let value = request.value else { continue }
                if request.characteristic.uuid == BuddyAssistService.pairingCharacteristicUUID {
                    delegate?.peripheralService(self, didReceiveHandshake: value, from: request.central)
                } else if request.characteristic.uuid == BuddyAssistService.messageCharacteristicUUID {
                    delegate?.peripheralService(self, didReceiveMessage: value, from: request.central)
                }
                peripheral.respond(to: request, withResult: .success)
            }
        }
    }
}
#endif
