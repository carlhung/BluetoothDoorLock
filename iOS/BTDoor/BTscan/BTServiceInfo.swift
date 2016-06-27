//
//  BTServiceInfo.swift
//  BTscan
//
//  Created by Carl Hung on 14/6/2016.
//  Copyright © 2016 carlhung. All rights reserved.
//

//import Foundation
import CoreBluetooth

class BTServiceInfo {
    var service: CBService!
    var characteristics: [CBCharacteristic]
    init(service: CBService, characteristics: [CBCharacteristic]) {
        self.service = service
        self.characteristics = characteristics
    }
}