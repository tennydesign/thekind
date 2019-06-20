//
//  BadgePhotoSetupView.swift
//  TheKind
//
//  Created by Tenny on 12/16/18.
//  Copyright © 2018 tenny. All rights reserved.


import UIKit

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

        self.logCurrentLandingView(tag: ActionViewName.BadgePhotoSetupView.rawValue)
        talk()
    }
    
    override func deactivate() {
        mainView.removeFromSuperview()
    }
    
    override func talk() {
        let txt = "First, take a selife.-This will help when meeting other people.-Justtap the camera above."
        let actions: [KindActionType] = [.none,.fadeInView, .none]
        let actionViews: [ActionViewName] = [.none,.BadgePhotoSetupView, .none]
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, actions: actions, actionViews: actionViews, options: nil))
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
        let txt = "-Cool!-I think it looks good too 🙂."
        let actions: [KindActionType] = [.none,.activate]
        let actionViews: [ActionViewName] = [.none, .DobOnboardingView]
        
        delay(bySeconds: 0.3, dispatchLevel: .main) {
            self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, actions: actions, actionViews: actionViews, options: nil))
        }
    }
    
    override func leftOptionClicked() {
        mainViewController?.hitPickerControl()
    }
    
}
