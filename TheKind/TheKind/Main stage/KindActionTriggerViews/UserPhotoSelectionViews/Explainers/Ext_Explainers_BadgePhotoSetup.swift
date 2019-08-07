//
//  Ext_Explainers_BadgePhotoSetup.swift
//  TheKind
//
//  Created by Tennyson Pinheiro on 7/31/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

//HERE
extension BadgePhotoSetupView {
    func takingSelfieExplainer() {
        let txt = "First, take a selife.-This will help when meeting other people.-Justtap the camera above."
        let actions: [KindActionTypeEnum] = [.none,.fadeInView, .none]
        let actionViews: [ViewForActionEnum] = [.none,.BadgePhotoSetupView, .none]
        let routine = self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, actions: actions, actionViews: actionViews, options: nil)
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkbox?.kindExplanationPublisher.onNext(rm)
        }
    }
    
    func badgePhotoConfirmation() {
        let txt = "-Cool!-I think it looks good too 🙂."
        let actions: [KindActionTypeEnum] = [.none,.activate]
        let actionViews: [ViewForActionEnum] = [.none, .DobOnboardingView]
        
        delay(bySeconds: 0.3, dispatchLevel: .main) {
            let routine = self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, actions: actions, actionViews: actionViews, options: nil)
            if let routine = routine {
                let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
                self.talkbox?.kindExplanationPublisher.onNext(rm)
            }
        }
    }
}
