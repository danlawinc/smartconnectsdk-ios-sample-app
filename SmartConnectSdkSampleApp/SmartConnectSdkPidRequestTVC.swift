//
//  SmartConnectSdkPidRequestTVC.swift
//  Danlaw SDK Sample App
//
//  Created by Danlaw on 6/15/18.
//  Copyright © 2018 Danlaw. All rights reserved.
//

import UIKit

class SmartConnectSdkPidRequestTVC: UITableViewController,DLDongleConnectionDelegate {
    
    var delegate : DLDongleDelegate?
    @IBOutlet weak var fuelLevel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var fuelLevelButton: UIButton!
    @IBOutlet weak var gpsDataButton: UIButton!
    @IBOutlet weak var registerDpidButton: UIButton!
    @IBOutlet weak var speedValue: UILabel!
    @IBOutlet weak var unRegisterDpidButton: UIButton!
    @IBOutlet weak var rpmValue: UILabel!
    @IBOutlet weak var eventValue: UILabel!
    @IBOutlet weak var registerEpidButton: UIButton!
    @IBOutlet weak var unRegisterEpidButton: UIButton!
    @IBOutlet weak var eventText: UILabel!
    @IBOutlet weak var autoConnectSwitch: UISwitch!
    @IBOutlet weak var autoConnectLabel: UILabel!
    @IBOutlet weak var disConnectButton: UIButton!
    @IBOutlet weak var gpsMsgLatitudeLabel: UILabel!
    @IBOutlet weak var gpsMsgLongitudeLabel: UILabel!
    @IBOutlet weak var gpsMsgDateLabel: UILabel!
    @IBOutlet weak var gpsMsgNoOfSatelliteLabel: UILabel!
    
    
    let defaults:UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigation bar settings
        self.navigationItem.title = "CONNECTED TO DATALOGGER"
        navigationItem.hidesBackButton = true
        
        //button layer settings
        self.setupButtonStyles(sender: fuelLevelButton)
        self.setupButtonStyles(sender: gpsDataButton)
        self.setupButtonStyles(sender: registerDpidButton)
        self.setupButtonStyles(sender: unRegisterDpidButton)
        self.setupButtonStyles(sender: registerEpidButton)
        self.setupButtonStyles(sender: unRegisterEpidButton)
        
        
        //hiding other sections by adding empty view
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        
        //saving state of UISwitch in userdefaluts
        let autoConnectState = defaults.bool(forKey:"isAutoConnectOn")
        autoConnectSwitch.isOn = autoConnectState
        if (autoConnectSwitch.isOn) {
            //if is AutoConnection on show bellow text
            if let favDeviceName: String = defaults.string(forKey: "favDevice"){
                if favDeviceName != ""{
                    self.autoConnectLabel.text = "Auto connect turned on for device:\(favDeviceName)"
                }else{
                    //if there is no favDeviceName shows bellow text
                    self.autoConnectLabel.text = "Auto connect not enabled for the connected device"
                }
            }
        }else{
            //if is AutoConnection not on shows bellow text
            self.autoConnectLabel.text = "Auto connect not enabled for the connected device"
        }
    }
    
    //seting button layer proprties
    func setupButtonStyles(sender: UIButton) {
        sender.layer.cornerRadius=5
        sender.clipsToBounds = true
        sender.layer.borderColor = UIColor.lightGray.cgColor
        sender.layer.borderWidth = 4
    }

    
    @objc func goback() {
        // Go back to the previous ViewController
        DLSettings.shared.connectionStatus = true
        self.navigationController?.popViewController(animated: true)
        delegate?.dongleDisconnect(event: "LostConnection")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 5
    }
    
    //Set Custom Rows for each Section in tableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 || section == 0 {
            return 2
        }else if section == 2 || section == 3 || section == 4{
            return 1
        }else{
            return 0
        }
        
    }

    // Set Custom Heights for Headers
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 50
    }
    
    //Adding Alerts for tableview cells
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if indexPath.section == 0{
           // if indexPath.row == 0{
                self.customAlertForCells(title: "Basic Data Channel - Data PIDs", msg: "Only data PIDs (Standard ODB and Non OBD/Custom PIDs) can be requested through basic data channel and not event PIDs.\nPIDs requested through this channel do not receive realtime continuous updates.")
           // }
        }else if indexPath.section == 1{
            if indexPath.row == 0{
                self.customAlertForCells(title: "Advanced Data Channel - Data PIDs", msg: "Standard ODB data PIDs and Event PIDs can be requested through advanced data channel.\nNon OBD/Custom PIDs cannot be requested through advanced data channel.\nPIDs requested through this channel continue to receive updates in realtime until they are unregistered.")
            }else if indexPath.row == 1{
                self.customAlertForCells(title: "Advanced Data Channel - Event PIDs", msg: "Event PIDs can only be requested through advanced data channel.\nPIDs requested through this channel continue to receive updates in realtime until they are unregistered.")
            }
        }else if indexPath.section == 2{
                self.customAlertForCells(title: "UDP Data Channel", msg: "If app is connected to Bleap device, application will receive data via UDP channel. App cannot register or unregister for UDP Data.")
        }else if indexPath.section == 3{
                self.customAlertForCells(title: "AutoConnect", msg: "If Auto Connect is turned on app will set the connected device as favorite and then the app will try to connect to the device automatically during any foreground or background (triggered by location change) scans.")
        }
        
    }
    
    //Giving more Info about basic, Advanced and Events Pids when cick on deatil accessory icon
    func customAlertForCells(title: String, msg: String){
        
        let alertView = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
         let messageText = NSMutableAttributedString( string: msg, attributes: [ NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body), NSAttributedString.Key.foregroundColor : UIColor.black ] )
        
        alertView.setValue(messageText, forKey: "attributedMessage")
        

        self.present(alertView, animated: true, completion: nil)
    }
    
    //AutoConect to save device and state of switch in userdefaults and to connect automatically if
    @IBAction func autoConnectSwitchAction(_ sender: Any) {
        //Saving swicth state in UserDefaults for AutoConnection
        defaults.set(autoConnectSwitch.isOn, forKey: "isAutoConnectOn")
        
        if autoConnectSwitch.isOn{
            //Saving switch state and deviceNmae to set as FavoriteDevice for AutoConnection
            DLSettings.shared.isAutoConnectOn = self.autoConnectSwitch.isOn
            self.defaults.set(self.autoConnectSwitch.isOn, forKey: "isAutoConnectOn")
            self.defaults.set(DLSettings.shared.connectedDevice, forKey: "favDevice")
            self.defaults.set(DLSettings.shared.connectedIdentifier, forKey: "favDeviceIdentifier")
            self.autoConnectLabel.text = "Auto connect turned on for device:\(DLSettings.shared.connectedDevice)"
            
            //delegate method to cal setFavDevice for adding device to fav device list.
            delegate?.registerFavDevieandIdentifier(deviceName: DLSettings.shared.connectedDevice, identifier: DLSettings.shared.connectedIdentifier)
            
        }else {
            //Removing FavoriteDevice name and switch state and saving it.
            self.defaults.set("", forKey: "favDevice")
            self.defaults.set("", forKey: "favDeviceIdentifier")
            self.autoConnectSwitch.isOn = false
            DLSettings.shared.isAutoConnectOn = self.autoConnectSwitch.isOn
            self.autoConnectLabel.text = "Auto connect not enabled for the connected device"
            //delegate method to cal forgetdevice for removing device from fav device list.
            delegate?.unRegisterFavDevieandIdentifier(deviceName: DLSettings.shared.connectedDevice, identifier: DLSettings.shared.connectedIdentifier)
        }
    }
    
    //GetFuel Level from basic data channel, Once button pressed this delegate method will be called
    @IBAction func getFuelLevel(_ sender: Any) {
        delegate?.getBasicPidData()
    }
    
    //Get GPS from basic data channel, Once button pressed this delegate method will be called
    @IBAction func getGPSData(_ sender: Any) {
        delegate?.getGPSBasicData()
    }
    
    //Register data pids through advanced channel, Once button pressed this delegate method will be called
    @IBAction func registerDpids(_ sender: Any) {
        delegate?.registerDataPids()
    }
    
    //UNRegister data pids through advanced channel, Once button pressed this delegate method will be called
    @IBAction func unRegisterDpids(_ sender: Any) {
        delegate?.unRegisterDataPids()
    }
    
    //Register Event pids through advanced channel, Once button pressed this delegate method will be called
    @IBAction func registerEpids(_ sender: Any) {
        delegate?.registerEventPids()
    }
    
    //UNRegister data pids through advanced channel, Once button pressed this delegate method will be called
    @IBAction func unRegisterEpids(_ sender: Any) {
        delegate?.unRegisterEventPids()
    }
    
    //Once Disconnect Button Pressed dongleDisconnect delegate will be triggered
    @IBAction func disConnectFromDongle(_ sender: Any) {
        // Go back to the previous ViewController
        DLSettings.shared.connectionStatus = true
        self.navigationController?.popViewController(animated: true)
        delegate?.dongleDisconnect(event: "UserDisconnected")
    }
    
    //converting kph to Mph
    private func convertToMph(kph: Int) -> Int {
        return Int((Double(kph) * 0.621371).rounded())
    }
    
    
    //DLDongleConnectionDelegate methods
    
    //If DATALOGGER disconnect itself from App without user action, below func will display alert and enables back button.
    func disconnectAlert(isDisConnected: Bool) {
        if isDisConnected == true{
            let newBackButton = UIBarButtonItem(title: "<Back", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.goback))
            newBackButton.tintColor = .white
            self.navigationItem.leftBarButtonItem = newBackButton
        }
    }
    
    //If is there any data that comming From Basic and Adanced channels DPids bellow func will trigger and display text in labels.
    func setDataFromChannels(value: Int,  pidName: String){
        if pidName == "speed"{
            let mph = convertToMph(kph: value)
            self.speedValue.text = "\(mph)mph"
        }else if pidName == "rpm"{
            self.rpmValue.text = "\(value)rpm"
        }else if pidName == "fuelLevel" {
            self.fuelLevel.text = "\(value)%"
        }
        
    }
    
    func setGPSFromChannels(latitude: Double, longitude: Double) {
        self.latitudeLabel.text = "\(latitude)"
        self.longitudeLabel.text = "\(longitude)"
    }
    
    //If is there any data that comming From Adanced channels EPids bellow func will trigger and display text in labels.
    func setEventPidsData(value: Double, eventPidName: String){
        if eventPidName == "HardAccel"{
            self.eventText.text = eventPidName + ":"
            self.eventValue.text = "\(value)mph"
        }else if eventPidName == "HardBrake"{
            self.eventText.text = eventPidName + ":"
            self.eventValue.text = "\(value)mph"
        }
    }
    
    //Once Unregiser Data Pids success bellow func will trigger to reset the data
    func unRegisterDPids(isSuccess: Bool){
        self.speedValue.text = "--"
        self.rpmValue.text = "--"
    }
    
    //Once Unregiser Event Pids success bellow func will trigger to reset the data
    func unRegisterEPids(isSuccess: Bool){
        self.eventText.text =  ""
        self.eventValue.text = "--"
    }
    
    func updateGPSMessageData(latitude: String, longitude: String, date: String, noOfSatellite: Int) {
                
        DispatchQueue.main.async {
            self.gpsMsgDateLabel.text = "Date: \(date)"
            self.gpsMsgLatitudeLabel.text = "Latitude: \(latitude)"
            self.gpsMsgLongitudeLabel.text = "Longitude: \(longitude)"
            self.gpsMsgNoOfSatelliteLabel.text = "Number Of Satellites: \(noOfSatellite)"
        }
        
    }
}


//DLDongleDelegate is passing data from self class to SmartConnectSdkVC. 
protocol DLDongleDelegate {
    func dongleDisconnect(event: String)
    func getBasicPidData()
    func getGPSBasicData()
    func registerDataPids()
    func unRegisterDataPids()
    func registerEventPids()
    func unRegisterEventPids()
    func registerFavDevieandIdentifier(deviceName: String, identifier: String)
    func unRegisterFavDevieandIdentifier(deviceName: String, identifier: String)

}
