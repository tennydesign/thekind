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

    @IBOutlet weak var hudControls: UIView!
    var mainViewController: MainViewController?
    @IBOutlet var viewForKindCard: UIView!
    @IBOutlet var hudView: UIView!
    
    @IBOutlet var kindIconImageView: UIImageView! {
        didSet {
            kindIconImageView.image = kindIconImageView.image?.withRenderingMode(.alwaysTemplate)
        }
    }
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

    private var gradient: CAGradientLayer!
    
    fileprivate func commonInit() {
        Bundle.main.loadNibNamed("HUDview", owner: self, options: nil)
        addSubview(hudView)
        receiveViewInTrasitionAnimateAndRemoveIt()
        

        gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0.45, 1]
        layer.insertSublayer(gradient, at: 0)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }
    

    // Received view from another screeen.
    // animate and remove it.
    // Only adjusts curtains after its gone. <----
    fileprivate func receiveViewInTrasitionAnimateAndRemoveIt() {
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
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
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


