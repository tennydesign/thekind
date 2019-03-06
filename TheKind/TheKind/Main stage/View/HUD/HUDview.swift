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
            // To take the color away.
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
        //receiveViewInTrasitionAnimateAndRemoveIt()
        

        gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0.55, 1]
        layer.insertSublayer(gradient, at: 0)

        updateHUDWithUserSettingsObserver()
        
        
        KindDeckManagement.userKindDeckChanged = { [unowned self] in
            if let kind = KindDeckManagement.userMainKind {
                self.showKindOnHUD(kind)
            }
        }
        

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }
    
    fileprivate func updateHUDWithUserSettingsObserver() {
        KindUserSettingsManager.sharedInstance.updateHUDWithUserSettings = { [unowned self] in
            self.updateUserPhotoWithCurrentState()
            
            // update kind
        }
        
    }
    
    fileprivate func updateUserPhotoWithCurrentState() {
        // update photo:
        if let urlString = KindUserSettingsManager.sharedInstance.userFields[UserFieldTitle.photoURL.rawValue] as? String {
            // only load new image if it changed.
            if KindUserSettingsManager.sharedInstance.currentUserImageURL != urlString {
                if let url = URL(string: urlString) {
                    let data = try? Data(contentsOf: url)
                    self.userPictureImageVIew.image = UIImage(data: data!)
                }
                KindUserSettingsManager.sharedInstance.currentUserImageURL = urlString
            }
            self.revealUserPhoto()
        } else {
            self.fadeOutUserPhoto()
        }
    }
    
    
    
    override func rightOptionClicked() {
        
    }
    
    override func leftOptionClicked() {
        
    }
    

    func showKindOnHUD(_ kind: KindCard) {
        kindIconImageView.image = UIImage(named: kind.iconImageName.rawValue)
        UIView.animate(withDuration: 1) {
            self.viewForKindCard.alpha = 1
        }
    }
    
    override func activate() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                self.alpha = 1}, completion: nil)
        
        revealUserPhoto()
    }
    
    func revealUserPhoto() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            self.viewForAvatar.alpha = 1}, completion: nil)
    }
    
    func fadeOutUserPhoto() {
        UIView.animate(withDuration: 0.5, animations: {
            self.viewForAvatar.alpha = 0
        })
    }
    
    override func deactivate() {
        // hide it.
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: {
            self.alpha = 0
        }, completion: nil)
    }
    
    

    
}

