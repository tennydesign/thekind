//
//  HUDview.swift
//  TheKind
//
//  Created by Tenny on 13/12/18.
//  Copyright © 2018 tenny. All rights reserved.
//

import Foundation
import UIKit

class HUDview: KindActionTriggerView {

    var mainViewController: MainViewController?
    @IBOutlet var viewForKindCard: UIView!
    @IBOutlet var hudView: UIView!
    
    @IBOutlet var viewForAvatar: UIView!
    @IBOutlet var userPictureImageVIew: UIImageView!
    @IBOutlet var photoFrame: UIView! {
        didSet {
            photoFrame.layer.cornerRadius = photoFrame.bounds.width / 2
            photoFrame.layer.masksToBounds = true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    
    fileprivate func commonInit() {
        Bundle.main.loadNibNamed("HUDview", owner: self, options: nil)
        addSubview(hudView)
        receiveViewInTrasitionAnimateAndRemoveIt()
        
    
        viewForKindCard.layer.shadowOpacity = 0.0
        viewForKindCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        viewForKindCard.layer.shadowColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1).cgColor
        viewForKindCard.layer.shadowRadius = 14
        
        print(hudView.convert(viewForKindCard.frame.origin, to: nil))
        
        delay(bySeconds: 2) {
            let animation = CABasicAnimation(keyPath: "shadowOpacity")
            animation.fromValue = self.viewForKindCard.layer.shadowOpacity
            animation.toValue = 0.9
            animation.duration = 1.0
            self.viewForKindCard.layer.shadowOpacity = 0.9
            self.viewForKindCard.layer.add(animation, forKey: animation.keyPath)


        }

        
   
    }
    
    // Received view from another screeen.
    // animate and remove it.
    // Only adjusts curtains after its gone. <----
    fileprivate func receiveViewInTrasitionAnimateAndRemoveIt() {
        //11
        delay(bySeconds: 1) {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                UIApplication.shared.keyWindow!.viewWithTag(11)?.alpha = 0
            }, completion: { (completed) in
                UIApplication.shared.keyWindow!.viewWithTag(11)?.removeFromSuperview()
                self.mainViewController?.adjustCurtains() // <----
            })
        }
    }
    
    
    override func rightOptionClicked() {
        
    }
    
    override func leftOptionClicked() {
        
    }
    
    
    
    override func activate() {
        UIView.animate(withDuration: 1.5, delay: 2, options: .curveEaseIn, animations: {
            self.viewForAvatar.alpha = 1
        }, completion: nil)
    }
    
    override func deactivate() {
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: {
            self.viewForAvatar.alpha = 0
        }, completion: nil)
    }
    
    
}





//        kindImageView.layer.shadowOpacity = 0.4
//        kindImageView.layer.cornerRadius = 11
//        kindImageView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        kindImageView.layer.shadowRadius = 6
//        kindImageView.layer.shadowColor = UIColor.white.cgColor

//gets the position related to the UIViewController


