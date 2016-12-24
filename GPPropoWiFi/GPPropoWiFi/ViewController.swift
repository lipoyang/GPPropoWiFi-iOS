//
//  ViewController.swift
//  GPPropo
//
//  Created by Bizan Nishimura on 2016/04/19.
//  Copyright (C)2016 Bizan Nishimura. All rights reserved.
//

import UIKit

// WiFi status
enum WiFiStatus {
    case DISCONNECTED
    case CONNECTING
    case CONNECTED
}

// main view controller
class ViewController: UIViewController, PropoDelegate, WiFiCommListener {
    
    // WiFi Communication
    let mWiFiComm = WiFiComm.shared
    
    // WiFi status
    var wifiState = WiFiStatus.DISCONNECTED
    
    // 4WS Mode
    var mode4ws:Int = 0
    let MODE_FRONT:Int = 0
    let MODE_COMMON:Int = 1
    let MODE_REVERSE:Int = 2
    let MODE_REAR:Int = 3
    
    // Propo view
    var propoView: PropoView?
    
    // timer
    var timerCommandB : NSTimer!
    
    // on view loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // position of UIViewController.view
        let x:CGFloat = self.view.bounds.origin.x
        let y:CGFloat = self.view.bounds.origin.y
        // size of UIViewController.view
        let width:CGFloat = self.view.bounds.width
        let height:CGFloat = self.view.bounds.height
        // create a frame fit to UIViewController.view
        let frame:CGRect = CGRect(x: x, y: y, width: width, height: height)
        // create a propo view
        propoView = PropoView(frame: frame)
        propoView!.parent = self
        self.view.addSubview(propoView!)
        
        // WiFi Communication
        mWiFiComm.begin()
    }
    
    // on view will appear
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // 4WS Mode
        let ud = NSUserDefaults.standardUserDefaults()
        mode4ws = ud.integerForKey("mode4ws")
        
        // WiFi Communication
        mWiFiComm.setListener(self)
        
        wifiState = mWiFiComm.isConnected() ? WiFiStatus.CONNECTED : WiFiStatus.DISCONNECTED;
        propoView!.setBtStatus(wifiState);
        
        // 1sec cyclic timer
        timerCommandB = NSTimer.scheduledTimerWithTimeInterval(1.0,
            target: self,
            selector: #selector(ViewController.onTimer),
            userInfo: nil,
            repeats: true)
    }
    
    // on view will disappear
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        timerCommandB.invalidate()
        timerCommandB = nil
        
        mWiFiComm.clearListener()
    }
    
    // on memory warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // On touch PropoView's Bluetooth Button
    func onTouchBtButton()
    {
/*
        // Connecting
        if(mWiFiComm.isConnected()){
            wifiState = WiFiStatus.CONNECTING;
            propoView!.setBtStatus(wifiState);
    
            // search
        }
        // Disconnecting
        else {
            // disconnect
        }
*/
    }
    
    // On touch PropoView's Setting Button
    func onTouchSetButton()
    {
        // go to SettingActivity
        if(mWiFiComm.isConnected()){
            let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier( "setting" )
            self.presentViewController( targetViewController, animated: true, completion: nil)
        }
    }
    
    // On touch PropoView's FB Stick
    // fb = -1.0 ... +1.0
    func onTouchFbStick(fb: Float)
    {
        if(!mWiFiComm.isConnected()) {return}
    
        // send the Koshian a message.
        var bFB = (Int)(fb * 127);
        if(bFB<0) {bFB += 256}
        let command = String(format: "#D%02X$", bFB )
        NSLog("command;\(command)")
        mWiFiComm.sendString(command)
    }
    
    // On touch PropoView's LR Stick
    // lr = -1.0 ... +1.0
    func onTouchLrStick(lr: Float)
    {
        if(!mWiFiComm.isConnected()) {return}
    
        // send the Koshian a message.
        var bLR = (Int)(lr * 127);
        if(bLR<0) {bLR += 256}
        let command = String(format: "#T%02X%1d$", bLR, mode4ws )
        NSLog("command;\(command)")
        mWiFiComm.sendString(command)
    }
    
    // On connect to GPduinoWiFi
    func onConnect()
    {
        NSLog("connectedHandler")
        self.wifiState = WiFiStatus.CONNECTED;
        self.propoView!.setBtStatus(self.wifiState);
    }
    
    // On disconnect from GPduinoWiFi
    func onDisconnect()
    {
        NSLog("disconnectedHandler")
        self.wifiState = WiFiStatus.DISCONNECTED;
        self.propoView!.setBtStatus(self.wifiState);
    }
    
    // On receive data from GPduinoWiFi
    func onReceive(data:[UInt8])
    {
        
    }
    
    // on 1sec timer
    func onTimer(sender:NSTimer)
    {
        if(mWiFiComm.isConnected()){
            timerCommandB.invalidate()
        }else{
            let command = "#B$"
            mWiFiComm.sendString(command)
        }
    }
}

