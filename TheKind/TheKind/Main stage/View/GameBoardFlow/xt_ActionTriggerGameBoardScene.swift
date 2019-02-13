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

// Refers to the ActionTriggerView.
extension GameBoardScene: ControlGameBoardProtocol {
    func searchBoardAndFindKindToIntroduce() {
        print("BOARD SHOULD MOVE!!!!!")
        moveCamToCenterOfTile(duration: 1, row: 1, column: 8) {
            self.moveCamToCenterOfTile(duration: 1, row: 4, column: 0) {
                self.moveCamToCenterOfTileAndZoom(duration: 2, row: 10, column: 10)
                self.resetToTestAgain()
            }
        }
    }
    
    func resetToTestAgain() {
        // RESET BUTTON TO KEEP TESTING - TESTING ONLY
        let txt = "Let me know if you want me to introduce you to someone."
        let actions: [KindActionType] = [.none]
        let actionViews: [ActionViewName] = [.none]
        
        //HERE
        let options = self.talkbox?.createUserOptions(opt1: "", opt2: "Yes... introduce me to someone", actionViews: (ActionViewName.GameBoardActionView,ActionViewName.GameBoardActionView))
        
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, action: actions, actionView: actionViews, options: options))
    }
}
