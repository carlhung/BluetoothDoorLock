//
//  ScanTableViewCell.swift
//  BTscan
//
//  Created by Carl Hung on 12/6/2016.
//  Copyright © 2016 carlhung. All rights reserved.
//

import UIKit
import CoreBluetooth

class ScanTableViewCell: UITableViewCell  {

    // MARK: - Properties
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbRSSI: UILabel!
    @IBOutlet weak var lbDistance: UILabel!
    @IBOutlet weak var lbUUID: UILabel!
    @IBOutlet weak var lbConntable: UILabel!
    
    weak var peripheral: CBPeripheral!
}
