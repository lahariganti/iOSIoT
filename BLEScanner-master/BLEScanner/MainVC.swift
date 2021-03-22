//
//  MainVC.swift
//  BLEScanner
//
//  Created by Lahari Ganti on 8/25/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import UIKit
import CoreBluetooth

class MainVC: UIViewController {
	@IBOutlet weak var segmentedControl: UISegmentedControl!
	@IBOutlet weak var textView: UITextView!
	@IBOutlet weak var valueLabel: UILabel!

	let SERVICE_UUID = "FFF0"
	let CHARACTERISTIC_UUID = "FFF3"

	var centralManager: CBCentralManager!
	var discoveredPeripheral: CBPeripheral!
	var bluetoothOn: Bool = false

	override func viewDidLoad() {
        super.viewDidLoad()
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(startScan))
		tLog("Bluetooth LE Device Scanner\r\n\r\nProgramming the Internet of Things for iOS")
		centralManager = CBCentralManager(delegate: self, queue: nil)
    }

	@objc func startScan() {
		if !bluetoothOn {
			tLog("Bluetooth is OFF")
			return
		}

		centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(value: false)])
	}

	func tLog(_ msg: String?) {
		textView.text = "\n\n\(msg ?? "")" + textView.text
	}

	func verboseMode() -> Bool {
		return segmentedControl.selectedSegmentIndex != 0
	}
}

extension MainVC: CBCentralManagerDelegate {
	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		if central.state != .poweredOn {
			tLog("Bluetooth OFF")
			bluetoothOn = false
		} else {
			tLog("Bluetooth ON")
			bluetoothOn = true
		}
	}
}

extension MainVC: CBPeripheralDelegate {
	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		if let object = advertisementData["kCBAdvDataLocalName"] {
			print(object)
			tLog("Discovered \(object), RSSI: \(RSSI)\n")
		}

		discoveredPeripheral = peripheral
		if verboseMode() {
			centralManager.connect(discoveredPeripheral, options: nil)
		}
	}

	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		peripheral.delegate = self
		peripheral.discoverServices(nil)

		guard let services = peripheral.services else { return }

		for service in services {
			print(service.description)
			tLog("\(service.description)")
			peripheral.discoverCharacteristics(nil, for: service)
		}
	}

	func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
		if let error = error {
			print(error)
			tLog("\(error.localizedDescription)")
			return
		}

		guard let characteristics = service.characteristics else { return }

		for characteristic in characteristics {
			print(characteristic)
			tLog("\(characteristic.description)")

			if characteristic.uuid.isEqual(CBUUID(string: CHARACTERISTIC_UUID)) {
				peripheral.setNotifyValue(true, for: characteristic)
			}
		}
	}

	func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
		if let error = error {
			print(error)
			tLog(error.localizedDescription)
			return
		}

		if let stringFromData = characteristic.value {
			print(stringFromData)
			tLog("\(stringFromData)")
			valueLabel.text = "\(stringFromData)"
		}
	}
}
