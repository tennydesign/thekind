//
//  KindTextField.swift
//  TheKind
//
//  Created by Tennyson Pinheiro on 12/5/18.
//  Copyright © 2018 tenny. All rights reserved.
//

import UIKit

class KindTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        commonInit()
    }
    
    override var textContentType: UITextContentType! {
        didSet {
            if textContentType == UITextContentType.newPassword {
                passwordRules = UITextInputPasswordRules(descriptor: "required: upper; required: lower; required: digit; max-consecutive: 2; minlength: 8;")
            }
        }
    }
    
    func commonInit() {
        borderStyle = .none
        layer.borderWidth = 1
        layer.borderColor = LIGHTGREYCOLOR.cgColor // UIColor.lightGray.cgColor
        layer.cornerRadius = 10
        textColor = LIGHTGREYCOLOR //UIColor(r: 237, g: 237, b: 237)
        layer.masksToBounds = true
    
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 16, dy: 0)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 16, dy: 0)
    }
    
}


class KindTransparentTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        commonInit()
    }
    
    func commonInit() {
        borderStyle = .none
        layer.borderWidth = 0
        layer.cornerRadius = 10
        textColor = LIGHTGREYCOLOR //UIColor(r: 237, g: 237, b: 237)
        layer.masksToBounds = true
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 16, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 16, dy: 0)
    }
    
}
