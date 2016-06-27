//
//  CharacteristicTableViewCell.swift
//  BTscan
//
//  Created by Carl Hung on 14/6/2016.
//  Copyright © 2016 carlhung. All rights reserved.
//

import UIKit
import CoreBluetooth

class CharacteristicTableViewCell: UITableViewCell {
    @IBOutlet weak var lbUUID: UILabel! // UUID
    @IBOutlet weak var lbName: UILabel! // Name
    @IBOutlet weak var lbProp: UILabel! // Prop
    @IBOutlet weak var lbValue: UILabel! // Value
    @IBOutlet weak var lbPropHex: UILabel! // PropHex
    
    weak var service: CBService!
    
    weak var char: CBCharacteristic!
}