//
//  BTDeviceConfigViewController.swift
//  BTscan
//
//  Created by Carl Hung on 14/6/2016.
//  Copyright © 2016 carlhung. All rights reserved.
//

import UIKit
import CoreBluetooth

class BTDeviceConfigViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    // MARK: - Properties
    var manger: CBCentralManager!
    var peripheral: CBPeripheral!
    
    var btServices: [BTServiceInfo] = []
    
    // MARK: - BT Delegates
    func centralManagerDidUpdateState(central: CBCentralManager) {
        print("central state:\(central.state.rawValue)")
    }
    
    // STEP 2 got connected.
    // got connected to peripheral
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        if peripheral.state == CBPeripheralState.Connected {
            navigationItem.title = "Connected"
            // navigationItem.
            peripheral.discoverServices(nil) // STEP 3, 
            // STEP 3, find the specified services of the peripheral you are insterested at.
        } // and call delegate method(STEP 4)
    }
    
    // STEP 4, the delegate get called by discoverServices: method.
    // this delegate will find a list of services from the connected peripheral.
    // this delegate only execute once.
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        for service in peripheral.services! {
            // let service: CBService = serviceObj
            let isServiceIncluded = self.btServices.filter({ (item: BTServiceInfo) -> Bool in
                return item.service.UUID == service.UUID
            }).count
            if isServiceIncluded == 0 {
                btServices.append(BTServiceInfo(service: service, characteristics: []))
            }
            
            // STEP 5, find the Characteristics you are interested at.
            // the method is in the loop, 
            // everytime it get called, it will find the discoverCharacteristics for one service.
            peripheral.discoverCharacteristics(nil, forService: service)
        }
    }
    
    // STEP 6, this delegate method gets called by discoverCharacteristics:forService: method.
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        let serviceCharacteristics = service.characteristics
        for item in btServices {
            if item.service.UUID == service.UUID {
                item.characteristics = serviceCharacteristics!
                break
            }
        }
        tableView.reloadData()
    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manger.connectPeripheral(peripheral, options: nil)  // STEP 1, try connecting
    }
    
    override func viewWillAppear(animated: Bool) {
        manger.delegate = self
        peripheral.delegate = self
    }
    
    // MARK: - TableView
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return btServices.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return btServices[section].characteristics.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return btServices[section].service.UUID.description
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CharacteristicCell") as! CharacteristicTableViewCell
        cell.lbUUID.text = btServices[indexPath.section].characteristics[indexPath.row].UUID.UUIDString
        cell.lbPropHex.text = String(format: "0x%02X", btServices[indexPath.section].characteristics[indexPath.row].properties.rawValue)
        cell.lbProp.text = btServices[indexPath.section].characteristics[indexPath.row].getPropertyContent()
        cell.lbName.text = btServices[indexPath.section].characteristics[indexPath.row].UUID.description
        cell.lbValue.text = btServices[indexPath.section].characteristics[indexPath.row].value?.description ?? "null"
        cell.char = btServices[indexPath.section].characteristics[indexPath.row]
        cell.service = btServices[indexPath.section].service
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToChar" {
            if let destination = segue.destinationViewController as? BTCharDetailsViewController {
                if let cell = sender as? CharacteristicTableViewCell {
                    destination.char = cell.char
                    destination.peripheral = self.peripheral
                    destination.service = cell.service
                }
            }
        }
    }
}
