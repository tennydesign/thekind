//
//  Ext_Create_MapActionTriggerView.swift
//  TheKind
//
//  Created by Tenny on 3/27/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import UIKit


extension MapActionTriggerView: UITextFieldDelegate {
    
    
    func adaptLineToTextSize(_ textField: UITextField) {
        let textBoundingSize = textField.frame.size
        guard let text = textField.text else {return}
        let frameForText = estimateFrameFromText(text, bounding: textBoundingSize, fontSize: 22, fontName: SECONDARYFONT)
        
        lineWidthConstraint.constant = frameForText.width
        UIView.animate(withDuration: 1) {
            self.layoutIfNeeded()
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField){
        adaptLineToTextSize(textField)
        //guard let username = textField.text, !(username.trimmingCharacters(in: .whitespaces).isEmpty) else {return}
        //self.username = username
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}


