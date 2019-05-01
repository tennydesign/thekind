//
//  Ext_Explainers_MapActionTriggerView.swift
//  TheKind
//
//  Created by Tenny on 4/11/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import UIKit
import MapKit
import Mapbox

extension MapActionTriggerView {
    
    func explainerCircleCreation() {
        let txt = "You are creating a circle.-Click the locker to toggle between public and private.-If private only invited people can join.-Name the circle and hit save when you are done."
        
        let actions: [KindActionType] = [.none, .none,.none, .none]
        let actionViews: [ActionViewName] = [.none,.none,.none, .none]
        let options = self.talkbox?.createUserOptions(opt1: "Cancel", opt2: "Save", actionView: self)
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, action: actions, actionView: actionViews, options: options))
    }
    
    func explainerCircleExploration(set: CircleAnnotationSet) {
        let dominantKind = "founder"
        let chanceScore = "high"
        var txt = "This place is dominated by the \(dominantKind) kind.-You have \(chanceScore) chances of making friends here."
        var actions: [KindActionType] = [.none, .none]
        var actionViews: [ActionViewName] = [.none,.none]
        
        if let isPrivate = set.isPrivate, isPrivate {
            txt.append("-You need to be invited to get in.")
            actions.append(.none)
            actionViews.append(.none)
        }
        
        let options = self.talkbox?.createUserOptions(opt1: "Back to map.", opt2: "Enter circle.", actionView: self)
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, action: actions, actionView: actionViews, options: options))
    }
    
    func explainerNameCircleBeforeSavingIt() {
        let txt = "Name the circle before saving it.-Tap above to do so."
        let actions: [KindActionType] = [.none,.none]
        let actionViews: [ActionViewName] = [.none,.none]
        let options = self.talkbox?.createUserOptions(opt1: "Cancel", opt2: "Save", actionView: self)
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, action: actions, actionView: actionViews, options: options))
        
    }
    
    func explainerGoToGameBoard() {
        //enter circle
        let actions: [KindActionType] = [KindActionType.deactivate,KindActionType.activate]
        let actionViews: [ActionViewName] = [ActionViewName.MapView, ActionViewName.GameBoard]
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineWithNoText(action: actions, actionView: actionViews, options: nil))
        
        //Happens behind the scenes.
        //Will delay 2 second to allow alpha into board, and then it will deselect the annotation and turn Map to normal state.
        delay(bySeconds: 2) {
            self.deactivate()
        }
    }
    
    func explainerCircleSavedSuccessfully() {
        let txt = "Done."
        let actions: [KindActionType] = [.none]
        let actionViews: [ActionViewName] = [.none]
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, action: actions, actionView: actionViews))
    }
}
