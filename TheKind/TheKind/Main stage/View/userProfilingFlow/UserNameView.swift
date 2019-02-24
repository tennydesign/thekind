//
//  UserNameView.swift
//  TheKind
//
//  Created by Tenny on 1/7/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import UIKit

class UserNameView: KindActionTriggerView, UITextFieldDelegate {
    
    var mainViewController: MainViewController?
    var talkbox: JungTalkBox?
    @IBOutlet var lineWidth: NSLayoutConstraint!
    
    @IBOutlet var userNameBox: UIView!
    @IBOutlet var userNameTextField: KindTransparentTextField!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        
    }
    
    @IBOutlet var mainView: UIView!
    
    func commonInit() {
        Bundle.main.loadNibNamed("UserNameView", owner: self, options: nil)
        addSubview(mainView)
        setupUserNameTextField()
        
        adaptLineToTextSize(userNameTextField)
        //KindUser.loggedUserName = "" // test purposes only
        setupKeyboardObservers()
        self.talkbox?.delegate = self
    }
    
    fileprivate func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    fileprivate func setupUserNameTextField() {
        userNameTextField.delegate = self
        userNameTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
    }
    

    
    @objc func handleKeyboardDidShow() {
        print("keyboard did show")
        UIView.animate(withDuration: 0.3) {
            self.userNameBox.transform = CGAffineTransform(translationX: 0, y: -35)
        }
    }
    
    @objc func handleKeyboardDidHide() {
        print("keyboard did hide")
        UIView.animate(withDuration: 0.3) {
            self.userNameBox.transform = .identity
        }
    }
    
    fileprivate func adaptLineToTextSize(_ textField: UITextField) {
        let textBoundingSize = textField.frame.size
        guard let text = textField.text else {return}
        let frameForText = estimateFrameFromText(text, bounding: textBoundingSize, fontSize: 21, fontName: PRIMARYFONT)
        
        lineWidth.constant = frameForText.width
        UIView.animate(withDuration: 1) {
            self.layoutIfNeeded()
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField){
        adaptLineToTextSize(textField)
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Cool guard for textfields.
        guard let username = textField.text, !(username.trimmingCharacters(in: .whitespaces).isEmpty) else {return true}

        textField.resignFirstResponder()
        
        KindUserManager.loggedUserName = username
        let txt = "Great, I will call you \(username) from now on.-You can change it again if you prefer."
        let actions: [KindActionType] = [.none,.none]
        let actionViews: [ActionViewName] = [.none,.none]
        let options = self.talkbox?.createUserOptions(opt1: "", opt2: "I'm good with that.", actionViews: (.none,.UserNameView))
        
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, action: actions, actionView: actionViews, options: options))

        return true
    }
    
     override func talk() {
        var txt: String = ""

        if !(KindUserManager.loggedUserName ?? "").isEmpty {
            userNameTextField.text = KindUserManager.loggedUserName
            txt = "Can I call you \(KindUserManager.loggedUserName!)?-If that's not good please change above."
        } else {
             userNameTextField.text = "[Type your name]"
             txt = "Hummm... I tried but didn't find your name.-Please enter your name above"
        }
       
        adaptLineToTextSize(userNameTextField)
        
        let actions: [KindActionType] = [.none,.activate]
        let actionViews: [ActionViewName] = [.none,.UserNameView]
        let options = self.talkbox?.createUserOptions(opt1: "", opt2: "I'm good with that.", actionView: self)
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, action: actions, actionView: actionViews, options: options))
        
    }
    

     override func activate() {
        self.fadeInView()
    }
    
    override  func deactivate() {
        self.talkbox?.delegate = nil
    }
    
    override func rightOptionClicked() {
        var txt: String = ""
        
        if let username = userNameTextField.text, !(username.trimmingCharacters(in: .whitespaces).isEmpty) {
            KindUserManager.loggedUserName = username
            txt = "Great, \(KindUserManager.loggedUserName ?? username) nice to meet you.-Welcome to The Kind."
            
            let kindUserManager = KindUserManager()
            kindUserManager.userFields[UserFields.name.rawValue] = username
            kindUserManager.updateUserSettings()
            
            //Move forward
            let actions: [KindActionType] = [.none,.talk]
            let actionViews: [ActionViewName] = [.none,.BadgePhotoSetupView]
            self.fadeOutView()
            
            self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, action: actions, actionView: actionViews, options: nil))
          
        } else {
            talk() // Talk to the user about the updated user name. (repeat the routine)
        }
       
    }

     override func leftOptionClicked() {
        
    }


}
