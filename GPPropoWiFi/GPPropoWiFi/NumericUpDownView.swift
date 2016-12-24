//
//  NumericUpDownView.swift
//  GPPropo
//
//  Created by Bizan Nishimura on 2016/06/01.
//  Copyright (C)2016 Bizan Nishimura. All rights reserved.
//

import UIKit

// event lisntener
protocol NumericUpDownDelegate {
    
    func onChangeValue(view:NumericUpDownView, value:Int);
}

@IBDesignable
class NumericUpDownView: UIView {
    
    @IBOutlet weak var buttonDown: MyButton!
    @IBOutlet weak var buttonUp: MyButton!
    @IBOutlet weak var textValue: UILabel!
    
    // view controller (parent)
    var parent : NumericUpDownDelegate!
    
    let REPEAT_DETECT_TIME = 0.5
    let REPEAT_INTERVAL = Int64(0.1 * Double(NSEC_PER_SEC))
    var isRepeatUp:Bool = false
    var isRepeatDown:Bool = false

    var mValue:Int = 0
    var MAX_VALUE:Int = 100
    var MIN_VALUE:Int = -100
    var FORMAT:String = "%+4d"
    
    func setValue(value:Int)
    {
        mValue = value
        textValue.text = String(format:FORMAT, mValue)
        // self.setNeedsDisplay()
    }
    func setMaxMin(max max:Int, min:Int)
    {
        MAX_VALUE = max
        MIN_VALUE = min
    }
    func setFormat(format:String)
    {
        FORMAT = format
    }

    // [-]
    func valueDown()
    {
        if(mValue > MIN_VALUE) { mValue -= 1 }
        textValue.text = String(format:FORMAT, mValue)
        // self.setNeedsDisplay()
        parent.onChangeValue(self, value: mValue);
    }
    @IBAction func onTapButtonDown(sender: UIButton)
    {
        valueDown()
    }
    func onLongPressButtonDown(sender:UILongPressGestureRecognizer){
        switch (sender.state) {
        case UIGestureRecognizerState.Began:
            isRepeatDown = true
            let time = dispatch_time(DISPATCH_TIME_NOW, REPEAT_INTERVAL)
            dispatch_after(time, dispatch_get_main_queue(), repeatDown)
            break
        case UIGestureRecognizerState.Changed:
            break
        case UIGestureRecognizerState.Ended:
            isRepeatDown = false
            break
        default:
            break
        }
    }
    func repeatDown()
    {
        if(!isRepeatDown) {return}
        
        valueDown()
        
        let time = dispatch_time(DISPATCH_TIME_NOW, REPEAT_INTERVAL)
        dispatch_after(time, dispatch_get_main_queue(), repeatDown)
    }
    // [+]
    func valueUp()
    {
        if(mValue < MAX_VALUE) { mValue += 1 }
        textValue.text = String(format:FORMAT, mValue)
        // self.setNeedsDisplay()
        parent.onChangeValue(self, value: mValue);
    }
    @IBAction func onTapButtonUp(sender: UIButton)
    {
        valueUp()
    }
    func onLongPressButtonUp(sender:UILongPressGestureRecognizer){
        switch (sender.state) {
        case UIGestureRecognizerState.Began:
            isRepeatUp = true
            let time = dispatch_time(DISPATCH_TIME_NOW, REPEAT_INTERVAL)
            dispatch_after(time, dispatch_get_main_queue(), repeatUp)
            break
        case UIGestureRecognizerState.Changed:
            break
        case UIGestureRecognizerState.Ended:
            isRepeatUp = false
            break
        default:
            break
        }
    }
    func repeatUp()
    {
        if(!isRepeatUp) {return}
        
        valueUp()
        
        let time = dispatch_time(DISPATCH_TIME_NOW, REPEAT_INTERVAL)
        dispatch_after(time, dispatch_get_main_queue(), repeatUp)
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    // コードから初期化はここから
    override init(frame: CGRect) {
        super.init(frame: frame)
        comminInit()
    }
    
    // Storyboard/xib から初期化はここから
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        comminInit()
    }
    
    // xibからカスタムViewを読み込んで準備する
    private func comminInit() {
        // MyCustomView.xib からカスタムViewをロードする
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "NumericUpDownView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil).first as! UIView
        addSubview(view)
        
        // カスタムViewのサイズを自分自身と同じサイズにする
        view.translatesAutoresizingMaskIntoConstraints = false
        let bindings = ["view": view]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|",
            options:NSLayoutFormatOptions(rawValue: 0),
            metrics:nil,
            views: bindings))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|",
            options:NSLayoutFormatOptions(rawValue: 0),
            metrics:nil,
            views: bindings))
        
        textValue.textAlignment = NSTextAlignment.Right
        
        // set long press handlers
        let longPressDown = UILongPressGestureRecognizer(target:self, action:#selector(onLongPressButtonDown(_:)));
        longPressDown.minimumPressDuration = REPEAT_DETECT_TIME;
        buttonDown.addGestureRecognizer(longPressDown)
        let longPressUp = UILongPressGestureRecognizer(target:self, action:#selector(onLongPressButtonUp(_:)));
        longPressUp.minimumPressDuration = REPEAT_DETECT_TIME;
        buttonUp.addGestureRecognizer(longPressUp)
    }
}
