//
//  DobViewExplainer.swift
//  TheKind
//
//  Created by Tennyson Pinheiro on 7/31/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift


extension DobOnboardingView {
    func fetchAgeExplainer() {
        let txt = "Sorry,not trying to be indiscrete.-But...what is your year of birth?-Choose from the options above."
        let actions: [KindActionTypeEnum] = [.none, .none,.fadeInView]
        let actionViews: [ViewForActionEnum] = [.none,.none, .DobOnboardingView]
        
        let options = self.talkbox?.createUserOptions(opt1: "", opt2: "Confirm year.", actionView: self)
        
        delay(bySeconds: 0.3, dispatchLevel: .main) {
            let routine = self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, actions: actions, actionViews: actionViews, options: options)
            if let routine = routine {
                let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
                self.talkbox?.kindExplanationPublisher.onNext(rm)
            }
        }
    }
    
    func NavigateAwayExplainer(_ age: Int) {
        let txt = "I understand you are about \(age) years old.-We are almost finished with the setup."
        let actions: [KindActionTypeEnum] = [.none,.activate]
        let actionViews: [ViewForActionEnum] = [.none,.ChooseDriverView]
        let routine = self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, actions: actions, actionViews: actionViews, options: nil)
        if let routine = routine {
            let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
            self.talkbox?.kindExplanationPublisher.onNext(rm)
        }
    }
}
