//
//  kindButton.swift
//  TheKind
//
//  Created by Tennyson Pinheiro on 12/5/18.
//  Copyright © 2018 tenny. All rights reserved.
//

import  UIKit

class KindButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()

    }

    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        commonInit()
    }
    
    func commonInit() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(r: 255, g: 36, b: 81).cgColor
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.tintColor = UIColor(r: 237, g: 237, b: 237)
    }
    
    
    enum buttonColor : Int {
        case special=0, normal
    }
    
    @IBInspectable var borderColorKind: UIColor? {
        didSet {
            self.layer.borderColor = borderColorKind?.cgColor
        }
    }
    
    func enableButton() {
        self.layer.borderColor = UIColor(r: 255, g: 36, b: 81).cgColor
        self.isEnabled = true
    }
    
    func disableButton() {
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.isEnabled = false
    }
    
}
