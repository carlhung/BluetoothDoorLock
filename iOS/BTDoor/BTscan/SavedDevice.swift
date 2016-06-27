//
//  SavedDevice.swift
//  BTscan
//
//  Created by Carl Hung on 20/6/2016.
//  Copyright © 2016 carlhung. All rights reserved.
//

import Foundation

class SavedDevice: NSObject {
    
    var name: String
    let serviceID: String
    let characteristicID: String
    let peripheralID: String
    var password: String
    
    init(name: String, peripheralID: String, serviceID: String, characteristicID: String, password: String){
        self.characteristicID = characteristicID
        self.peripheralID = peripheralID
        self.password = password
        self.serviceID = serviceID
        if name.isEmpty {
            self.name = "No Name"
        } else { self.name = name }
    }
}