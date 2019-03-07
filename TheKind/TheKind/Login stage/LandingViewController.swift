//
//  LandingViewController.swift
//  TheKind
//
//  Created by Tenny on 20/08/18.
//  Copyright © 2018 tenny. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

// This protocol allows the same toggleButtonControl call to all login types (existing, new)
protocol loginValidationProtocol {
    func toggleButtonControl(_ active: Bool)
}

class LandingViewController: UIViewController,UITextFieldDelegate {
    
    
    let KEYBOARDSHOWSLIDEAMOUNT: CGFloat = -66
    //== HOSTS
    @IBOutlet var loginWindow: UIView!

    //== Content Views (as they appear in the enum)
    @IBOutlet var loginOptions: LoginOptionsView!
    @IBOutlet var loginExistingUser: LoginExistingUser! {
        didSet {
            loginExistingUser.alpha = 0
        }
    }
    
    @IBOutlet var createNewUser: CreateNewUser! {
        didSet {
            createNewUser.alpha = 0
        }
    }
    
    var choosenLoginView: loginValidationProtocol?
    
    // ===  Supporting and layout views

    
    // == Constraints.

    @IBOutlet var loginWindowCenterYConstraint: NSLayoutConstraint!
    
    // == MVVM
    let landingViewControllerViewModel = LandingViewControllerViewModel()
    
    var email: String? {
        didSet {
            landingViewControllerViewModel.email = email
        }
    }
    
    var password: String? {
        didSet {
            landingViewControllerViewModel.password = password
        }
    }
    
    // == Gestures
    var loginTapGesture: UIGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginOptions.landingViewController = self
        loginExistingUser.landingViewController = self
        createNewUser.landingViewController = self
        
        setupKeyboardObservers()
        
        GIDSignIn.sharedInstance()?.uiDelegate = self
        //GIDSignIn.sharedInstance()?.signInSilently()
        
        loginTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.loginWindow.addGestureRecognizer(loginTapGesture)
        self.view.addGestureRecognizer(loginTapGesture)

        setupViewModelObservers()
        print("one time View Did Load LandingViewControllerV ")
        KindUserSettingsManager.sharedInstance.userSignedIn = { [unowned self] in
            print("one time userSignedIn")
            self.goToOnboading()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func setupViewModelObservers() {
        //return from viewmodel.
        landingViewControllerViewModel.bindableIsFormValid.bind { [unowned self](isFormValid) in
            guard let isFormValid = isFormValid else {return}
            guard let loginView = self.choosenLoginView else {return}
            loginView.toggleButtonControl(isFormValid)
        }
    }
  
        
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    

    @objc func handleKeyboardDidShow(notification: Notification) {
        print("keyboard did show")

        UIView.animate(withDuration: 0.3) {
            self.loginExistingUser.transform = CGAffineTransform(translationX: 0, y: self.KEYBOARDSHOWSLIDEAMOUNT)
            self.createNewUser.transform = CGAffineTransform(translationX: 0, y: self.KEYBOARDSHOWSLIDEAMOUNT)
        }
        
    }
    
    @objc func handleKeyboardDidHide() {
        print("keyboard did hide")
        UIView.animate(withDuration: 0.3) {
            self.loginExistingUser.transform = .identity
            self.createNewUser.transform = .identity
        }

    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc fileprivate func handleTapGesture(tap: UITapGestureRecognizer) {
         view.endEditing(true)
    }
    
}

// MARK: === LOGIN WITH FIREBASE
extension LandingViewController: GIDSignInUIDelegate {
    
    // === THIS USES THE MVVM - it mimics the VM just so we don't have to call VM from the Views
    func createNewUser(email:String, password: String, completion: @escaping (Error?)->()) {
        landingViewControllerViewModel.createNewUser(email, password) { (err) in
            if let err = err {
                print("something wrong when creating user:", err)
                completion(err)
                return
            }
            
            completion(nil)
        }
    }
    
    func loginWithEmailAndPassword(email: String, password: String, completion: @escaping (Error?)->()) {
        
        landingViewControllerViewModel.loginWithEmailAndPassword(email, password) { (err) in
            if let err = err {
                print("something wrong when login in user:", err)
                completion(err)
                return
            }
            completion(nil)
        }
        
    }
    
     func goToOnboading() {
        print("one time goToOnboading")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MainViewController")
        vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        present(vc, animated: true, completion: nil)
    }
}

// == ANIMATIONS

enum LandingVCViews {
    case existingUser, loginOptions, createNewUser
}

extension LandingViewController {
    // === ANIMATIONS
    func switchViewsInsideController(toViewName: LandingVCViews, originView: UIView, removeOriginFromSuperView: Bool) {
        let slideAmount:CGFloat = 40
        var destinationView: UIView
        // Do all the prep to transition here.
        switch toViewName {
        case .existingUser:
            destinationView = loginExistingUser
            viewTransitionUsingAlphaAndSkatingX(originView, destinationView, left: false, slideAmount)
        case .loginOptions:
            destinationView = loginOptions
            viewTransitionUsingAlphaAndSkatingX(originView, destinationView, left: true, slideAmount)
        case .createNewUser:
            destinationView = createNewUser
            viewTransitionUsingAlphaAndSkatingX(originView, destinationView, left: false, slideAmount)
        }
    }


}

