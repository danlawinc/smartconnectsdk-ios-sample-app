//
//  ViewController.swift
//  DanlawSDKSampleApp
//
//  Created by Danlaw on 6/14/18.
//  Copyright © 2018 Danlaw. All rights reserved.
//

import UIKit
import SmartConnectSDK

class SmartConnectSdkVC: UIViewController,gatewayInterfaceInstance,DLDongleDelegate,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var deviceListTable: UITableView!
    @IBOutlet weak var animatedView: UIView!
    @IBOutlet weak var scanningButton: UIButton!
    var devicesFound: [String: String] = [:]
    var gatewayDelegate: gatewayInterfaceInstance?
    var alertView: UIAlertController?
    var gateway:DLGatewayInterface?
    var connectionDelegate : DLDongleConnectionDelegate?
    var currentConnectionIndex: Int?
    let defaults:UserDefaults = UserDefaults.standard
    var pids: [String: Int] = [//getting pids from sdk and storing it in dict
        "speed": DLCommandPId.basic.vehicleSpeed,
        "rpm": DLCommandPId.basic.engineRPM,
        "gps": DLCommandPId.basic.GPSBasic,
        "fuelLevel": DLCommandPId.basic.fuelLevel,
        ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        
        //navigation bar settings
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.17, green:0.20, blue:0.55, alpha:1.0)
        
        //clearing out devicesfound dict
        devicesFound = [:]
        
        //checking is bluetooth enabled or not. Once requset sent, App will revice response through call back func onBluetoothEnabled.
        _ = self.gateway?.isBluetoothEnabled()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //gateway Start Scan will be triggered and once it's triggered scanner timer will start after 10 seconds timer will call stopscan func in sdk. if App found any Danlaw devices with in that time will show it App otherwise not.
    @IBAction func scanningButtonAction(_ sender: Any) {
        self.deviceListRefresh()
        self.gateway?.startScan(start: true)
        self.scanningButton.isHidden = true
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.showActivity("SCANNING...", onview: self.animatedView)
        }
        
    }
    
    //If App found Any devices devicesfound get the device name. Here it will insert newly availabe devices all time by deleting old devices.
    func deviceListRefresh(){
        if devicesFound.count > 0 {
            for index in stride(from: (devicesFound.count-1), to: 0, by: 1){
                _ = devicesFound.popFirst()
                deviceListTable?.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
            devicesFound = [:]
            deviceListTable?.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devicesFound.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46 // other cell height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "devices", for: indexPath) as UITableViewCell
        
        let deviceName = Array(devicesFound.keys)[indexPath.row]
        cell.textLabel?.text=deviceName
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = UIColor.gray
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 2
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Here Stopping Scan Once user Select the device by calling gateway?.startScan(start: false)
        self.gateway?.startScan(start: false)
        DLSettings.shared.connectionStatus = false
        DispatchQueue.main.async {
            //hiding activity Indicator
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.hideActivity()
        }
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor(red: 0.1686, green: 0.1961, blue: 0.5529, alpha: 1.0)
        let deviceName = Array(devicesFound.keys)[indexPath.row]
        let identifier = Array(devicesFound.values)[indexPath.row]
        //Once User Selects the device after stop scan, Calling gateway?.connect and it will try to connect to device by using devicename. If device is transmitting.
        let isConnected = gateway?.connect(name: deviceName)
        guard isConnected == true else{
            //If is connected is false it will return this error
            print("Error Connecting: No peripherals to connect to. Please scan again")
            return
        }
        //Here checking AutoConnection, If Auto Connection on this will save the selected device in user defaults.
        DLSettings.shared.connectedDevice = deviceName
        DLSettings.shared.connectedIdentifier = identifier
        DLSettings.shared.isAutoConnectOn = defaults.bool(forKey: "isAutoConnectOn")
        if DLSettings.shared.isAutoConnectOn  {
            defaults.set(DLSettings.shared.connectedDevice, forKey: "favDevice")
            defaults.set(DLSettings.shared.connectedIdentifier, forKey: "favDeviceIdentifier")
        }
        //alert shown
        self.makeAlert(title: "Please Wait", msg: "Connecting..")
        
    }
    
    //Handling UI Chnages after stop Scan call back triggered
    func scanStoped(){
        self.scanningButton?.isHidden = false
        DLSettings.shared.connectionStatus = false
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.hideActivity()
        }
    }
    
    //If App scanning for devices making sure there is no duplicates
    private func isNotDuplicate(device: String) -> Bool {
        for deviceName in devicesFound.keys {
            if deviceName == device {
                return false
            }
        }
        
        return true
    }
    
    //Once connection starts it will take couple of secs to connect and if there is anything wrong while connection in progress sdk sends failed response by using call back within that call back bellow alert shows.
    func failedToconnectAlert(){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "", message: "Disconnected", preferredStyle: UIAlertController.Style.alert)
            alert.view.layoutIfNeeded()
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //Once connection starts it will take couple of secs to connect and sdk starts to send commands while it's happening until app gets either success or failure commands App will show below alert.
    func makeAlert(title: String, msg: String){
        DispatchQueue.main.async {
            self.alertView = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
            self.alertView?.view.layoutIfNeeded()
            self.present(self.alertView!, animated: true, completion: nil)
        }
    }
    
    //until app gets either success or failure commands App will show alert and dismiss after we get either of those.
    func dismissAlert(){
        DispatchQueue.main.async {
            self.alertView?.dismiss(animated: true, completion: nil)
        }
    }
    
    //gatewayInterfaceInstance Delegate method Implementation. Getting Interface of Gateway and setting delegate to get DLGatewayDelegate callback methods.
    func getwayGetInstance() {
        DispatchQueue.main.async {
            do {
                try self.gateway = DLGatewayInterface.getInstance()
                self.gateway?.setDelegate(delegate: self)
            }catch DLException.SdkNotAuthenticatedException(let error) {
                print(error)
            }catch let error1 as NSError{
                print(error1)
            }
        }
        
    }

    
    
    //DLDongleDelegate methods
    
    //Once dongleDisconnect delegate method will triggered here actually checking is it diconnected by user or it's disconnected itself. If it's disconnected by user we are calling gateway disconnect method and it will disconnect from connected dongle successfully.
    func dongleDisconnect(event: String) {
        if event == "LostConnection"{
            self.deviceListRefresh()
            self.scanningButton.isHidden = false
        }else{
            //check SDK document for more info on disconnect
            self.gateway?.disconnect()
            self.deviceListRefresh()
            self.scanningButton.isHidden = false
        }
    }
    
    //Once getBasicPidData delegate method will triggered here passing specific basic pid number and it will send request to DataLogger basic channel by calling gateway readBasicPidData. Once pid number sent and if it's supported by Vechicle App will get response data.
    func getBasicPidData() {
        //check SDK document for more info
        _ = self.gateway?.readBasicPidData(pid: pids["fuelLevel"]!)
        
    }
    
    func getGPSBasicData() {
        _ = self.gateway?.readBasicPidData(pid: pids["gps"]!)
    }
    
    //Once registerDataPids delegate method will triggered here passing specific basic/Advanced pid number and Sends the request to the DataLogger to register an array of data Pids. Once pid number sent and if it's supported by Vechicle App will get response data. DPid: The ID of the Pid Array
    func registerDataPids() {
        guard
            let speed = pids["speed"],
            let rpm = pids["rpm"]
            
            else {
                return
        }
        let _ = gateway?.registerDataPid(DPid: 1, pids: [speed])
        let _ = gateway?.registerDataPid(DPid: 2, pids: [rpm])
    }
    
    //Once unregisterDataPids delegate method will triggered here passing specific basic/Advanced DPid: The ID of the Pid Array and it sends the request to the DataLogger to unregister data Pid. Once pid ID sent App will get response data through calback.
    func unRegisterDataPids() {
        let _ = gateway?.unregisterDataPid(DPid: 1)
        let _ = gateway?.unregisterDataPid(DPid: 2)
    }
    
    //Once registerEventPids delegate method will triggered here passing specific Advanced  Pids Array and it sends the request to the DataLogger to register those events pids. Once Event sent and if it's supported by Vechicle App will get response data when that particular event happens.
    func registerEventPids() {
        let _ = gateway?.registerEventPid(pids: [DLEventID.hardBraking, DLEventID.hardAcceleration])
    }
    
    //Once unregisterEventPids delegate method will triggered here passing specific Advanced  Pids Array and it sends the request to the DataLogger to unregister those events pids.Once pid list sent to datalogger App will get response data through calback.
    func unRegisterEventPids() {
        let _ = self.gateway?.unregisterEventPid(pids: [DLEventID.hardBraking, DLEventID.hardAcceleration])
    }
    
//Once registerFavDevieandIdentifier delegate method will triggered here passing stored device name and identifier.
    func registerFavDevieandIdentifier(deviceName: String, identifier: String) {
        //Setting the device as favorite by calling gateway?.setFavoriteDevice to set that device as favoriate and in sdk it will save the device in userdefaults. If it's favorite device sdk will initiate connection command itself and it will connect to that favoriate device.
     
        if let favDeviceName: String = defaults.string(forKey: "favDevice"){
            if deviceName.compare(favDeviceName) == ComparisonResult.orderedSame {
            
                gateway?.setFavoriteDevice(name: deviceName, identifier: identifier)
            }
        }
    }
    
    //Once unRegisterFavDevieandIdentifier delegate method will triggered here passing stored device name and identifier.
    func unRegisterFavDevieandIdentifier(deviceName: String, identifier: String){
        
        //Removing device as favorite by calling gateway?.forgetDevice() it will devicename from userdefaults.
     
            gateway?.forgetDevice()
        
    }
    
    //Once App gets response for the Basic/Advanced pids this func will call upon the onBasicDataReceived and onDataPidDataReceived call backs from sdk. Here checking by pid if pid match getting particular data of that object and passing along.
    private func setCorrectDataPidSwitch(pid: Int, object: DLBasicPIDObject){
        switch pid {
        case DLCommandPId.basic.vehicleSpeed: // speed
            
            guard let speed = object as? DLVehicleSpeed else {
                return
            }
            
            guard let speedvalue = speed.value else {
                return
            }
            //passing data to delegate
            connectionDelegate?.setDataFromChannels(value: speedvalue,  pidName: "speed")
            
        case DLCommandPId.basic.engineRPM: // rpm
            
            guard let rpm = object as? DLEngineRPM else {
                return
            }
            
            guard let rpmvalue = rpm.value else {
                return
            }
            //passing data to delegate
            connectionDelegate?.setDataFromChannels(value: rpmvalue, pidName: "rpm")
            
        case DLCommandPId.basic.fuelLevel: // fuel level
            
            guard let fuelLevel = object as? DLFuelLevel else {
                return
            }
            
            guard let fuel = fuelLevel.value else {
                return
            }
            //passing data to delegate
            connectionDelegate?.setDataFromChannels(value: fuel,  pidName: "fuelLevel")
            
        case DLCommandPId.basic.GPSBasic: // GPS
        
            guard let gpsData = object as? DLGPS else {
                return
            }
            
            guard let latitude = gpsData.latitude, let longitude = gpsData.longitude else {
                return
            }
            //passing data to delegate
            connectionDelegate?.setGPSFromChannels(latitude: latitude, longitude: longitude)
            
        default:
            return
            
        }
    }
    
    //Once devices found if Auto connection is enabled, it will find the index of favorite device.
    private func findIndexOfFavorite(deviceName: String) -> Int {
        var index = 0
        
        for key in Array(devicesFound.keys) {
            if key == deviceName {
                return index
            } else {
                index += 1
            }
        }
        
        return index
    }
    
}

//Custom Singleton Class to store required properties to access through out the app.
final class DLSettings{
    static let shared = DLSettings()
    
    private init(){
    }
    var connectedDevice:String = ""
    var connectedIdentifier:String = ""
    var isAutoConnectOn = false
    var connectionStatus = false
}

//DLDongleConnectionDelegate is passing data from self class to SmartConnectSdkPidRequestTVC.
protocol DLDongleConnectionDelegate {
    func disconnectAlert(isDisConnected : Bool)
    func setDataFromChannels(value: Int, pidName: String)
    func setGPSFromChannels(latitude: Double, longitude: Double)
    func setEventPidsData(value: Double, eventPidName: String)
    func unRegisterDPids(isSuccess: Bool)
    func unRegisterEPids(isSuccess: Bool)
}

extension SmartConnectSdkVC: DLGatewayDelegate{
    
    
    //This will trigger once StopScan called from app or from sdk. If scantime done after starts scan it will get scanTimeOut is true, if user click on device and starts connection progress it will return false.
    func onScanStopped(scanTimeOut: Bool) {
        self.scanStoped()
    }
    
    func onBluetoothEnabled(enabled: Bool) {
        //This method is called when Bluetooth status is changed(enabled/disabled). Please make sure bluetooth is on for scanning and connecting.
    }
    
    //Once scan starts this fun will triggered if there is any device that founds in range.
    func onOBDDeviceFound(deviceName: String, identifier: String) {
        if isNotDuplicate(device: deviceName) {
            print("Device Found: \(deviceName)")
            
            // save device name
            devicesFound[deviceName] = identifier
            
            // TODO: Handle when dongles found
            self.deviceListTable?.reloadData()
            
        }
    }
    
    //Once App starts connection App will get this callback for every stage of connection.
    func onConnectionStatusChange(responseCode: Int, connectionStatus: Int) {
        print("onConnectionStatusChange responseCode: \(responseCode) connectionStatus: \(connectionStatus)")
        if connectionStatus == DLConnectionStatus.connected{
            //if connection is success it will come here
            self.dismissAlert()
            let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "pidInfo") as! SmartConnectSdkPidRequestTVC
            VC1.delegate = self
            self.connectionDelegate = VC1.self as? DLDongleConnectionDelegate
            self.navigationController?.pushViewController(VC1, animated: false)
        }else if connectionStatus == DLConnectionStatus.checkingHealthStatusFailed || connectionStatus == DLConnectionStatus.authenticationFailed || connectionStatus == DLConnectionStatus.disconnected{
            //By any reason if connection fails it will come here
            self.dismissAlert()
            self.deviceListRefresh()
            connectionDelegate?.disconnectAlert(isDisConnected: true)
            if  DLSettings.shared.connectionStatus != true{
                self.failedToconnectAlert()
                self.scanningButton.isHidden = false
            }
            
        }
    }
    
    //upon Auto connection  it will send call back here  and checking isfavDevcie or not by gateway?.isFavDevice interface func.
    func onAutoConnecting(deviceName: String, identifier: String) {
        if (gateway?.isFavDevice(name: deviceName, identifier: identifier))! {
            self.makeAlert(title: "Please Wait", msg: "Connecting..")
            let index = findIndexOfFavorite(deviceName: deviceName)
            currentConnectionIndex = index
        }
    }
    
    //Gateway uses this method when the DataLogger responds back for a password change request. Please find more in sdk document.
    func onPasswordChange(responseCode: Int) {
        
    }
    
    //Gateway uses this method when the DataLogger responds back with the data for the `readBasicPidData` interface call
    func onBasicDataReceived(responseCode: Int, pid: Int, object: DLBasicPIDObject?) {
        if responseCode != DLResponseCode.success {
            print("Received Failing Response Code: \(responseCode) for pid:", "<<<<<<<<<< \(pid)")
            return
        }
        guard let pidObject = object else {
            return
        }
        //passing recevied pid number and pidobject data
        setCorrectDataPidSwitch(pid: pid, object: pidObject)
    }
    
    //This call back will triggered once App send command to registerData pids. Please find more in sdk document.Gateway uses this method once it receives the response from the DataLogger for the `registerDataPid` interface call
    func onDataPidRegistered(responseCode: Int, DPid: Int) {
        print(responseCode, DPid)
        
        if responseCode == DLResponseCode.success {
            
        } else {
            
        }
    }
    
    //This call back will triggered once App send command to registerData pids and if there is are any data for that pid is available. Please find more in sdk document.
    func onDataPidDataReceived(responseCode: Int, DPid: Int, hashmap: [Int : DLBasicPIDObject]) {
        if responseCode != 0 {
            print("Received Failing Response Code")
            return
        }
        for (pid, object) in hashmap {
            //passing recevied pid number and pidobject data
            setCorrectDataPidSwitch(pid: pid, object: object)
        }
    }
    
    //This call back will triggered once App send command to unregisterData pids. Please find more in sdk document.Gateway uses this method once it receives the response from the DataLogger for the `unregisterDataPid` interface call
    func onDataPidUnregistered(responseCode: Int, DPid: Int) {
        print(DPid)
        if responseCode == DLResponseCode.success {
            //delegate method to pass response code
            connectionDelegate?.unRegisterDPids(isSuccess: true)
        } else {
            
        }
    }
    
    //This call back will triggered once App send command to registerEvent pids. Please find more in sdk document. Gateway uses this method when it receives the response from the DataLogger for the `registerEventPid` interface call
    func onEventPidRegistered(responseCode: Int) {
        print("onEventPidRegistered:", responseCode)
        if responseCode == DLResponseCode.success {
        }else{
            
        }
    }
    
    //This call back will triggered once App send command to registerEvent pids and if there is are any events occured. Please find more in sdk document.
    func onEventPidDataReceived(responseCode: Int, EPid: Int, object: DLDataObject?) {
        if responseCode != DLResponseCode.success {
            print("Received Failing Response Code")
            return
        }
        switch EPid {
        case DLEventID.hardBraking: // Hard Braking Data
            
            guard let obj = object as? DLHardBrakingData else {
                return
            }
            
            guard  let maxDecelInKMHrSec = obj.maxBraking else {
                return
            }
            
            
            
            //delegate method to pass values
            connectionDelegate?.setEventPidsData(value: maxDecelInKMHrSec, eventPidName: "HardBrake")
            
        case DLEventID.hardAcceleration: // Hard Acceleration Data
            
            guard let obj = object as? DLHardAccelerationData else {
                return
            }
            
            guard  let maxAccelInKMHrSec = obj.maxAcceleration else {
                return
            }
            
     
            //delegate method to pass values
            connectionDelegate?.setEventPidsData(value: maxAccelInKMHrSec, eventPidName: "HardAccel")
            
        default:
            return
            
        }
    }
    
    //This call back will triggered once App send command to unregisterEvent pids. Please find more in sdk document.Gateway uses this method once it receives the response from the DataLogger for the `unregisterEventPid` interface call
    func onEventPidUnregistered(responseCode: Int) {
        print("onEventPidRegistered:", responseCode)
        if responseCode == DLResponseCode.success {
            //delegate method to pass response code
            connectionDelegate?.unRegisterEPids(isSuccess: true)
        }else{
            
        }
    }
//this callback is to download firware update for bleap devices
//    func fotaDowloadRequest(responseCode: Int) {
//
//    }
    
    //wifi callback response for adding wifi network to device
    func addingWiFiNetwork(responseCode: Int) {
        
    }
    
    //wifi callback response for deleting wifi network from device
    func deleteWiFiNetwork(responseCode: Int) {
        
    }
    
    //wifi callback to response it will all the available list of wifi network names for that device
    func configureListWiFiNetworks(responseCode: Int, data: [String]) {
        
    }
    
}

