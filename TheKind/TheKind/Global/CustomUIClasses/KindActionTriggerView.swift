//
//  KindActionTriggerView.swift
//  TheKind
//
//  Created by Tenny on 12/19/18.
//  Copyright © 2018 tenny. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

@objc protocol KindActionTriggerViewProtocol {
    func talk()
    func activate()
    func deactivate()
    func rightOptionClicked()
    func leftOptionClicked()
    func fadeInView()
    func fadeOutView()
    @objc optional func loadView()
}


class KindActionTriggerView: UIView, KindActionTriggerViewProtocol {
    
    var mainViewController2: MainViewController?
    var talkBox2: JungTalkBox?
    
    var nextView: UIView?
    // ===> POLYMORPHIC ACTIONS <===
    // There is a generic function shooting these guys.
    //
    func activate() {
    }


    func deactivate() {
    }

    func rightOptionClicked() {
    }

    func leftOptionClicked() {
    }
    
    func talk() {
    
    }
    
    func logCurrentLandingView(tag: Int) {
        KindUserSettingsManager.sharedInstance.userFields[UserFieldTitle.currentLandingView.rawValue] = tag
        KindUserSettingsManager.sharedInstance.updateUserSettings(completion: nil)
    }

    // ===> NON-POLYMORPHIC ACTIONS <===
    
    func fadeInView() {
        self.alpha = 0
        self.isHidden = false
        
        self.fadeIn(0.7)
    }
    
    func fadeOutView() {
        self.fadeOut(0.7) {
            self.isHidden = true
        }
    }
    
}



