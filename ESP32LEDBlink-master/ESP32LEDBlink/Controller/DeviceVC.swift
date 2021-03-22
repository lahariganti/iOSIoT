//
//  DeviceVC.swift
//  ESP32LEDBlink
//
//  Created by Lahari Ganti on 8/29/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import UIKit
import UserNotifications

class DeviceVC: UIViewController {
	enum ViewState: Int {
		case disconnected
		case connected
		case ready
	}

	var device: BTDevice? {
		didSet {
			navigationItem.title = device?.name ?? "Device"
			device?.delegate = self
		}
	}

	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var blinkSwitch: UISwitch!
	@IBOutlet weak var disconnectButton: UIButton!
	@IBOutlet weak var serialLabel: UILabel!
	@IBOutlet weak var speedSlider: UISlider!

	var viewState: ViewState = .disconnected {
		didSet {
			switch viewState {
			case .disconnected:
				statusLabel.text = "Disconnected"
				blinkSwitch.isEnabled = false
				blinkSwitch.isOn = false
				speedSlider.isEnabled = false
				disconnectButton.isEnabled = false
				serialLabel.isHidden = true
			case .connected:
				statusLabel.text = "Probing..."
				blinkSwitch.isEnabled = false
				blinkSwitch.isOn = false
				speedSlider.isEnabled = false
				disconnectButton.isEnabled = true
				serialLabel.isHidden = true
			case .ready:
				statusLabel.text = "Ready"
				blinkSwitch.isEnabled = true
				disconnectButton.isEnabled = true
				serialLabel.isHidden = false
				speedSlider.isEnabled = true

				if let b = device?.blink {
					blinkSwitch.isOn = b
				}
				if let s = device?.speed {
					speedSlider.value = Float(s)
				}
				serialLabel.text = device?.serial ?? "reading..."
			}
		}
	}

	deinit {
		device?.disconnect()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		viewState = .disconnected
		disconnectButton.addTarget(self, action: #selector(disconnectAction), for: .touchUpInside)
		blinkSwitch.addTarget(self, action: #selector(blinkChanged(_:)), for: .touchUpInside)
		speedSlider.addTarget(self, action: #selector(speedChanged(_:)), for: .touchDragInside)
	}

	@objc func disconnectAction() {
		device?.disconnect()
	}

	@objc func blinkChanged(_ sender: Any) {
		device?.blink = blinkSwitch.isOn
	}

	@objc func speedChanged(_ sender: UISlider) {
		device?.speed = Int(speedSlider.value)
	}

}

extension DeviceVC: BTDeviceDelegate {
	func deviceSerialChanged(value: String) {
		serialLabel.text = value
	}

	func deviceSpeedChanged(value: Int) {
		speedSlider.value = Float(value)
	}

	func deviceConnected() {
		viewState = .connected
	}

	func deviceDisconnected() {
		viewState = .disconnected
	}

	func deviceReady() {
		viewState = .ready
	}

	func deviceBlinkChanged(value: Bool) {
		blinkSwitch.setOn(value, animated: true)

		if UIApplication.shared.applicationState == .background {
			let content = UNMutableNotificationContent()
			content.title = "ESP32 Blinking LED"
			content.body = value ? "Now blinking" : "Not blinking anymore"
			let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
			UNUserNotificationCenter.current().add(request) { (error) in
				if let error = error {
					print("DeviceVC: failed to deliver notification \(error)")
				}
			}
		}
	}
}
