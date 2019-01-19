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
}

class KindActionTriggerView: UIView {
    
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

