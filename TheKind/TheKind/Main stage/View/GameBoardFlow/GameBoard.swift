//
//  GameBoard.swift
//  TheKind
//
//  Created by Tennyson Pinheiro on 11/5/18.
//  Copyright © 2018 tenny. All rights reserved.
//
//

import Foundation
import UIKit
import SpriteKit

class GameBoard: KindActionTriggerView {
    

    @IBOutlet var gameBoardView: UIView!
    @IBOutlet weak var boardSkView: SKView!
    var tileMapSize: CGSize?
    var talkbox: JungTalkBox?
    var mainViewController: MainViewController?
    var gameBoardScene: GameBoardScene?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        
        Bundle.main.loadNibNamed("GameBoard", owner: self, options: nil)
        addSubview(gameBoardView)
        
        gameBoardView.frame = self.bounds
        gameBoardView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        
        if let scene = SKScene(fileNamed: "gameboardScene") as? GameBoardScene {
            scene.scaleMode = .aspectFill
            boardSkView.presentScene(scene)
            gameBoardScene = scene
        } else {
            print("scene not found")
        }
        
        boardSkView.ignoresSiblingOrder = true
        
        
    }
    
    override func activate() {
        mainViewController?.setHudDisplayGradientBg(on: true) {
            self.fadeInView()
        }
        self.mainViewController?.bottomCurtainView.isUserInteractionEnabled = true
        gameBoardScene?.mainViewController = self.mainViewController
        gameBoardScene?.routineFinishedPostObserver()
        
        UIView.animate(withDuration: 0.3) {
            self.gameBoardScene?.mainViewController?.jungChatLogger.bottomGradient.alpha = 1
        }
        gameBoardScene?.talkbox = self.talkbox
        let txt = "Let me know if you want me to introduce you to someone."
        let actions: [KindActionType] = [.none]
        let actionViews: [ActionViewName] = [.none]
        
        let options = self.talkbox?.createUserOptions(opt1: "No... keep in wired-in mode.", opt2: "Yes... introduce me to someone.", actionViews: (ActionViewName.GameBoardSceneControlView,ActionViewName.GameBoardSceneControlView))
        
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, action: actions, actionView: actionViews, options: options))
        
    }
    
    override func deactivate() {
        self.fadeOutView()
    }
}
