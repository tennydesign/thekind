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
        
        let explainer = JungChatExplainer(txt: txt, actions: nil, actionViews: nil, optButtonText: nil, optButtonViews: nil, optButtonActionType: nil)
        let routine = self.talkBox2?.routineGenerator(explainer: explainer, sender: .Jung)
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkBox2?.kindExplanationPublisher.onNext(rm)
        }
    }
    
    
    func saveLoadingExplainer() {
        let txt = "Retrieved coordinates.-Saving circle configuration."
        
        let explainer = JungChatExplainer(txt: txt, actions: nil, actionViews: nil, optButtonText: nil, optButtonViews: nil, optButtonActionType: nil)
        let routine = self.talkBox2?.routineGenerator(explainer: explainer, sender: .Jung)
        
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkBox2?.kindExplanationPublisher.onNext(rm)
        }
    }
    
    func cantFindLocationExplainer() {
        let txt = "Sorry \(KindUserSettingsManager.sharedInstance.loggedUserName ?? "").-I could not fetch your location.-I need your location in order to load the map."
        
        let explainer = JungChatExplainer(txt: txt, actions: nil, actionViews: nil, optButtonText: nil, optButtonViews: nil, optButtonActionType: nil)
        let routine = self.talkBox2?.routineGenerator(explainer: explainer, sender: .Jung)
        
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkBox2?.kindExplanationPublisher.onNext(rm)
        }
    }
    
    func explainerSaveFailed() {
        let txt = "I could not save the circle.-Check the name and try again."
        
        let explainer = JungChatExplainer(txt: txt, actions: nil, actionViews: nil, optButtonText: ("Cancel", "Save"), optButtonViews: (.mapView,.mapView), optButtonActionType: (.leftOptionClicked,.rightOptionClicked))
        
        let routine = self.talkBox2?.routineGenerator(explainer: explainer, sender: .Jung)
        
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkBox2?.kindExplanationPublisher.onNext(rm)
        }
        
    }
    
    
    func explainerCircleCreation() {
        let txt = "You are creating a circle.-Click the locker to toggle between public and private.-If private only invited people can join.-Name the circle and hit save when you are done."
        
        let explainer = JungChatExplainer(txt: txt, actions: nil, actionViews: nil, optButtonText: ("Cancel", "Save"), optButtonViews: (.mapView,.mapView), optButtonActionType: (.leftOptionClicked,.rightOptionClicked))
        
        let routine = self.talkBox2?.routineGenerator(explainer: explainer, sender: .Jung)
        
        
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkBox2?.kindExplanationPublisher.onNext(rm)
        }
    }
    
    func doneExplainer() {
        let txt = "Done."
         let explainer = JungChatExplainer(txt: txt, actions: nil, actionViews: nil, optButtonText: nil, optButtonViews: nil, optButtonActionType: nil)
        let routine = self.talkBox2?.routineGenerator(explainer: explainer, sender: .Jung)
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkBox2?.kindExplanationPublisher.onNext(rm)
        }
    }
    
    func explainerCircleExploration() {
        let dominantKind = "founder"
        let chanceScore = "high"
        var txt = "This place is dominated by the \(dominantKind) kind.-You have \(chanceScore) chances of making friends here."
        let optTxts = ("Back to map", "Enter circle")
        
        if circleIsPrivate {
            txt.append("-You need to be invited to get in.")
        }
        
        let explainer = JungChatExplainer(txt: txt, actions: nil, actionViews: nil, optButtonText: optTxts, optButtonViews: (.mapView,.mapView), optButtonActionType: (.leftOptionClicked,.rightOptionClicked))
        let routine = self.talkBox2?.routineGenerator(explainer: explainer, sender: .Jung)
        
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkBox2?.kindExplanationPublisher.onNext(rm)
        }
    }
    
    
    func explainerNavigator(destination: ViewForActionEnum) {
        //enter circle
        let actions: [KindActionTypeEnum] = [.deactivate,.activate]
        let actionViews: [ViewForActionEnum] = [.mapView, destination]
    
        let explainer = JungChatExplainer(txt: nil, actions: actions, actionViews: actionViews, optButtonText: nil, optButtonViews: nil, optButtonActionType: nil)
        let routine = self.talkBox2?.routineGenerator(explainer: explainer, sender: .Jung)
        
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


