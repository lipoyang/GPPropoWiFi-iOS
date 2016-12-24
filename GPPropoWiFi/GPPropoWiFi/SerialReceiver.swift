//
//  SerialReceiver.swift
//  GPPropo
//
//  Created by Bizan Nishimura on 2016/06/04.
//  Copyright (C)2016 Bizan Nishimura. All rights reserved.
//

import UIKit

// event lisntener
protocol SerialDelegate {
    
    // On received a serial command
    func onCommandReceived(data:[UInt8]);
}

class SerialReceiver {
    
    // receiving state
    var rxState:Int
    let STATE_READY:Int = 0
    let STATE_RECEIVING:Int = 1
    
    // receiving buffer
    var rxPtr:Int
    var rxBuff = [UInt8](count:1024, repeatedValue: 0)
    
    // start of text / end of text
    let STX_CODE:UInt8 = "#".utf8.first! //0x23
    let ETX_CODE:UInt8 = "$".utf8.first! //0x24
    
    var listener:SerialDelegate?
    
    // constructor
    init()
    {
        rxState = STATE_READY;
        rxPtr = 0;
    }
    
    // receiving
    func put(data:[UInt8])
    {
        //let dataNS: NSData = dataStr.dataUsingEncoding(NSUTF8StringEncoding)!
        //var data = Array<UInt8>(count: dataNS.length, repeatedValue: 0)
        //dataNS.getBytes(&data, length: dataNS.length)
        
        var c:UInt8
        
        for i in 0..<data.count
        {
            c = data[i];
            
            switch (rxState)
            {
            case STATE_READY:
                if (c == STX_CODE)
                {
                    rxState = STATE_RECEIVING;
                    rxPtr = 0;
                }
                break;
            case STATE_RECEIVING:
                if (c == STX_CODE)
                {
                    rxPtr = 0;
                }
                else if (c == ETX_CODE)
                {
                    // call event handler
                    rxBuff[rxPtr] = 0; // "\0"
                    listener!.onCommandReceived(rxBuff);
                    rxState = STATE_READY;
                }
                else
                {
                    rxBuff[rxPtr] = c;
                    rxPtr += 1
                    if (rxPtr >= 5000)
                    {
                        rxState = STATE_READY;
                    }
                }
                break;
            default:
                rxState = STATE_READY;
                break;
            }
        }
    }
    
    // set event listener
    func setListener(listener:SerialDelegate){
        self.listener = listener;
    }
}

