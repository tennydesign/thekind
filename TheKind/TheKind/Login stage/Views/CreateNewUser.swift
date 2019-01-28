//
//  CreateNewUser.swift
//  TheKind
//
//  Created by Tenny on 1/28/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import Foundation
import UIKit

//HERE:
class CreateNewUser: UIView,loginValidationProtocol,UITextFieldDelegate {
    var landingViewController: LandingViewController?
    @IBOutlet var emailTextField: KindTextField!
    @IBOutlet var passwordTextField: KindTextField!
    @IBOutlet var createUserBtn: KindButton!
    
    @IBOutlet var mainView: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("CreateNewUser", owner: self, options: nil)
        addSubview(mainView)
        mainView.frame = self.bounds
        mainView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        
        emailTextField.addTarget(self, action: #selector(handleTyping), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(handleTyping), for: .editingChanged)
        
        createUserBtn.disableButton()
    }
    
    func toggleButtonControl(_ active: Bool) {
        if active {
            self.createUserBtn.enableButton()
        } else {
            self.createUserBtn.disableButton()
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
    
    @IBAction func createUserClicked(_ sender: KindButton) {
        guard let email = emailTextField.text, email.count > 0 else {return}
        guard let password = passwordTextField.text, password.count > 0 else {return}
        
        landingViewController?.createNewUser(email: email, password: password, completion: { [unowned self](err) in
            if let err = err {
                print("something wrong when creating user:", err)
                return
            }
            
            KindUser.loggedUserEmail = email
            KindUser.loggedUserName = String(email.split(separator: "@").first ?? "")
            self.navigateAfterFadingOut()
        })
        
        landingViewController?.dismissKeyboard()
    }
    
    @IBAction func backToLoginOptionsClicked(_ sender: UIButton) {
        landingViewController?.switchViewsInsideController(toViewName: LandingVCViews.loginOptions, originView: self, removeOriginFromSuperView: false)
    }
    
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
