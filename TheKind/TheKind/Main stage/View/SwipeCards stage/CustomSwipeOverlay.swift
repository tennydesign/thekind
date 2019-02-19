//
//  CustomSwipeOverlay.swift
//  TheKind
//
//  Created by Tenny on 2/18/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import UIKit
import SpriteKit
import Koloda

class CustomSwipeOverlay: OverlayView {
    let scene = SKScene()
    var loadedParticles: Bool = false
    @IBOutlet lazy var skView: SKView! = { [unowned self] in
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        var skview = SKView(frame: frame)
        skview.translatesAutoresizingMaskIntoConstraints = true
        skview.clipsToBounds = false
        skview.allowsTransparency = true
        skview.alpha = 0.7
        skview.backgroundColor = UIColor.clear
        self.addSubview(skview)
        self.sendSubviewToBack(skview)
        return skview
    }()
    
    
    override var overlayState: SwipeResultDirection?  {
        didSet {
            switch overlayState {
            case .left? :
                let size = CGSize(width: skView.bounds.width, height: skView.bounds.height)
                scene.size = size
                scene.scaleMode = .fill
                scene.backgroundColor = UIColor.clear.withAlphaComponent(0)
                skView.alpha = 0.7
                
                guard let heartCascadeNode = SKEmitterNode(fileNamed: "KeepParticle") else {return}
                heartCascadeNode.name = "keep"
                heartCascadeNode.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2 )

                
                if scene.childNode(withName: "keep") == nil {
                    scene.addChild(heartCascadeNode)
                    skView.presentScene(scene)
                }
                
            case .right? :
                skView.alpha = 0
                let size = CGSize(width: skView.bounds.width, height: skView.bounds.height)
                scene.size = size
                scene.scaleMode = .aspectFill
                scene.backgroundColor = UIColor.clear
                if let keep = scene.childNode(withName: "keep") {
                    keep.removeFromParent()
                }
                skView.presentScene(scene)
                
            default:
                skView.alpha = 0
                let scene = SKScene(size:  self.bounds.size)
                scene.scaleMode = .aspectFill
                scene.backgroundColor = UIColor.clear
                skView.presentScene(scene)
            }
            
        }
    }
}
