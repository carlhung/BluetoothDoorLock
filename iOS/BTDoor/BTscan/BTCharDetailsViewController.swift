//
//  BTCharDetailsViewController.swift
//  BTscan
//
//  Created by Carl Hung on 15/6/2016.
//  Copyright © 2016 carlhung. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

class BTCharDetailsViewController: UIViewController, CBPeripheralDelegate, UITextFieldDelegate{
    
    // MARK: - Properties
    var char: CBCharacteristic!
    var peripheral: CBPeripheral!
    var service: CBService!
    var password: String?
    var savedDevice: [SavedDevice] = []
    
    @IBOutlet weak var lbUUID: UILabel!
    @IBOutlet weak var lbProp: UILabel!
    @IBOutlet weak var lbPropHex: UILabel!
    @IBOutlet weak var btnClean: UIButton!
    @IBOutlet weak var tvResponse: UITextView!
    @IBOutlet weak var pwdfield: UITextField!
    @IBOutlet weak var namefield: UITextField!
    @IBOutlet weak var checkBox: CheckBox!

    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        lbUUID.text = char.UUID.UUIDString
        lbProp.text = char.getPropertyContent()
        lbPropHex.text = String(format: "0x%02X", char.properties.rawValue)
        
        pwdfield.delegate = self
        namefield.delegate = self
        
        peripheral.setNotifyValue(true, forCharacteristic: char)

        if let arr = NSUserDefaults.standardUserDefaults().objectForKey("devices") as? [String]{
            savedDevice = arr.toArrSavedDevice()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        peripheral.delegate = self
        if !char.isReadable() {
            btnClean.enabled = false
        }
    }
    
    // MARK: - methods
    @IBAction func cleanButton(sender: UIButton) {
        if sender === btnClean {
            tvResponse.text = ""
        }
    }
    
    // MARK: - delegates
    // The delegate gets called after reading value
    // or getting notification by setting true with setNotifyValue:forCharacteristic: method
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if let characteristicValue = characteristic.value{
            let datastring = NSString(data: characteristicValue, encoding: NSUTF8StringEncoding)
            if let datastring = datastring{
                tvResponse.text! += datastring as String
            }
        }
        
        // once it finds the keyword, do something here.
        if findInLastStr("Unlock") {
            if checkBox.isChecked == true {
                let device = SavedDevice(name: namefield.text!, peripheralID: peripheral.identifier.UUIDString, serviceID: service.UUID.UUIDString, characteristicID: characteristic.UUID.UUIDString, password: pwdfield.text!)
                
                // save
                if savedDevice.filter({ $0.peripheralID == device.peripheralID }).count == 0 {
                    savedDevice += [device]
                }
                else {
                    for element in savedDevice {
                        if device.peripheralID == element.peripheralID && device.serviceID == element.serviceID && device.characteristicID == element.characteristicID {
                            element.name = device.name
                            element.password = device.password
                            break
                        }
                    }
                }
            
            let str = savedDevice.toArrString()
            NSUserDefaults.standardUserDefaults().setObject(str, forKey: "devices")
            }
            //centralManager.cancelPeripheralConnection(selectedPeripheral!)
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if  textField === pwdfield {
            let data = ((textField.text! + "\n") as NSString).dataUsingEncoding(NSUTF8StringEncoding)
            if let data = data {
                peripheral.writeValue(data, forCharacteristic: char, type: CBCharacteristicWriteType.WithoutResponse)
            }
        } else if textField === namefield{
            // do something
        }
    }
    
    // MARK: - helper
    private func findInLastStr(subStr: String) -> Bool{
        var result:[String] = []
        tvResponse.text.enumerateLines { (line, _) -> () in
            result.append(line)
        }
        if result.last!.containsString(subStr) {
            return true
        }
        return false
    }
}