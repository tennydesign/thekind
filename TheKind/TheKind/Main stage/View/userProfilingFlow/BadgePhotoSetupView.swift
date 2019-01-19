//
//  BadgePhotoSetupView.swift
//  TheKind
//
//  Created by Tenny on 12/16/18.
//  Copyright © 2018 tenny. All rights reserved.
// HERE:

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
    
    //TODO: This is not firing with the delegate alternative
    // REACTIVE HERE... INSTEAD OF COMPLETION!!!
    
    override func activate() {
 
    }
    
    override func deactivate() {

    }
    
    override func talk() {
        
    }
    

    
    override func fadeInView() {
        super.fadeInView()
    }
    
    
    override func rightOptionClicked() {
        self.fadeOutView()
        let txt = "Ok.-Now tell me what year you were born.-Choose from the options above."
        let actions: [KindActionType] = [.none, .none,.activate]
        let actionViews: [ActionViewName] = [.none,.none, .DobOnboardingView]
        
        let options = self.talkbox?.createUserOptions(opt1: "", opt2: "Confirm this year.", actionViews: (.none,.DobOnboardingView))
        
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, action: actions, actionView: actionViews, options: options))
    }
    
    override func leftOptionClicked() {
        mainViewController?.hitPickerControl()
    }
    
}
