//
//  GlobalFunctions.swift
//  TheKind
//
//  Created by Tenny on 31/08/18.
//  Copyright © 2018 tenny. All rights reserved.
//

import Foundation
import UIKit


let PRIMARYFONT = "Acrylic Hand Sans"
let SECONDARYFONT = "Horizon Rounded"
// This var is true when user clicks to see the carousel of another user.
// It is used to distinguish two functions for the same view
// 1) ChooseKind 2) UserCarousel. 
//var isBrowsingAnotherUserKindDeck:Bool = false

func returnActionTriggerView(by tag: Int) -> KindActionTriggerViewProtocol? {
    //Starts in the root of the view hierarchy and search for the tagged view.
    guard let targetView = UIApplication.shared.keyWindow?.viewWithTag(tag) as? KindActionTriggerViewProtocol else {return nil}
    return targetView
}


func formatLabelTextWithLineSpacing(text: String) -> NSAttributedString {
    let attr = NSMutableAttributedString(string: text)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 3.2
    paragraphStyle.hyphenationFactor = 1
    paragraphStyle.alignment = .center
    paragraphStyle.lineBreakMode = .byWordWrapping
    attr.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attr.length))
    return attr
}


func returnDesiredDestinationFrame(by tag: Int) -> CGPoint? {
    guard let targetView = UIApplication.shared.keyWindow?.viewWithTag(tag) else {return nil}
    return targetView.frame.origin
}

func navigateBetweenViews(from currentView: UIView, to nextView: UIView, delay: Double? = nil, duration: Double? = nil) {
    
    nextView.alpha = 0
    nextView.isHidden = false
    
    UIView.animate(withDuration: duration ?? 0.5, delay: delay ?? 0, options: .curveEaseOut, animations: {
        currentView.alpha = 0
    }) { (completed) in
        currentView.isHidden = true
        UIView.animate(withDuration: duration ?? 0.5, animations: {
            nextView.alpha = 1
        })
    }
}

func estimateFrameFromText(_ text: String, bounding: CGSize, fontSize: CGFloat, fontName: String) -> CGRect {
    let size = bounding
    let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
    return NSString(string: text).boundingRect(with: size, options: options, attributes: [kCTFontAttributeName as NSAttributedString.Key : UIFont.init(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)], context: nil)
}




func viewTransitionUsingAlpha(_ originView: UIView, _ destinationView: UIView,_ unloadOrigin: Bool) {
    destinationView.isHidden = false
    originView.isUserInteractionEnabled = false
    destinationView.isUserInteractionEnabled = true
    
    UIView.animate(withDuration: 0.5, animations: {
        originView.alpha = 0.0
        destinationView.alpha = 1.0
    }) { (success) in
        if unloadOrigin {
            originView.removeFromSuperview()
        }
    }
}


func viewTransitionUsingAlphaAndSkatingX(_ originView: UIView, _ destinationView: UIView, left: Bool,_ slideAmount: CGFloat) {
    destinationView.isHidden = false
    originView.isUserInteractionEnabled = false
    destinationView.isUserInteractionEnabled = true
    let slideDirection:CGFloat = left ? slideAmount : (0 - slideAmount)
    // increasing this will increase starter position of incoming view. 2 is pretty subtle and smooth
    let incomingWindowDistanceFactor:CGFloat = 2
    UIView.animate(withDuration: 0.3, animations: {
        originView.transform = CGAffineTransform(translationX: slideDirection, y: originView.frame.origin.y)
        originView.alpha = 0.0
    }) { (success) in
        if !left {
            destinationView.transform = CGAffineTransform(translationX: (incomingWindowDistanceFactor * slideAmount), y: 0)
        }
        UIView.animate(withDuration: 0.4, delay: 0.2, options: .curveEaseOut, animations: {
            destinationView.transform = .identity
            destinationView.alpha = 1.0
        })
    }
}

// Just a delay function to make sure I don't write a dispatch every time

public func delay(bySeconds seconds: Double, dispatchLevel: DispatchLevel = .main, closure: @escaping () -> Void) {
    let dispatchTime = DispatchTime.now() + seconds
    dispatchLevel.dispatchQueue.asyncAfter(deadline: dispatchTime, execute: closure)
}

public enum DispatchLevel {
    case main, userInteractive, userInitiated, utility, background
    var dispatchQueue: DispatchQueue {
        switch self {
        case .main:                 return DispatchQueue.main
        case .userInteractive:      return DispatchQueue.global(qos: .userInteractive)
        case .userInitiated:        return DispatchQueue.global(qos: .userInitiated)
        case .utility:              return DispatchQueue.global(qos: .utility)
        case .background:           return DispatchQueue.global(qos: .background)
        }
    }
}

//not in use
func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
}

func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
}


// EMAIL VALIDATION
let __firstpart = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
let __serverpart = "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}"
let __emailRegex = __firstpart + "@" + __serverpart + "[A-Za-z]{2,8}"
let __emailPredicate = NSPredicate(format: "SELF MATCHES %@", __emailRegex)

extension String {
    func isEmail() -> Bool {
        return __emailPredicate.evaluate(with: self)
    }
}

extension UITextField {
    func isEmail() -> Bool {
        return self.text?.isEmail() ?? false
    }
}
