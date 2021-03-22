//
//  ScanVC.swift
//  ESP32LEDBlink
//
//  Created by Lahari Ganti on 8/28/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import UIKit
import CoreBluetooth

class ScanVC: UITableViewController {
	private let reuseIdentifier = "deviceCell"
	private var manager = BTManager()
	private var devices: [BTDevice] = [] {
		didSet {
			if isViewLoaded {
				tableView.reloadData()
			}
		}
	}

	let statusLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 32, height: 30))

    override func viewDidLoad() {
        super.viewDidLoad()
		manager.delegate = self
		navigationController?.isToolbarHidden = false
		navigationController?.toolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
											   UIBarButtonItem(customView: statusLabel),
											   UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)]

		updateStatusLabel()
		tableView.dataSource = self
		tableView.delegate = self
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }

	func updateStatusLabel() {
		statusLabel.text = "state: \(manager.state), scan: \(manager.scanning)"
	}
}

extension ScanVC: BTManagerDelegate {
	func didChangeState(state: CBManagerState) {
		devices = manager.devices
		updateStatusLabel()
	}

	func didDiscover(device: BTDevice) {
		devices = manager.devices
	}

	func didEnableScan(on: Bool) {
		updateStatusLabel()
	}
}

extension ScanVC {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return devices.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)!
		let device = devices[indexPath.row]
		cell.textLabel?.text = device.name
		cell.detailTextLabel?.text = device.detail
		cell.accessoryType = .disclosureIndicator
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let device = devices[indexPath.row]
		let vc = DeviceVC()
		vc.device = device
		device.connect()
		navigationController?.pushViewController(vc, animated: true)
	}
}
