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
7. [Basic PIDs](#basic-pids)
8. [Advanced PIDs](#advanced-pids)
9. [Data PIDs](#data-pids)
10.[UDP Events](#udp-events)
11. [FAQ](#faq)
12.[Credits](#credits)



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
- Replace ApiKey issued by Danlaw in 'LaunchScreenVC'

```import SmartConnectSDK``` in swift file to access framework.

# Component Library
- DLAuthInterface: This class AuthInterface provides the entry point for the SDK. The hosting application should call the interface method validateToken to get the SDK authenticated. If the SDK is not authenticated, then none of the services that are offered by the SDK will be available.
- DLGatewayInterface: This class handles communication between the app and the SDK. It provides the outward facing methods for interacting with the Danlaw iOS SDK.
- DLGatewayDelegate: This protocol `protocol DLGatewayDelegate` defines the callbacks required for the delegate on the `DLGatewayInterface`.

# Authentication
After installing the SDK, **you MUST authenticate it before you can use all the interfaces**. 
To authenticate the SDK, use the following method where `apiKey:` is "APiKey" issued by Danlaw, `issuedTo:` is project's main bundle and `delegate:` is instance of implementation class of `DLAuthDelegate`.

```
DLAuthInterface.sharedInstance.validateToken(apiKey: self.apiKey, issuedTo: Bundle.main, delegate: self)
```
Once you get response code 200 in delegate method `func onAuthenticationResult(authenticationResult: Int, message: String)`, app will be able to access SmartConnectSDK. 

# Connecting to Datalogger
1. Get an instance:

```
do {
    var gateway:DLGatewayInterface
    try gateway = DLGatewayInterface.getInstance()
    gateway.setDelegate(delegate: self)
}catch DLException.SdkNotAuthenticatedException(let error) {
    print(error)
}
``` 

2. Scan for devices, scan results are received in delegate method of DLGatewayDelegate ```func onOBDDeviceFound(deviceName: String, identifier: String)```

```gateway.startScan(start: true)```

3. Connect to device using the `deviceName` returned in `onOBDDeviceFound`:

```gateway.connect(name: deviceName)```

# Auto-Connect

1. Set favorite device to connect app to device automatically:

```gateway.setFavoriteDevice(name: deviceName, identifier: identifier)```

2. To remove favorite device, use following method:

```gateway.forgetDevice()```

# Reading Events/PIDs from Device

# FAQ
-	**No such module ‘SmartConnectSDK’**  

    Go to project's target settings. Make sure SDK is imported in General-> Framework, Libraries and Embedded content as well as in Build Phases-> Link Binary with Library and Build Phases-> Embed frameworks.
  
-	**Module compiled with Swift 5.1 cannot be imported by the Swift compiler 5.0.1**

    Please make sure you are using Xcode11+ to compile and build this app. If you need support for older verison of Xcode, please contact mobile@danlawinc.com.
  
-	**“App” requires provisioning profile.**
    
    Please make sure you have provided Developer team and valid code signing info in project's settings. You can try 'Automatically manage signing'. SDK is not code signed. Select 'Embed & Sign' in imported Framework's settings.


# Credits
SmartConnect sample app and SmartConnectSDK is owned by Danlaw Inc. A valid license is required to use Danlaw’s Smart Connect products. Licenses are issued by Danlaw on an annual basis for a rolling twelve-month effective time period. License fees established by Danlaw are comprised of a baseline minimum fee, plus a per device fee for each active device at the time of the annual Smart Connect license renewal. Please contact mobile@danlawinc.com for the Key and Licensing information.
