//
//  SavedListTableViewController.swift
//  BTscan
//
//  Created by Carl Hung on 20/6/2016.
//  Copyright © 2016 carlhung. All rights reserved.
//

import UIKit
import CoreBluetooth

class SavedListTableViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    // MARK: - Properties
    var centralManager: CBCentralManager!
    var peripheralList: [CBPeripheral] = []
    var selectedPeripheral: CBPeripheral?
    
    var selectedDevice: SavedDevice?
    var savedDeviceInRange: [SavedDevice] = []
    var savedDevice: [SavedDevice] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        centralManager.delegate = self
        
        if let arr = NSUserDefaults.standardUserDefaults().objectForKey("devices") as? [String] {
            savedDevice = arr.toArrSavedDevice()
        }
        
        actionScan(navigationItem.leftBarButtonItem!)
        
        for item in savedDevice {
            print(item.name)
            print(item.peripheralID)
            print(item.serviceID)
            print(item.characteristicID)
            print(item.password)
        }
    
        if selectedDevice != nil || selectedPeripheral != nil {
            centralManager.cancelPeripheralConnection(selectedPeripheral!)
            selectedPeripheral = nil
            selectedDevice = nil
        }
    }
    
    // MARK: - methods
    @IBAction func actionScan(sender: UIBarButtonItem) {
        sender.enabled = false
        navigationItem.title = "Scanning..."
        navigationItem.rightBarButtonItem?.enabled = false
        peripheralList.removeAll()
        savedDeviceInRange.removeAll()
        selectedPeripheral = nil
        selectedDevice = nil
        NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(ScanTableViewController.stopScan), userInfo: nil, repeats: false)
        centralManager.scanForPeripheralsWithServices(nil, options: nil) // STEP 1
        
    }
    
    // Step 3
    func stopScan() {
        centralManager.stopScan()
        navigationItem.title = "Saved Door"
        navigationItem.leftBarButtonItem!.enabled = true
        navigationItem.rightBarButtonItem?.enabled = true
        tableView.reloadData()
    }
    
    // Step 1
    // MARK: - BT delegates
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case CBCentralManagerState.PoweredOn:
            print("BT ON")
            actionScan(navigationItem.leftBarButtonItem!) // Step 2
        case CBCentralManagerState.PoweredOff:
            print("BT OFF")
        case CBCentralManagerState.Resetting:
            print("BT RESSTING")
        case CBCentralManagerState.Unknown:
            print("BT UNKNOW")
        case CBCentralManagerState.Unauthorized:
            print("BT UNAUTHORIZED")
        case CBCentralManagerState.Unsupported:
            print("BT UNSUPPORTED")
        }
    }
    
    // STEP 4
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        savedDeviceInRange += savedDevice.filter { $0.peripheralID == peripheral.identifier.UUIDString }
        
        if peripheralList.filter({$0.identifier.UUIDString == peripheral.identifier.UUIDString}).count == 0 {
            peripheralList.append(peripheral)
        }
        tableView.reloadData()
    }
    
    // Step 6
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        if peripheral.state == .Connected {
            peripheral.discoverServices(nil)
        } else {
            selectedPeripheral = nil
            selectedDevice = nil
        }
    }
    
    // Step 7
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        for service in peripheral.services! {
            if service.UUID.UUIDString == selectedDevice?.serviceID {
                peripheral.discoverCharacteristics(nil, forService: service) // Step 8
                break
            }
        }
    }
    
    // Step 9
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        for characteristic in service.characteristics! {
            if characteristic.UUID.UUIDString == selectedDevice?.characteristicID {
                let data = ((selectedDevice!.password + "\n") as NSString).dataUsingEncoding(NSUTF8StringEncoding)
                if let data = data {
                    peripheral.writeValue(data, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithoutResponse)
                    break
                }
            }
        }
        centralManager.cancelPeripheralConnection(peripheral) // Step 11
    }
    
    //didDisconnect // Step 12
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?){
        selectedPeripheral = nil
        selectedPeripheral = nil
    }
    
    // Step 13
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        // characteristic.value // this property is the reply from the bluetooth device.
        // got replied by the bluetooth device, you can do something here.
    }
    
    
    // MARK: - Table view setup
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedDeviceInRange.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("savdDeviceCell", forIndexPath: indexPath) as! SavedDeviceTableViewCell
        cell.name.text = savedDeviceInRange[indexPath.row].name
        cell.uuid.text = savedDeviceInRange[indexPath.row].peripheralID
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        for item in peripheralList {
            if item.identifier.UUIDString == savedDeviceInRange[indexPath.row].peripheralID{
                selectedPeripheral = item
                selectedDevice = savedDeviceInRange[indexPath.row]
                selectedPeripheral?.delegate = self
                centralManager.connectPeripheral(item, options: nil) // Step 5
                break
            }
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if navigationItem.leftBarButtonItem!.enabled == false {
            return false
        } else { return true }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let itemNumber = savedDevice.indexOf(savedDeviceInRange[indexPath.row])
            savedDevice.removeAtIndex(itemNumber!)
            savedDeviceInRange.removeAtIndex(indexPath.row)
            
            let str = savedDevice.toArrString()
            NSUserDefaults.standardUserDefaults().setObject(str, forKey: "devices")
            
            tableView.reloadData()
        }
    }
    
    // MARK: - segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toScanNewDevice" {
            if let destinationMVC = segue.destinationViewController as? ScanTableViewController {
                destinationMVC.btCentralManager = self.centralManager!
            }
        }
    }
}
