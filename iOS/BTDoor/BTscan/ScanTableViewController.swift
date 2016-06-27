//
//  ScanTableViewController.swift
//  BTscan
//
//  Created by Carl Hung on 12/6/2016.
//  Copyright © 2016 carlhung. All rights reserved.
//

import UIKit
import CoreBluetooth

class ScanTableViewController: UITableViewController, CBCentralManagerDelegate{
    
    // Nested type, only for this class
    private enum ScanState{
        case on
        case off
    }
    
    // MARK: - BT Properties
    var btCentralManager: CBCentralManager!
    
    var btPeripherals:[CBPeripheral] = [] // list of peripherals after scanning
    var selectedPeripheral: CBPeripheral?
    var btConnectable: [Int] = [] // list of the devices that can be connected
    var btRSSIs:[NSNumber] = [] // signal strongness
    
    let RSSI_MEAN = 70
    let RSSI_N = 1
    
    // MARK: - BT Override
    override func viewDidLoad() {
        super.viewDidLoad()
        btCentralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        btCentralManager.delegate = self
        if selectedPeripheral != nil {
            btCentralManager.cancelPeripheralConnection(selectedPeripheral!)
        }
    }
    
    // MARK: - BT delegates
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case CBCentralManagerState.PoweredOn:
            print("BT ON")
            actionScan(navigationItem.rightBarButtonItem!)
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
    
    // STEP 2, didDiscoverPeripheral delegate method gets called for "every peripheral" found.
    // so, each peripheral was found, this method will execute for each peripheral.
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        let temp = btPeripherals.filter { (pl) -> Bool in
            return pl.identifier.UUIDString == peripheral.identifier.UUIDString
        }
        if temp.count == 0 {
            btPeripherals.append(peripheral)
            btRSSIs.append(RSSI)
            btConnectable.append(Int(advertisementData[CBAdvertisementDataIsConnectable]!.description)!)
        }
        tableView.reloadData()
    }
    
    // MARK: - methods
    @IBAction func actionScan(sender: UIBarButtonItem) {
        sender.enabled = false
        navigationItem.title = "Scanning..."
        // scanState = .on
        btConnectable.removeAll()
        btPeripherals.removeAll()
        btRSSIs.removeAll()
        NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(ScanTableViewController.stopScan), userInfo: nil, repeats: false)
        btCentralManager.scanForPeripheralsWithServices(nil, options: nil) // STEP 1
    }
    
    func stopScan() {
        btCentralManager.stopScan()
        navigationItem.title = "Scan"
        navigationItem.rightBarButtonItem!.enabled = true
        
        tableView.reloadData()
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingMode = presentingViewController is UINavigationController // True
        
        if isPresentingMode {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            navigationController!.popViewControllerAnimated(true)
        }
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return btPeripherals.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PeripheralCell", forIndexPath: indexPath) as! ScanTableViewCell
        cell.lbConntable.text = btConnectable[indexPath.row].description
        cell.lbName.text = btPeripherals[indexPath.row].name
        cell.lbRSSI.text = btRSSIs[indexPath.row].description
        cell.lbUUID.text = btPeripherals[indexPath.row].identifier.UUIDString
        let distancePower = Double(abs(btRSSIs[indexPath.row].integerValue) - RSSI_MEAN) / Double(10 * RSSI_N)
        cell.lbDistance.text = "\(pow(10.0,distancePower)) M"
        cell.peripheral = btPeripherals[indexPath.row]
        return cell
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToConfig" {
            var destinationvc = segue.destinationViewController
            if let navcon = destinationvc as? UINavigationController {
                destinationvc = navcon.visibleViewController ?? destinationvc
            }
            if let destinationMVC = destinationvc as? BTDeviceConfigViewController {
                destinationMVC.manger = self.btCentralManager!
                let cell = sender as! ScanTableViewCell
                selectedPeripheral = cell.peripheral
                destinationMVC.peripheral = selectedPeripheral
            } else { print("can't transfer the sague") }
        }
    }
    
//    @IBAction func unwind(sender: UIStoryboardSegue){
//        if let sourceViewController = sender.sourceViewController as? BTDeviceConfigViewController {
//            self.btCentralManager = sourceViewController.manger
//            self.btPeripherals = []
//            self.selectedPeripheral = nil
//            self.btConnectable = []
//            self.btRSSIs = []
//        } else { print("can't cast back to BTDeviceConfigViewController") }
//    }
}
