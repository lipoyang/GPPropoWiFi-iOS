//
//  MyButton.swift
//  GPPropo
//
//  Created by Bizan Nishimura on 2016/05/29.
//  Copyright (C)2016 Bizan Nishimura. All rights reserved.
//

import UIKit

@IBDesignable
class MyButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        common_init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        common_init()
    }
    
    func common_init()
    {
        self.layer.cornerRadius = 8.0
        //self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
        //self.layer.borderColor = UIColor(red:0.0, green:122/255.0, blue:1.0, alpha:1.0).CGColor
        self.layer.borderWidth = 1.0
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override func drawRect(rect: CGRect)
    {
        /*
        self.layer.cornerRadius = 10.0
        //self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderColor = UIColor(red:0.0, green:122/255.0, blue:1.0, alpha:1.0).CGColor
        self.layer.borderWidth = 1.0
    */
        super.drawRect(rect);
    }

}
