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

//HERE: Maybe MOVE UP the chatbox during the onboarding.
class MainViewController: UIViewController {

    var isOnboarding: Bool!
    var minMapBottomPanelPosition: CGFloat!
    var maxMapBottomPanelPosition: CGFloat!
    var rekognitionObject: AWSRekognition?
    @IBOutlet var hudWindow: UIView!
    @IBOutlet var jungChatWindow: UIView! {
        didSet{
            //MExer aqui quando o mapa entra pra ajustar o chatbox
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
    
    
    @IBOutlet var top_curtain_top_constraint: NSLayoutConstraint!
    @IBOutlet var bottom_curtain_bottom_constraint: NSLayoutConstraint!


    @IBOutlet var bottomCurtainView: UIView!
    @IBOutlet weak var topCurtainView: UIView!
    @IBOutlet var bottomCurtainImage: UIImageView! {
        didSet {
            bottomCurtainImage.image = bottomCurtainImage.image?.withRenderingMode(.alwaysTemplate)
            bottomCurtainImage.tintColor = UIColor.black //(r: 6, g: 6, b: 6)
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
    
    //SETUP First activated view.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // ADDTRIGGERVIEW: Must add it here.
        hudView.mainViewController = self
        jungChatLogger.mainViewController = self
        badgePhotoSetupViewHost.mainViewController = self
        userNameViewHost.mainViewController = self
        mapViewHost.mainViewController = self
        
        jungChatLogger.talkbox = talkbox
        badgePhotoSetupViewHost.talkbox = talkbox
        dobOnboardingViewHost.talkbox = talkbox
        userNameViewHost.talkbox = talkbox
        chooseDriverView.talkbox = talkbox
        chooseKindCardViewHost.talkbox = talkbox

        loggedUserEmail = Auth.auth().currentUser?.email
        
        chatMask.isHidden = false
        jungChatWindow.mask = chatMask
        
        delay(bySeconds: 1) {
            self.presentJungIntro() // using this routine to test scripts before deploying them.
        }
        
        minMapBottomPanelPosition = bottom_curtain_bottom_constraint.constant
        maxMapBottomPanelPosition = bottom_curtain_bottom_constraint.constant + MAXSLIDEFORBOTTOMPANEL
       
    }
    
    
    
    func presentJungIntro() {
        let intro = JungRoutine(snippets: introSnippets, userResponseOptions: nil, sender: .Jung)
        talkbox.displayRoutine(routine: intro)
    }
    
    func adjustCurtains() {
         UIView.adjustCurtainsToScreen(topCurtain: self.top_curtain_top_constraint , bottomCurtain: self.bottom_curtain_bottom_constraint, view: self.view)

    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    func moveMapBottomPanel(distance: CGFloat, completion: (()->())?) {
       
        // To make sure it nevers go over the limit
        bottom_curtain_bottom_constraint.constant += distance
        if bottom_curtain_bottom_constraint.constant > maxMapBottomPanelPosition {
            bottom_curtain_bottom_constraint.constant = maxMapBottomPanelPosition
        }
        else if bottom_curtain_bottom_constraint.constant < minMapBottomPanelPosition {
             bottom_curtain_bottom_constraint.constant = minMapBottomPanelPosition
        }
        
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
                                  Snippet(message: "You say it like 'YUNG'.", action: .talk,id: 2, actionView: ActionViewName.UserNameView)]




