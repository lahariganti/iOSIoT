//
//  ESP32LEDBlink+Utilities.swift
//  ESP32LEDBlink
//
//  Created by Lahari Ganti on 8/29/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import Foundation
import CoreBluetooth

extension Data {
	func parseBool() -> Bool? {
		guard count == 1 else { return nil }

		return self[0] != 0 ? true : false
	}

	func parseInt() -> UInt8? {
		guard count == 1 else { return nil }
		return self[0]
	}
}

extension CBManagerState: CustomStringConvertible {
	public var description: String {
		switch self {
		case .unknown: return "unknown"
		case .resetting: return "resetting"
		case .unsupported: return "unsupported"
		case .unauthorized: return "unauthorized"
		case .poweredOff: return "poweredOff"
		case .poweredOn: return "poweredOn"
		@unknown default:
			fatalError("blep")
		}
	}
}
