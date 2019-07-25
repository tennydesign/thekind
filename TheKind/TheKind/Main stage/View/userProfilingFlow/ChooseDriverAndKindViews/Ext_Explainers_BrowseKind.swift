//
//  Ext_Explainers_BrowseKind.swift
//  TheKind
//
//  Created by Tennyson Pinheiro on 7/16/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension BrowseKindCardView {
    func chooseMainKindExplainer() {
        let txt = "Choose your kind. -Tap the icon to know more or go back to change your main driver."
        let actions: [KindActionType] = [.none, .none]
        let actionViews: [ActionViewName] = [.none,.none]
        var options: (Snippet,Snippet)?
        
        guard let kindName = kindsList.first?.kindName.rawValue else {return}

//        options = self.talkbox?.createUserOptions(opt1: "Back", opt2: "I'm like \(kindName)", actionView: self)
//
        options = self.talkbox?.createUserOptions(opt1: "Back", opt2: "I'm like the \(kindName)", actionViews: (.BrowseKindView,.BrowseKindView), actions: (.leftOptionClicked,.rightOptionClicked) , id: nil)
        
        let routine = self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: options)
        
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkbox?.kindExplanationPublisher.onNext(rm)
        }
    }
    
    func onboardingKindChosenExplainer(kindName: String) {
        //HERE HUDVIEW AS ACTIVATED
        let txt = "You chose\(kindName). -Now, let me show you the map.-Use it to find circles to join."
        let actions: [KindActionType] = [.none, .deactivate, .activate]
        let actionViews: [ActionViewName] = [.none,.BrowseKindView, .MapView]
        let routine = self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: nil)
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkbox?.kindExplanationPublisher.onNext(rm)
        }
    }
    
    func backToTheGameBoardExplainer() {
        let actions: [KindActionType] = [.talk]
        let actionViews: [ActionViewName] = [ActionViewName.GameBoardSceneControlView]
        let routine = self.talkbox?.routineWithNoText(snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: nil)
        
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkbox?.kindExplanationPublisher.onNext(rm)
        }
    }
    
    func onboardingBackToChooseDriverExplainer() {
        let actions: [KindActionType] = [.activate]
        let actionViews: [ActionViewName] = [.ChooseDriverView]

        let routine = self.talkbox?.routineWithNoText(snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: nil)
        
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkbox?.kindExplanationPublisher.onNext(rm)
        }
    }
    
    func userIsBrowsingAnotherUserKindsExplainer(kindName: String) {
        let txt = "\(kindName) says: You can transform any sitation into an ideal one.-They are all about the power to create things."
        let actions: [KindActionType] = [.none,.none]
        let actionViews: [ActionViewName] = [.none,.none]
        
        
        let options = self.talkbox?.createUserOptions(opt1: "Back to the board", opt2: "Introduce us.", actionViews: (ActionViewName.BrowseKindView,ActionViewName.KindMatchControlView))
        
        let routine = self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: options)
        
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkbox?.kindExplanationPublisher.onNext(rm)
        }
    }
    
    func userIsBrowsingToSelectOwnKindExplainer(kindName: String) {
        let txt = "\(kindName) says: You can transform anything...-and turn any ordinary situations into extraordinary ones."
        let actions: [KindActionType] = [.none,.none]
        let actionViews: [ActionViewName] = [.none,.none]
        
        
        let options = self.talkbox?.createUserOptions(opt1: "Back to main driver.", opt2: "I'm like \(kindName)", actionView: self)
        
        let routine = self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: options)
        
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkbox?.kindExplanationPublisher.onNext(rm)
        }
    }
    
    
    
}
