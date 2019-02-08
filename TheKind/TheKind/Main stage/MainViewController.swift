//
//  MainViewController.swift
//  TheKind
//
//  Created by Tenny on 23/08/18.
//  Copyright © 2018 tenny. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import AWSRekognition
import FirebaseAuth

class MainViewController: UIViewController {

    var isOnboarding: Bool!
    @IBOutlet var bottomConstraintPanelMover: NSLayoutConstraint!
    var maxMapBottomPanelPosition: CGFloat!
    var rekognitionObject: AWSRekognition?
    @IBOutlet var hudWindow: UIView!
    @IBOutlet var jungChatWindow: UIView! {
        didSet{
            //If you want to adjust chatbox window independently of bottomPanel.
        }
    }
    
    @IBOutlet var JungChatWindowY: NSLayoutConstraint!
    @IBOutlet var chatMask: UIImageView!
    
    
    var loggedUserEmail: String?
    // TODO: Gameboard is hidden
    @IBOutlet var gameBoardViewHost: GameBoard! {
        didSet {
            gameBoardViewHost.isHidden = true
        }
    }
    
    // ADDTRIGGERVIEW: Must add it here.
    @IBOutlet var dobOnboardingViewHost: dobOnboardingView! {
        didSet{
            dobOnboardingViewHost.isHidden = true
            dobOnboardingViewHost.alpha = 0
        }
    }
    @IBOutlet var userNameViewHost: UserNameView! {
        didSet {
            userNameViewHost.isHidden = true
            userNameViewHost.alpha = 0
        }
    }
    @IBOutlet var badgePhotoSetupViewHost: BadgePhotoSetupView! {
        didSet {
            badgePhotoSetupViewHost.isHidden = true
            badgePhotoSetupViewHost.alpha = 0
        }
    }
    
    @IBOutlet var mapViewHost: MapActionTriggerView! {
        didSet {
            mapViewHost.isHidden = true
            mapViewHost.alpha = 0
        }
    }

    
    @IBOutlet var chooseKindCardViewHost: ChooseKindCardView! {
        didSet {
            chooseKindCardViewHost.isHidden = true
            chooseKindCardViewHost.alpha = 0
        }
    }
    
    @IBOutlet var chooseDriverView: ChooseDriverView! {
        didSet {
            chooseDriverView.isHidden = true
            chooseDriverView.alpha = 0
        }
    }
    

    @IBOutlet var bottomCurtainView: UIView!
    @IBOutlet weak var topCurtainView: UIView!
    @IBOutlet var bottomCurtainImage: UIImageView! {
        didSet {
            bottomCurtainImage.image = bottomCurtainImage.image?.withRenderingMode(.alwaysTemplate)
            bottomCurtainImage.tintColor = UIColor.black
        }
    }
    @IBOutlet var bottomCurtainImageBase: UIImageView! {
        didSet {
            bottomCurtainImageBase.image = bottomCurtainImage.image?.withRenderingMode(.alwaysTemplate)
            bottomCurtainImageBase.tintColor = UIColor(r: 34, g: 34, b: 34)
        }
    }
    
    
    @IBOutlet var hudView: HUDview!
    @IBOutlet var jungChatLogger: JungChatLogger!
    
    let talkbox = JungTalkBox()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // ADDTRIGGERVIEW: Must add it here.
        hudView.mainViewController = self
        jungChatLogger.mainViewController = self
        badgePhotoSetupViewHost.mainViewController = self
        userNameViewHost.mainViewController = self
        mapViewHost.mainViewController = self
        chooseKindCardViewHost.mainViewController = self
        
        jungChatLogger.talkbox = talkbox
        badgePhotoSetupViewHost.talkbox = talkbox
        dobOnboardingViewHost.talkbox = talkbox
        userNameViewHost.talkbox = talkbox
        chooseDriverView.talkbox = talkbox
        chooseKindCardViewHost.talkbox = talkbox
        mapViewHost.talkbox = talkbox

        loggedUserEmail = Auth.auth().currentUser?.email
        
        chatMask.isHidden = false
        jungChatWindow.mask = chatMask

        
        delay(bySeconds: 1) {
            self.adaptHUDAndPanelToIphoneXFamily()
            self.presentJungIntro() // using this routine to test scripts before deploying them.
        }
       
    }
    
    
    func adaptHUDAndPanelToIphoneXFamily() {
        if UIScreen.isPhoneXfamily {
            UIView.animate(withDuration: 0.3) {
                self.hudView.hudControls.transform = CGAffineTransform.init(translationX: 0, y: 20)
                self.bottomCurtainView.transform = CGAffineTransform(translationX: 0, y: -20)
            }
            
        }

    }
    
    func presentJungIntro() {
        hitPickerControl()
        let options = self.talkbox.createUserOptions(opt1: "Wire-in mode.", opt2: "Introduce me to someone.", actionView: self.view)
        let intro = JungRoutine(snippets: introSnippets, userResponseOptions: options, sender: .Jung)
        talkbox.displayRoutine(routine: intro)
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    func moveBottomPanel(distance: CGFloat, completion: (()->())?) {
        //fix for iphoneX family
        bottomConstraintPanelMover.constant = UIScreen.isPhoneXfamily ? distance-44.0 :distance
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }) { (completed) in
            if let completion = completion {
                completion()
            }
        }
        
    }

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    
}



var introSnippets : [Snippet] = [Snippet(message: "Hi my name is JUNG.", action: .none, id: 1, actionView: ActionViewName.none),
                                  Snippet(message: "You say it like 'YUNG'.", action: .activate,id: 2, actionView: ActionViewName.GameBoard)]




