//
//  UserNameView.swift
//  TheKind
//
//  Created by Tenny on 1/7/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import UIKit

//TODO: REFACTOR IT AND FIX THE WORKFLOW BETWEEN TALK RIGHT CLICK.

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
        let frameForText = estimateFrameFromText(text, bounding: textBoundingSize, fontSize: 21, fontName: "Acrylic Hand Sans")
        
        lineWidth.constant = frameForText.width + 16
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
        
        KindUser.loggedUserName = username
        let txt = "Great, I will call you \(username) from now on.-You can change it again if you prefer."
        let actions: [KindActionType] = [.none,.none]
        let actionViews: [ActionViewName] = [.none,.none]
        let options = self.talkbox?.createUserOptions(opt1: "", opt2: "I'm good with that.", actionViews: (.none,.UserNameView))
        
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, action: actions, actionView: actionViews, options: options))

        return true
    }
    
     override func talk() {
        var txt: String = ""

        if !(KindUser.loggedUserName ?? "").isEmpty {
            userNameTextField.text = KindUser.loggedUserName
            txt = "Can I call you \(KindUser.loggedUserName!)?-If that's not good please change above."
        } else {
             userNameTextField.text = "[Type your name]"
             txt = "Hummm... I still don't know your name.-Please enter your name above"
        }
       
        adaptLineToTextSize(userNameTextField)
        
        let actions: [KindActionType] = [.none,.activate]
        let actionViews: [ActionViewName] = [.none,.UserNameView]
        let options = self.talkbox?.createUserOptions(opt1: "", opt2: "I'm good with that.", actionViews: (.none,.UserNameView))
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
            KindUser.loggedUserName = username
            txt = "Great, \(KindUser.loggedUserName ?? username) you are all set.-Welcome to The Kind.-Create a circle or join a circle."
            // SAVE USERNAME TO FIRESTORE.
            // PROCEED ON COMPLETED
        } else {
            talk() // Talk to the user about the user name. (repeat the routine)
            return
        }
        
        let actions: [KindActionType] = [.none,.none,.activate]
        let actionViews: [ActionViewName] = [.none,.none,.MapView]
        //let options = self.talkbox?.createUserOptions(opt1: "If.", opt2: "No need. Skip it.", actionViews: (.none,.none))
        
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, action: actions, actionView: actionViews, options: nil))
    }

     override func leftOptionClicked() {
        
    }


}
