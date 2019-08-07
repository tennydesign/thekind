//
//  xt_Explainer_UserNameView.swift
//  TheKind
//
//  Created by Tennyson Pinheiro on 7/31/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension UserNameView {
    func nameTryOutExplainer(txt: String) {
        //        let actions: [KindActionType] = [.none,.none]
        //        let actionViews: [ActionViewName] = [.none,.none]
        let options = self.talkbox?.createUserOptions(opt1: "", opt2: "I'm good with that.", actionView: self)
        let routine = self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, actions: nil, actionViews: nil, options: options)
        
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkbox?.kindExplanationPublisher.onNext(rm)
        }
    }
    
    func setupPaceExplainer(_ txt: String) {
        //Move forward
        let actions: [KindActionTypeEnum] = [.none,.activate]
        let actionViews: [ViewForActionEnum] = [.none,.BadgePhotoSetupView]
        
        
        let routine = self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, actions: actions, actionViews: actionViews, options: nil)
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkbox?.kindExplanationPublisher.onNext(rm)
        }
    }
}
