//
//  KindActionTriggerView.swift
//  TheKind
//
//  Created by Tenny on 12/19/18.
//  Copyright © 2018 tenny. All rights reserved.
//

import UIKit

protocol KindActionTriggerViewProtocol {
    func talk()
    func activate()
    func deactivate()
    func rightOptionClicked()
    func leftOptionClicked()
    func fadeInView()
    func fadeOutView()
}

class KindActionTriggerView: UIView, KindActionTriggerViewProtocol {
    
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
        
        UIView.animate(withDuration: 0.7, animations: {
            self.alpha = 1
        }) { (completed) in

        }
    }
    
    func fadeOutView() {
        UIView.animate(withDuration: 0.7, animations: {
            self.alpha = 0
        }) { (completed) in
            self.isHidden = true
        }
    }

    
    
}

