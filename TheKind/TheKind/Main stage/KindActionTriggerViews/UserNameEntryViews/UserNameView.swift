//
//  UserNameView.swift
//  TheKind
//
//  Created by Tenny on 1/7/19.
//  Copyright © 2019 tenny. All rights reserved.
//
// FOR NAVIGATION ALWAYS SEARCH FOR THE RIGHTCLICKED OPTION.
import UIKit
import RxCocoa
import RxSwift

class UserNameView: KindActionTriggerView, UITextFieldDelegate {
    var username: String = ""
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
        //print("keyboard did show")
        UIView.animate(withDuration: 0.3) {
            self.userNameBox.transform = CGAffineTransform(translationX: 0, y: -35)
        }
    }
    
    @objc func handleKeyboardDidHide() {
        //print("keyboard did hide")
        UIView.animate(withDuration: 0.3) {
            self.userNameBox.transform = .identity
        }
    }
    
    //TODO: REMOVE THIS AND USE THE GLOBAL ONE
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
        guard let username = textField.text, !(username.trimmingCharacters(in: .whitespaces).isEmpty) else {return}
        self.username = username
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Cool guard for textfields.
        guard let username = textField.text, !(username.trimmingCharacters(in: .whitespaces).isEmpty) else {return true}
        self.username = username
        textField.resignFirstResponder()
        
        KindUserSettingsManager.sharedInstance.loggedUserName = username
        let txt = "Great, I will call you \(username) from now on.-You can change it again if you prefer."
        let actions: [KindActionTypeEnum] = [.none,.none]
        let actionViews: [ViewForActionEnum] = [.none,.none]
        let options = self.talkbox?.createUserOptions(opt1: "", opt2: "I'm good with that.", actionViews: (.none,.UserNameView))
        
        let routine = self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, actions: actions, actionViews: actionViews, options: options)
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkbox?.kindExplanationPublisher.onNext(rm)
        }

        return true
    }
    
    override func activate() {

        //Bundle.main.loadNibNamed("UserNameView", owner: self, options: nil)
        Bundle.main.loadNibNamed("UserNameView", owner: self, options: nil)
        //guard let view = xibViews?.first as? UIView else {return}
        //self.addSubview(view)
        //self.mainViewController?.main_content_view = mainView
        addSubview(mainView)
        setupUserNameTextField()
        
        adaptLineToTextSize(userNameTextField)
        //KindUser.loggedUserName = "" // test purposes only
        setupKeyboardObservers()
        self.talkbox?.delegate = self
        
        self.logCurrentLandingView(tag: ViewForActionEnum.UserNameView.rawValue)
        self.fadeInView()
        self.talk()
    }
    

    
    override func talk() {
        var txt: String = ""

        if !(KindUserSettingsManager.sharedInstance.loggedUserName ?? "").isEmpty {
            userNameTextField.text = KindUserSettingsManager.sharedInstance.loggedUserName
            txt = "Can I call you \(KindUserSettingsManager.sharedInstance.loggedUserName!)?-If that's not good please change above."
        } else {
            userNameTextField.text = "[Type your name]"
            userNameTextField.clearsOnInsertion = true
            txt = "Hummm... I tried but didn't find your name.-Please enter your name above"
        }
       
        adaptLineToTextSize(userNameTextField)
        
        nameTryOutExplainer(txt: txt)
    }
    


    
    override  func deactivate() {
        mainView.removeFromSuperview()
        NotificationCenter.default.removeObserver(self)
        self.talkbox?.delegate = nil
    }
    

    
    override func rightOptionClicked() {
        var txt: String = ""
        
        if let username = userNameTextField.text, !(username.trimmingCharacters(in: .whitespaces).isEmpty) {
            self.fadeOutView()
            KindUserSettingsManager.sharedInstance.loggedUserName = username
            KindUserSettingsManager.sharedInstance.userFields[UserFieldTitle.name.rawValue] = username
            KindUserSettingsManager.sharedInstance.updateUserSettings(completion: nil)
            
            txt = "Great, nice to meet you \(KindUserSettingsManager.sharedInstance.loggedUserName ?? username).-This setup will only take a few more seconds"
            
            setupPaceExplainer(txt)
          
        } else {
            talk() // Talk to the user about the updated user name. (repeat the routine)
        }
       
    }

     override func leftOptionClicked() {
        
    }


}
