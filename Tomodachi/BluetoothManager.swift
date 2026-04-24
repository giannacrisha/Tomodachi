import CoreBluetooth
import Combine

private let serviceUUID = CBUUID(string: "1234")
private let characteristicUUID = CBUUID(string: "5678")
private let deviceName = "TOMODACHI_GI"

enum ConnectionState {
    case disconnected
    case searching
    case connecting
    case connected

    var displayText: String {
        switch self {
        case .disconnected: return "Disconnected"
        case .searching:    return "Searching…"
        case .connecting:   return "Connecting…"
        case .connected:    return "Connected"
        }
    }

    var isConnected: Bool { self == .connected }
}

final class BluetoothManager: NSObject, ObservableObject {
    @Published private(set) var connectionState: ConnectionState = .disconnected

    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var writeCharacteristic: CBCharacteristic?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func sendCommand(_ command: String) {
        guard
            let peripheral,
            let characteristic = writeCharacteristic,
            let data = command.data(using: .utf8)
        else { return }
        peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
    }

    private func startScan() {
        guard centralManager.state == .poweredOn else { return }
        connectionState = .searching
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }

    private func reset() {
        peripheral = nil
        writeCharacteristic = nil
    }
}

// MARK: - CBCentralManagerDelegate

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScan()
        } else {
            connectionState = .disconnected
            reset()
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        guard peripheral.name == deviceName else { return }
        self.peripheral = peripheral
        centralManager.stopScan()
        connectionState = .connecting
        centralManager.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        reset()
        startScan()
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectionState = .disconnected
        reset()
        startScan()
    }
}

// MARK: - CBPeripheralDelegate

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services where service.uuid == serviceUUID {
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics where characteristic.uuid == characteristicUUID {
            writeCharacteristic = characteristic
            connectionState = .connected
        }
    }
}
