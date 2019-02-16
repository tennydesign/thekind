//
//  GameBoardSceneControlView.swift
//  TheKind
//
//  Created by Tenny on 2/14/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

protocol ControlGameBoardProtocol {
    func searchBoardAndFindKindToIntroduce()
    func resetCameraZoom()
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
