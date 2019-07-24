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
    
    func manageKindFromKindDeckExplainer(kind: KindCard) {
        let txt = "The \(kind.kindName) \(kind.kindId.rawValue) kind says... [expainer for \(kind.kindName) goes here]"
        let actions: [KindActionType] = [.none]
        let actionViews: [ActionViewName] = [.none]
        
        var options:(Snippet,Snippet)?
        options = self.talkbox?.createUserOptions(opt1: "Tell me more.", opt2: "Release kind.", actionView: self)
        
        let routine = self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, actions: actions, actionViews: actionViews, options: options)
        
        //self.talkbox?.emmitSignalToClearUI()
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkbox?.kindExplanationPublisher.onNext(rm)
        }
    }

    
    func kindCardIntroExplainer() {
        
        guard let kind = cardOnTop else {return}
        let txt = "The \(kind.kindName) \(kind.kindId.rawValue) kind says... [expainer for \(kind.kindName) goes here]"
        let actions: [KindActionType] = [.none]
        let actionViews: [ActionViewName] = [.none]
        var options:(Snippet,Snippet)?
        
        if !deckIsFull {
            options = self.talkbox?.createUserOptions(opt1: "Don't keep it.", opt2: "Keep it.", actionView: self)
        } else {
            options = nil
        }
        
        let routine = self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, actions: actions, actionViews: actionViews, options: options)
        
        //self.talkbox?.emmitSignalToClearUI()
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
    
    func cleanBtnsExplainer() {
        guard let routine = self.talkbox?.jungClearButtonsRoutine else { return  }
        let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
        self.talkbox?.kindExplanationPublisher.onNext(rm)
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
    
    func deckIsFullExplainer(){
        let txt = "Your deck is maximized release a card to continue."
        let actions: [KindActionType] = [.none]
        let actionViews: [ActionViewName] = [.none]
        let routine = self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, actions: actions, actionViews: actionViews, options: nil)
        if let routine = routine {
            self.talkbox?.emmitSignalToClearUI()
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkbox?.kindExplanationPublisher.onNext(rm)
        }
    }
}
