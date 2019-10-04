//
//  LaunchScreenVC.swift
//  Danlaw SDK Sample App
//
//  Created by Danlaw on 6/14/18.
//  Copyright © 2018 Danlaw. All rights reserved.
//

import UIKit
import SmartConnectSDK

class LaunchScreenVC: UIViewController,DLAuthDelegate {
    //Object reference of gatewayInterfaceInstance protocal
    var gatewayDelegate: gatewayInterfaceInstance?
    var apiKey = "YOUR_API_KEY"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        //Making Authenticaion request in order to get instance of GatewayInterface. Please check Danlaw SDK document for more info. If don't have Auth token please contact mobile@danlawinc.com to get the IOS Mobile frameworks and the API KEY for you to be using before start developing application.

        DispatchQueue.main.async {
            //Please use APi Key provided by danlaw
            //App won't start in this condition So please request new Token from  mobile@danlawinc.com and make sure you have internet connection
            DLAuthInterface.sharedInstance.validateToken(apiKey: self.apiKey, issuedTo: Bundle.main, delegate: self)
        }
    }
    
    //Authentication callback Once it's sucess will naviagte to SmartConnectSdkVC.
    //Please check SDK Danlaw SDK document for more info.
    func onAuthenticationResult(authenticationResult: Int, message: String) {
        
        DispatchQueue.main.async {
            if authenticationResult == 200{
                //we are directing to SmartConnectSdkVC once got 200 request
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "smartConnectSdkVC") as? SmartConnectSdkVC
                {
                    //confirming delegate
                    self.gatewayDelegate = vc.self
                    self.gatewayDelegate?.getwayGetInstance()
                    //Navigating to Main Screen After getting GatewayInstance
                    let navController = UINavigationController(rootViewController: vc)
                    navController.modalPresentationStyle = .fullScreen
                    self.present(navController, animated:true, completion: nil)
                }
                
            }else{
                
                print(message)
                
                //display alert or some custom action
                //App won't start in this condition So please request new Token from  mobile@danlawinc.com and make sure you have internet connection
                
            }
        }
    }
    
    
}
//Once Authentication validation successful trying to get GatewayInstance and for that added bellow protocal that can be implemented in SmartConnectSdkVC
protocol gatewayInterfaceInstance{
    func getwayGetInstance()
}
