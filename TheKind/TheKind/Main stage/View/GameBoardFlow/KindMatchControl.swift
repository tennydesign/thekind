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

class KindMatchControl: UIView, KindActionTriggerViewProtocol {
    func deactivate() {
        
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
    
    func talk() {
    }
    
    func preIntroduction() {
        let txt = "Tenny meet Alex.-Alex is the Founder Kind and I think you have a lot in common."
        let actions: [KindActionType] = [.none,.none]
        let actionViews: [ActionViewName] = [.none,.none]
        
        //HERE
        let options = self.talkbox?.createUserOptions(opt1: "Tell me more.", opt2: "Introduce us.", actionViews: (ActionViewName.KindMatchControlView,ActionViewName.KindMatchControlView))
        
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, action: actions, actionView: actionViews, options: options))
    }
    
    func activate() {
    }
    
    func rightOptionClicked() {
        //HERE:
        // 1) Send Alex a message
        // 2) If Alex agrees send this screen to CHAT
        // 3) If alex does not want to meet, send a message saying: I can't reach for Alex right now.
        print("Send Alex a message")
        print("GO TO CHAT SCREEN")
    }
    
    func leftOptionClicked() {
        let actions: [KindActionType] = [.activate]
        let actionViews: [ActionViewName] = [ActionViewName.BrowseKindView]
        
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineWithNoText(snippetId: nil, sender: .Jung, action: actions, actionView: actionViews, options: nil))
        
        isShowingUserCarousel = true
    }
    
    func fadeInView() {
        
    }
    
    func fadeOutView() {
        
    }
    
    
}
