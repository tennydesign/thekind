//
//  xt_ActionTriggerGameBoardScene.swift
//  TheKind
//
//  Created by Tenny on 2/12/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

protocol ControlGameBoardProtocol {
    func searchBoardAndFindKindToIntroduce()
    func resetCameraZoom()
}

// Refers to the ActionTriggerView.
extension GameBoardScene: ControlGameBoardProtocol {
    func searchBoardAndFindKindToIntroduce() {
        print("BOARD SHOULD MOVE!!!!!")
        moveCamToCenterOfTile(duration: 1, row: 1, column: 8) {
            self.moveCamToCenterOfTile(duration: 1, row: 4, column: 0) {
                self.moveCamToCenterOfTileAndZoom(duration: 0.6, row: 13, column: 11, completion: {
                    self.kindMatchControlView.preIntroduction()
                })
            }
        }
    }
    
    func resetCameraZoom() {
        let action:SKAction = SKAction.scale(to: initCamScale!, duration: 2)
        action.timingFunction = CubicEaseOut
        sceneCamera.run(action)
    }

}


class GameBoardSceneControlView: UIView, KindActionTriggerViewProtocol {
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
        tag = 201
    }
    
    func talk() {
        delegate?.resetCameraZoom()
    }
    
    func activate() {
        self.isHidden = false
        self.alpha = 1
    }
    
    func rightOptionClicked() {
        delegate?.searchBoardAndFindKindToIntroduce()

    }
    
    func leftOptionClicked() {
        
    }
    
    func fadeInView() {
        
    }
    
    func fadeOutView() {
        
    }
}


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
