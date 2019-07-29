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
import RxCocoa
import RxSwift

extension MapActionTriggerView {
    
    func mapExplainer() {
        let txt = "Tap a circle to enter it or tap & hold anywhere to create a circle.-People within 0.5 miles will be able join."
        let actions: [KindActionTypeEnum] = [.none,.none]
        let actionViews: [ViewForActionEnum] = [.none,.none]
        
        let routine = self.talkBox2?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: nil)
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkBox2?.kindExplanationPublisher.onNext(rm)
        }
    }
    
    
    func saveLoadingExplainer() {
        let txt = "Retrieved coordinates.-Saving circle configuration."
        let actions: [KindActionTypeEnum] = [.none,.none]
        let actionViews: [ViewForActionEnum] = [.none,.none]
        
        let routine = self.talkBox2?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: nil)
        
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkBox2?.kindExplanationPublisher.onNext(rm)
        }
    }
    
    func doneExplainer() {
        let txt = "Done."
        let actions: [KindActionTypeEnum] = [.none]
        let actionViews: [ViewForActionEnum] = [.none]
        
        let routine = self.talkBox2?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: nil)
        
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkBox2?.kindExplanationPublisher.onNext(rm)
        }
    }
    

    func cantFindLocationExplainer() {
        var txt = ""
        if let name = KindUserSettingsManager.sharedInstance.loggedUserName {
            txt = "Sorry \(name).-I could not fetch your location.-I need your location in order to open the map."
        } else {
            txt = "Sorry.-I could not fetch your location.-I need your location in order to open the map."
        }
        let actions: [KindActionTypeEnum] = [.none,.none,.none]
        let actionViews: [ViewForActionEnum] = [.none,.none,.none]
        
        let routine = self.talkBox2?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: nil)
        
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkBox2?.kindExplanationPublisher.onNext(rm)
        }
    }
    
    
    
    func explainerCircleCreation() {
        let txt = "You are creating a circle.-Click the locker to toggle between public and private.-If private only invited people can join.-Name the circle and hit save when you are done."
        
        let actions: [KindActionTypeEnum] = [.none, .none,.none, .none]
        let actionViews: [ViewForActionEnum] = [.none,.none,.none, .none]
        let options = self.talkBox2?.createUserOptions(opt1: "Cancel", opt2: "Save", actionView: self)
        let routine = self.talkBox2?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: options)
        
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkBox2?.kindExplanationPublisher.onNext(rm)
        }
    }
    
    
    
    func explainerCircleEdit() {
        let txt = "You are editing a circle.-Click save whenever you are done."
        
        let actions: [KindActionTypeEnum] = [.none, .none ]
        let actionViews: [ViewForActionEnum] = [.none,.none]
        let options = self.talkBox2?.createUserOptions(opt1: "Cancel", opt2: "Save", actionView: self)
        let routine = self.talkBox2?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: options)
        
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkBox2?.kindExplanationPublisher.onNext(rm)
        }
    }
    
    func explainerCircleGotDeleted() {
        let txt = "The circle you activated was deactivated."
        
        let actions: [KindActionTypeEnum] = [.none ]
        let actionViews: [ViewForActionEnum] = [.none]
      //  let options = self.talkbox?.createUserOptions(opt1: "Cancel", opt2: "Save", actionView: self)
        let routine = self.talkBox2?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: nil)
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkBox2?.kindExplanationPublisher.onNext(rm)
        }
    }
    
    func explainerSaveFailed() {
        let txt = "I could not save the circle.-Check the name and try again."
        let actions: [KindActionTypeEnum] = [.none,.none]
        let actionViews: [ViewForActionEnum] = [.none,.none]
        let options = self.talkBox2?.createUserOptions(opt1: "Cancel", opt2: "Save", actionView: self)
        let routine = self.talkBox2?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: options)
        
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkBox2?.kindExplanationPublisher.onNext(rm)
        }
        
    }
    
    func explainerCircleSavedSuccessfully() {
        let txt = "Done."
        let actions: [KindActionTypeEnum] = [.none]
        let actionViews: [ViewForActionEnum] = [.none]
        let routine = self.talkBox2?.routineFromText(dialog: txt, actions: actions, actionViews: actionViews)
        
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkBox2?.kindExplanationPublisher.onNext(rm)
        }
    }
    
    //NEW EXPLAINERS
    func explainerCircleExploration() {
        let dominantKind = "founder"
        let chanceScore = "high"
        var txt = "This place is dominated by the \(dominantKind) kind.-You have \(chanceScore) chances of making friends here."
        var actions: [KindActionTypeEnum] = [.none, .none]
        var actionViews: [ViewForActionEnum] = [.none, .none]
        //let options = self.talkBox2?.createUserOptions(opt1: "Back to Map", opt2: "Enter Circle", actionViews: (ViewForActionEnum.mapView, ViewForActionEnum.GameBoard))
        let optTxts = ("Back to map", "Enter circle")
        
        if circleIsPrivate {
            txt.append("-You need to be invited to get in.")
            actions.append(.none)
            actionViews.append(.none)
        }
        
        let explainer = JungChatExplainer(txt: txt, actions: actions, actionViews: actionViews, optButtonText: optTxts, optButtonViews: (.mapView,.GameBoard), optActions: (.deactivate,.activate))
        let routine = self.talkBox2?.routineGenerator(explainer: explainer)
        
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkBox2?.kindExplanationPublisher.onNext(rm)
        }
    }
    
    
    func explainerNavigator(destination: ViewForActionEnum) {
        //enter circle
        let actions: [KindActionTypeEnum] = [.deactivate,.activate]
        let actionViews: [ViewForActionEnum] = [.mapView, destination]
    
        let explainer = JungChatExplainer(txt: nil, actions: actions, actionViews: actionViews, optButtonText: nil, optButtonViews: nil, optActions: nil)
        let routine = self.talkBox2?.routineGenerator(explainer: explainer)
        
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkBox2?.kindExplanationPublisher.onNext(rm)
        }
        
        //Happens behind the scenes.
        //Will delay 2 second to allow alpha into board, and then it will deselect the annotation and turn Map to normal state.
        delay(bySeconds: 2) {
            self.deactivate()
        }
    }

}

struct JungChatExplainer {
    var txt: String?
    var actions: [KindActionTypeEnum]?
    var actionViews: [ViewForActionEnum]?
    var optButtonText: (String,String)?
    var optButtonViews: (ViewForActionEnum,ViewForActionEnum)?
    var optActions: (KindActionTypeEnum, KindActionTypeEnum)?

}
