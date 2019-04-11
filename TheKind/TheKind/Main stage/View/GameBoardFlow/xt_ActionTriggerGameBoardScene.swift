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



// Functions triggered by GameBoardSceneControlView.
extension GameBoardScene: ControlGameBoardProtocol {
    func searchBoardAndFindKindToIntroduce() {
        //print("BOARD SHOULD MOVE!!!!!")
        moveCamToCenterOfTile(duration: 1, row: 1, column: 8) {
            self.moveCamToCenterOfTile(duration: 1, row: 4, column: 0) {
                self.moveCamToCenterOfTileAndZoom(duration: 2, row: 13, column: 11, completion: {
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


