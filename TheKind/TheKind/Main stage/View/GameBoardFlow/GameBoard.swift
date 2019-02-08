//
//  GameBoard.swift
//  TheKind
//
//  Created by Tennyson Pinheiro on 11/5/18.
//  Copyright © 2018 tenny. All rights reserved.
//
// HERE: TESTED WITH MANY IPHONE FORMATS AND LOOKS OKAY, with a small diff between X models and previous model, small adjsutment probably 15-20px

import Foundation
import UIKit
import SpriteKit

class GameBoard: KindActionTriggerView {
    

    @IBOutlet var gameBoardView: UIView!
    @IBOutlet weak var boardSkView: SKView!
    var tileMapSize: CGSize?
    
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
        } else {
            print("scene not found")
        }
        
        boardSkView.ignoresSiblingOrder = true
        
        
    }
    
    override func activate() {
        self.isHidden = false
        self.alpha = 1
    }
}
