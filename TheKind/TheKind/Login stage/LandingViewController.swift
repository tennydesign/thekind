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

class LandingViewController: UIViewController,UITextFieldDelegate {
    
    //== HOSTS
    @IBOutlet var loginWindow: UIView!

    //== Content Views (as they appear in the enum)
    @IBOutlet var loginOptions: LoginOptionsView!
    @IBOutlet var loginOrCreateNewUser: LoginOrCreateNewUser! {
        didSet {
            loginOrCreateNewUser.alpha = 0
        }
    }
    
    // ===  Supporting and layout views
    @IBOutlet var jung: UIImageView!
    @IBOutlet var bottom_curtainView: UIView!
    @IBOutlet var top_curtainView: UIView!
    
    // == Constraints.
    @IBOutlet var bottom_curtain_bottom_constraint: NSLayoutConstraint!
    @IBOutlet var top_curtain_top_constraint: NSLayoutConstraint!
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
        loginOrCreateNewUser.landingViewController = self
        
        setupKeyboardObservers()
        
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
        
        loginTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.loginWindow.addGestureRecognizer(loginTapGesture)

        setupViewModelObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func setupViewModelObservers() {
        landingViewControllerViewModel.bindableIsFormValid.bind { [unowned self](isFormValid) in
            guard let isFormValid = isFormValid else {return}
            self.loginOrCreateNewUser.toggleButtonControl(isFormValid)
        }
    }
  
        
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    

    @objc func handleKeyboardDidShow(notification: Notification) {
        print("keyboard did show")
        UIView.animate(withDuration: 0.3) {
            self.loginOrCreateNewUser.transform = CGAffineTransform(translationX: 0, y: -35)
        }
        
    }
    
    @objc func handleKeyboardDidHide() {
        print("keyboard did hide")
        UIView.animate(withDuration: 0.3) {
            self.loginOrCreateNewUser.transform = .identity
        }

    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc fileprivate func handleTapGesture(tap: UITapGestureRecognizer) {
         view.endEditing(true)
    }
    
   func segueToMainStoryboard(callerClassName: String) {
        print(callerClassName)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MainViewController")
        present(vc, animated: false, completion: nil)
    }
}

// MARK: === LOGIN WITH FIREBASE
extension LandingViewController: GIDSignInDelegate,GIDSignInUIDelegate {
    
    // === THIS USES THE MVVM
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
    
    // === THIS IS SITTING HERE FOR NOW CAUSE IT NEEDS UIVIEWCONTROLLER
    func switchToAnotherStoryboard() {
        let storyboard = UIStoryboard(name: "OnBoarding", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "OnBoardingViewController")
        vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        present(vc, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
    
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        if let authentication = user.authentication {
            print("Access token: \(String(describing: authentication.accessToken))")
            
            if let email = user.profile.email, let name = user.profile.name {
                KindUser.loggedUserEmail = email
                KindUser.loggedUserName = name
            }
            
            switchToAnotherStoryboard()
            

        }
    }
    
    func signOutWithGoogle() {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("trying to sign out")
            GIDSignIn.sharedInstance().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func signInWithGoogle() {
        GIDSignIn.sharedInstance().signIn()
        
    }
}

// == ANIMATIONS

enum LandingVCViews {
    case emailLogin, loginOptions
}

extension LandingViewController {
    // === ANIMATIONS
    func switchViewsInsideController(toViewName: LandingVCViews, originView: UIView, removeOriginFromSuperView: Bool) {
        let slideAmount:CGFloat = 40
        var destinationView: UIView
        
        // Do all the prep to transition here.
        switch toViewName {
        case .emailLogin:
            destinationView = loginOrCreateNewUser
            viewTransitionUsingAlphaAndSkatingX(originView, destinationView, left: false, slideAmount)
        case .loginOptions:
            destinationView = loginOptions
            viewTransitionUsingAlphaAndSkatingX(originView, destinationView, left: true, slideAmount)
        }
    }


}

