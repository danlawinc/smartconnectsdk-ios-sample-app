# smartconnectsdk-ios-sample-app
This sample app is quick guide on how to start using SmartConnectSDK in your app.

# Feature
- [x] Scan Devices
- [x] Bluetooth Enable/Disable
- [x] Autoconnect Devices
- [x] Connect/Disconnect Devices
- [x] Set Favorite/Forget Devices
- [x] Firmware Update
- [x] Register/Unregister Pids
- [x] Create/Remove Notifications
- [x] Configure/Remove wi-fi



# Requirements
- iOS 10.0+
- Xcode 11.0+
- Swift 5.0+


# Installation
- Create Framework directory inside your Project's root folder. Copy-paste iOS SDK provided by Danlaw. 
- Go to Project's Target settings and import framework from the directory.
- Replace ApiKey issued by Danlaw in 'LaunchScreenVC'


# Component Library
- DLAuthInterface: This class AuthInterface provides the entry point for the SDK. The hosting application should call the interface method validateToken to get the SDK authenticated. If the SDK is not authenticated, then none of the services that are offered by the SDK will be available.
- DLGatewayInterface: This class handles communication between the app and the SDK. It provides the outward facing methods for interacting with the Danlaw iOS SDK.
- DLGatewayDelegate: This protocol `protocol DLGatewayDelegate` defines the callbacks required for the delegate on the `DLGatewayInterface`.

# FAQ
-	**No such module ‘SmartConnectSDK’**  

    Go to project's target settings. Make sure SDK is imported in General-> Framework, Libraries and Embedded content as well as in Build Phases-> Link Binary with Library and Build Phases-> Embed frameworks.
  
-	**Module compiled with Swift 5.1 cannot be imported by the Swift compiler 5.0.1**

    Please make sure you are using Xcode11+ to compile and build this app. If you need support on older verison of Xcode, please contact mobile@danlawinc.com.
  
-	**“App” requires provisioning profile.**
    
    Please make sure you have provided Developer team and valid code signin info in project's settings. You can try 'Automatically manage signing'. SDK is not code signed. Select 'Embed & Sign' in imported Framework's settings.


# Credits
SmartConnect sample app and SmartConnectSDK is owned by Danlaw Inc. A valid license is required to use Danlaw’s Smart Connect products. Licenses are issued by Danlaw on an annual basis for a rolling twelve-month effective time period. License fees established by Danlaw are comprised of a baseline minimum fee, plus a per device fee for each active device at the time of the annual Smart Connect license renewal. Please contact mobile@danlawinc.com for the Key and Licensing information.
