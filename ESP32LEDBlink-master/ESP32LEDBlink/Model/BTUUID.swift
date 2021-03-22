//
//  BTUUID.swift
//  ESP32LEDBlink
//
//  Created by Lahari Ganti on 8/28/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import Foundation
import CoreBluetooth

struct BTUUIDs {
	static let blinkOn = CBUUID(string: "552cade0-73f0-4fee-a427-7543c2161912")
	static let blinkSpeed = CBUUID(string: "cebe1934-f80d-4116-adbc-eaf200cd2e17")
	static let blinkService = CBUUID(string: "a5a33251-5b8c-452b-b2bd-2931b649282d")

	static let infoService = CBUUID(string: "180a")
	static let infoManufacturer = CBUUID(string: "2a29")
	static let infoName = CBUUID(string: "2a24")
	static let infoSerial = CBUUID(string: "2a25")
}
