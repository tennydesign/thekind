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
import RxCocoa
import RxSwift
//TODO: HAVE A SWITCH FOR TILES THAT ARE PHOTOS NOT ICONS.

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
        
//        Bundle.main.loadNibNamed("GameBoard", owner: self, options: nil)
//        addSubview(gameBoardView)
//
//        gameBoardView.frame = self.bounds
//        gameBoardView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
//
//        if let scene = SKScene(fileNamed: "gameboardScene") as? GameBoardScene {
//            scene.scaleMode = .aspectFill
//            boardSkView.presentScene(scene)
//            gameBoardScene = scene
//        } else {
//            print("scene not found")
//        }
//
//        boardSkView.ignoresSiblingOrder = true
        
        
    }
    
    override func activate() {
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
        
        mainViewController?.setHudDisplayGradientBg(on: true) {
            self.fadeInView()
        }
        self.mainViewController?.bottomCurtainView.isUserInteractionEnabled = true
        gameBoardScene?.mainViewController = self.mainViewController
        gameBoardScene?.routineFinishedPostObserver()
        
//        UIView.animate(withDuration: 0.3) {
//            self.gameBoardScene?.mainViewController?.jungChatLogger.bottomGradient.alpha = 1
//        }
        self.gameBoardScene?.mainViewController?.jungChatLogger.bottomGradient.fadeIn(0.3)
        gameBoardScene?.talkbox = self.talkbox
        let txt = "Let me know if you want me to introduce you to someone."
        let actions: [KindActionTypeEnum] = [.none]
        let actionViews: [ViewForActionEnum] = [.none]
        
        let options = self.talkbox?.createUserOptions(opt1: "No... keep in wired-in mode.", opt2: "Yes... introduce me to someone.", actionViews: (ViewForActionEnum.GameBoardSceneControlView,ViewForActionEnum.GameBoardSceneControlView))

        
        let routine = self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: options)
        
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkbox?.kindExplanationPublisher.onNext(rm)
        }
        
    }
    
    
    
    override func deactivate() {
        self.fadeOutView()
        gameBoardView.removeFromSuperview()
    }
}
