//
//  BadgePhotoSetupView.swift
//  TheKind
//
//  Created by Tenny on 12/16/18.
//  Copyright © 2018 tenny. All rights reserved.


import UIKit

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
        Bundle.main.loadNibNamed("BadgePhotoSetupView", owner: self, options: nil)
        addSubview(mainView)
        
    }
    
    @IBAction func selfieButtonClicked(_ sender: UIButton) {
        mainViewController?.hitPickerControl()
    }
    
    override func activate() {
 
    }
    
    override func deactivate() {

    }
    
    override func talk() {
        let txt = "Please take a selife.-This will help when meeting other people.-Just tap the camera above."
        let actions: [KindActionType] = [.none,.fadeInView, .none]
        let actionViews: [ActionViewName] = [.none,.BadgePhotoSetupView, .none]
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, action: actions, actionView: actionViews, options: nil))
    }
    

    
    override func fadeInView() {
        super.fadeInView()
    }
    
    
    override func rightOptionClicked() {
        self.fadeOutView()
        let txt = "-Cool!-I think it looks good too 🙂."
        let actions: [KindActionType] = [.none,.talk]
        let actionViews: [ActionViewName] = [.none, .DobOnboardingView]
        
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, action: actions, actionView: actionViews, options: nil))
    }
    
    override func leftOptionClicked() {
        mainViewController?.hitPickerControl()
    }
    
}
