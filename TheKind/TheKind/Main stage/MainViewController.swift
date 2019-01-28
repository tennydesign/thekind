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
    var minBottomCurtainPosition: CGFloat!
    var maxBottomCurtainPosition: CGFloat!
    var rekognitionObject: AWSRekognition?
    @IBOutlet var hudWindow: UIView!
    @IBOutlet var jungChatWindow: UIView!
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
    
    @IBOutlet var circleDetailsHost: CircleDetailView! {
        didSet {
            circleDetailsHost.alpha = 0
        }
    }
    
    
    
    @IBOutlet var top_curtain_top_constraint: NSLayoutConstraint!
    @IBOutlet var bottom_curtain_bottom_constraint: NSLayoutConstraint!

    @IBOutlet var bottomCurtainView: UIView!
    @IBOutlet weak var topCurtainView: UIView!
    
    
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
        

        loggedUserEmail = Auth.auth().currentUser?.email
        
        chatMask.isHidden = false
        jungChatWindow.mask = chatMask
        
        delay(bySeconds: 1) {
            self.presentJungIntro() // using this routine to test scripts before deploying them.
        }
        
        minBottomCurtainPosition = bottom_curtain_bottom_constraint.constant
        maxBottomCurtainPosition = bottom_curtain_bottom_constraint.constant + maxSlideBottomCurtainPosition
       
    }
    
    
    
    func presentJungIntro() {
        let intro = JungRoutine(snippets: introSnippets, userResponseOptions: nil, sender: .Jung)
        talkbox.displayRoutine(routine: intro)
    }
    
    func adjustCurtains() {
         UIView.adjustCurtainsToScreen(topCurtain: self.top_curtain_top_constraint , bottomCurtain: self.bottom_curtain_bottom_constraint, view: self.view)

    }
    
    func moveBottomCurtain(distance: CGFloat, completion: (()->())?) {
       
        // To make sure it nevers go over the limit
        bottom_curtain_bottom_constraint.constant += distance
        if bottom_curtain_bottom_constraint.constant > maxBottomCurtainPosition {
            bottom_curtain_bottom_constraint.constant = maxBottomCurtainPosition
        }
        else if bottom_curtain_bottom_constraint.constant < minBottomCurtainPosition {
             bottom_curtain_bottom_constraint.constant = minBottomCurtainPosition
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



//var introSnippets : [Snippet] = [Snippet(message: "Hi Tenny my name is JUNG.", action: .activate, id: 1, actionView: ActionViewName.BadgePhotoSetupView),
//                                  Snippet(message: "You say it like 'YUNG'.", action: .none,id: 2, actionView: nil),
//                                  Snippet(message: "Think of me like a friend that can introduce you to other people.", action: .none,id: 2, actionView: nil),
//                                  Snippet(message: "... or kinds like I like to call.", action: .none,id: 2, actionView: nil),
//                                  Snippet(message: "Whenever you join a circle I can introduce you to someone", action: .none, id: 4, actionView: nil),
//                                  Snippet(message: "That is... if you want of course.", action: .none, id: 6, actionView: nil),
//                                  Snippet(message: "But first let's take a selfie.", action: .fadeInView, id: 7, actionView: ActionViewName.BadgePhotoSetupView),
//                                  Snippet(message: "Nothing to worry. No one will ever swipe your photo. I promise", action: .none, id: 7, actionView: nil)]

var introSnippets : [Snippet] = [Snippet(message: "Hi Tenny my name is JUNG.", action: .activate, id: 1, actionView: ActionViewName.MapView),
                                 Snippet(message: "You say it like 'YUNG'.", action: .none,id: 2, actionView: nil),
                                 Snippet(message: "Think of me like a friend that can introduce you to other people.", action: .none,id: 2, actionView: nil),
                                 Snippet(message: "... or kinds like I like to call.", action: .none,id: 2, actionView: nil),
                                 Snippet(message: "Whenever you join a circle I can introduce you to someone", action: .none, id: 4, actionView: nil),
                                 Snippet(message: "That is... if you want of course.", action: .none, id: 6, actionView: nil),
                                 Snippet(message: "But first let's take a selfie.", action: .none, id: 7, actionView: ActionViewName.none),
                                 Snippet(message: "Nothing to worry. No one will ever swipe your photo. I promise", action: .none, id: 7, actionView: nil)]



