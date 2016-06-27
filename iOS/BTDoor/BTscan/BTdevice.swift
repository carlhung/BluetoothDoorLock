//
//  BTdevice.swift
//  BTscan
//
//  Created by Carl Hung on 13/6/2016.
//  Copyright © 2016 carlhung. All rights reserved.
//

import Foundation

class BTdevice {
    var lbName: String
    var lbRSSI: String
    var lbDistance: String
    var lbUUID: String
    var lbConntable: String
    
    init(lbName: String, lbRSSI: String, lbDistance: String, lbUUID: String, lbConntable: String){
        self.lbName = lbName
        self.lbRSSI = lbRSSI
        self.lbDistance = lbDistance
        self.lbUUID = lbUUID
        self.lbConntable = lbConntable
    }
}