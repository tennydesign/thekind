//
//  Ext_Explainers_CardSwipeView.swift
//  TheKind
//
//  Created by Tennyson Pinheiro on 7/16/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension CardSwipeView {
    
    func manageKindFromKindDeckExplainer() {
        let txt = "The Poet kind says: There should be no filter between reality and emotions."
        let actions: [KindActionType] = [.none]
        let actionViews: [ActionViewName] = [.none]
        let options = self.talkbox?.createUserOptions(opt1: "Tell me more.", opt2: "Release kind.", actionView: self)
        
        let routine = self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, actions: actions, actionViews: actionViews, options: options)
        
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkbox?.kindExplanationPublisher.onNext(rm)
        }
        
    }

    
    func kindCardIntroExplainer() {
        guard let currentlyShowingKindCard = currentlyShowingKindCard else {return}
        let txt = "The \(currentlyShowingKindCard.kindName.rawValue) says: There should be no filter between reality and emotions."
        let actions: [KindActionType] = [.none]
        let actionViews: [ActionViewName] = [.none]
        let options = self.talkbox?.createUserOptions(opt1: "Keep it.", opt2: "Don't keep it.", actionView: self)
        
        let routine = self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, actions: actions, actionViews: actionViews, options: options)
        
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkbox?.kindExplanationPublisher.onNext(rm)
        }
        
    }
    
    func moreInfoOnKindExplainer() {
        let txt = "Life is like a rollercoaster.-The ups are high and the downs are low.-The rollercoaster of life is what makes it genuine, sensible, intense and worth living."
        let actions: [KindActionType] = [.none,.none,.none]
        let actionViews: [ActionViewName] = [.none,.none,.none]
        let options = self.talkbox?.createUserOptions(opt1: "", opt2: "Release kind.", actionView: self)

        let routine = self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, actions: actions, actionViews: actionViews, options: options)
        
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkbox?.kindExplanationPublisher.onNext(rm)
        }
    }
    
    func removedKindFromDeckExplainer() {
        let txt = "Done."
        let actions: [KindActionType] = [.none]
        let actionViews: [ActionViewName] = [.none]
        let routine = self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, actions: actions, actionViews: actionViews, options: nil)
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkbox?.kindExplanationPublisher.onNext(rm)
        }
    }
    
    func failedToRemoveKindFromDeckExplainer(){
        print("YOU CANT REMOVE THE MAIN KIND FROM HERE!!!!!!!!!!!")
        let txt = "You can only remove the main kind from the settings menu."
        let actions: [KindActionType] = [.none]
        let actionViews: [ActionViewName] = [.none]
        let routine = self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, actions: actions, actionViews: actionViews, options: nil)
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkbox?.kindExplanationPublisher.onNext(rm)
        }
    }
}
