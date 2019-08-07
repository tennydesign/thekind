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

class GameBoardSceneControlView: KindActionTriggerView {
    override func deactivate() {
        
    }
    
    func navigateBack() {
        
    }
    
    var talkbox: JungTalkBox?
    var delegate: ControlGameBoardProtocol?
    var mainViewController: MainViewController?
    
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
    
    override func talk() {
        delegate?.resetCameraZoom()
    }
    
    override func activate() {
        self.isHidden = false
        self.alpha = 1
        self.mainViewController?.bottomCurtainView.isUserInteractionEnabled = true
    }
    
    override func rightOptionClicked() {
        delegate?.searchBoardAndFindKindToIntroduce()
        
    }
    
    override func leftOptionClicked() {
        
    }
    
    
    override func fadeInView() {
        
    }
    
    override func fadeOutView() {
        
    }
}
