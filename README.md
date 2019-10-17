# smartconnectsdk-iOS-sample-app
This sample app acts as a template to quickstart your iOS app development. 

To build the project, just **copy the SDK (.framework file) to Frameworks folder** of your project and **replace apiKey with your key** that was issued to you by Danlaw in ```LaunchScreenVC.swift``` file.

# Table of Contents  

1. [Features](#features)
2. [Requirements](#requirements)
3. [Installation](#installation)
4. [Authentication](#authentication)
5. [Connecting to Datalogger](#connecting-to-datalogger)
6. [Auto-Connect](#auto-connect)
7. [Get PID data (Basic Channel)](#get-pid-data-basic-channel)
8. [Register PID Data for Continuous Updates (Advanced Channel)](#register-pid-data-for-continuous-updates-advanced-channel)
9. [Realtime Events (Advanced Channel)](#realtime-events-advanced-channel)
10. [UDP Events (BLEAP)](#udp-events-bleap)
11. [FAQ](#faq)
12. [Credits](#credits)


# Features
- [x] Scan Devices
- [x] Enable Bluetooth
- [x] Connect/Disconnect to Devices
- [x] Set Favorite/Forget Devices
- [x] Autoconnect to Favorite Device
- [x] Firmware Update
- [x] Read basic and data pids 
- [x] Register/unregister data pids for continuous updates
- [x] Register/unregister for event updates

# Requirements
- iOS 10.0+
- Xcode 11.0+
- Swift 5.0+


# Installation
- Create Framework directory inside your Project's root folder. Copy-paste iOS SDK provided by Danlaw. 
- Go to Project's Target settings and import framework from the directory.
- ```import SmartConnectSDK``` in swift file to access framework.

# Component Library
- DLAuthInterface: This class AuthInterface provides the entry point for the SDK. The hosting application should call the interface method validateToken to get the SDK authenticated. If the SDK is not authenticated, then none of the services that are offered by the SDK will be available.
- DLGatewayInterface: This class handles communication between the app and the SDK. It provides the outward facing methods for interacting with the Danlaw iOS SDK.
- DLGatewayDelegate: This `protocol DLGatewayDelegate` defines the callbacks required for the delegate on the `DLGatewayInterface`.


# Authentication
After installing the SDK, **app MUST authenticate it before it can use all the interfaces**. 
To authenticate the SDK, use the following method:

```
/**
 - parameter apiKey: ApiKey issued by Danlaw Inc.
 - parameter issuedTo: App's main bundle
 - parameter delegate: Instance of implementing class of DLAuthDelegate
*/
// Request to SDK
DLAuthInterface.sharedInstance.validateToken(apiKey: self.apiKey, issuedTo: Bundle.main, delegate: self)
```

SDK uses `DLAuthDelegate` method in response of `validateToken:`

```
// Response from SDK
/**
    - parameter authenticationResult: 200 in case of Success
    - parameter message: Message from SDK success/error
*/
func onAuthenticationResult(authenticationResult: Int, message: String) {
     if authenticationResult == 200{
        //SDK Authenticated
        // Get DLGatewayInterface Instance
        // Confirm DLGatewayDelegate 
     }
     else{
        print("Authentication Message: \(message)")            
     }
}
``` 

# Connecting to Datalogger
1. Get an instance:

```
/**
 - parameter delegate: Instance of implementing class of DLGatewayDelegate
*/

var gateway = DLGatewayInterface.getInstance()
gateway.setDelegate(delegate: self)
``` 

2. Scan for devices, scan results are received in delegate method of DLGatewayDelegate `onOBDDeviceFound`:

```
/**
 - parameter start: true to start scan and false to stop scan
*/
gateway.startScan(start: true)
```

3. Connect to device using the `deviceName` returned in `func onOBDDeviceFound(deviceName: String, identifier: String)`:

```
/**
 - parameter name: String (deviceName received in 'onOBDDeviceFound')
*/
gateway.connect(name: deviceName)
```

# Auto-Connect

SmartConnect SDK allows mobile app to connect to Datalogger automatically. To enable this feature, device must be set as favorite. SDK uses iBeacon Services and Location services to search for favorite datalogger. 

1. Set a device as favorite:

```
/**
 - parameter name: String (deviceName received in 'onOBDDeviceFound')
 - parameter identifier: String (identifier received in 'onOBDDeviceFound')
*/
gateway.setFavoriteDevice(name: deviceName, identifier: identifier)
```

2. To remove favorite device, use following method:

```gateway.forgetDevice()```

Auto-connect requires Bluetooth access and Location service enabled to "Always".<br /> Auto connect works in all states of mobile app(Active, InActive, Background, Suspended, Non-Running)<br />
Add ```gateway.enableiBeaconServices(isBeaconMonitoring: true)``` and ```gateway.startBackgroundScan(start: true)``` in ```func applicationDidEnterBackground(_ application: UIApplication)``` method to enable background wakeups<br />
Add required Privacy permission property keys in app's info.plist(Refer 'Getting started with iOS' section of Danlaw SmartConnect Installation guide)


# Get PID Data (Basic Channel)

Datalogger uses Basic channel to send data pids and custom pids. The request can be made as often as needed, and the data will be returned once for every request.<br /> Basic channel can be used to request data that does not require frequent update<br />
**Note:**<br />
- Basic channel executes each PIDs in sequential order. 

Data that can be requested using Basic channel:<br />
 1. Standard Pids (id: 0-255)<br />
 2. Danlaw's Custom PIDs (id: 256 and over)<br />
Refer 'List of Formatted PIDs' section of Danlaw SmartConnect Installation guide for a complete list of the PID IDs and its respective return Objects. 

Here is an example to request FuelLevel:

```
/**
 - parameter pid: Int (Pid Id)
*/
let isPidAvailable = gateway.readBasicPidData(pid: DLCommandPId.basic.fuelLevel)
```

SDK uses following method to respond with received PID data:

```
/**
 - parameter responseCode: Int (0 if success)
 - parameter pid: Int (Pid Id)
 - parameter object: DLBasicPIDObject
*/
func onBasicDataReceived(responseCode: Int, pid: Int, object: DLBasicPIDObject?){
    if responseCode != 0 {
       print("Response failed for pid:", " \(pid)")
    } else {
      switch pid {
        case DLCommandPId.basic.fuelLevel: //Fuel Level
            guard let fuelLevel = object as? DLFuelLevel else { return }
                if let fuel = fuelLevel.value {
                    print("\nFuel: \(fuel)")
                 }
         default:
             print("Basic data")
        }
     }
}
```

# Register PID Data for Continuous Updates (Advanced Channel)
Registering for PID allows to receive data continuously until the request is unregistered. 

A max of 5 PIDs can be registered in a single request.
Data that can be requested:
 - Only Standard PIDs (id: 0-255) are supported for continuous updates.
Refer 'List of Formatted PIDs' section of Danlaw SmartConnect Installation guide for a complete list of the PID IDs and its respective return Objects. 

An example to get continuous updates for the PIDs speed and engine rpm
```
/**
 - parameter DPid: constant Int value
 - parameter pids: [Int](Array of Pid Id)
*/

let dataPidId = 1
gateway.registerDataPid(DPid: dataPidId, pids: [DLCommandPId.basic.vehicleSpeed, DLCommandPId.basic.engineRPM])
```

SDK uses following method to respond with received Data Pid's data:

```
/**
 - parameter responseCode: Int (0 if success)
 - parameter DPid: Int (Constant)
 - parameter hashmap: Int - Pid Id, DLBasicPIDObject(Super class of all basic Object. Refer Page55-56 of Installation guide to see Object class for respective PID)
*/
func onDataPidDataReceived(responseCode: Int, DPid: Int, hashmap: [Int : DLBasicPIDObject]) {
        if responseCode != 0 {
            print("Received Failing Response Code")
            return }
        for (pid, object) in hashmap {
            switch pid {
            case DLCommandPId.basic.vehicleSpeed:
                guard let speed = object as? DLVehicleSpeed else {
                    return}
                if let value = speed.value {
                    print("\nVehicle Speed: \(value)")}
            case DLCommandPId.basic.engineRPM:
                guard let rpm = object as? DLEngineRPM else {
                    return}
                if let rpm = rpm.value {
                    print("\nEngineRPM: \(rpm)")}
            default:
                print("Data Pid received")
            }
        }
    }
```

Unregister Data Pids to stop receiving updates:
```
/**
 - parameter DPid: constant Int value that is used to register Data Pids
 - parameter pids: Array of Int(where Int is Pid Id. Eg. DLCommandPId.basic.vehicleSpeed)
 - returns: true or false
*/
let isPidsUnregistered = gateway.unregisterDataPid(DPid: dataPidId, pids: [DLCommandPId.basic.vehicleSpeed, DLCommandPId.basic.engineRPM])
```

# Realtime Events:

Registering for events allows to receive data in real-time when an event such as hard break, hard acceleration, cornering etc., is detected by the datalogger while the vehicle is being driven.<br /><br />

Realtime events can only be received if the mobile is connected to the Datalogger when the event occurred. If the datalogger is not connected to a mobile device, event is delivered as a part of UDP Event the next time a connection is established.<br /><br />

Data that can be requested:<br />

- Custom events pre defined by Danlaw's communication protocol.
Refer 'List of Formatted PIDs' section of Danlaw SmartConnect Installation guide for a complete list of the PID IDs and its respective return Objects.
A max of 5 event PIDs can be registered in a single request.

Here's an example to register hard break and hard acceleration events:

```
/**
 - parameter pids: [Int] (Array of Pid Id)
*/
let isEPidsRegistered = gateway.registerEventPid(pids: [DLEventID.hardBraking, DLEventID.hardAcceleration])
```

SDK uses following method to respond with received Event data:

```
/**
 - parameter responseCode: 0 if success
 - parameter EPid: Pid Id
 - parameter object: DLDataObject (Super class of all event Object. Refer Page.57 of Installation guide to see Object class for each event)
*/
func onEventPidDataReceived(responseCode: Int, EPid: Int, object: DLDataObject?) {
    if responseCode != 0 {
        print("Received Failing Response Code")
        return
     }else {
        switch EPid {
            case DLEventID.hardBraking: // Hard Braking
                guard let obj = object as? DLHardBrakingData else { return }
                if let messageHeader = obj.header {
                    print("Latitude: \(String(describing: messageHeader.lattitude)), Longitude: \(String(describing: messageHeader.longitude))")}
                if let startSpeedInMph = obj.initialSpeed, let endSpeedInMph = obj.finalSpeed, let maxDecelInMphrSec = obj.maxBraking {
                print("\nHard Brake Event:- StartSpeed(MpHr): \(startSpeedInMph), EndSpeed(MpHr): \(endSpeedInMph), MaxDecel: \(maxDecelInMphrSec)")}
            case DLEventID.hardAcceleration: // Hard Acceleration
                guard let obj = object as? DLHardAccelerationData else { return }
                if let messageHeader = obj.header {
                    print("Latitude: \(String(describing: messageHeader.lattitude)), Longitude: \(String(describing: messageHeader.longitude))")}
                if let startSpeedInMph = obj.initialSpeed, let endSpeedInMph = obj.finalSpeed, let maxAeccelInMphrSec = obj.maxAcceleration {
                print("\nHard Acceleration Event:- StartSpeed(MpHr): \(startSpeedInMph), EndSpeed(MpHr): \(endSpeedInMph), MaxAeccel: \(maxAeccelInMphrSec)")}
            default:
                print("Event Pids")
        }}
}
```

Unregister Event Pids to stop receiving updates:
```
/**
 - parameter pids: [Int](Array of Pid Id)
 - returns: true or false
*/
let isEventPidUnregistered = unregisterEventPid(pids: [DLEventID.hardBraking, DLEventID.hardAcceleration])
```

# UDP Events

Datalogger logs every event occured in realtime and sends it via UDP channel when datalogger is connected to mobile app. 
App cannot register or unregister for UDP events.<br />
By default mobile app acts as pass thru to send UDP events to Danlaw Server. But for datalogger with BLEAP configuration, UDP Events are delivered to the mobile app.

Data that can be received using UDP channel:<br />
 - Custom events pre defined by Danlaw's communication protocol<br />
 Refer 'List of Formatted PIDs' section of Danlaw SmartConnect Installation guide for a complete list of the PID IDs and its respective return Objects.<br />
 **Note:** Events have to be preconfigured in datalogger to receive udp events.
 

1. Set this flag to “false” to send acknowledgement manually.(Default value: true)

```
/**
 - parameter isAutoAcknowledgementOn: Bool (true by default)
*/
gateway.setAutoAcknowledgement(isAutoAcknowledgementOn: false)
```

**NOTE:**<br />
If app fails to send acknowledgement to datalogger, datalogger will keep sending same data again.<br />
Once acknowledgement is sent to datalogger, datalogger will erase that data from its memory.<br />

2. DLGatewayDelegate method to receive Parsed UDP Data:

```
/**
 - parameter udpMessages: [UDPMessage] (Properties of UDPMessage: messagePayload:Type of DLDataObject, messageId- type of Int)
 - parameter acknowledgementId: Data
*/
func onParsedUDPDataReceived(udpMessages: [UDPMessage], acknowledgementId: Data) {
    
    /// Send acknowledgement here if "isAutoAcknowledgementOn" is "false"
    
    gateway.udpPacketReceivedAcknowledgement(acknowledgementId: acknowledgementId)
    
    for message in udpMessages {
       let messagePayload = message.messagePayload // Type of DLDataObject
       let messageId = message.messageType // Type of Int
       switch messageId {
          case DLEventID.GPSMessage:
              guard let obj = messagePayload as? DLGPSMessage else { return }
              guard let messageHeader = obj.header else { return }
              if let time = messageHeader.time, let lat = messageHeader.lattitude, let long = messageHeader.longitude {                         print(“Latitude: \(lat), Longitude:\(long), time: \(time)”) }
               if let satellite = obj.noOfSatellite {
                  print(“No of Satellites: \(satellite)”)}
           // Handle more events here
          default:
            return       
        }              
     } 
}

```


# FAQ
-	**No such module ‘SmartConnectSDK’**  

    Go to project's target settings. Make sure SDK is imported in General-> Framework, Libraries and Embedded content as well as in Build Phases-> Link Binary with Library and Build Phases-> Embed frameworks.
  
-	**Module compiled with Swift 5.1 cannot be imported by the Swift compiler 5.0.1**

    Please make sure you are using Xcode11+ to compile and build this app. If you need support for older verison of Xcode, please contact mobile@danlawinc.com.
  
-	**“App” requires provisioning profile.**
    
    Please make sure you have provided Developer team and valid code signing info in project's settings. You can try 'Automatically manage signing'. SDK is not code signed. Select 'Embed & Sign' in imported Framework's settings.

-	**App keeps receiving same UDP Events.**
    
    If app fails to send acknowledgement to datalogger, datalogger will keep sending same data again. Make sure if app has `isAutoAcknowledgementOn` set to `true` or if app calls `udpPacketReceivedAcknowledgement` method to send acknowledgement manually.

- **Continuous Updates/Realtime event request failed.**

  Although you can register upto 5 PIDs per request, if any of the PIDs is not supported by the vehicle or if data is not available, the entire request fails.

  Try registering the PIDs individually to see which request fails.

  For example, instead of registering speed and rpm together in a single request, break it into 2 requests.

  ```
  let vehicleSpeedDPid = 1
  let _ = gateway?.registerDataPid(DPid: vehicleSpeedDPid, pids: [DLCommandPId.basic.vehicleSpeed])
        
   // Registering other PID after 1 sec delay to avoid receiving "Datalogger busy" error
   DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      let rpmDPid = 2
      let _ = self.gateway?.registerDataPid(DPid: rpmDPid, pids: [DLCommandPId.basic.engineRPM])
   }
   ```
**NOTE:** Only Standard PIDs(id: 0-255) are supported for continuous updates. Danlaw's Custom PIDs (id: 256 and over) must be requested everytime a new value is needed.

# Credits
SmartConnect sample app and SmartConnectSDK is owned by Danlaw Inc. A valid license is required to use Danlaw’s Smart Connect products. Licenses are issued by Danlaw on an annual basis for a rolling twelve-month effective time period. License fees established by Danlaw are comprised of a baseline minimum fee, plus a per device fee for each active device at the time of the annual Smart Connect license renewal. Please contact mobile@danlawinc.com for the Key and Licensing information.
