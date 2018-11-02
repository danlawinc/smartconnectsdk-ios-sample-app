//
//  AppDelegate.swift
//  DanlawSDKSampleApp
//
//  Created by Danlaw on 6/14/18.
//  Copyright © 2018 Danlaw. All rights reserved.
//

import UIKit
import SmartConnectSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var strLabel = UILabel()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
       
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        do {
            //This method enables background wakeups for Beacon Region monitoring.
            try DLGatewayInterface.getInstance().enableiBeaconServices(isBeaconMonitoring: true)
            //It will be usefull to restore state of ble
            try DLGatewayInterface.getInstance().startBackgroundScan(start: true)
        } catch let error {
            print(error)
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //Adding Activity Indicator while Scanning in progress
    @objc  func showActivity(_ Messeage: String, onview: UIView) {
        DispatchQueue.main.async(execute: {() -> Void in
  
            self.strLabel.removeFromSuperview()
            
            self.loadingView.frame =  CGRect(x: 0, y: 0, width: 60, height: 60)
            self.loadingView.center = CGPoint(x: onview.frame.size.width / 2, y: onview.frame.size.height / 2 + 10);
            self.loadingView.backgroundColor = self.UIColorFromHex(rgbValue: 0x444444, alpha: 0.7)
            self.loadingView.clipsToBounds = true
            self.loadingView.layer.cornerRadius = 10
            
            self.strLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 160, height: 46))
            self.strLabel.text = Messeage
            self.strLabel.center = CGPoint(x: self.loadingView.frame.origin.x+70, y: self.loadingView.frame.size.height / 2);
            self.strLabel.font = .systemFont(ofSize: 14, weight: .medium)
            self.strLabel.textColor = UIColor.gray

            
            self.activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
            self.activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
            self.activityIndicator.center = CGPoint(x: self.loadingView.frame.size.width / 2, y: self.loadingView.frame.size.height / 2);
            self.loadingView.addSubview(self.activityIndicator)
            
            onview.addSubview(self.loadingView)
            onview.addSubview(self.strLabel)
            self.activityIndicator.startAnimating()
        })
    }
    
    //Hiding Activity indicator after scanning complete
    @objc   func hideActivity() {
        DispatchQueue.main.async(execute: {() -> Void in
            self.activityIndicator.stopAnimating()
            self.loadingView.removeFromSuperview()
            self.strLabel.text = ""
        })
    }
    
    //Custom color for activity background 
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }

}

