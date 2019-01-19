//
//  xt_GameBoardScene.swift
//  TheKind
//
//  Created by Tennyson Pinheiro on 11/5/18.
//  Copyright © 2018 tenny. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

extension GameBoardScene {
    
    
    @objc func handlePanFrom(withSender sender: UIPanGestureRecognizer) {
        
        if sender.state == .began || sender.state == .changed {
            let translation = sender.translation(in: sender.view)

            slideGameBoard(translation: translation)

            //this clears up the gesture buffer? maybe. It doesn't work well without it.
            sender.setTranslation(CGPoint.zero, in: sender.view)
            
            
        }
        
    }
    
    func slideGameBoard(translation: CGPoint) {
        
        let slideSpeed:CGFloat = 9
        let zoomedOutSpeedFactor:CGFloat = self.size.width/100
        
        let changeX = (camera?.position.x)! - (translation.x * abs((slideSpeed + zoomedOutSpeedFactor * ((camera?.xScale)! - initCamScale!))))
        let changeY = (camera?.position.y)! + (translation.y * abs((slideSpeed + zoomedOutSpeedFactor * ((camera?.xScale)! - initCamScale!))))
        
        
        print("x:\(changeX) :: y:\(changeY)")
        
        
        let targetPosition = keepWithinPanLimitPoints(for: CGPoint(x: changeX, y: changeY))
        
        
        //move to position.
        let action: SKAction = SKAction.move(to: targetPosition, duration: 1)
        
        //action.timingMode = .easeOut
        action.timingFunction = CubicEaseOut
        
        
        self.camera?.run(action)
        
    }
    
    func keepWithinPanLimitPoints(for coordinate: CGPoint) -> CGPoint
    {
        // this sets the boundaries that will be used below.
        updatePanLimitPoint()
        
        var xPoint: CGFloat = coordinate.x
        var yPoint: CGFloat = coordinate.y
        let zero: CGFloat = 0
        
        if xPoint < -maxPan.x || coordinate.x > maxPan.x{
            xPoint = xPoint < zero ? -maxPan.x : maxPan.x
        }
        
        if yPoint < -maxPan.y || coordinate.y > maxPan.y{
            yPoint = yPoint < zero ? -maxPan.y : maxPan.y
        }
        
        return CGPoint(x: xPoint,y: yPoint)
    }
    
    func updatePanLimitPoint() {
        
        if let scene = self.scene as? GameBoardScene {
            
            if let tileMap = scene.childNode(withName: "GameBoardTileMap") as? SKTileMapNode {
                
                let mapHeight = tileMap.mapSize.height
                let mapWidth = tileMap.mapSize.width
                
                // zoomFactor = How many times the board is zoomed. Eg. 1 to 4x
                let zoomFactor = (maxZoomOutLimit! / (camera?.xScale)!)
                
                let maxPanX = (mapWidth/2) - (280/zoomFactor) + 5 // 5 is a buffer.
                let maxPanY = (mapHeight/2) - (340/zoomFactor) + 5
                maxPan = CGPoint(x: maxPanX, y: maxPanY)
                
            }
            
            
        }
    }
    
    @objc func handlePinchFrom(withSender pinch: UIPinchGestureRecognizer) {
        
        if pinch.state == .began {
            //initialize it with the last camera scale state
            lastCamScale = (camera?.xScale)!
            // update limtits of the board
            updatePanLimitPoint()
        }
        
        // sets the new scale.
        camera?.setScale(lastCamScale! * 1 / pinch.scale)

        
        // Limits Zoom
        
        if (camera?.xScale)! < maxZoomInLimit! {
            camera?.xScale = maxZoomInLimit!
            camera?.yScale = maxZoomInLimit!
        }
        
        if (camera?.xScale)! > maxZoomOutLimit! {
            camera?.xScale = maxZoomOutLimit!
            camera?.yScale = maxZoomOutLimit!
        }
        

        
        print("camera zoom: \(String(describing: camera?.xScale))")
        
    }

    
    
    func CubicEaseOut(_ t:Float)->Float
    {
        let f:Float = (t - 1);
        return f * f * f + 1;
    }
    
    func changeCameraZoom(camera: SKCameraNode, scale: CGFloat) {
        let action:SKAction = SKAction.scale(to: scale, duration: 2)
        action.timingFunction = CubicEaseOut
        camera.run(action)
    }
    
}
