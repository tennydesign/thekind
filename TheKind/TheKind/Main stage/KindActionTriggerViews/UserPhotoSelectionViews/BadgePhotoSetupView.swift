//
//  BadgePhotoSetupView.swift
//  TheKind
//
//  Created by Tenny on 12/16/18.
//  Copyright © 2018 tenny. All rights reserved.


import UIKit
import RxCocoa
import RxSwift
//TODO: Screen is blinking after user chooses photo.

class BadgePhotoSetupView: KindActionTriggerView {
    
    @IBOutlet var mainView: UIView!
    var mainViewController: MainViewController?
    var talkbox: JungTalkBox?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        
    }
    
    func commonInit() {
//        Bundle.main.loadNibNamed("BadgePhotoSetupView", owner: self, options: nil)
//        addSubview(mainView)
//
    }
    
    @IBAction func selfieButtonClicked(_ sender: UIButton) {
        mainViewController?.hitPickerControl()
    }
    
    override func activate() {
//             KindUserSettingsManager.sharedInstance.userFields[UserFieldTitle.currentLandingView.rawValue] = ActionViewName.BadgePhotoSetupView.rawValue
//             KindUserSettingsManager.sharedInstance.updateUserSettings(completion: nil)
        Bundle.main.loadNibNamed("BadgePhotoSetupView", owner: self, options: nil)
        addSubview(mainView)

        self.logCurrentLandingView(tag: ViewForActionEnum.BadgePhotoSetupView.rawValue)
        talk()
    }
    
    override func deactivate() {
        mainView.removeFromSuperview()
    }
    

    
    override func talk() {
        takingSelfieExplainer()
    }
    

    
    override func fadeInView() {
        super.fadeInView()
    }

    
    override func rightOptionClicked() {
        
        // SAVE PHOTO TO DATABASE
        guard let image = mainViewController?.hudView.userPictureImageVIew.image else {
            fatalError("couldn't find an image to update")
        }
        guard let uploadData = image.jpegData(compressionQuality: 0.1) else {
            fatalError("error compressing image")
        }
        
        KindUserSettingsManager.sharedInstance.uploadUserPicture(profileImageData: uploadData)
        
        self.fadeOutView()
        badgePhotoConfirmation()
    }
    
    override func leftOptionClicked() {
        mainViewController?.hitPickerControl()
    }
    
}
