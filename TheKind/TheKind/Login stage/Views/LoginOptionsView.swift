//
//  LoginOptionsView.swift
//  TheKind
//
//  Created by Tenny on 20/08/18.
//  Copyright © 2018 tenny. All rights reserved.
//

import UIKit

class LoginOptionsView: UIView {

    var landingViewController: LandingViewController?
    let handleLoginWithFireStore =  HandleLoginWithFirestore()
    
    @IBOutlet var loginOptionsView: UIView!
    @IBOutlet var newUserButton: KindButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("LoginOptionsView", owner: self, options: nil)
        addSubview(loginOptionsView)
        loginOptionsView.frame = self.bounds
        loginOptionsView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        
    }
    @IBAction func loginWithEmailClicked(_ sender: UIButton) {
        if sender.titleLabel?.text == "Create new user" {
            landingViewController?.choosenLoginView = landingViewController?.createNewUser
            landingViewController?.switchViewsInsideController(toViewName: LandingVCViews.createNewUser, originView: self, removeOriginFromSuperView: false)
        } else {
            landingViewController?.choosenLoginView = landingViewController?.loginExistingUser
            landingViewController?.switchViewsInsideController(toViewName: LandingVCViews.existingUser, originView: self, removeOriginFromSuperView: false)
        }

    }
    
    @IBAction func GoogleLoginClicked(_ sender: KindButton) {
        self.fadeOut(0.4)
//        UIView.animate(withDuration: 0.4) {
//            self.alpha = 0
//        }
        handleLoginWithFireStore.signInWithGoogle()
    }
    
    @IBAction func googleSignOutClicked(_ sender: UIButton) {
        handleLoginWithFireStore.signOutWithGoogle()
    }
}

