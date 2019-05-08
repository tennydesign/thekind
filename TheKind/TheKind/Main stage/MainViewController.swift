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
    
    @IBOutlet var hudView: HUDview! // content is here.
    @IBOutlet var hudWindow: UIView! // overall top
    
    @IBOutlet var jungChatWindow: UIView! {
        didSet{
            //If you want to adjust chatbox window independently of bottomPanel.
        }
    }
    
    
    @IBOutlet var searchView: SearchView!
    @IBOutlet var chatMask: UIImageView!
    @IBOutlet var chatMaskView: UIView!
    
    // TODO: Gameboard is hidden
    @IBOutlet var gameBoardViewHost: GameBoard! {
        didSet {
            gameBoardViewHost.isHidden = true
        }
    }

    @IBOutlet var cardSwipeViewHost: CardSwipeView! {
        didSet{
            cardSwipeViewHost.isHidden = false
            cardSwipeViewHost.alpha = 0
        }
    }
    
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
    
    
    @IBOutlet var chooseKindCardViewHost: BrowseKindCardView! {
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
    
    @IBOutlet var jungChatLogger: JungChatLogger!
    
    let talkbox = JungTalkBox()
    
    @IBOutlet var confirmationView: ConfirmationView!
    
    fileprivate func initMainViewControllerForViews() {
        hudView.mainViewController = self
        jungChatLogger.mainViewController = self
        badgePhotoSetupViewHost.mainViewController = self
        userNameViewHost.mainViewController = self
        mapViewHost.mainViewController = self
        chooseKindCardViewHost.mainViewController = self
        gameBoardViewHost.mainViewController = self
        cardSwipeViewHost.mainViewController = self
        dobOnboardingViewHost.mainViewController = self
        chooseDriverView.mainViewController = self
        
        
    }
    
    fileprivate func initTalkboxForViews() {
        jungChatLogger.talkbox = talkbox
        badgePhotoSetupViewHost.talkbox = talkbox
        dobOnboardingViewHost.talkbox = talkbox
        userNameViewHost.talkbox = talkbox
        chooseDriverView.talkbox = talkbox
        chooseKindCardViewHost.talkbox = talkbox
        mapViewHost.talkbox = talkbox
        gameBoardViewHost.talkbox = talkbox
        cardSwipeViewHost.talkbox = talkbox
    }
    
    //First view of the sequence
    var firstViewToPresent: ActionViewName = ActionViewName.UserNameView
    var introSnippets : [Snippet] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        initMainViewControllerForViews()
        initTalkboxForViews()

        self.adaptHUDAndPanelToIphoneXFamily()

        self.updateViewTagWithCurrentState()
        self.intro()
        
        KindDeckManagement.sharedInstance.initializeDeckObserver()
    }
    
    fileprivate func updateViewTagWithCurrentState() {
        //update tag:
        guard let tag = KindUserSettingsManager.sharedInstance.userFields[UserFieldTitle.currentLandingView.rawValue] as? Int  else {return}
        if let actionViewNameEnum = ActionViewName(rawValue: tag) {
            self.firstViewToPresent = actionViewNameEnum
        }
    }
    
    
    fileprivate func loadUserDeck() {
        //load user deck
        KindDeckManagement.sharedInstance.getCurrentUserDeck { (success) in
            //print(KindDeckManagement.sharedInstance.userKindDeck)
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
    
    fileprivate func intro() {
        let actions: [KindActionType] = [.activate]
        let actionViews: [ActionViewName] = [self.firstViewToPresent]
        self.talkbox.displayRoutine(routine: self.talkbox.routineWithNoText(snippetId: nil, sender: .Jung, action: actions, actionView: actionViews, options: nil))
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
    
    func setHudDisplayGradientBg(on:Bool, completion: (()->())?) {
        UIView.animate(withDuration: 0.4, animations: {
            self.hudView.hudCenterDisplay.alpha = on ? 1 : 0
            self.hudView.hudGradient.alpha = on ? 1 : 0
        }) { (completed) in
            self.hudView.isUserInteractionEnabled = on ? true : false
            completion?()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    
    
}








