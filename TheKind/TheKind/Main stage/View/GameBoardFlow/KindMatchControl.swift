//
//  kindMatchSceneControl.swift
//  TheKind
//
//  Created by Tenny on 2/14/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import RxCocoa
import RxSwift

class KindMatchControl: KindActionTriggerView {
    override func deactivate() {
        
    }
    
    var talkbox: JungTalkBox?
    var delegate: ControlGameBoardProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit(){
        tag = 202
    }
    
    override func talk() {
    }
    
    func preIntroduction() {
        let txt = "Tenny meet Alex.-Alex is the Founder Kind and I think you have a lot in common."
//        let actions: [KindActionType] = [.none,.none]
//        let actionViews: [ActionViewName] = [.none,.none]

        let options = self.talkbox?.createUserOptions(opt1: "See Kind deck.", opt2: "Intro us.", actionViews: (ActionViewName.KindMatchControlView,ActionViewName.KindMatchControlView))
        
        let routine = self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: nil, actionViews: nil, options: options)
        
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkbox?.kindExplanationPublisher.onNext(rm)
        }
    }
    
    override func activate() {
    }
    
    override func rightOptionClicked() {
        //HERE:
        // 1) Send Alex a message
        // 2) If Alex agrees send this screen to CHAT
        // 3) If alex does not want to meet, send a message saying: I can't reach for Alex right now.
        print("Send Alex a message")
        print("GO TO CHAT SCREEN")
    }
    
    override func leftOptionClicked() {
        let actions: [KindActionType] = [.activate, .none]
        let actionViews: [ActionViewName] = [ActionViewName.BrowseKindView, ActionViewName.GameBoard]
         KindDeckManagement.sharedInstance.isBrowsingAnotherUserKindDeck = true
        let routine = self.talkbox?.routineWithNoText(snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: nil)
        
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkbox?.kindExplanationPublisher.onNext(rm)
        }
        
       
    }
    
    override func fadeInView() {
        
    }
    
    override func fadeOutView() {
        
    }
    
    
}
