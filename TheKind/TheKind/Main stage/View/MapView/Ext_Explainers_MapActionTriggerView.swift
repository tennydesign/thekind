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
    
    func mapExplainer() {
        let txt = "Tap a circle to enter it or tap & hold anywhere to create a circle.-People within 0.5 miles will be able join."
        let actions: [KindActionType] = [.none,.none]
        let actionViews: [ActionViewName] = [.none,.none]
        
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: nil))
    }
    
    
    func saveLoadingExplainer() {
        let txt = "Retrieved coordinates.-Saving circle configuration."
        let actions: [KindActionType] = [.none,.none]
        let actionViews: [ActionViewName] = [.none,.none]
        
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: nil))
    }
    
    func doneExplainer() {
        let txt = "Done."
        let actions: [KindActionType] = [.none]
        let actionViews: [ActionViewName] = [.none]
        
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: nil))
    }
    

    func cantFindLocationExplainer() {
        var txt = ""
        if let name = KindUserSettingsManager.sharedInstance.loggedUserName {
            txt = "Sorry \(name).-I could not fetch your location.-I need your location in order to open the map."
        } else {
            txt = "Sorry.-I could not fetch your location.-I need your location in order to open the map."
        }
        let actions: [KindActionType] = [.none,.none,.none]
        let actionViews: [ActionViewName] = [.none,.none,.none]
        
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: nil))
    }
    
    
    
    func explainerCircleCreation() {
        let txt = "You are creating a circle.-Click the locker to toggle between public and private.-If private only invited people can join.-Name the circle and hit save when you are done."
        
        let actions: [KindActionType] = [.none, .none,.none, .none]
        let actionViews: [ActionViewName] = [.none,.none,.none, .none]
        let options = self.talkbox?.createUserOptions(opt1: "Cancel", opt2: "Save", actionView: self)
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: options))
    }
    
    
    
    func explainerCircleEdit() {
        let txt = "You are editing a circle.-Click save whenever you are done."
        
        let actions: [KindActionType] = [.none, .none ]
        let actionViews: [ActionViewName] = [.none,.none]
        let options = self.talkbox?.createUserOptions(opt1: "Cancel", opt2: "Save", actionView: self)
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: options))
    }
    
    func explainerCircleGotDeleted() {
        let txt = "The circle you activated was deactivated."
        
        let actions: [KindActionType] = [.none ]
        let actionViews: [ActionViewName] = [.none]
      //  let options = self.talkbox?.createUserOptions(opt1: "Cancel", opt2: "Save", actionView: self)
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: nil))
    }
    
    func explainerCircleExploration() {
        let dominantKind = "founder"
        let chanceScore = "high"
        var txt = "This place is dominated by the \(dominantKind) kind.-You have \(chanceScore) chances of making friends here."
        var actions: [KindActionType] = [.none, .none]
        var actionViews: [ActionViewName] = [.none,.none]
        let options = self.talkbox?.createUserOptions(opt1: "Back to map.", opt2: "Enter circle.", actionView: self)

        if circleIsPrivate {
                txt.append("-You need to be invited to get in.")
                actions.append(.none)
                actionViews.append(.none)
        }
        
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: options))
    }
    
    func explainerSaveFailed() {
        let txt = "I could not save the circle.-Check the name and try again."
        let actions: [KindActionType] = [.none,.none]
        let actionViews: [ActionViewName] = [.none,.none]
        let options = self.talkbox?.createUserOptions(opt1: "Cancel", opt2: "Save", actionView: self)
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: options))
        
    }
    
    func explainerGoToGameBoard() {
        //enter circle
        let actions: [KindActionType] = [KindActionType.deactivate,KindActionType.activate]
        let actionViews: [ActionViewName] = [ActionViewName.MapView, ActionViewName.GameBoard]
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineWithNoText(actions: actions, actionViews: actionViews, options: nil))
        
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
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, actions: actions, actionViews: actionViews))
    }
}
