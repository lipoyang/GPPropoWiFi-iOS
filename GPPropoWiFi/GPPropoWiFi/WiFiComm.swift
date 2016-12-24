//
//  WiFiComm.swift
//  GPPropoWiFi
//
//  Created by Bizan Nishimura on 2016/12/19.
//  Copyright (C)2016 Bizan Nishimur. All rights reserved.
//

import Foundation


//import Cocoa
import CocoaAsyncSocket

// Event Listener of WiFi Communication
protocol WiFiCommListener {
    
    func onConnect();
    func onDisconnect();
    func onReceive(data:[UInt8]);
}

// WiFi Communication Class
class WiFiComm : NSObject, GCDAsyncUdpSocketDelegate{
    
    // event listener
    var mWiFiCommListener : WiFiCommListener!
    // is connected to GPduino WiFi
    var mIsConnected:Bool = false
    // WiFi Thread Flag
    var mThreadFlag:Bool = false
    // GPduino WiFi's IP Address
    let REMOTE_IP:String = "192.168.4.1"
    // local & remote port number
    let REMOTE_PORT:UInt16 = 0xC000
    let LOCAL_PORT:UInt16  = 0xC001
    // timer
    var mTimer : NSTimer!
    // count for no data
    var cntNoData:Int = 0
    
    // UDP Socket
    var _socket: GCDAsyncUdpSocket?
    var socket: GCDAsyncUdpSocket? {
        get {
            if _socket == nil {
                let sock = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
                do {
                    try sock.bindToPort(LOCAL_PORT)
                    try sock.beginReceiving()
                } catch let err as NSError {
                    NSLog(">>> Error while initializing socket: \(err.localizedDescription)")
                    sock.close()
                    return nil
                }
                _socket = sock
            }
            return _socket
        }
        set {
            _socket?.close()
            _socket = newValue
        }
    }
    
    /************************************************************
     *  for Singleton
     ************************************************************/
    
    // static instance for singleton
    static let shared = WiFiComm()
    
    // private constructor for singleton
    private override init() {
    }
    
    /************************************************************
     *  Public APIs
     ************************************************************/
    
    // begin WiFi
    func begin() {
        mIsConnected = false;
        
        // 500msec cyclic timer
        mTimer = NSTimer.scheduledTimerWithTimeInterval(
            0.5,
            target: self,
            selector: #selector(WiFiComm.onTimer),
            userInfo: nil,
            repeats: true)
    }
    
    // terminate WiFi
    func terminate() {
        mTimer.invalidate()
        socket = nil
    }
    
    // set event listener
    func setListener(listener : WiFiCommListener){
        mWiFiCommListener = listener;
    }
    
    // clear event listener
    func clearListener(){
        mWiFiCommListener = nil;
    }
    
    // is connected to GPduino WiFi
    func isConnected() -> Bool {
        return mIsConnected
    }
    
    // write data to GPduino WiFi
    func send(data:[UInt8])
    {
        guard socket != nil else {
            return
        }
        socket?.sendData( NSData(bytes: data, length: data.count),
                          toHost: REMOTE_IP, port: REMOTE_PORT, withTimeout: 2, tag: 0)
    }
    
    // write string data to GPduino WiFi
    func sendString(stData:String)
    {
        // String -> NSData
        if let nsData: NSData = stData.dataUsingEncoding(NSUTF8StringEncoding)
        {
            // NSData -> Array<UInt8>
            var bData = Array<UInt8>(count: nsData.length, repeatedValue: 0)
            nsData.getBytes(&bData, length: nsData.length)
            
            // send data
            send(bData)
        }
    }
    
    // on received
    func udpSocket(
        sock: GCDAsyncUdpSocket,
        didReceiveData data: NSData,
        fromAddress address: NSData,
        withFilterContext filterContext: AnyObject?)
    {
        var host: NSString?
        var port1: UInt16 = 0
        GCDAsyncUdpSocket.getHost(&host, port: &port1, fromAddress: address)
        
        // from GPduino WiFi?
        if(host == REMOTE_IP){
            // connected!
            cntNoData = 0
            if(!mIsConnected){
                //if(DEBUGGING) Log.e(TAG, "mReceivingThread: connected!");
                mIsConnected = true
                mWiFiCommListener?.onConnect()
            }
            
            var bytedata = Array<UInt8>(count: data.length, repeatedValue: 0)
            data.getBytes(&bytedata, length: data.length)
            
            mWiFiCommListener?.onReceive(bytedata)
        }
    }
    
    // on 500msec timer
    func onTimer(sender:NSTimer) {
        if(mIsConnected){
            //NSLog("onTimer")
            cntNoData += 1
            if(cntNoData>=6){
                mIsConnected = false
                mWiFiCommListener?.onDisconnect()
            }
        } else {
            cntNoData = 0
        }
    }
}
