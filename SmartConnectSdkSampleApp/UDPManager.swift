//
//  UDPManager.swift
//  SdkSampleApp
//
//  Created by Komal Sanghani on 10/10/19.
//  Copyright © 2019 Tharun Nallamothu. All rights reserved.
//

import Foundation
import SmartConnectSDK

class UDPManager: DLBleapUDPDataDelegate {
    
    //var eventData: DLEventData
    var bleapInterface: DLBleapInterface
    //var fotaDelegate: DLFotaUpdateDelegate?
    var isAcknowledgementSent = true
    var udpDelegate: UDPDataDelegate?
    
    init(bleapInterface: DLBleapInterface) {
        self.bleapInterface = bleapInterface
        bleapInterface.onAutoSendAcknowledgement(onSendAcknowledgement: isAcknowledgementSent) // if setting "onSendAcknowledgement" to "false", uncomment code in "onBleapRawUDPDataReceived" method
        
        if let _ = udpDelegate {
            print("udp delegate is not nil")
        }
    }
    
    // MARK: - UDP Data Received for Bleap device - Callback Method
        
        func onBleapRawUDPDataReceived(rawUDPData: Data, acknowledgementId: Data) {
         
            /// Do not delete commentented code below, refer init section or SmartConnect Guide. Acknowledgement has to be sent to Datalogger, either automatically or manually
    //        DispatchQueue.global(qos: .background).async {
    //            self.bleapInterface.udpPacketReceivedAcknowledgement(acknowledgementId: acknowledgementId)
    //        }
        }
        
        func onBleapUDPDataParsed(udpMessages: [UDPMessage], acknowledgementId: Data) {
            
            /// Send acknowledgement here or in "onBleapRawUDPDataReceived" method if "onSendAcknowledgement" is "false" in init()
            
            print("bleap received")
            DispatchQueue.global(qos: .utility).async {
                
                let eventGroup = DispatchGroup()
                eventGroup.enter()
                
                for message in udpMessages {
                    
                    let messagePayload = message.messagePayload
                    let messageId = message.messageType
                    
                    self.eventDataReceived(EPid: messageId, object: messagePayload) // For UDP Channel
                }
                eventGroup.leave()
            }
        }

        ///this callback is to download firware update for bleap devices
        func fotaDowloadRequest(responseCode: Int) {
            
            
        }
    
    // MARK:- Event Pids Data received
    
    func eventDataReceived(EPid: Int, object: DLDataObject?) {
        
        switch EPid {
        
        case DLEventID.GPSMessage:
            
            print("gps msg received")
            guard let obj = object as? DLGPSMessage else {
                return
            }
            guard let messageHeader = obj.header else {
                return
            }
            if let time = messageHeader.time, let lat = messageHeader.lattitude, let long = messageHeader.longitude {
                setGPSMessage(timestamp: time, lat: lat, long: long)
            }
           // Handle more events here
        default:
            return
            
        }
    }
    
    func setGPSMessage(timestamp: Date,lat: Double, long: Double){
        
        print("set gps msg")
        print(lat)
        print(long)
        print(timestamp)
        let latitude = "\(lat)"
        let longitude = "\(long)"
        let date = displayDateFormat(withDate: timestamp)
        udpDelegate?.updateGPSMessageData(latitude: latitude, longitude: longitude, date: date)
    }
    
    func displayDateFormat(withDate: Date) -> String {
        let formatter = DateFormatter()
        let current = Calendar.current
        let dateComponents = current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: withDate)
        let startTime = current.date(from: dateComponents)
        formatter.dateFormat = "M/d/yy h:mm:ss a"
        let displayTime = formatter.string(from: startTime!)
        return displayTime
    }
}
