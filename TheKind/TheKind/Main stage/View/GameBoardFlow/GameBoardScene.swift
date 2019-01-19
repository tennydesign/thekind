//
//  GameBoardScene.swift
//  TheKind
//
//  Created by Tennyson Pinheiro on 11/5/18.
//  Copyright © 2018 tenny. All rights reserved.
//
// TOMORROW: Start with Directed Zoom feature.

import UIKit
import SpriteKit

class GameBoardScene: SKScene {


    var lastCamScale: CGFloat?
    var maxZoomOutLimit: CGFloat?
    var maxZoomInLimit: CGFloat?
    var maxPan: CGPoint!
    var tileMapSize: CGSize?
    
    //Initializes all zoom variables.
    var initCamScale: CGFloat? {
        didSet {
            maxZoomOutLimit = initCamScale! * 2
            maxZoomInLimit = initCamScale! / 2
            lastCamScale = initCamScale!
        }
    }
    
    
    override func sceneDidLoad() {
        
        if let tileMap = self.childNode(withName: "GameBoardTileMap") as? SKTileMapNode {
            tileMapSize = tileMap.mapSize
            scene!.size = CGSize(width: tileMapSize!.width + 30, height: tileMapSize!.height + 30) // 30 is to add a "cushion" to give the cards breathing space.
            if let camera = scene?.childNode(withName: "camera") as? SKCameraNode {
                let numberOfColumns: CGFloat = CGFloat(tileMap.numberOfColumns)
                // Zoom is relative to the size of the map. Currently showing 4 cards (fator = 6).
                initCamScale = 6/numberOfColumns
                camera.setScale(maxZoomOutLimit!*2)
                self.camera = camera
                changeCameraZoom(camera: camera, scale: initCamScale!)
            }
        }
        
    }
    
    
    override func didMove(to view: SKView) {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanFrom(withSender:)))
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchFrom(withSender:)))
        
        self.view?.addGestureRecognizer(panGestureRecognizer)
        self.view?.addGestureRecognizer(pinchGestureRecognizer)
    }
    


}
