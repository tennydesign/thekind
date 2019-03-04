//
//  CreateNewUser.swift
//  TheKind
//
//  Created by Tenny on 20/08/18.
//  Copyright © 2018 tenny. All rights reserved.
//

import UIKit

class LoginExistingUser: UIView,UITextFieldDelegate,loginValidationProtocol {

    var landingViewController: LandingViewController?
    @IBOutlet var joinButton: KindButton!
    @IBOutlet var LoginOrCreateNewUser: UIView!
    @IBOutlet var emailTextField: KindTextField!
    @IBOutlet var passwordTextField: KindTextField!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("LoginExistingUser", owner: self, options: nil)
        addSubview(LoginOrCreateNewUser)
        LoginOrCreateNewUser.frame = self.bounds
        LoginOrCreateNewUser.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        
        emailTextField.addTarget(self, action: #selector(handleTyping), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(handleTyping), for: .editingChanged)
        
        joinButton.disableButton()

    }
    
    func toggleButtonControl(_ active: Bool) {
        if active {
            self.joinButton.enableButton()
        } else {
            self.joinButton.disableButton()
        }
    }

     @objc func handleTyping(textField: UITextField) {
        // This sends the info all the way up to the ViewModel layer, through the viewcontroller
        if textField == emailTextField {
            landingViewController?.email = textField.text ?? ""
        } else if textField == passwordTextField {
            landingViewController?.password = textField.text ?? ""
        }
    }
    

    @IBAction func backToLoginOptionsClicked(_ sender: UIButton) {
        landingViewController?.switchViewsInsideController(toViewName: LandingVCViews.loginOptions, originView: self, removeOriginFromSuperView: false)

    }

    @IBAction func join(_ sender: UIButton) {
        guard let email = emailTextField.text, email.count > 0 else {return}
        guard let password = passwordTextField.text, password.count > 0 else {return}
        
        landingViewController?.loginWithEmailAndPassword(email: email, password: password, completion:  { [unowned self](err) in
            if let err = err {
                print(err)
                return
            }

            self.navigateAfterFadingOut()

        })
        
        landingViewController?.dismissKeyboard()
    }
    
    // WILL CALL AFTER LOGIN WAS APPROVED.
    func navigateAfterFadingOut() {
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0
        }, completion: { (completed) in

            
            // call function to move to OnboardingStoryboard.
            self.landingViewController?.goToOnboading()
            self.removeFromSuperview()
            

        })
    }
}
