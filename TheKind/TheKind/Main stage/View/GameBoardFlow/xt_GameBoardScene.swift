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


// GESTURES AND MOVEMENTS.
extension GameBoardScene {
    @objc func handleTap(withSender sender: UITapGestureRecognizer) {
        let location = self.convertPoint(fromView: sender.location(in: self.view))
        let column = kindTilemap.tileColumnIndex(fromPosition: location)
        let row = kindTilemap.tileRowIndex(fromPosition: location)
        //let tile = kindTilemap.tileDefinition(atColumn: column, row: row)
        //print(tile?.name)
        let centerLocation = kindTilemap.centerOfTile(atColumn: column, row: row)
        //moveCamToCenterOfTileAndZoom(row: row, column: column)
        
        moveCamToCenterOfTileAndZoom(duration: 0.6, centerLocation: centerLocation) {
            self.kindMatchControlView.preIntroduction()
        }
    }
    

    
    
    func moveCamToCenterOfTile(duration: Double, centerLocation: CGPoint, completion: (()->())?) {
        let cameraMoveAction = SKAction.move(to: centerLocation, duration: duration)
        cameraMoveAction.timingFunction = CubicEaseOut
        
        if !isPanning {
            camera?.run(cameraMoveAction, completion: {
                if let completion = completion {
                    completion()
                }
            })
        }
    }
    
    func moveCamToCenterOfTile(duration: Double, row: Int, column: Int, completion: (()->())?) {
        let centerLocation = kindTilemap.centerOfTile(atColumn: column, row: row)
        let cameraMoveAction = SKAction.move(to: centerLocation, duration: duration)
        cameraMoveAction.timingFunction = CubicEaseOut
        
        if !isPanning {
            camera?.run(cameraMoveAction, completion: {
                if let completion = completion {
                    completion()
                }
            })
        }
    }
    
    func moveCamToCenterOfTileAndZoom(duration: Double,centerLocation: CGPoint, completion: (()->())?) {
        //let centerLocation = kindTilemap.centerOfTile(atColumn: column, row: row)
        let cameraMoveAction = SKAction.move(to: centerLocation, duration: duration)
        cameraMoveAction.timingFunction = CubicEaseOut
        let cameraZoomAction = SKAction.scale(to: maxZoomInLimit ?? 0.15, duration: duration)
        cameraZoomAction.timingFunction = CubicEaseOut
        let parallelActions = SKAction.group([cameraMoveAction,cameraZoomAction])
        
        
        if !isPanning {
            camera?.run(parallelActions, completion: {
                if let completion = completion {
                    completion()
                }
            })
        }
        
    }
    
    func moveCamToCenterOfTileAndZoom(duration: Double, row: Int, column: Int, completion: (()->())?) {
        let centerLocation = kindTilemap.centerOfTile(atColumn: column, row: row)
        let cameraMoveAction = SKAction.move(to: centerLocation, duration: duration)
        cameraMoveAction.timingFunction = CubicEaseOut
        let cameraZoomAction = SKAction.scale(to: maxZoomInLimit ?? 0.15, duration: duration)
        cameraZoomAction.timingFunction = CubicEaseOut
        let parallelActions = SKAction.group([cameraMoveAction,cameraZoomAction])

        if !isPanning {
            camera?.run(parallelActions, completion: {
                if let completion = completion {
                    completion()
                }
            })
        }
        
        
    }
    
    @objc func handlePanFrom(withSender sender: UIPanGestureRecognizer) {
        isPanning = true
        if sender.state == .began || sender.state == .changed {
            let translation = sender.translation(in: sender.view)
            
            slideGameBoard(translation: translation) {
                self.isPanning = false
            }
            
            //this clears up the gesture buffer? maybe. It doesn't work well without it.
            sender.setTranslation(CGPoint.zero, in: sender.view)
            
            
        }
        
    }
    
    func slideGameBoard(translation: CGPoint, completion: @escaping (()->())) {
        
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
        
        
        self.camera?.run(action, completion: {
            completion()
        })

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

        let zoomFactor = (maxZoomOutLimit! / (camera?.xScale)!)
        print(zoomFactor)
        maxPan = CGPoint(x: (kindTilemap.mapSize.width/2), y: (kindTilemap.mapSize.height/2))

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



