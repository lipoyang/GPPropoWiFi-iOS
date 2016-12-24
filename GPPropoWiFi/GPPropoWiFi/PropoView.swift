//
//  PropoView.swift
//  GPPropo
//
//  Created by Bizan Nishimura on 2016/04/19.
//  Copyright (C)2016 Bizan Nishimura. All rights reserved.
//

import UIKit

// Propo event lisntener
protocol PropoDelegate{
    // On touch PropoView's Bluetooth Button
    func onTouchBtButton()
    // On touch PropoView's Setting Button
    func onTouchSetButton()
    // On touch PropoView's FB Stick
    // fb = -1.0 ... +1.0
    func onTouchFbStick(fb: Float)
    // On touch PropoView's LR Stick
    // lr = -1.0 ... +1.0
    func onTouchLrStick(lr: Float)
}

// Propo view
class PropoView: UIView {
    // screen size of the original design
    let W_SCREEN : Float = 1184;
    let H_SCREEN : Float = 720;
    // Bluetooth button size
    var W_BT_BUTTON : Float = 240;
    var H_BT_BUTTON : Float = 106;
    // Bluetooth button base point
    var X_BT_BUTTON : Float! // = W_SCREEN/2 - W_BT_BUTTON/2;
    var Y_BT_BUTTON : Float = 107; // (54 + 106/2)
    // Setting button size
    var W_SET_BUTTON : Float = 150;
    var H_SET_BUTTON : Float = 150;
    // Setting button base point (left-top)
    var X_SET_BUTTON : Float! // = W_SCREEN/2 - W_SET_BUTTON/2;
    var Y_SET_BUTTON : Float = 605; // (530 + 150/2)
    // bar diameter
    var W_BAR : Float = 84;
    var H_BAR : Float = 84;
    // F<->B bar radius and length of movement (half)
    var R_FB_BAR : Float = 42;
    var L_FB_BAR : Float = 173; //(range/2 - radius/2)
    // F<->B bar neutral point
    var X_FB_BAR : Float = 296;
    var Y_FB_BAR : Float = 377;
    // L<->R bar radius and length of movement (half)
    var R_LR_BAR : Float = 42;
    var L_LR_BAR : Float = 173; //(range/2 - radius/2)
    // L<->R bar neutral point
    var X_LR_BAR : Float = 888;
    var Y_LR_BAR : Float = 377;
    // margin of bar touch range
    var MARGIN_BAR : Float = 50;

    // handle of touch point
    var fbTouch : UITouch!	// touch on F<->B bar
    var lrTouch : UITouch!	// touch on L<->R bar
    var btTouch : UITouch!	// touch on Bluetooth button
    var setTouch : UITouch! // touch on Setting button

    // position of F<->B bar, L<->R bar
    var fb_y : Float!
    var lr_x : Float!
    
    // Bluetooth state
    var wifiState = WiFiStatus.DISCONNECTED
    
    // image objects
    var imgBar : UIImage!
    var imgDisconnected : UIImage!
    var imgConnecting : UIImage!
    var imgConnected : UIImage!
    var imgSetting : UIImage!
    var viewBarFB : UIImageView!
    var viewBarLR : UIImageView!
    var viewBtButton : UIImageView!
    var viewSetButton : UIImageView!
    
    // view controller (parent)
    var parent : PropoDelegate!
    
    // initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // set background image
        UIGraphicsBeginImageContext(self.frame.size)
        UIImage(named: "bg")?.drawInRect(self.bounds)
        let image: UIImage! = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.backgroundColor = UIColor(patternImage: image)
        
        // scale factor
        let W = Float(self.bounds.width)
        let H = Float(self.bounds.height)
        let xScale : Float = W / W_SCREEN;
        let yScale : Float = H / H_SCREEN;
        
        // Bluetooth button size
        W_BT_BUTTON *= xScale;
        H_BT_BUTTON *= yScale;
        // Bluetooth button base point
        X_BT_BUTTON = Float(self.bounds.width)/2;
        Y_BT_BUTTON *= yScale;
        
        // Setting button size
        W_SET_BUTTON *= xScale;
        H_SET_BUTTON *= yScale;
        // Setting button base point
        X_SET_BUTTON = Float(self.bounds.width)/2;
        Y_SET_BUTTON *= yScale;
        
        // Bar Dimameter
        W_BAR *= xScale;
        H_BAR *= yScale;
        
        // F<->B bar radius and length of movement (half)
        R_FB_BAR *= xScale;
        L_FB_BAR *= yScale; //(range/2 - radius/2)
        // F<->B bar neutral point
        X_FB_BAR *= xScale;
        Y_FB_BAR *= yScale;
        
        // L<->R bar radius and length of movement (half)
        R_LR_BAR *= yScale;
        L_LR_BAR *= xScale; //(range/2 - radius/2)
        // L<->R bar neutral point
        X_LR_BAR *= xScale;
        Y_LR_BAR *= yScale;
        
        // margin of bar touch range
        MARGIN_BAR *= xScale;
        
        // initial position of sticks
        fb_y = Y_FB_BAR;
        lr_x = X_LR_BAR;
        
        // load images
        imgBar = UIImage(named: "bar")
        imgDisconnected = UIImage(named: "disconnected")
        //imgDisconnected = UIImage(named: "connected") // for debug
        imgConnecting = UIImage(named: "connecting")
        imgConnected = UIImage(named: "connected")
        imgSetting = UIImage(named: "setting")
        
        // set images
        viewBarFB = UIImageView(frame: CGRectMake(0,0,CGFloat(W_BAR),CGFloat(H_BAR)))
        viewBarLR = UIImageView(frame: CGRectMake(0,0,CGFloat(W_BAR),CGFloat(H_BAR)))
        viewBtButton = UIImageView(frame: CGRectMake(0,0,CGFloat(W_BT_BUTTON),CGFloat(H_BT_BUTTON)))
        viewSetButton = UIImageView(frame: CGRectMake(0,0,CGFloat(W_SET_BUTTON),CGFloat(H_SET_BUTTON)))
        viewBarFB.image = imgBar
        viewBarLR.image = imgBar
        viewBtButton.image = imgDisconnected
        viewSetButton.image = imgSetting
        viewBarFB.layer.position = CGPoint(x: CGFloat(X_FB_BAR), y: CGFloat(fb_y    ))
        viewBarLR.layer.position = CGPoint(x: CGFloat(lr_x    ), y: CGFloat(Y_LR_BAR))
        viewBtButton.layer.position = CGPoint(x: CGFloat(X_BT_BUTTON), y: CGFloat(Y_BT_BUTTON))
        viewSetButton.layer.position = CGPoint(x: CGFloat(X_SET_BUTTON), y: CGFloat(Y_SET_BUTTON))
        self.addSubview(viewBarFB)
        self.addSubview(viewBarLR)
        self.addSubview(viewBtButton)
        self.addSubview(viewSetButton)
        
        // enable multi touch
        self.userInteractionEnabled = true;
        self.multipleTouchEnabled = true;
        fbTouch = nil
        lrTouch = nil
        btTouch = nil
        setTouch = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // set Bluetooth State
    func setBtStatus(state: WiFiStatus)
    {
        wifiState = state;
        self.setNeedsDisplay()
    }

    // on draw
    override func drawRect(rect: CGRect) {
        
        // Bluetooth button
        switch(wifiState){
        case WiFiStatus.CONNECTING:
            viewBtButton.image = imgConnecting
            break;
        case WiFiStatus.CONNECTED:
            viewBtButton.image = imgConnected
            break;
        case WiFiStatus.DISCONNECTED:
            viewBtButton.image = imgDisconnected
            break;
        }
        // Setting Button
        viewSetButton.layer.position = CGPoint(x: CGFloat(X_SET_BUTTON), y: CGFloat(Y_SET_BUTTON))
        // F<->B bar
        viewBarFB.layer.position = CGPoint(x: CGFloat(X_FB_BAR), y: CGFloat(fb_y    ))
        // L<->R bar
        viewBarLR.layer.position = CGPoint(x: CGFloat(lr_x    ), y: CGFloat(Y_LR_BAR))
    }

    // on touches begun
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch: UITouch in touches {
            
            // get the touch point
            let tx:Float = Float(touch.locationInView(self).x)
            let ty:Float = Float(touch.locationInView(self).y)
            
            // (1) touch F<->B bar?
            if(fbTouch == nil) {
                if( (tx > (X_FB_BAR - R_FB_BAR - MARGIN_BAR)) &&
                    (tx < (X_FB_BAR + R_FB_BAR + MARGIN_BAR)) &&
                    (ty > (Y_FB_BAR - L_FB_BAR - R_FB_BAR - MARGIN_BAR*2)) &&
                    (ty < (Y_FB_BAR + L_FB_BAR + R_FB_BAR + MARGIN_BAR*2)))
                {
                    fbTouch = touch
                    
                    // message to the main activity
                    //   F<->B value (-1.0 ... +1.0)
                    fb_y = ty;
                    if(fb_y < Y_FB_BAR - L_FB_BAR) {fb_y = Y_FB_BAR - L_FB_BAR}
                    if(fb_y > Y_FB_BAR + L_FB_BAR) {fb_y = Y_FB_BAR + L_FB_BAR}
                    let fb: Float = -(fb_y - Y_FB_BAR) / L_FB_BAR;
                    parent.onTouchFbStick(fb);
                }
            }
            // (2) touch L<->R bar?
            if(lrTouch == nil) {
                if( (tx > (X_LR_BAR - L_LR_BAR - R_LR_BAR - MARGIN_BAR*2)) &&
                    (tx < (X_LR_BAR + L_LR_BAR + R_LR_BAR + MARGIN_BAR*2)) &&
                    (ty > (Y_LR_BAR - R_LR_BAR - MARGIN_BAR)) &&
                    (ty < (Y_LR_BAR + R_LR_BAR + MARGIN_BAR)))
                {
                    lrTouch = touch
                    
                    // message to the main activity
                    //   L<->R value (-1.0 ... +1.0)
                    lr_x = tx;
                    if(lr_x < X_LR_BAR - L_LR_BAR) {lr_x = X_LR_BAR - L_LR_BAR}
                    if(lr_x > X_LR_BAR + L_LR_BAR) {lr_x = X_LR_BAR + L_LR_BAR}
                    let lr: Float = (lr_x - X_LR_BAR) / L_LR_BAR;
                    parent.onTouchLrStick(lr);
                }
            }
            // (3) touch Bluetooth button?
            if(btTouch == nil){
                if( (tx >= (X_BT_BUTTON - W_BT_BUTTON/2)) &&
                    (tx <= (X_BT_BUTTON + W_BT_BUTTON/2)) &&
                    (ty >= (Y_BT_BUTTON - H_BT_BUTTON/2)) &&
                    (ty <= (Y_BT_BUTTON + H_BT_BUTTON/2)))
                {
                    btTouch = touch
                }
            }
            // (4) touch Setting button?
            if(setTouch == nil){
                if( (tx >= (X_SET_BUTTON - W_SET_BUTTON/2)) &&
                    (tx <= (X_SET_BUTTON + W_SET_BUTTON/2)) &&
                    (ty >= (Y_SET_BUTTON - H_SET_BUTTON/2)) &&
                    (ty <= (Y_SET_BUTTON + H_SET_BUTTON/2)))
                {
                    setTouch = touch
                }
            }
        }
        // redraw
        self.setNeedsDisplay()
    }
    
    // on touches moved
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch: UITouch in touches {
            
            // get the touch point
            let tx:Float = Float(touch.locationInView(self).x)
            let ty:Float = Float(touch.locationInView(self).y)
            
            // (1) move F<->B bar?
            if(touch === fbTouch)
            {
                if( (tx > (X_FB_BAR - R_FB_BAR - MARGIN_BAR)) &&
                    (tx < (X_FB_BAR + R_FB_BAR + MARGIN_BAR)) &&
                    (ty > (Y_FB_BAR - L_FB_BAR - R_FB_BAR - MARGIN_BAR*2)) &&
                    (ty < (Y_FB_BAR + L_FB_BAR + R_FB_BAR + MARGIN_BAR*2)))
                {
                    fb_y = ty;
                    if(fb_y < Y_FB_BAR - L_FB_BAR) {fb_y = Y_FB_BAR - L_FB_BAR}
                    if(fb_y > Y_FB_BAR + L_FB_BAR) {fb_y = Y_FB_BAR + L_FB_BAR}
                }else{
                    fbTouch = nil
                    fb_y = Y_FB_BAR;
                }
                // message to the main activity
                //   F<->B value (-1.0 ... +1.0)
                let fb: Float = -(fb_y - Y_FB_BAR) / L_FB_BAR;
                parent.onTouchFbStick(fb);
            }
            // (2) move L<->R bar
            else if(touch === lrTouch)
            {
                if( (tx > (X_LR_BAR - L_LR_BAR - R_LR_BAR - MARGIN_BAR*2)) &&
                    (tx < (X_LR_BAR + L_LR_BAR + R_LR_BAR + MARGIN_BAR*2)) &&
                    (ty > (Y_LR_BAR - R_LR_BAR - MARGIN_BAR)) &&
                    (ty < (Y_LR_BAR + R_LR_BAR + MARGIN_BAR)))
                {
                    lr_x = tx;
                    if(lr_x < X_LR_BAR - L_LR_BAR) {lr_x = X_LR_BAR - L_LR_BAR}
                    if(lr_x > X_LR_BAR + L_LR_BAR) {lr_x = X_LR_BAR + L_LR_BAR}
                }else{
                    lrTouch = nil
                    lr_x = X_LR_BAR;
                }
                // message to the main activity
                //   L<->R value (-1.0 ... +1.0)
                let lr: Float = (lr_x - X_LR_BAR) / L_LR_BAR;
                parent.onTouchLrStick(lr);
            }
        }
        // redraw
        self.setNeedsDisplay()
    }
    
    // on touches ended
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch: UITouch in touches {
            
            // (1) leave F<->B bar?
            if(touch === fbTouch) {
                fb_y = Y_FB_BAR;
                fbTouch = nil
                
                // message to the main activity
                //   L<->R value (-1.0 ... +1.0)
                let fb:Float = -(fb_y - Y_FB_BAR) / L_FB_BAR;
                parent.onTouchFbStick(fb);
            }
            // (2) leave L<->R bar?
            else if(touch === lrTouch) {
                lr_x = X_LR_BAR;
                lrTouch = nil
                
                // message to the main activity
                //   L<->R value (-1.0 ... +1.0)
                let lr:Float = (lr_x - X_LR_BAR) / L_LR_BAR;
                parent.onTouchLrStick(lr);
            }
            // (3) leave Bluetooth button?
            else if(touch === btTouch){
                btTouch = nil
                
                // message to the main activity
                parent.onTouchBtButton();
            }
            // (4) leave Setting button?
            else if(touch === setTouch){
                setTouch = nil
                
                // message to the main activity
                parent.onTouchSetButton();
            }
        }
        // redraw
        self.setNeedsDisplay()
    }
    
    // on touch cancelled
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent!) {
        
        // (1) cancel F<->B bar
        fb_y = Y_FB_BAR;
        fbTouch = nil
            
        // message to the main activity
        //   L<->R value (-1.0 ... +1.0)
        let fb:Float = -(fb_y - Y_FB_BAR) / L_FB_BAR;
        parent.onTouchFbStick(fb);
        
        // (2) cancel L<->R bar
        lr_x = X_LR_BAR;
        lrTouch = nil
        
        // message to the main activity
        //   L<->R value (-1.0 ... +1.0)
        let lr:Float = (lr_x - X_LR_BAR) / L_LR_BAR;
        parent.onTouchLrStick(lr);
        
        // (3) cancel Bluetooth button
        btTouch = nil
        
        // (4) cancel Setting button
        setTouch = nil
        
        // redraw
        self.setNeedsDisplay()
    }
}
