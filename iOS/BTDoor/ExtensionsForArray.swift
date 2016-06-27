//
//  ExtensionsForArray.swift
//  BTscan
//
//  Created by Carl Hung on 22/6/2016.
//  Copyright © 2016 carlhung. All rights reserved.
//

import Foundation

extension CollectionType where Generator.Element == SavedDevice {
    func toArrString() -> [String] {
        var str = [String]()
        for device in self {
            str += [device.name + "\n" + device.peripheralID + "\n" + device.serviceID + "\n" + device.characteristicID + "\n" + device.password]
        }
        return str
    }
}

extension CollectionType where Generator.Element == String {
    func toArrSavedDevice() -> [SavedDevice] {
        var devices: [SavedDevice] = []
        for device in self {
            var result:[String] = []
            device.enumerateLines { (line, _) -> () in
                result.append(line)
            }
            devices += [SavedDevice(name: result[0], peripheralID: result[1], serviceID: result[2], characteristicID: result[3], password: result[4])]
        }
        return devices
    }
}