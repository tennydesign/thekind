//
//  LoginOptionsView.swift
//  TheKind
//
//  Created by Tenny on 20/08/18.
//  Copyright © 2018 tenny. All rights reserved.
//

import UIKit

class LoginOptionsView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var landingViewController: LandingViewController?
    
    @IBOutlet var loginOptionsView: UIView!
    
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
        landingViewController?.switchViewsInsideController(toViewName: LandingVCViews.emailLogin, originView: self, removeOriginFromSuperView: false)
    }
    
    @IBAction func GoogleLoginClicked(_ sender: KindButton) {
        landingViewController?.signInWithGoogle()
    }
    
    @IBAction func googleSignOutClicked(_ sender: UIButton) {
        landingViewController?.signOutWithGoogle()
    }
}

